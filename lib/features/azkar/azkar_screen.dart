import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/azkar_model.dart';
import '../../core/providers/font_settings_provider.dart';
import '../../core/services/azkar_service.dart';
import '../../core/widgets/font_settings_sheet.dart';

class AzkarScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const AzkarScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends ConsumerState<AzkarScreen> {
  List<AzkarModel> _allAzkar = [];
  List<AzkarModel> _filteredAzkar = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All', 'labelUrdu': 'تمام'},
    {'id': 'morning', 'label': 'Morning', 'labelUrdu': 'صبح کے اذکار'},
    {'id': 'evening', 'label': 'Evening', 'labelUrdu': 'شام کے اذکار'},
    {'id': 'after_prayer', 'label': 'Post-Prayer', 'labelUrdu': 'نماز کے بعد'},
    {'id': 'sleep', 'label': 'Sleep', 'labelUrdu': 'سوتے وقت'},
    {'id': 'protection', 'label': 'Protection', 'labelUrdu': 'حفاظت و شفا'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _loadAzkar();
  }

  Future<void> _loadAzkar() async {
    final list = await AzkarService.loadAzkarList();
    if (mounted) {
      setState(() {
        _allAzkar = list;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAzkar = _allAzkar.where((item) {
        final matchesCategory = _selectedCategory == 'all' || item.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.titleUrdu.contains(_searchQuery) ||
            item.arabic.contains(_searchQuery);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _incrementCount(AzkarModel azkar) {
    if (azkar.currentCount < azkar.targetCount) {
      setState(() {
        azkar.currentCount++;
      });
      _triggerHaptic(isComplete: azkar.isCompleted);
    }
  }

  void _resetCount(AzkarModel azkar) {
    setState(() {
      azkar.currentCount = 0;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _triggerHaptic({bool isComplete = false}) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (isComplete) {
          Vibration.vibrate(duration: 150);
        } else {
          Vibration.vibrate(duration: 40);
        }
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  void _copyDua(AzkarModel item) {
    final text = '${item.arabic}\n\n${item.translationUrdu}\n\n[حوالہ: ${item.reference}]';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Dua copied to clipboard!',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSettings = ref.watch(fontSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daily Azkar & Duas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sageLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.sageBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.format_size_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 2),
                  Text(
                    'Aa',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            tooltip: 'Arabic Font Settings',
            onPressed: () => FontSettingsSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Search Bar
                _buildSearchBar(),

                // Category Chips Selector
                _buildCategoryChips(),

                const SizedBox(height: 10),

                // Azkar List View
                Expanded(
                  child: _filteredAzkar.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: _filteredAzkar.length,
                          itemBuilder: (context, index) {
                            final item = _filteredAzkar[index];
                            return _buildAzkarCard(item, fontSettings);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.sageBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
          onChanged: (val) {
            _searchQuery = val;
            _applyFilters();
          },
          decoration: InputDecoration(
            hintText: 'Search Azkar or Duas...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['id']!;
                _applyFilters();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.sageBorder,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAzkarCard(AzkarModel item, FontSettingsState fontSettings) {
    final isDone = item.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDone ? AppColors.activeGreen : AppColors.sageBorder,
          width: isDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDone
                ? AppColors.activeGreen.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Category Badge & Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.sageBorder,
                  ),
                ),
                child: Text(
                  item.categoryUrdu,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
                    onPressed: () => _copyDua(item),
                    tooltip: 'Copy Dua',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  if (item.currentCount > 0)
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: () => _resetCount(item),
                      tooltip: 'Reset Count',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Arabic Text inside soft Sage container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.sageLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.sageBorder,
              ),
            ),
            child: Text(
              item.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: fontSettings.getArabicTextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Urdu Translation
          Text(
            item.translationUrdu,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoNastaliqUrdu(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 2.0,
            ),
          ),
          const SizedBox(height: 10),

          // Fazilat / Benefit Badge
          if (item.virtueUrdu.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.goldBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.goldAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.virtueUrdu,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 12,
                        color: const Color(0xFF8C6819),
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Footer: Reference & Tap-To-Count Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.reference,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
              ),

              // Interactive Tap-to-Count Action Button
              GestureDetector(
                onTap: () => _incrementCount(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDone ? AppColors.activeGreen : AppColors.sageLight,
                    border: Border.all(
                      color: isDone ? AppColors.activeGreen : AppColors.primary.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: AppColors.activeGreen.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDone)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      else
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value: item.progress,
                                strokeWidth: 2.5,
                                backgroundColor: AppColors.sageBorder,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const Icon(
                              Icons.touch_app_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isDone ? 'Completed (${item.targetCount})' : '${item.currentCount} / ${item.targetCount}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDone ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'No Azkar found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try selecting another category or clear search.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
