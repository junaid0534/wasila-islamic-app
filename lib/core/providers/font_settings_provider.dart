import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

enum ArabicFontFamily {
  scheherazade('Scheherazade New', 'عثمانى / مصحف رسم الخط (Recommended)'),
  amiri('Amiri', 'کلاسیکی نَسخ خط'),
  notoNaskh('Noto Naskh Arabic', 'بولڈ اور واضح نَسخ'),
  lateef('Lateef', 'نرم اور روایتی خط'),
  cairo('Cairo', 'جدید خط');

  final String displayName;
  final String description;
  const ArabicFontFamily(this.displayName, this.description);
}

class FontSettingsState {
  final ArabicFontFamily arabicFont;
  final double arabicFontSize;

  FontSettingsState({
    this.arabicFont = ArabicFontFamily.scheherazade,
    this.arabicFontSize = 24.0,
  });

  FontSettingsState copyWith({
    ArabicFontFamily? arabicFont,
    double? arabicFontSize,
  }) {
    return FontSettingsState(
      arabicFont: arabicFont ?? this.arabicFont,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
    );
  }

  TextStyle getArabicTextStyle({
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.bold,
    double? customSize,
    double height = 2.0,
  }) {
    final size = customSize ?? arabicFontSize;
    switch (arabicFont) {
      case ArabicFontFamily.scheherazade:
        return GoogleFonts.scheherazadeNew(
          fontSize: size,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case ArabicFontFamily.amiri:
        return GoogleFonts.amiri(
          fontSize: size,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case ArabicFontFamily.notoNaskh:
        return GoogleFonts.notoNaskhArabic(
          fontSize: size,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case ArabicFontFamily.lateef:
        return GoogleFonts.lateef(
          fontSize: size + 2,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case ArabicFontFamily.cairo:
        return GoogleFonts.cairo(
          fontSize: size - 2,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
    }
  }
}

class FontSettingsNotifier extends StateNotifier<FontSettingsState> {
  FontSettingsNotifier() : super(FontSettingsState()) {
    _loadFromPrefs();
  }

  static const String _fontKey = 'selected_arabic_font';
  static const String _sizeKey = 'selected_arabic_font_size';

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fontIndex = prefs.getInt(_fontKey);
      final fontSize = prefs.getDouble(_sizeKey);

      ArabicFontFamily selectedFont = ArabicFontFamily.scheherazade;
      if (fontIndex != null && fontIndex >= 0 && fontIndex < ArabicFontFamily.values.length) {
        selectedFont = ArabicFontFamily.values[fontIndex];
      }

      state = state.copyWith(
        arabicFont: selectedFont,
        arabicFontSize: fontSize ?? 24.0,
      );
    } catch (_) {}
  }

  Future<void> setFont(ArabicFontFamily font) async {
    state = state.copyWith(arabicFont: font);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_fontKey, font.index);
    } catch (_) {}
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(arabicFontSize: size);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_sizeKey, size);
    } catch (_) {}
  }
}

final fontSettingsProvider = StateNotifierProvider<FontSettingsNotifier, FontSettingsState>((ref) {
  return FontSettingsNotifier();
});
