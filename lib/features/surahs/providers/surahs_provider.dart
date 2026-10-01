import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/surah_model.dart';

class SurahsRepository {
  static List<Surah>? _cachedSurahs;

  static Future<List<Surah>> loadAllSurahs() async {
    if (_cachedSurahs != null && _cachedSurahs!.isNotEmpty) {
      return _cachedSurahs!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/essential_surahs.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _cachedSurahs = jsonList.map((j) => Surah.fromJson(j as Map<String, dynamic>)).toList();
      return _cachedSurahs!;
    } catch (e) {
      // Fallback empty list or cached
      return _cachedSurahs ?? [];
    }
  }
}

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  return SurahsRepository.loadAllSurahs();
});
