import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/name_model.dart';
import '../../../core/providers/font_settings_provider.dart';

class AnimatedNameCard extends ConsumerWidget {
  final IslamicNameModel name;
  final bool isListMode;

  const AnimatedNameCard({
    super.key,
    required this.name,
    this.isListMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSettings = ref.watch(fontSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E6050), // Forest Pine Green
            Color(0xFF14473B), // Deep Forest Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF134539).withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isListMode ? 16 : 10,
        vertical: isListMode ? 12 : 9,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: ID Badge & Transliteration
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  '#${name.id.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Color(0xFFFFD54F), // Luminous Gold
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name.transliteration,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: isListMode ? 12 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Spacing to position texts down gracefully in grid view
          SizedBox(height: isListMode ? 6 : 14),

          // 1. Arabic Name (28px in Column mode, 24px in Grid)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: fontSettings.getArabicTextStyle(
                customSize: isListMode ? 28 : 24,
                color: Colors.white,
                height: 1.3,
              ).copyWith(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isListMode ? 6 : 5),

          // 2. Urdu Meaning (14px in Column mode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name.urduMeaning,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: isListMode ? 14 : 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFD54F), // Rich Gold Highlight
                height: 1.85,
              ),
            ),
          ),

          SizedBox(height: isListMode ? 5 : 4),

          // 3. English Meaning
          Text(
            name.englishMeaning,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isListMode ? 12 : 9.5,
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),

          // 4. Fazilat / Spiritual Benefit Box (for List Mode)
          if (isListMode && name.benefits != null && name.benefits!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.7,
                ),
              ),
              child: Text(
                name.benefits!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
