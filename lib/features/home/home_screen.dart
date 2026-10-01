import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/widgets/location_selector_sheet.dart';
import '../notifications/prayer_notifications_screen.dart';
import 'widgets/animated_date_pill.dart';
import 'widgets/prayer_card.dart';
import 'widgets/names_banner_card.dart';
import 'widgets/rabbana_banner_card.dart';
import 'widgets/quick_grid.dart';
import '../../core/widgets/font_settings_sheet.dart';
import '../names/names_screen.dart';
import '../rabbana/rabbana_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PrayerSchedule _schedule;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    LocationService.activeLocation.addListener(_onLocationChanged);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _loadData();
        });
      }
    });
  }

  void _onLocationChanged() {
    if (mounted) {
      setState(() {
        _loadData();
      });
    }
  }

  void _loadData() {
    final loc = LocationService.activeLocation.value;
    _schedule = PrayerService.calculatePrayerTimes(
      lat: loc.latitude,
      lng: loc.longitude,
      cityName: loc.isGps ? '${loc.name} (GPS)' : '${loc.name}, ${loc.country}',
      method: loc.method,
    );
    NotificationService.scheduleAllPrayers(_schedule);
  }

  @override
  void dispose() {
    LocationService.activeLocation.removeListener(_onLocationChanged);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar
              _buildHeader(),
              const SizedBox(height: 20),

              // Prayer Times Card (Deep Forest Green Banner)
              PrayerCard(
                schedule: _schedule,
                onTap: () {
                  widget.onNavigateTab?.call(1);
                },
              ),
              const SizedBox(height: 18),

              // 99 Names Featured Banner (Sage / Mint Card)
              NamesBannerCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NamesScreen(),
                    ),
                  );
                },
                onPlayAudio: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NamesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 40 Rabbana Duas Banner Card
              RabbanaBannerCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RabbanaScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),

              // Section Title: Quick Access
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Access',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Wasila Essentials',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2x2 Quick Feature Grid
              QuickGrid(
                items: [
                  QuickGridItem(
                    title: 'Essential Surahs',
                    subtitle: 'Yaseen, Mulk, Rahman',
                    icon: Icons.menu_book_rounded,
                    onTap: () => widget.onNavigateTab?.call(1),
                  ),
                  QuickGridItem(
                    title: 'Daily Azkar & Duas',
                    subtitle: 'Subh o Sham Wazaif',
                    icon: Icons.favorite_rounded,
                    onTap: () => widget.onNavigateTab?.call(4),
                  ),
                  QuickGridItem(
                    title: 'Qibla Compass',
                    subtitle: 'Direction to Kaaba',
                    icon: Icons.explore_rounded,
                    onTap: () => widget.onNavigateTab?.call(2),
                  ),
                  QuickGridItem(
                    title: 'Digital Tasbih',
                    subtitle: 'Zikr Counter & Haptics',
                    icon: Icons.fingerprint_rounded,
                    onTap: () => widget.onNavigateTab?.call(3),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Daily Quranic Inspiration Card
              _buildDailyVerseCard(),

              // Bottom padding for floating nav dock
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.sageBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Half: Forest Green
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E6050), // Forest Pine Green
                  Color(0xFF14473B), // Deep Forest Pine
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand: Wasila (وَسِیْلَہ)
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFFFD54F),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'وَسِيلَة',
                              style: GoogleFonts.amiri(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'WASILA',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFD54F),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Daily Islamic Companion',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Action Buttons: Adhan Alarms & Font Style
                Row(
                  children: [
                    // Adhan & Prayer Alarms
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFFFD54F),
                          size: 18,
                        ),
                        tooltip: 'Adhan & Prayer Alarms',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrayerNotificationsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Font Style Changer
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.format_size_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        tooltip: 'Arabic Font Style',
                        onPressed: () => FontSettingsSheet.show(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Bottom Half: Pure White with Full Location Name & Animated Date Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                // Location Pill (Interactive with Location Picker & Full City Name)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => LocationSelectorSheet.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                        decoration: BoxDecoration(
                          color: AppColors.sageLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            width: 1.1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _schedule.locationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Animated Date Pill (Urdu Hijri <-> English AD every 3s)
                const AnimatedDatePill(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.sageBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.goldAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Verse of the Day',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Surah Ar-Ra\'d (13:28)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'أَلَا بِذِكْرِ ٱللَّٰهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
              textAlign: TextAlign.center,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '"خبردار! اللہ کے ذکر ہی سے دلوں کو اطمینان حاصل ہوتا ہے۔"',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
