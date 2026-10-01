import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/prayer_service.dart';

class PrayerScheduleSheet extends StatelessWidget {
  final PrayerSchedule schedule;

  const PrayerScheduleSheet({super.key, required this.schedule});

  static void show(BuildContext context, PrayerSchedule schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PrayerScheduleSheet(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                      child: const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Prayer Timings',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'مکمل اوقاتِ نماز، زوال و مکروہ اوقات',
                          style: GoogleFonts.notoNastaliqUrdu(
                            fontSize: 11,
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

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: 5 Daily Prayers
                  _buildSectionHeader('5 Daily Prayers', 'پانچ وقت کی فرض نمازیں', Icons.mosque_rounded),
                  const SizedBox(height: 8),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Prayer (نماز)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Start (شروع)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'End (ختم)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Prayer Rows
                  ...schedule.prayers.map((prayer) => _buildPrayerRow(prayer)),

                  const SizedBox(height: 18),

                  // Section 2: Prohibited / Makrooh Times (ممنوعہ و مکروہ اوقات)
                  _buildSectionHeader('Prohibited / Makrooh Times', 'ممنوعہ و مکروہ اوقات (نماز پڑھنا منع ہے)', Icons.block_rounded, isWarning: true),
                  const SizedBox(height: 8),

                  // Prohibited Times Cards
                  _buildSpecialCard(
                    title: 'زوالِ آفتاب / نصف النہار (Zawal Time)',
                    subtitle: 'ظہر سے قبل سورج کا عین سر پر ہونا (نماز ممنوع ہے)',
                    timeRange: schedule.formattedZawalRange,
                    icon: Icons.wb_sunny_rounded,
                    isWarning: true,
                  ),
                  const SizedBox(height: 8),

                  _buildSpecialCard(
                    title: 'غروبِ آفتاب / مکروہ وقت (Sunset Makrooh)',
                    subtitle: 'عصر اور مغرب کے درمیان، زردیِ آفتاب سے مغرب تک',
                    timeRange: schedule.formattedMakroohAsrRange,
                    icon: Icons.wb_twilight_rounded,
                    isWarning: true,
                  ),
                  const SizedBox(height: 8),

                  _buildSpecialCard(
                    title: 'طلوعِ آفتاب کا مکروہ وقت (Sunrise Makrooh)',
                    subtitle: 'سورج نکلنے سے لے کر بلندی (اشراق) تک',
                    timeRange: '${schedule.formattedSunrise} - ${schedule.formattedIshraq}',
                    icon: Icons.wb_sunny_outlined,
                    isWarning: true,
                  ),

                  const SizedBox(height: 18),

                  // Section 3: Sunnah & Extra Times
                  _buildSectionHeader('Sunnah & Nafl Times', 'مسنون و مستحب اوقات', Icons.auto_awesome),
                  const SizedBox(height: 8),

                  _buildSpecialCard(
                    title: 'سحری و تہجد اختتام (Sehri / Tahajjud End)',
                    subtitle: 'صبح صادق (فجر شروع) پر سحری اور تہجد ختم ہو جاتی ہے',
                    timeRange: schedule.formattedSehriEnd,
                    icon: Icons.nightlight_round,
                  ),
                  const SizedBox(height: 8),

                  _buildSpecialCard(
                    title: 'نمازِ اشراق و چاشت (Ishraq & Chasht)',
                    subtitle: 'سورج کے بلندی پر آنے کے بعد شروع ہوتا ہے',
                    timeRange: '${schedule.formattedIshraq} onwards',
                    icon: Icons.light_mode_rounded,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String urdu, IconData icon, {bool isWarning = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isWarning ? const Color(0xFFD32F2F) : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isWarning ? const Color(0xFFD32F2F) : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($urdu)',
          style: GoogleFonts.scheherazadeNew(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isWarning ? const Color(0xFFD32F2F) : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerRow(PrayerInfo prayer) {
    final isCurrent = prayer.isCurrent;
    final isNext = prayer.isNext;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary
            : (isNext ? AppColors.sageLight : AppColors.background),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary
              : (isNext ? AppColors.primary : AppColors.sageBorder),
          width: isCurrent || isNext ? 1.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Prayer Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isCurrent ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  prayer.urduName,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCurrent
                        ? const Color(0xFFFFD54F)
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Start Time
          Expanded(
            flex: 3,
            child: Text(
              prayer.formattedStartTime,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isCurrent ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),

          // End Time
          Expanded(
            flex: 3,
            child: Text(
              prayer.formattedEndTime,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isCurrent
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.textSecondary,
              ),
            ),
          ),

          // Status Badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFFFFD54F)
                      : (isNext
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCurrent
                      ? 'Active'
                      : (isNext ? 'Next' : (prayer.isPassed ? 'Done' : 'Later')),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCurrent
                        ? const Color(0xFF14473B)
                        : (isNext ? AppColors.primary : AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialCard({
    required String title,
    required String subtitle,
    required String timeRange,
    required IconData icon,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFFFEBEE)
            : AppColors.sageLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFFFCDD2)
              : AppColors.sageBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isWarning
                  ? const Color(0xFFEF5350).withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isWarning ? const Color(0xFFD32F2F) : AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isWarning ? const Color(0xFFC62828) : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.notoNastaliqUrdu(
                    fontSize: 9.5,
                    color: isWarning ? const Color(0xFFD32F2F) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isWarning ? const Color(0xFFD32F2F) : AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              timeRange,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
