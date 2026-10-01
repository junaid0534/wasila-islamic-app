import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rabbana_dua_model.dart';

class RabbanaState {
  final List<RabbanaDua> allDuas;
  final List<RabbanaDua> filteredDuas;
  final Set<int> favoriteIds;
  final String searchQuery;
  final String selectedCategory;
  final int? currentlyPlayingDuaId;
  final bool isPlaying;
  final bool isLoadingAudio;
  final bool showTransliteration;
  final bool showEnglishTranslation;

  const RabbanaState({
    this.allDuas = const [],
    this.filteredDuas = const [],
    this.favoriteIds = const {},
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.currentlyPlayingDuaId,
    this.isPlaying = false,
    this.isLoadingAudio = false,
    this.showTransliteration = true,
    this.showEnglishTranslation = false,
  });

  RabbanaState copyWith({
    List<RabbanaDua>? allDuas,
    List<RabbanaDua>? filteredDuas,
    Set<int>? favoriteIds,
    String? searchQuery,
    String? selectedCategory,
    int? currentlyPlayingDuaId,
    bool? isPlaying,
    bool? isLoadingAudio,
    bool? showTransliteration,
    bool? showEnglishTranslation,
    bool clearPlaying = false,
  }) {
    return RabbanaState(
      allDuas: allDuas ?? this.allDuas,
      filteredDuas: filteredDuas ?? this.filteredDuas,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentlyPlayingDuaId: clearPlaying ? null : (currentlyPlayingDuaId ?? this.currentlyPlayingDuaId),
      isPlaying: clearPlaying ? false : (isPlaying ?? this.isPlaying),
      isLoadingAudio: clearPlaying ? false : (isLoadingAudio ?? this.isLoadingAudio),
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showEnglishTranslation: showEnglishTranslation ?? this.showEnglishTranslation,
    );
  }
}

class RabbanaNotifier extends StateNotifier<RabbanaState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _favKey = 'rabbana_fav_ids';

  RabbanaNotifier() : super(const RabbanaState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Load favorites from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_favKey) ?? [];
      final favIds = favList.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();

      // 2. Load JSON asset
      final jsonStr = await rootBundle.loadString('assets/data/rabbana_duas.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr);

      final List<RabbanaDua> duas = jsonList.map((item) {
        final id = item['id'] as int? ?? 0;
        return RabbanaDua.fromJson(item as Map<String, dynamic>, isFavorite: favIds.contains(id));
      }).toList();

      state = state.copyWith(
        allDuas: duas,
        filteredDuas: duas,
        favoriteIds: favIds,
      );

      // Listen to Audio Player state changes
      _audioPlayer.playerStateStream.listen((playerState) {
        final isPlaying = playerState.playing;
        final isBuffering = playerState.processingState == ProcessingState.buffering ||
            playerState.processingState == ProcessingState.loading;
        final isCompleted = playerState.processingState == ProcessingState.completed;

        if (isCompleted) {
          state = state.copyWith(clearPlaying: true);
        } else {
          state = state.copyWith(
            isPlaying: isPlaying,
            isLoadingAudio: isBuffering,
          );
        }
      });
    } catch (e) {
      debugPrint('Error loading Rabbana Duas: $e');
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void toggleTransliteration() {
    state = state.copyWith(showTransliteration: !state.showTransliteration);
  }

  void toggleEnglishTranslation() {
    state = state.copyWith(showEnglishTranslation: !state.showEnglishTranslation);
  }

  Future<void> toggleFavorite(int duaId) async {
    final newFavs = Set<int>.from(state.favoriteIds);
    if (newFavs.contains(duaId)) {
      newFavs.remove(duaId);
    } else {
      newFavs.add(duaId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, newFavs.map((e) => e.toString()).toList());

    final updatedAll = state.allDuas.map((d) {
      return d.copyWith(isFavorite: newFavs.contains(d.id));
    }).toList();

    state = state.copyWith(
      favoriteIds: newFavs,
      allDuas: updatedAll,
    );
    _applyFilters();
  }

  Future<void> playAudio(RabbanaDua dua) async {
    try {
      if (state.currentlyPlayingDuaId == dua.id && state.isPlaying) {
        await _audioPlayer.pause();
        state = state.copyWith(isPlaying: false);
        return;
      }

      if (state.currentlyPlayingDuaId == dua.id && !state.isPlaying) {
        await _audioPlayer.play();
        state = state.copyWith(isPlaying: true);
        return;
      }

      // New Dua audio
      state = state.copyWith(
        currentlyPlayingDuaId: dua.id,
        isLoadingAudio: true,
        isPlaying: false,
      );

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(dua.audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio for Dua ${dua.id}: $e');
      state = state.copyWith(clearPlaying: true);
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    state = state.copyWith(clearPlaying: true);
  }

  void _applyFilters() {
    List<RabbanaDua> list = List.from(state.allDuas);

    // 1. Category Filter
    if (state.selectedCategory == 'Favorites') {
      list = list.where((d) => state.favoriteIds.contains(d.id)).toList();
    } else if (state.selectedCategory == 'Maghfirat') {
      list = list.where((d) =>
          d.title.contains('Maghfirat') ||
          d.title.contains('Bakhshish') ||
          d.title.contains('Gunahon') ||
          d.title.contains('Taubah') ||
          d.translationUrdu.contains('بخش') ||
          d.translationUrdu.contains('مغفرت')).toList();
    } else if (state.selectedCategory == 'Hidayat') {
      list = list.where((d) =>
          d.title.contains('Hidayat') ||
          d.title.contains('Istaqamat') ||
          d.title.contains('Noor') ||
          d.translationUrdu.contains('ہدایت')).toList();
    } else if (state.selectedCategory == 'Aafiyat & Sabar') {
      list = list.where((d) =>
          d.title.contains('Sabar') ||
          d.title.contains('Aafiyat') ||
          d.title.contains('Nemat') ||
          d.title.contains('Bhalai') ||
          d.translationUrdu.contains('صبر') ||
          d.translationUrdu.contains('عافیت')).toList();
    } else if (state.selectedCategory == 'Aulad & Ghar') {
      list = list.where((d) =>
          d.title.contains('Aulad') ||
          d.title.contains('Ghar') ||
          d.title.contains('Khandan') ||
          d.title.contains('Walidain') ||
          d.translationUrdu.contains('اولاد') ||
          d.translationUrdu.contains('والدین')).toList();
    }

    // 2. Search Query Filter
    if (state.searchQuery.trim().isNotEmpty) {
      final q = state.searchQuery.trim().toLowerCase();
      list = list.where((d) {
        return d.id.toString() == q ||
            d.title.toLowerCase().contains(q) ||
            d.englishTitle.toLowerCase().contains(q) ||
            d.surah.toLowerCase().contains(q) ||
            d.ayahNumber.toLowerCase().contains(q) ||
            d.transliteration.toLowerCase().contains(q) ||
            d.translationUrdu.contains(q) ||
            d.arabic.contains(q) ||
            d.benefit.toLowerCase().contains(q);
      }).toList();
    }

    state = state.copyWith(filteredDuas: list);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

final rabbanaProvider = StateNotifierProvider<RabbanaNotifier, RabbanaState>((ref) {
  return RabbanaNotifier();
});
