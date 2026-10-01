class IslamicNameModel {
  final int id;
  final String arabic;
  final String transliteration;
  final String englishMeaning;
  final String urduMeaning;
  final String? benefits; // Fazilat or spiritual benefit
  final String? audioUrl; // Audio recitation link or asset

  IslamicNameModel({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.englishMeaning,
    required this.urduMeaning,
    this.benefits,
    this.audioUrl,
  });

  factory IslamicNameModel.fromJson(Map<String, dynamic> json) {
    return IslamicNameModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      englishMeaning: json['englishMeaning'] ?? json['meaning_en'] ?? '',
      urduMeaning: json['urduMeaning'] ?? json['meaning_ur'] ?? '',
      benefits: json['benefits'] ?? json['fazilat'],
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'transliteration': transliteration,
      'englishMeaning': englishMeaning,
      'urduMeaning': urduMeaning,
      'benefits': benefits,
      'audioUrl': audioUrl,
    };
  }
}
