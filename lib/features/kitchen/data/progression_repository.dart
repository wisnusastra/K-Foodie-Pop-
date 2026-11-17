// lib/features/kitchen/data/progression_repository.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final progressionRepositoryProvider = Provider<ProgressionRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressionRepository(prefs);
});

class PlayerProgress {
  final int unlockedDay;
  final int totalCoins;

  const PlayerProgress({
    required this.unlockedDay,
    required this.totalCoins,
  });

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      unlockedDay: json['unlockedDay'] as int? ?? 1,
      totalCoins: json['totalCoins'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'unlockedDay': unlockedDay,
        'totalCoins': totalCoins,
      };

  PlayerProgress copyWith({
    int? unlockedDay,
    int? totalCoins,
  }) {
    return PlayerProgress(
      unlockedDay: unlockedDay ?? this.unlockedDay,
      totalCoins: totalCoins ?? this.totalCoins,
    );
  }
}

class ProgressionRepository {
  static const _storageKey = 'k_foodie_pop_progress_v1';
  final SharedPreferences _prefs;

  ProgressionRepository(this._prefs);

  Future<PlayerProgress> loadProgress() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const PlayerProgress(unlockedDay: 1, totalCoins: 0);
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return PlayerProgress.fromJson(decoded);
    } catch (_) {
      return const PlayerProgress(unlockedDay: 1, totalCoins: 0);
    }
  }

  Future<PlayerProgress> completeDay({
    required int dayCompleted,
    required int earnedCoins,
  }) async {
    final current = await loadProgress();
    final nextDay = (dayCompleted + 1) > current.unlockedDay
        ? (dayCompleted + 1).clamp(1, 3)
        : current.unlockedDay;
    final updated = current.copyWith(
      unlockedDay: nextDay,
      totalCoins: current.totalCoins + earnedCoins,
    );
    await _prefs.setString(_storageKey, jsonEncode(updated.toJson()));
    return updated;
  }
}
