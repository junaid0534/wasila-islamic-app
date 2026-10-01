import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/font_settings_provider.dart';
import '../../core/widgets/font_settings_sheet.dart';

class DhikrItem {
  final String arabic;
  final String transliteration;
  final String urdu;
  final int defaultTarget;

  const DhikrItem({
    required this.arabic,
    required this.transliteration,
    required this.urdu,
    this.defaultTarget = 33,
  });
}

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen>
    with SingleTickerProviderStateMixin {
  static const List<DhikrItem> _presets = [
    DhikrItem(
      arabic: 'سُبْحَانَ ٱللَّٰهِ',
      transliteration: 'SubhanAllah',
      urdu: 'اللہ ہر عیب سے پاک ہے',
      defaultTarget: 33,
    ),
    DhikrItem(
      arabic: 'ٱلْحَمْدُ لِلَّٰهِ',
      transliteration: 'Alhamdulillah',
      urdu: 'تمام تعریفیں اللہ ہی کے لیے ہیں',
      defaultTarget: 33,
    ),
    DhikrItem(
      arabic: 'ٱللَّٰهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      urdu: 'اللہ سب سے بڑا ہے',
      defaultTarget: 34,
    ),
    DhikrItem(
      arabic: 'لَا إِلٰهَ إِلَّا ٱللَّٰهُ',
      transliteration: 'La ilaha illallah',
      urdu: 'اللہ کے سوا کوئی معبود نہیں',
      defaultTarget: 100,
    ),
    DhikrItem(
      arabic: 'أَسْتَغْفِرُ ٱللَّٰهَ',
      transliteration: 'Astaghfirullah',
      urdu: 'میں اللہ سے بخشش مانگتا ہوں',
      defaultTarget: 100,
    ),
    DhikrItem(
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      transliteration: 'Durood Shareef',
      urdu: 'اے اللہ! محمد ﷺ پر رحمتیں نازل فرما',
      defaultTarget: 100,
    ),
    DhikrItem(
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      urdu: 'پاک ہے اللہ اور اس کی تعریف کے ساتھ',
      defaultTarget: 100,
    ),
    DhikrItem(
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      transliteration: 'La Hawla wa la Quwwata',
      urdu: 'گناہوں سے بچنے اور نیکی کرنے کی طاقت اللہ ہی کی طرف سے ہے',
      defaultTarget: 100,
    ),
  ];

  int _selectedDhikrIndex = 0;
  int _currentCount = 0;
  int _targetCount = 33;
  int _completedLaps = 0;
  int _totalDailyCount = 0;
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.94,
      upperBound: 1.0,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    );
    _pulseController.value = 1.0;
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentCount = prefs.getInt('tasbih_current_count') ?? 0;
        _targetCount = prefs.getInt('tasbih_target_count') ?? 33;
        _completedLaps = prefs.getInt('tasbih_completed_laps') ?? 0;
        _totalDailyCount = prefs.getInt('tasbih_total_daily') ?? 0;
        _selectedDhikrIndex = prefs.getInt('tasbih_dhikr_index') ?? 0;
        _isVibrationOn = prefs.getBool('tasbih_vibrate') ?? true;
        _isSoundOn = prefs.getBool('tasbih_sound') ?? true;
      });
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbih_current_count', _currentCount);
      await prefs.setInt('tasbih_target_count', _targetCount);
      await prefs.setInt('tasbih_completed_laps', _completedLaps);
      await prefs.setInt('tasbih_total_daily', _totalDailyCount);
      await prefs.setInt('tasbih_dhikr_index', _selectedDhikrIndex);
      await prefs.setBool('tasbih_vibrate', _isVibrationOn);
      await prefs.setBool('tasbih_sound', _isSoundOn);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapCount() {
    _pulseController.forward(from: 0.94);

    if (_isVibrationOn) {
      HapticFeedback.lightImpact();
    }
    if (_isSoundOn) {
      SystemSound.play(SystemSoundType.click);
    }

    setState(() {
      _currentCount++;
      _totalDailyCount++;

      // Check Target Completion
      if (_targetCount > 0 && _currentCount >= _targetCount) {
        _completedLaps++;
        _currentCount = 0;
        if (_isVibrationOn) {
          HapticFeedback.heavyImpact();
        }
        _showLapCompletedToast();
      }
    });

    _saveState();
  }

  void _undoCount() {
    if (_currentCount > 0) {
      if (_isVibrationOn) HapticFeedback.selectionClick();
      setState(() {
        _currentCount--;
        if (_totalDailyCount > 0) _totalDailyCount--;
      });
      _saveState();
    }
  }

  void _resetCount() {
    if (_isVibrationOn) HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تسبیح ری سیٹ کریں؟',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoNastaliqUrdu(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          'کیا آپ موجودہ گنتی کو صفر (0) کرنا چاہتے ہیں؟',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoNastaliqUrdu(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'نہیں',
              style: GoogleFonts.notoNastaliqUrdu(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentCount = 0;
                _completedLaps = 0;
              });
              _saveState();
            },
            child: Text(
              'ہاں، ری سیٹ کریں',
              style: GoogleFonts.notoNastaliqUrdu(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLapCompletedToast() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFFFD54F), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ماشاءاللہ! ایک دور ($_targetCount مرتبہ) مکمل ہو گیا',
                style: GoogleFonts.notoNastaliqUrdu(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectDhikr(int index) {
    if (_isVibrationOn) HapticFeedback.selectionClick();
    setState(() {
      _selectedDhikrIndex = index;
      _targetCount = _presets[index].defaultTarget;
      _currentCount = 0;
      _completedLaps = 0;
    });
    _saveState();
  }

  void _setTarget(int target) {
    if (_isVibrationOn) HapticFeedback.selectionClick();
    setState(() {
      _targetCount = target;
      _currentCount = 0;
    });
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    final fontSettings = ref.watch(fontSettingsProvider);
    final activeDhikr = _presets[_selectedDhikrIndex];
    final double progress = _targetCount > 0 ? (_currentCount / _targetCount).clamp(0.0, 1.0) : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ڈیجیٹل تسبیح',
          style: GoogleFonts.notoNastaliqUrdu(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVibrationOn ? Icons.vibration_rounded : Icons.smartphone_rounded,
              color: _isVibrationOn ? const Color(0xFFFFD54F) : Colors.white60,
            ),
            tooltip: 'وائبریشن آن/آف',
            onPressed: () {
              setState(() => _isVibrationOn = !_isVibrationOn);
              _saveState();
            },
          ),
          IconButton(
            icon: Icon(
              _isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _isSoundOn ? const Color(0xFFFFD54F) : Colors.white60,
            ),
            tooltip: 'آواز آن/آف',
            onPressed: () {
              setState(() => _isSoundOn = !_isSoundOn);
              _saveState();
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded, color: Colors.white),
            tooltip: 'فونٹ تبدیل کریں',
            onPressed: () => FontSettingsSheet.show(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 95), // Space for floating bottom dock
          child: Column(
            children: [
              // 1. Horizontal Dhikr Presets Selector
              Container(
                height: 48,
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _presets.length,
                  itemBuilder: (context, index) {
                    final item = _presets[index];
                    final isSelected = _selectedDhikrIndex == index;
                    return GestureDetector(
                      onTap: () => _selectDhikr(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.sageBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.22)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            item.transliteration,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Active Dhikr Display Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sageBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        activeDhikr.arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: fontSettings.getArabicTextStyle(
                          customSize: 22,
                          color: AppColors.primary,
                          height: 1.3,
                        ).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      activeDhikr.urdu,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Target Limit Selector Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTargetButton(33),
                    const SizedBox(width: 8),
                    _buildTargetButton(100),
                    const SizedBox(width: 8),
                    _buildTargetButton(1000),
                    const SizedBox(width: 8),
                    _buildTargetButton(0, label: 'آزاد (∞)'),
                  ],
                ),
              ),

              // Spacing to bring circle slightly down
              const SizedBox(height: 24),

              // 4. Compact Interactive Center Tasbih Dial (175px)
              Center(
                child: GestureDetector(
                  onTap: _onTapCount,
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 175,
                      height: 175,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E6050), // Forest Pine Green
                            Color(0xFF134539),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Smooth Circular Progress Ring
                          SizedBox(
                            width: 155,
                            height: 155,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                            ),
                          ),

                          // Center Counter Display
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Current Big Number
                              Text(
                                '$_currentCount',
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),

                              // Target / Free Mode
                              Text(
                                _targetCount > 0 ? '/ $_targetCount' : 'Free Mode',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFFD54F).withValues(alpha: 0.9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),

                              // Laps Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'دور: $_completedLaps',
                                  style: GoogleFonts.notoNastaliqUrdu(
                                    fontSize: 9.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. Bottom Controls: 3 Equal-Sized Unified Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Button 1: Undo (-1)
                    Expanded(
                      child: _buildEqualActionButton(
                        icon: Icons.undo_rounded,
                        label: 'واپس (-1)',
                        onTap: _undoCount,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Button 2: Total Today Stat
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.sageBorder, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'آج کی تعداد',
                              style: GoogleFonts.notoNastaliqUrdu(
                                fontSize: 9.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$_totalDailyCount',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Button 3: Reset
                    Expanded(
                      child: _buildEqualActionButton(
                        icon: Icons.refresh_rounded,
                        label: 'ری سیٹ',
                        onTap: _resetCount,
                        isDestructive: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetButton(int target, {String? label}) {
    final isSelected = _targetCount == target;
    return GestureDetector(
      onTap: () => _setTarget(target),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.sageBorder,
            width: 1.2,
          ),
        ),
        child: Text(
          label ?? target.toString(),
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEqualActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFDECEB) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive ? const Color(0xFFF5C6CB) : AppColors.sageBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDestructive ? Colors.red : AppColors.primary).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive ? const Color(0xFFD9534F) : AppColors.primary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isDestructive ? const Color(0xFFD9534F) : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
