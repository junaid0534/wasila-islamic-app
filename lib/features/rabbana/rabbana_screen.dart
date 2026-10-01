import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/rabbana_dua_model.dart';
import '../../core/services/rabbana_service.dart';

class RabbanaScreen extends ConsumerStatefulWidget {
  const RabbanaScreen({super.key});

  @override
  ConsumerState<RabbanaScreen> createState() => _RabbanaScreenState();
}

class _RabbanaScreenState extends ConsumerState<RabbanaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = [
    'All',
    'Favorites',
    'Maghfirat',
    'Hidayat',
    'Aafiyat & Sabar',
    'Aulad & Ghar',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyDua(RabbanaDua dua) {
    final text = '''
${dua.title} (#${dua.id})
Surah ${dua.surah} (${dua.ayahNumber})

${dua.arabic}

Tarjuma:
${dua.translationUrdu}

Fazilat:
${dua.benefit}

(Wasila - Daily Islamic Companion)''';

    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Dua #${dua.id} copy ho gayi!',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rabbanaProvider);
    final notifier = ref.read(rabbanaProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Header with Back Button, Title & Controls
            _buildHeader(state, notifier),

            // 2. Search Bar & Filter Chips
            _buildSearchAndFilters(state, notifier),

            // 3. Duas List
            Expanded(
              child: state.filteredDuas.isEmpty
                  ? _buildEmptyState(state)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: state.filteredDuas.length,
                      itemBuilder: (context, index) {
                        final dua = state.filteredDuas[index];
                        return _buildDuaCard(dua, state, notifier);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RabbanaState state, RabbanaNotifier notifier) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E6050), // Forest Pine Green
            Color(0xFF14473B), // Deep Forest Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              notifier.stopAudio();
              Navigator.of(context).pop();
            },
            child: Container(
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Quran Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '40 Rabbana Duas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'رَبَّنَا',
                        style: GoogleFonts.amiri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Quranic Duas with Audio & Urdu Meaning',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),

          // Transliteration Toggle Button
          GestureDetector(
            onTap: () => notifier.toggleTransliteration(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: state.showTransliteration
                    ? Colors.white.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.showTransliteration ? Icons.text_fields_rounded : Icons.abc_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Roman',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(RabbanaState state, RabbanaNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.sageBorder,
                width: 1.2,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => notifier.search(val),
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Dua number, Surah, ya lafz search karein...',
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          notifier.search('');
                        },
                        child: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),

        // Categories Chips Row
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = state.selectedCategory == cat;

              return GestureDetector(
                onTap: () => notifier.selectCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.sageBorder,
                      width: 1.2,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cat == 'Favorites') ...[
                        Icon(
                          Icons.favorite_rounded,
                          size: 13,
                          color: isSelected ? Colors.white : Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        cat == 'All' ? 'All (40)' : cat,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDuaCard(RabbanaDua dua, RabbanaState state, RabbanaNotifier notifier) {
    final isCurrentlyPlaying = state.currentlyPlayingDuaId == dua.id && state.isPlaying;
    final isCurrentlyBuffering = state.currentlyPlayingDuaId == dua.id && state.isLoadingAudio;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentlyPlaying
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.sageBorder,
          width: isCurrentlyPlaying ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentlyPlaying
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.03),
            blurRadius: isCurrentlyPlaying ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card Bar: Number Badge + Title + Surah + Bookmark
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                // Dua Number Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sageLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.sageBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#${dua.id.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Title & Surah Reference
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dua.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Surah ${dua.surah} • Ayah ${dua.ayahNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Favorite Bookmark Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.toggleFavorite(dua.id);
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: dua.isFavorite
                          ? const Color(0xFFFFEBEE)
                          : AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dua.isFavorite
                            ? const Color(0xFFFFCDD2)
                            : AppColors.sageBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      dua.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: dua.isFavorite ? Colors.redAccent : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Arabic Quranic Invocations Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.sageBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Text(
              dua.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.85,
                color: const Color(0xFF14473B),
              ),
            ),
          ),

          // 3. Transliteration (Roman Urdu / English Pronunciation)
          if (state.showTransliteration && dua.transliteration.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                dua.transliteration,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),

          // 4. Urdu Translation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              dua.translationUrdu,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.9,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // 5. Benefit / Fazilat Box
          if (dua.benefit.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6), // Soft warm cream
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFE082), // Soft Gold
                  width: 0.9,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFD48806),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dua.benefit,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A4F01),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 6. Action Bar: Audio Play/Pause Button + Copy + Share
          Container(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
            child: Row(
              children: [
                // Audio Tilawat Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      notifier.playAudio(dua);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isCurrentlyPlaying
                            ? const Color(0xFF14473B)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCurrentlyBuffering)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            Icon(
                              isCurrentlyPlaying
                                  ? Icons.pause_rounded
                                  : Icons.volume_up_rounded,
                              color: isCurrentlyPlaying ? const Color(0xFFFFD54F) : Colors.white,
                              size: 16,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            isCurrentlyBuffering
                                ? 'Loading Audio...'
                                : isCurrentlyPlaying
                                    ? 'Pause Tilawat'
                                    : 'Sunain (Tilawat)',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Copy Button
                GestureDetector(
                  onTap: () => _copyDua(dua),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.sageBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          color: AppColors.primary,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(RabbanaState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.sageLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sageBorder, width: 1),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              state.selectedCategory == 'Favorites'
                  ? 'Abhi koi favorite dua add nahi ki'
                  : 'Koi Dua nahi mili',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.selectedCategory == 'Favorites'
                  ? 'Kisi bhi dua ke dil ❤️ icon par tap kar ke use yahan save karein.'
                  : 'Dusra lafz ya Surah ka naam likh kar search karein.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
