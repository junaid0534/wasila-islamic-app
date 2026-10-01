import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'prayer_service.dart';

enum PrayerAlertType {
  adhan,
  beep,
  silent,
  off,
}

class PrayerAlarmConfig {
  final bool fajrEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;
  final PrayerAlertType alertType;
  final bool prePrayerReminder; // 10 mins before
  final int preReminderMinutes;

  const PrayerAlarmConfig({
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
    this.alertType = PrayerAlertType.adhan,
    this.prePrayerReminder = true,
    this.preReminderMinutes = 10,
  });

  PrayerAlarmConfig copyWith({
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
    PrayerAlertType? alertType,
    bool? prePrayerReminder,
    int? preReminderMinutes,
  }) {
    return PrayerAlarmConfig(
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
      alertType: alertType ?? this.alertType,
      prePrayerReminder: prePrayerReminder ?? this.prePrayerReminder,
      preReminderMinutes: preReminderMinutes ?? this.preReminderMinutes,
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefFajr = 'alarm_fajr';
  static const String _prefDhuhr = 'alarm_dhuhr';
  static const String _prefAsr = 'alarm_asr';
  static const String _prefMaghrib = 'alarm_maghrib';
  static const String _prefIsha = 'alarm_isha';
  static const String _prefAlertType = 'alarm_alert_type';
  static const String _prefPreReminder = 'alarm_pre_reminder';

  static final ValueNotifier<PrayerAlarmConfig> configNotifier =
      ValueNotifier<PrayerAlarmConfig>(const PrayerAlarmConfig());

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    await _createNotificationChannels();
    await _loadSavedConfig();
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      'wasila_adhan_channel',
      'Wasila Adhan Alarms (اذان و نماز)',
      description: 'Prayer time and Adhan alarms for daily prayers',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      'wasila_reminder_channel',
      'Wasila Pre-Prayer Reminders (یاد دہانی)',
      description: 'Pre-prayer preparation reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(adhanChannel);
      await androidPlugin.createNotificationChannel(reminderChannel);
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  static Future<void> _loadSavedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fajr = prefs.getBool(_prefFajr) ?? true;
      final dhuhr = prefs.getBool(_prefDhuhr) ?? true;
      final asr = prefs.getBool(_prefAsr) ?? true;
      final maghrib = prefs.getBool(_prefMaghrib) ?? true;
      final isha = prefs.getBool(_prefIsha) ?? true;
      final preRem = prefs.getBool(_prefPreReminder) ?? true;
      final alertIdx = prefs.getInt(_prefAlertType) ?? 0;

      final type = alertIdx >= 0 && alertIdx < PrayerAlertType.values.length
          ? PrayerAlertType.values[alertIdx]
          : PrayerAlertType.adhan;

      configNotifier.value = PrayerAlarmConfig(
        fajrEnabled: fajr,
        dhuhrEnabled: dhuhr,
        asrEnabled: asr,
        maghribEnabled: maghrib,
        ishaEnabled: isha,
        alertType: type,
        prePrayerReminder: preRem,
      );
    } catch (_) {}
  }

  static Future<void> saveConfig(PrayerAlarmConfig config, PrayerSchedule? currentSchedule) async {
    configNotifier.value = config;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefFajr, config.fajrEnabled);
      await prefs.setBool(_prefDhuhr, config.dhuhrEnabled);
      await prefs.setBool(_prefAsr, config.asrEnabled);
      await prefs.setBool(_prefMaghrib, config.maghribEnabled);
      await prefs.setBool(_prefIsha, config.ishaEnabled);
      await prefs.setBool(_prefPreReminder, config.prePrayerReminder);
      await prefs.setInt(_prefAlertType, config.alertType.index);

      if (currentSchedule != null) {
        await scheduleAllPrayers(currentSchedule);
      }
    } catch (_) {}
  }

  static Future<void> scheduleAllPrayers(PrayerSchedule schedule) async {
    await _notificationsPlugin.cancelAll();

    final config = configNotifier.value;
    if (config.alertType == PrayerAlertType.off) return;

    final now = DateTime.now();

    for (int i = 0; i < schedule.prayers.length; i++) {
      final prayer = schedule.prayers[i];
      bool isEnabled = false;

      switch (prayer.name.toLowerCase()) {
        case 'fajr':
          isEnabled = config.fajrEnabled;
          break;
        case 'dhuhr':
          isEnabled = config.dhuhrEnabled;
          break;
        case 'asr':
          isEnabled = config.asrEnabled;
          break;
        case 'maghrib':
          isEnabled = config.maghribEnabled;
          break;
        case 'isha':
          isEnabled = config.ishaEnabled;
          break;
      }

      if (!isEnabled) continue;

      // 1. Exact Prayer Time Notification
      if (prayer.startTime.isAfter(now)) {
        await _scheduleSingleNotification(
          id: 100 + i,
          title: 'حی علی الصلاۃ • وقتِ ${prayer.urduName}',
          body: '${prayer.name} Prayer time has started (${prayer.formattedStartTime}). الصلاة خير من النوم',
          scheduledTime: prayer.startTime,
          isAdhan: config.alertType == PrayerAlertType.adhan,
          isSilent: config.alertType == PrayerAlertType.silent,
        );
      }

      // 2. Pre-Prayer Reminder (10 mins before)
      if (config.prePrayerReminder) {
        final preTime = prayer.startTime.subtract(
          Duration(minutes: config.preReminderMinutes),
        );
        if (preTime.isAfter(now)) {
          await _scheduleSingleNotification(
            id: 200 + i,
            title: 'یاد دہانی • ${prayer.urduName} کا وقت قریب ہے',
            body: '${prayer.name} starts in ${config.preReminderMinutes} minutes (${prayer.formattedStartTime}). Prepare for Wudu.',
            scheduledTime: preTime,
            isAdhan: false,
            isSilent: false,
          );
        }
      }
    }
  }

  static Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool isAdhan = false,
    bool isSilent = false,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        isAdhan ? 'wasila_adhan_channel' : 'wasila_reminder_channel',
        isAdhan ? 'Wasila Adhan Alarms' : 'Wasila Reminders',
        channelDescription: 'Prayer notifications',
        importance: isSilent ? Importance.low : (isAdhan ? Importance.max : Importance.high),
        priority: isSilent ? Priority.low : (isAdhan ? Priority.max : Priority.high),
        playSound: !isSilent,
        enableVibration: !isSilent,
        fullScreenIntent: isAdhan,
        category: AndroidNotificationCategory.alarm,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'wasila_adhan_channel',
      'Wasila Adhan Alarms',
      channelDescription: 'Prayer notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      999,
      'حي علی الصلاۃ • Wasila Adhan Alert',
      'This is a test notification for prayer times. وقتِ اذان و نماز',
      platformDetails,
    );
  }
}
