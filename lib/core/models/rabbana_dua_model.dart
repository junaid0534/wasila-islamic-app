class RabbanaDua {
  final int id;
  final String title;
  final String englishTitle;
  final String surah;
  final String ayahNumber;
  final String arabic;
  final String transliteration;
  final String translationUrdu;
  final String translationEnglish;
  final String benefit;
  final String audioUrl;
  final bool isFavorite;

  const RabbanaDua({
    required this.id,
    required this.title,
    required this.englishTitle,
    required this.surah,
    required this.ayahNumber,
    required this.arabic,
    required this.transliteration,
    required this.translationUrdu,
    required this.translationEnglish,
    required this.benefit,
    required this.audioUrl,
    this.isFavorite = false,
  });

  factory RabbanaDua.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    return RabbanaDua(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      englishTitle: json['englishTitle'] as String? ?? '',
      surah: json['surah'] as String? ?? '',
      ayahNumber: json['ayahNumber'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translationUrdu: json['translationUrdu'] as String? ?? '',
      translationEnglish: json['translationEnglish'] as String? ?? '',
      benefit: json['benefit'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      isFavorite: isFavorite,
    );
  }

  RabbanaDua copyWith({
    int? id,
    String? title,
    String? englishTitle,
    String? surah,
    String? ayahNumber,
    String? arabic,
    String? transliteration,
    String? translationUrdu,
    String? translationEnglish,
    String? benefit,
    String? audioUrl,
    bool? isFavorite,
  }) {
    return RabbanaDua(
      id: id ?? this.id,
      title: title ?? this.title,
      englishTitle: englishTitle ?? this.englishTitle,
      surah: surah ?? this.surah,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      translationUrdu: translationUrdu ?? this.translationUrdu,
      translationEnglish: translationEnglish ?? this.translationEnglish,
      benefit: benefit ?? this.benefit,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
