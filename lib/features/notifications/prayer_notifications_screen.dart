import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/prayer_service.dart';

class PrayerNotificationsScreen extends StatefulWidget {
  const PrayerNotificationsScreen({super.key});

  @override
  State<PrayerNotificationsScreen> createState() =>
      _PrayerNotificationsScreenState();
}

class _PrayerNotificationsScreenState extends State<PrayerNotificationsScreen> {
  late PrayerAlarmConfig _config;
  late PrayerSchedule _schedule;

  @override
  void initState() {
    super.initState();
    _config = NotificationService.configNotifier.value;
    final loc = LocationService.activeLocation.value;
    _schedule = PrayerService.calculatePrayerTimes(
      lat: loc.latitude,
      lng: loc.longitude,
      cityName: loc.displayName,
      method: loc.method,
    );
  }

  Future<void> _updateConfig(PrayerAlarmConfig newConfig) async {
    setState(() => _config = newConfig);
    await NotificationService.saveConfig(newConfig, _schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Clean Top Bar: Just "Prayer Alarms"
            _buildTopBar(),

            // 2. Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Sync Status Pill
                    _buildLocationPill(),
                    const SizedBox(height: 14),

                    // Sound Alert Mode Selector (Compact)
                    _buildSoundModeSection(),
                    const SizedBox(height: 18),

                    // 5 Daily Prayers Alarm List
                    _buildSectionTitle(
                      'Daily Prayer Alarms',
                      'پانچ وقت کی نمازیں',
                      Icons.mosque_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildPrayerAlarmsList(),
                    const SizedBox(height: 18),

                    // Pre-Prayer Reminder Card
                    _buildSectionTitle(
                      'Pre-Prayer Reminder',
                      'پیشگی یاد دہانی',
                      Icons.access_alarm_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildPreReminderCard(),
                    const SizedBox(height: 18),

                    // Special Islamic Reminders
                    _buildSectionTitle(
                      'Islamic Reminders',
                      'مسنون اعمال',
                      Icons.auto_awesome,
                    ),
                    const SizedBox(height: 8),
                    _buildSpecialRemindersCard(),
                    const SizedBox(height: 18),

                    // Test Notification Button
                    _buildTestButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.sageBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.sageLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sageBorder),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Prayer Alarms',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.sageLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 12,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Location: ${_schedule.locationName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            'Auto Synced',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Alert Style',
          'آواز کا انداز',
          Icons.volume_up_rounded,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCompactModeCard(
              'Adhan',
              'اذان',
              Icons.volume_up_rounded,
              PrayerAlertType.adhan,
            ),
            const SizedBox(width: 8),
            _buildCompactModeCard(
              'Chime',
              'بیپ',
              Icons.notifications_rounded,
              PrayerAlertType.beep,
            ),
            const SizedBox(width: 8),
            _buildCompactModeCard(
              'Silent',
              'خاموش',
              Icons.volume_off_rounded,
              PrayerAlertType.silent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactModeCard(
    String title,
    String urdu,
    IconData icon,
    PrayerAlertType type,
  ) {
    final isSelected = _config.alertType == type;

    return Expanded(
      child: InkWell(
        onTap: () => _updateConfig(_config.copyWith(alertType: type)),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.sageBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected ? const Color(0xFFFFD54F) : AppColors.primary,
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                urdu,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 9.5,
                  color: isSelected
                      ? const Color(0xFFFFD54F)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerAlarmsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sageBorder),
      ),
      child: Column(
        children: [
          _buildPrayerRow(
            'Fajr',
            'فجر',
            _schedule.prayers[0].formattedStartTime,
            _config.fajrEnabled,
            (val) => _updateConfig(_config.copyWith(fajrEnabled: val)),
          ),
          const Divider(height: 1, color: AppColors.sageBorder),
          _buildPrayerRow(
            'Dhuhr',
            'ظہر',
            _schedule.prayers[1].formattedStartTime,
            _config.dhuhrEnabled,
            (val) => _updateConfig(_config.copyWith(dhuhrEnabled: val)),
          ),
          const Divider(height: 1, color: AppColors.sageBorder),
          _buildPrayerRow(
            'Asr',
            'عصر',
            _schedule.prayers[2].formattedStartTime,
            _config.asrEnabled,
            (val) => _updateConfig(_config.copyWith(asrEnabled: val)),
          ),
          const Divider(height: 1, color: AppColors.sageBorder),
          _buildPrayerRow(
            'Maghrib',
            'مغرب',
            _schedule.prayers[3].formattedStartTime,
            _config.maghribEnabled,
            (val) => _updateConfig(_config.copyWith(maghribEnabled: val)),
          ),
          const Divider(height: 1, color: AppColors.sageBorder),
          _buildPrayerRow(
            'Isha',
            'عشاء',
            _schedule.prayers[4].formattedStartTime,
            _config.ishaEnabled,
            (val) => _updateConfig(_config.copyWith(ishaEnabled: val)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(
    String name,
    String urdu,
    String time,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              size: 16,
              color: isEnabled ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      urdu,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 10.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPreReminderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sageBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert ${_config.preReminderMinutes} min before',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'وضو اور نماز کی تیاری کے لیے',
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _config.prePrayerReminder,
                activeTrackColor: AppColors.primary,
                onChanged: (val) => _updateConfig(
                  _config.copyWith(prePrayerReminder: val),
                ),
              ),
            ],
          ),
          if (_config.prePrayerReminder) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.sageBorder),
            const SizedBox(height: 10),
            Row(
              children: [5, 10, 15, 20].map((mins) {
                final isSelected = _config.preReminderMinutes == mins;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => _updateConfig(
                        _config.copyWith(preReminderMinutes: mins),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.sageLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.sageBorder,
                          ),
                        ),
                        child: Text(
                          '$mins m',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialRemindersCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sageBorder),
      ),
      child: Column(
        children: [
          _buildSpecialRow(
            'Surah Al-Mulk Reminder',
            'رات کو سونے سے قبل تلاوت',
            Icons.menu_book_rounded,
            true,
          ),
          const Divider(height: 14, color: AppColors.sageBorder),
          _buildSpecialRow(
            'Friday Surah Al-Kahf',
            'جمعۃ المبارک کے دن تلاوت',
            Icons.calendar_today_rounded,
            true,
          ),
          const Divider(height: 14, color: AppColors.sageBorder),
          _buildSpecialRow(
            'Tahajjud & Sehri Reminder',
            'رات کے آخری پہر بیداری',
            Icons.nightlight_round,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRow(
    String title,
    String subtitle,
    IconData icon,
    bool isDefaultOn,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 9.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: isDefaultOn,
          activeTrackColor: AppColors.primary,
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await NotificationService.showTestNotification();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Test notification sent! Check your tray.',
                        style: GoogleFonts.poppins(fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        icon: const Icon(Icons.notifications_active_rounded, size: 16),
        label: Text(
          'Send Test Notification (ابھی الرٹ چیک کریں)',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String urdu, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '($urdu)',
          style: GoogleFonts.notoNastaliqUrdu(
            fontSize: 9.5,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
