import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../core/services/qibla_service.dart';
import 'widgets/qibla_compass_dial.dart';

class CityPreset {
  final String name;
  final String urduName;
  final double latitude;
  final double longitude;

  const CityPreset({
    required this.name,
    required this.urduName,
    required this.latitude,
    required this.longitude,
  });
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // Preset cities for manual selection and offline fallback
  static const List<CityPreset> _presetCities = [
    CityPreset(name: 'Lahore', urduName: 'لاہور', latitude: 31.5204, longitude: 74.3587),
    CityPreset(name: 'Karachi', urduName: 'کراچی', latitude: 24.8607, longitude: 67.0011),
    CityPreset(name: 'Islamabad', urduName: 'اسلام آباد', latitude: 33.6844, longitude: 73.0479),
    CityPreset(name: 'Rawalpindi', urduName: 'راولپنڈی', latitude: 33.5651, longitude: 73.0169),
    CityPreset(name: 'Faisalabad', urduName: 'فیصل آباد', latitude: 31.4504, longitude: 73.1350),
    CityPreset(name: 'Multan', urduName: 'ملتان', latitude: 30.1575, longitude: 71.5249),
    CityPreset(name: 'Peshawar', urduName: 'پشاور', latitude: 34.0151, longitude: 71.5249),
    CityPreset(name: 'Quetta', urduName: 'کوئٹہ', latitude: 30.1798, longitude: 66.9750),
    CityPreset(name: 'Sialkot', urduName: 'سیالکوٹ', latitude: 32.4945, longitude: 74.5229),
    CityPreset(name: 'Gujranwala', urduName: 'گوجرانوالہ', latitude: 32.1877, longitude: 74.1945),
    CityPreset(name: 'Makkah', urduName: 'مکہ مکرمہ', latitude: 21.4225, longitude: 39.8262),
    CityPreset(name: 'Madinah', urduName: 'مدینہ منورہ', latitude: 24.5247, longitude: 39.5692),
    CityPreset(name: 'Dubai', urduName: 'دبئی', latitude: 25.2048, longitude: 55.2708),
    CityPreset(name: 'London', urduName: 'لندن', latitude: 51.5074, longitude: -0.1278),
  ];

  // Current Location State
  double _latitude = 31.5204;
  double _longitude = 74.3587;
  String _cityName = 'Lahore, Pakistan';
  bool _isGpsActive = false;
  bool _isLoadingGps = false;

  // Sensor Heading State
  double _currentHeading = 0.0;
  double _smoothedHeading = 0.0;
  bool _hasSensor = true;
  bool _wasAligned = false;

  // Qibla Info
  late QiblaInfo _qiblaInfo;

  // Subscriptions
  StreamSubscription<MagnetometerEvent>? _magSubscription;

  @override
  void initState() {
    super.initState();
    final activeLoc = LocationService.activeLocation.value;
    _latitude = activeLoc.latitude;
    _longitude = activeLoc.longitude;
    _cityName = activeLoc.displayName;
    _isGpsActive = activeLoc.isGps;
    _updateQiblaInfo();
    _initSensors();
  }

  @override
  void dispose() {
    _magSubscription?.cancel();
    super.dispose();
  }

  void _updateQiblaInfo() {
    setState(() {
      _qiblaInfo = QiblaService.getQiblaInfo(
        latitude: _latitude,
        longitude: _longitude,
        cityName: _cityName,
      );
    });
  }

  void _initSensors() {
    try {
      _magSubscription = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          // Calculate heading from X and Y magnetic fields
          // When top of device points North, y > 0, x = 0
          double rawHeading = (math.atan2(-event.x, event.y) * (180.0 / math.pi) + 360.0) % 360.0;

          // Exponential smoothing to eliminate magnetic jitter
          double diff = rawHeading - _smoothedHeading;
          while (diff < -180) {
            diff += 360;
          }
          while (diff > 180) {
            diff -= 360;
          }

          _smoothedHeading = (_smoothedHeading + diff * 0.25 + 360.0) % 360.0;

          final bool isAligned = _checkIsAligned(_smoothedHeading, _qiblaInfo.qiblaAngle);

          // Haptic feedback trigger once when entering alignment
          if (isAligned && !_wasAligned) {
            _triggerAlignmentHaptic();
          }
          _wasAligned = isAligned;

          if (mounted) {
            setState(() {
              _currentHeading = _smoothedHeading;
              _hasSensor = true;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              _hasSensor = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasSensor = false;
        });
      }
    }
  }

  bool _checkIsAligned(double heading, double qiblaAngle) {
    double diff = (qiblaAngle - heading + 360) % 360;
    if (diff > 180) diff = 360 - diff;
    return diff <= 3.5;
  }

