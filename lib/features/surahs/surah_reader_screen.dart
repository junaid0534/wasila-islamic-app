import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/font_settings_provider.dart';
import '../../core/services/tajweed_parser.dart';
import '../../core/widgets/font_settings_sheet.dart';
import '../../core/widgets/tajweed_legend_sheet.dart';
import 'models/surah_model.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final Surah surah;

  const SurahReaderScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  late AudioPlayer _audioPlayer;
  bool _isTajweedEnabled = true;
  bool _showTajweedGuide = true;
  bool _showTranslation = true;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlayerLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isPlayerLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });

    _audioPlayer.durationStream.listen((d) {
      if (mounted && d != null) {
        setState(() => _duration = d);
      }
    });

    _audioPlayer.positionStream.listen((p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.audioSource == null) {
          setState(() => _isPlayerLoading = true);
          await _audioPlayer.setUrl(widget.surah.audioUrl);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio stream error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _copyVerse(Verse verse) {
    final cleanArabic = TajweedParser.stripTags(verse.textArabic);
    final textToCopy = '$cleanArabic\n${verse.textUrdu}\n[${widget.surah.nameEnglish} : ${verse.verseNumber}]';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ayah ${verse.verseNumber} copied (آیت کاپی کر لی گئی)'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSettings = ref.watch(fontSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.surah.nameEnglish,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.surah.nameArabic,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Tajweed Guide Button
          IconButton(
            icon: const Icon(Icons.palette_rounded, color: AppColors.primary),
            tooltip: 'Tajweed Rules Guide',
            onPressed: () => TajweedLegendSheet.show(context),
          ),
          // Font Settings
          IconButton(
            icon: const Icon(Icons.format_size_rounded, color: AppColors.primary),
            tooltip: 'Font & Display Settings',
            onPressed: () => FontSettingsSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Reading Controls Bar
          _buildControlsToolbar(),

          // Horizontal Indo-Pak Tajweed Rules Strip (Toggleable)
          if (_isTajweedEnabled && _showTajweedGuide) _buildTajweedLegendStrip(),

          // Verses List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
              itemCount: widget.surah.verses.length + 1, // 0 is Header/Bismillah
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSurahHeaderCard();
                }
                final verse = widget.surah.verses[index - 1];
                return _buildVerseCard(verse, fontSettings, isDark);
              },
            ),
          ),
        ],
      ),
      bottomSheet: _buildAudioPlayerDock(),
    );
  }

  Widget _buildTajweedLegendStrip() {
    final rules = [
      {'name': 'قلقلہ', 'color': TajweedColors.qalqalah},
      {'name': 'غنہ', 'color': TajweedColors.ghunnah},
      {'name': 'مد / تفخیم', 'color': TajweedColors.madd},
      {'name': 'اخفاء', 'color': TajweedColors.ikhfa},
      {'name': 'اخفائے میم', 'color': TajweedColors.ikhfaMeem},
      {'name': 'ادغام', 'color': TajweedColors.idgham},
      {'name': 'ادغام میم', 'color': TajweedColors.idghamMeem},
      {'name': 'قلب', 'color': TajweedColors.qalb},
      {'name': 'ساکن', 'color': TajweedColors.sakin},
    ];

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.sageLight.withValues(alpha: 0.6),
        border: const Border(
          bottom: BorderSide(color: AppColors.sageBorder, width: 0.9),
        ),
      ),
      child: Row(
        children: [
          // Rules Horizontal List (Tappable to open full detail dialog)
          Expanded(
            child: GestureDetector(
              onTap: () => TajweedLegendSheet.show(context),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: rules.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  final Color color = rule['color'] as Color;
                  final String name = rule['name'] as String;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        name,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Hide / Close Strip Button
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
            tooltip: 'Hide Guidelines (رہنمائی چھپائیں)',
            onPressed: () => setState(() => _showTajweedGuide = false),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.sageBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tajweed Mode Toggle Pill
          GestureDetector(
            onTap: () {
              setState(() => _isTajweedEnabled = !_isTajweedEnabled);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _isTajweedEnabled ? AppColors.primary : AppColors.sageLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isTajweedEnabled ? AppColors.primary : AppColors.sageBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.color_lens_rounded,
                    size: 14,
                    color: _isTajweedEnabled ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isTajweedEnabled ? 'Tajweed ON' : 'Tajweed OFF',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _isTajweedEnabled ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // View / Hide Tajweed Guide Strip Button (Only when Tajweed is enabled)
          if (_isTajweedEnabled) ...[
            GestureDetector(
              onTap: () {
                setState(() => _showTajweedGuide = !_showTajweedGuide);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _showTajweedGuide ? AppColors.sageLight : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _showTajweedGuide ? AppColors.primary : AppColors.sageBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showTajweedGuide ? Icons.visibility_off_rounded : Icons.palette_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showTajweedGuide ? 'Hide Guide' : 'View Guide',
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

          // Translation Toggle Pill
          GestureDetector(
            onTap: () {
              setState(() => _showTranslation = !_showTranslation);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _showTranslation ? AppColors.sageLight : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sageBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showTranslation ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Translation',
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
    );
  }

  Widget _buildSurahHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.sageBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Surah Meta row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sageBorder),
                ),
                child: Text(
                  '${widget.surah.revelationType} • ${widget.surah.versesCount} Verses',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.surah.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Benefits / Hadith banner
          if (widget.surah.benefitsUrdu.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sageBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.goldAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.surah.benefitsUrdu,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Bismillah Calligraphy (except for Ayat-ul-Kursi which is a single ayah)
          if (widget.surah.id != 2) ...[
            Center(
              child: Text(
                'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerseCard(Verse verse, dynamic fontSettings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sageBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Number Badge & Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ayah Number Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sageLight,
                  border: Border.all(color: AppColors.sageBorder),
                ),
                child: Center(
                  child: Text(
                    '${verse.verseNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              // Action buttons (Copy)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
                tooltip: 'Copy Ayah',
                onPressed: () => _copyVerse(verse),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Arabic Text with Tajweed Color Coding
          Text.rich(
            TajweedParser.parse(
              verse.textArabic,
              baseStyle: fontSettings.getArabicTextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                height: 2.1,
              ),
              enableTajweed: _isTajweedEnabled,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 10),

          // Urdu Translation
          if (_showTranslation) ...[
            const Divider(height: 16, color: AppColors.sageBorder),
            Text(
              verse.textUrdu,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.9,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioPlayerDock() {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds % 60;
    final totalMinutes = _duration.inMinutes;
    final totalSeconds = _duration.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.sageBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player info header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over_rounded, size: 15, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Mishary Rashid Alafasy',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} / ${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Slider & Play Button Row
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.sageBorder,
                    thumbColor: AppColors.primary,
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble().clamp(
                          0.0,
                          _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                        ),
                    max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                    onChanged: (val) {
                      _audioPlayer.seek(Duration(seconds: val.toInt()));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Play / Pause Button
              GestureDetector(
                onTap: _isPlayerLoading ? null : _toggleAudio,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isPlayerLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
