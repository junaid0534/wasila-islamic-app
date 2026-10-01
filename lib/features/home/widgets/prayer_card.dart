import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/prayer_service.dart';
import 'prayer_schedule_sheet.dart';

class PrayerCard extends StatelessWidget {
  final PrayerSchedule schedule;
  final VoidCallback? onTap;

  const PrayerCard({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activePrayer = schedule.currentPrayer ?? schedule.nextPrayer;
    final bool isCurrentActive = schedule.currentPrayer != null;

    return GestureDetector(
      onTap: onTap ?? () => PrayerScheduleSheet.show(context, schedule),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E6050), // Forest Pine Green
              Color(0xFF14473B), // Deep Forest Pine
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Makrooh / Prohibited Warning Banner (if currently in Makrooh time)
            if (schedule.isCurrentlyMakroohTime && schedule.makroohWarningText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                color: const Color(0xFFD32F2F),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.makroohWarningText!,
                        style: GoogleFonts.notoNastaliqUrdu(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 2. Main Section: Active Prayer Name, Time Range, Countdown & Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row 1: Prayer Name & Range Pill
                  Row(
                    children: [
                      // Prayer Name & Icon
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isCurrentActive
                                      ? Icons.mosque_rounded
                                      : Icons.hourglass_top_rounded,
                                  color: const Color(0xFFFFD54F),
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          activePrayer?.name ?? 'Prayer',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        activePrayer?.arabicName ?? '',
                                        style: GoogleFonts.scheherazadeNew(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFFFD54F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    isCurrentActive
                                        ? 'Active Time'
                                        : 'Upcoming Prayer',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Start - End Time Range Pill (Compact & Overlap-Proof)
                      if (activePrayer != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${activePrayer.formattedStartTime} - ${activePrayer.formattedEndTime}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFFD54F),
                                ),
                              ),
                              Text(
                                'Start - End',
                                style: GoogleFonts.poppins(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Status & Countdown Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          schedule.statusUrduSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoNastaliqUrdu(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          schedule.statusCountdownText,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF14473B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar for Active Prayer Window
                  if (isCurrentActive && activePrayer != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: activePrayer.progressPercentage,
                        minHeight: 4.5,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 3. Bottom Section: 5 Prayers + Zawal & Sunrise Strip
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.black.withValues(alpha: 0.15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Fajr
                    _buildPrayerChip(schedule.prayers[0]),

                    // Sunrise Chip (طلوع)
                    _buildSpecialChip(
                      title: 'Sunrise',
                      urdu: 'طلوعِ آفتاب',
                      time: schedule.formattedSunrise,
                      isSpecial: true,
                    ),

                    // Zawal Chip (زوال - قبل ظہر)
                    _buildSpecialChip(
                      title: 'Zawal',
                      urdu: 'زوالِ آفتاب',
                      time: schedule.formattedZawalRange,
                      isWarning: true,
                    ),

                    // Dhuhr
                    _buildPrayerChip(schedule.prayers[1]),

                    // Asr
                    _buildPrayerChip(schedule.prayers[2]),

                    // Makrooh Asr / Ghurub Chip (غروب - قبل مغرب)
                    _buildSpecialChip(
                      title: 'Ghurub',
                      urdu: 'مکروہ وقت',
                      time: schedule.formattedMakroohAsrRange,
                      isWarning: true,
                    ),

                    // Maghrib
                    _buildPrayerChip(schedule.prayers[3]),

                    // Isha
                    _buildPrayerChip(schedule.prayers[4]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerChip(PrayerInfo prayer) {
    final isCurrent = prayer.isCurrent;
    final isNext = prayer.isNext;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.white
            : (isNext
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFFFFD54F)
              : (isNext
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.15)),
          width: isCurrent ? 1.8 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                prayer.name,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent ? AppColors.primaryDark : Colors.white,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            prayer.formattedStartTime,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isCurrent ? AppColors.primary : const Color(0xFFFFD54F),
            ),
          ),
          Text(
            'تا ${prayer.formattedEndTime}',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isCurrent
                  ? AppColors.textMuted
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialChip({
    required String title,
    required String urdu,
    required String time,
    bool isWarning = false,
    bool isSpecial = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFD32F2F).withValues(alpha: 0.25)
            : const Color(0xFFF57F17).withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFEF5350).withValues(alpha: 0.5)
              : const Color(0xFFFFD54F).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isWarning ? Icons.do_not_disturb_on_rounded : Icons.wb_sunny_rounded,
                size: 11,
                color: isWarning ? const Color(0xFFFF8A80) : const Color(0xFFFFD54F),
              ),
              const SizedBox(width: 3),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isWarning ? const Color(0xFFFFCDD2) : const Color(0xFFFFF9C4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            urdu,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isWarning ? const Color(0xFFFF8A80) : const Color(0xFFFFD54F),
            ),
          ),
        ],
      ),
    );
  }
}
