import 'package:flutter/material.dart';

class TajweedColors {
  // 1. Qalqalah (قلقلہ) - Red
  static const Color qalqalah = Color(0xFFD32F2F);

  // 2. Ghunnah (غنہ) - Rich Amber Red
  static const Color ghunnah = Color(0xFFE65100);

  // 3. Madd / Tafkheem (مد / تفخيم) - Sky Blue
  static const Color madd = Color(0xFF0288D1);

  // 4. Ikhfa (اخفاء) - Deep Navy Blue
  static const Color ikhfa = Color(0xFF1565C0);

  // 5. Ikhfa Meem Sakin (اخفائے میم ساکن) - Magenta / Pink
  static const Color ikhfaMeem = Color(0xFFC2185B);

  // 6. Idgham (ادغام) - Light Lime Green
  static const Color idgham = Color(0xFF43A047);

  // 7. Idgham Meem (ادغام میم) - Dark Emerald Green
  static const Color idghamMeem = Color(0xFF00695C);

  // 8. Qalb / Iqlab (قلب / اقلاب) - Orange
  static const Color qalb = Color(0xFFFF6F00);

  // 9. Sakin (ساکن) - Indigo / Purple
  static const Color sakin = Color(0xFF4A148C);

  // Normal Base Letter
  static const Color normal = Color(0xFF0F172A);
}

class TajweedParser {
  /// Parses standard Tajweed tagged Quranic text and returns a TextSpan with accurate Indo-Pak Tajweed color styling.
  static TextSpan parse(
    String text, {
    required TextStyle baseStyle,
    bool enableTajweed = true,
  }) {
    if (!enableTajweed) {
      return TextSpan(
        text: stripTags(text),
        style: baseStyle,
      );
    }

    final List<InlineSpan> spans = [];
    final RegExp tagPattern = RegExp(r'\[([a-zA-Z0-9_:]+)\[|\]|<(\w+)>(.*?)</\2>');

    // Check if XML-style tags (<gh>...</gh>)
    if (text.contains('<') && text.contains('</')) {
      return _parseXmlTags(text, baseStyle);
    }

    // Parse standard Tajweed bracket tags: [tag[content]]
    int lastIdx = 0;
    final List<String> tagStack = [];

    for (final Match match in tagPattern.allMatches(text)) {
      if (match.start > lastIdx) {
        final String plain = text.substring(lastIdx, match.start);
        final Color currentColor = tagStack.isNotEmpty
            ? _getColorForBracketTag(tagStack.last, baseStyle.color)
            : (baseStyle.color ?? TajweedColors.normal);

        spans.add(
          TextSpan(
            text: plain,
            style: baseStyle.copyWith(
              color: currentColor,
              fontWeight: tagStack.isNotEmpty && _isColoredRule(tagStack.last)
                  ? FontWeight.bold
                  : baseStyle.fontWeight,
            ),
          ),
        );
      }

      final String matchStr = match.group(0)!;
      if (matchStr == ']') {
        if (tagStack.isNotEmpty) {
          tagStack.removeLast();
        }
      } else if (match.group(1) != null) {
        final rawTag = match.group(1)!;
        final cleanTag = rawTag.split(':').first.toLowerCase();
        tagStack.add(cleanTag);
      }

      lastIdx = match.end;
    }

    if (lastIdx < text.length) {
      final String trailing = text.substring(lastIdx);
      final Color currentColor = tagStack.isNotEmpty
          ? _getColorForBracketTag(tagStack.last, baseStyle.color)
          : (baseStyle.color ?? TajweedColors.normal);

      spans.add(
        TextSpan(
          text: trailing,
          style: baseStyle.copyWith(
            color: currentColor,
          ),
        ),
      );
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  static TextSpan _parseXmlTags(String taggedText, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    final RegExp tagRegExp = RegExp(r'<(\w+)>(.*?)</\1>', dotAll: true);
    int lastMatchEnd = 0;

    for (final Match match in tagRegExp.allMatches(taggedText)) {
      if (match.start > lastMatchEnd) {
        final plainText = taggedText.substring(lastMatchEnd, match.start);
        spans.add(TextSpan(text: plainText, style: baseStyle));
      }

      final String tag = match.group(1)!;
      final String content = match.group(2)!;
      final Color ruleColor = _getColorForXmlTag(tag, baseStyle.color);

      spans.add(
        TextSpan(
          text: content,
          style: baseStyle.copyWith(
            color: ruleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < taggedText.length) {
      final trailingText = taggedText.substring(lastMatchEnd);
      spans.add(TextSpan(text: trailingText, style: baseStyle));
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  static bool _isColoredRule(String tag) {
    const coloredTags = {'g', 'q', 'm', 'o', 'f', 'c', 'w', 'a', 'd', 'u', 'i', 's'};
    return coloredTags.contains(tag);
  }

  static Color _getColorForBracketTag(String tag, Color? defaultColor) {
    switch (tag) {
      // 1. Qalqalah (قلقلہ) -> Bright Red
      case 'q':
        return TajweedColors.qalqalah;

      // 2. Ghunnah (غنہ) -> Rich Amber Red
      case 'g':
        return TajweedColors.ghunnah;

      // 3. Madd (مد واجب و جائز) / Tafkheem -> Sky Blue
      case 'm':
      case 'o':
        return TajweedColors.madd;

      // 4. Ikhfa (اخفاء) -> Deep Navy Blue
      case 'f':
        return TajweedColors.ikhfa;

      // 5. Ikhfa-e-Meem Sakin (اخفائے میم ساکن) -> Magenta / Pink
      case 'c':
        return TajweedColors.ikhfaMeem;

      // 6. Idgham (ادغام) -> Light Lime Green
      case 'w':
      case 'a':
        return TajweedColors.idgham;

      // 7. Idgham Meem (ادغام میم) / Mutajanisayn -> Dark Emerald Green
      case 'd':
      case 'u':
        return TajweedColors.idghamMeem;

      // 8. Qalb / Iqlab (قلب / اقلاب) -> Orange
      case 'i':
        return TajweedColors.qalb;

      // 9. Sakin (ساکن) -> Indigo / Purple
      case 's':
        return TajweedColors.sakin;

      // Normal letters / Hamzat Wasl / Lam Shamsiyyah
      case 'h':
      case 'l':
      case 'n':
      case 'p':
      default:
        return defaultColor ?? TajweedColors.normal;
    }
  }

  static Color _getColorForXmlTag(String tag, Color? defaultColor) {
    switch (tag) {
      case 'ql':
        return TajweedColors.qalqalah;
      case 'gh':
        return TajweedColors.ghunnah;
      case 'm':
      case 'ml':
        return TajweedColors.madd;
      case 'ik':
        return TajweedColors.ikhfa;
      case 'id':
        return TajweedColors.idgham;
      case 'iq':
        return TajweedColors.qalb;
      case 'sk':
        return TajweedColors.sakin;
      default:
        return defaultColor ?? TajweedColors.normal;
    }
  }

  /// Removes all Tajweed bracket and XML markup tags from text
  static String stripTags(String text) {
    String cleaned = text.replaceAll(RegExp(r'\[[a-zA-Z0-9_:]+\[|\]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'</?\w+>'), '');
    return cleaned;
  }
}
