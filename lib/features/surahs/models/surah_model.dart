class Verse {
  final int verseNumber;
  final String textArabic; // Contains Uthmani script or Tajweed markup tags
  final String textUrdu;
  final String textEnglish;
  final String? audioUrl;

  const Verse({
    required this.verseNumber,
    required this.textArabic,
    required this.textUrdu,
    required this.textEnglish,
    this.audioUrl,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verseNumber: json['verseNumber'] as int,
      textArabic: json['textArabic'] as String,
      textUrdu: json['textUrdu'] as String,
      textEnglish: json['textEnglish'] as String,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}

class Surah {
  final int id;
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameUrdu;
  final String meaning;
  final int versesCount;
  final String revelationType; // 'Makki' or 'Madani'
  final String benefitsUrdu;
  final String audioUrl;
  final List<Verse> verses;

  const Surah({
    required this.id,
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameUrdu,
    required this.meaning,
    required this.versesCount,
    required this.revelationType,
    required this.benefitsUrdu,
    required this.audioUrl,
    required this.verses,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    final rawVerses = json['verses'] as List<dynamic>? ?? [];
    final versesList = rawVerses
        .map((v) => Verse.fromJson(v as Map<String, dynamic>))
        .toList();

    return Surah(
      id: json['id'] as int,
      number: json['number'] as int,
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      nameUrdu: json['nameUrdu'] as String,
      meaning: json['meaning'] as String,
      versesCount: json['versesCount'] as int? ?? versesList.length,
      revelationType: json['revelationType'] as String,
      benefitsUrdu: json['benefitsUrdu'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      verses: versesList,
    );
  }
}
