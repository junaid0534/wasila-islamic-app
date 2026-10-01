class AzkarModel {
  final int id;
  final String category;
  final String categoryUrdu;
  final String title;
  final String titleUrdu;
  final String arabic;
  final String transliteration;
  final String translationUrdu;
  final String translationEn;
  final int targetCount;
  final String virtueUrdu;
  final String reference;
  int currentCount;

  AzkarModel({
    required this.id,
    required this.category,
    required this.categoryUrdu,
    required this.title,
    required this.titleUrdu,
    required this.arabic,
    required this.transliteration,
    required this.translationUrdu,
    required this.translationEn,
    required this.targetCount,
    required this.virtueUrdu,
    required this.reference,
    this.currentCount = 0,
  });

  bool get isCompleted => currentCount >= targetCount;
  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      category: json['category'] ?? 'general',
      categoryUrdu: json['categoryUrdu'] ?? 'اذکار',
      title: json['title'] ?? '',
      titleUrdu: json['titleUrdu'] ?? '',
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translationUrdu: json['translationUrdu'] ?? '',
      translationEn: json['translationEn'] ?? '',
      targetCount: json['targetCount'] is int ? json['targetCount'] : int.tryParse(json['targetCount'].toString()) ?? 1,
      virtueUrdu: json['virtueUrdu'] ?? '',
      reference: json['reference'] ?? '',
      currentCount: 0,
    );
  }
}
