import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/prayer_service.dart';

class PrayerNotificationSettingsSheet extends StatefulWidget {
  final PrayerSchedule schedule;

  const PrayerNotificationSettingsSheet({super.key, required this.schedule});

  static void show(BuildContext context, PrayerSchedule schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PrayerNotificationSettingsSheet(schedule: schedule),
    );
  }

  @override
  State<PrayerNotificationSettingsSheet> createState() =>
      _PrayerNotificationSettingsSheetState();
}

class _PrayerNotificationSettingsSheetState
    extends State<PrayerNotificationSettingsSheet> {
  late PrayerAlarmConfig _config;

  @override
  void initState() {
    super.initState();
    _config = NotificationService.configNotifier.value;
  }

  Future<void> _saveAndApply(PrayerAlarmConfig newConfig) async {
    setState(() => _config = newConfig);
    await NotificationService.saveConfig(newConfig, widget.schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.sageBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adhan & Prayer Alarms',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'اذان، نماز اور پیشگی یاد دہانی کے الرٹس',
                          style: GoogleFonts.notoNastaliqUrdu(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.sageBorder),

          // Scrollable Settings Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert Sound Mode Selection
                  Text(
                    'Alert Sound & Style (آواز کا انداز)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _buildAlertModeChip(
                        'Adhan Voice',
                        'مکمل اذان',
                        Icons.volume_up_rounded,
                        PrayerAlertType.adhan,
                      ),
                      const SizedBox(width: 8),
                      _buildAlertModeChip(
                        'Soft Chime',
                        'بیپ / ٹون',
                        Icons.notifications_rounded,
                        PrayerAlertType.beep,
                      ),
                      const SizedBox(width: 8),
                      _buildAlertModeChip(
                        'Silent',
                        'خاموش',
                        Icons.volume_off_rounded,
                        PrayerAlertType.silent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 5 Daily Prayers Switches
                  Text(
                    'Daily Prayers Selection (نمازوں کا انتخاب)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.sageBorder),
                    ),
                    child: Column(
                      children: [
                        _buildPrayerSwitch(
                          'Fajr',
                          'فجر',
                          widget.schedule.prayers[0].formattedStartTime,
                          _config.fajrEnabled,
                          (val) => _saveAndApply(_config.copyWith(fajrEnabled: val)),
                        ),
                        const Divider(height: 1, color: AppColors.sageBorder),
                        _buildPrayerSwitch(
                          'Dhuhr',
                          'ظہر',
                          widget.schedule.prayers[1].formattedStartTime,
                          _config.dhuhrEnabled,
                          (val) => _saveAndApply(_config.copyWith(dhuhrEnabled: val)),
                        ),
                        const Divider(height: 1, color: AppColors.sageBorder),
                        _buildPrayerSwitch(
                          'Asr',
                          'عصر',
                          widget.schedule.prayers[2].formattedStartTime,
                          _config.asrEnabled,
                          (val) => _saveAndApply(_config.copyWith(asrEnabled: val)),
                        ),
                        const Divider(height: 1, color: AppColors.sageBorder),
                        _buildPrayerSwitch(
                          'Maghrib',
                          'مغرب',
                          widget.schedule.prayers[3].formattedStartTime,
                          _config.maghribEnabled,
                          (val) => _saveAndApply(_config.copyWith(maghribEnabled: val)),
                        ),
                        const Divider(height: 1, color: AppColors.sageBorder),
                        _buildPrayerSwitch(
                          'Isha',
                          'عشاء',
                          widget.schedule.prayers[4].formattedStartTime,
                          _config.ishaEnabled,
                          (val) => _saveAndApply(_config.copyWith(ishaEnabled: val)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Pre-Prayer Reminder (10 mins before)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sageBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_alarm_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pre-Prayer Reminder (10 min before)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'وضو اور نماز کی تیاری کے لیے 10 منٹ قبل یاد دہانی',
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
                          onChanged: (val) => _saveAndApply(
                            _config.copyWith(prePrayerReminder: val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Test Notification Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await NotificationService.showTestNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Test notification sent! Check your notification tray.',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        'Send Test Notification (نوٹیفکیشن چیک کریں)',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertModeChip(
    String title,
    String urdu,
    IconData icon,
    PrayerAlertType type,
  ) {
    final isSelected = _config.alertType == type;

    return Expanded(
      child: InkWell(
        onTap: () => _saveAndApply(_config.copyWith(alertType: type)),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.sageBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFFFFD54F) : AppColors.primary,
              ),
              const SizedBox(height: 4),
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
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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

  Widget _buildPrayerSwitch(
    String name,
    String urdu,
    String time,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
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
            child: Row(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  urdu,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