  Future<void> _triggerAlignmentHaptic() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }
  }

  Future<void> _detectGpsLocation() async {
    setState(() => _isLoadingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingGps = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingGps = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingGps = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _cityName = 'GPS Location (${_latitude.toStringAsFixed(2)}°, ${_longitude.toStringAsFixed(2)}°)';
          _isGpsActive = true;
          _isLoadingGps = false;
        });
        _updateQiblaInfo();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingGps = false);
      }
    }
  }

  void _selectCity(CityPreset city) {
    setState(() {
      _latitude = city.latitude;
      _longitude = city.longitude;
      _cityName = '${city.name}, Pakistan';
      _isGpsActive = false;
    });
    _updateQiblaInfo();
    Navigator.pop(context);
  }

  void _showCityPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Sheet Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.sageBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Location',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'مقام منتخب کریں (قبلہ کی درستگی کے لیے)',
                          style: GoogleFonts.notoNastaliqUrdu(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
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

              // GPS Button Option
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  tileColor: AppColors.sageLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.sageBorder),
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    'Use Current GPS Location',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: Text(
                    'خودکار GPS سے قبلہ سمت معلوم کریں',
                    style: GoogleFonts.notoNastaliqUrdu(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: _isLoadingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                  onTap: () {
                    Navigator.pop(context);
                    _detectGpsLocation();
                  },
                ),
              ),

              // Cities List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _presetCities.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.sageBorder),
                  itemBuilder: (context, index) {
                    final city = _presetCities[index];
                    final isSelected = _cityName.contains(city.name);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      title: Text(
                        city.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            city.urduName,
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                          ],
                        ],
                      ),
                      onTap: () => _selectCity(city),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAligned = _checkIsAligned(_currentHeading, _qiblaInfo.qiblaAngle);
    final angleDiff = (_qiblaInfo.qiblaAngle - _currentHeading + 360) % 360;
    final normalizedDiff = angleDiff > 180 ? angleDiff - 360 : angleDiff;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Location & Calibration Header
              _buildTopHeader(),
              const SizedBox(height: 16),

              if (!_hasSensor) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFEEBA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sensors_off_rounded, color: Color(0xFF856404), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Compass sensor not detected on this device. Showing direct Qibla angle.',
                          style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF856404)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Qibla Status & Alignment Direction Banner
              _buildStatusBanner(isAligned, normalizedDiff),
              const SizedBox(height: 22),

              // Interactive Compass Dial
              QiblaCompassDial(
                heading: _currentHeading,
                qiblaAngle: _qiblaInfo.qiblaAngle,
                isAligned: isAligned,
                size: 290,
              ),
              const SizedBox(height: 24),

              // Qibla Statistics & Detail Cards
              _buildInfoGrid(),
              const SizedBox(height: 16),

              // Sensor Calibration & Flat Surface Notice
              _buildCalibrationNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
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
          // 1. Top Half: Forest Green Gradient
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
                // Brand / Title: Qibla (قِبْلَة)
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
                          Icons.explore_rounded,
                          color: Color(0xFFFFD54F),
                          size: 20,
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
                              'قِبْلَة',
                              style: GoogleFonts.amiri(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'QIBLA',
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
                          'Accurate Kaaba Direction',
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

                // GPS Locate / Refresh Button
                Container(
                  width: 38,
                  height: 38,
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
                    icon: _isLoadingGps
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFFD54F),
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                    tooltip: 'Detect GPS Location',
                    onPressed: _isLoadingGps ? null : _detectGpsLocation,
                  ),
                ),
              ],
            ),
          ),

          // 2. Bottom Half: Pure White with Location & Qibla Angle Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location Pill (Tappable)
                Flexible(
                  child: GestureDetector(
                    onTap: _showCityPickerSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.sageLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.sageBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isGpsActive ? Icons.my_location_rounded : Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _cityName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Qibla Angle Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sageBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.navigation_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_qiblaInfo.qiblaAngle.toStringAsFixed(1)}°',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(bool isAligned, double normalizedDiff) {
    if (isAligned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E6050), Color(0xFF14473B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFFFD54F),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Facing the Holy Kaaba ✨',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'آپ قبلہ کے بالکل عین سامنے ہیں',
                    style: GoogleFonts.notoNastaliqUrdu(
                      fontSize: 11,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final bool turnRight = normalizedDiff > 0;
    final double degreesToTurn = normalizedDiff.abs();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sageBorder, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sageLight,
            ),
            child: Icon(
              turnRight ? Icons.rotate_right_rounded : Icons.rotate_left_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rotate ${degreesToTurn.toStringAsFixed(0)}° ${turnRight ? "Right ➔" : "⬅ Left"}',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  turnRight
                    ? 'فون کو ${degreesToTurn.toStringAsFixed(0)}° دائیں گھمائیں'
                    : 'فون کو ${degreesToTurn.toStringAsFixed(0)}° بائیں گھمائیں',
                  style: GoogleFonts.notoNastaliqUrdu(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        // Qibla Angle Card
        Expanded(
          child: _buildMetricCard(
            title: 'Qibla Bearing',
            value: '${_qiblaInfo.qiblaAngle.toStringAsFixed(1)}°',
            subtext: _qiblaInfo.directionText,
            icon: Icons.navigation_rounded,
          ),
        ),
        const SizedBox(width: 12),

        // Distance to Kaaba Card
        Expanded(
          child: _buildMetricCard(
            title: 'Kaaba Distance',
            value: '${_qiblaInfo.distanceKm.toStringAsFixed(0)} km',
            subtext: 'مکہ مکرمہ کا فاصلہ',
            icon: Icons.mosque_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sageBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoNastaliqUrdu(
              fontSize: 9.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sageLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accuracy Tip',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Place your phone flat and away from strong magnetic objects (magnets, metal, laptops). If the needle wavers, move your phone in a figure-8 motion to calibrate.',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
