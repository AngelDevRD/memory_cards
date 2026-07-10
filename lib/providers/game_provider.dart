import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_service.dart';
import '../domain/achievement.dart';
import '../domain/board_generator.dart';
import '../domain/board_size.dart';
import '../domain/card_category.dart';
import '../domain/game_state_machine.dart';
import '../domain/memory_card.dart';
import '../domain/score_calculator.dart';
import '../domain/star_rating.dart';
import 'progress_provider.dart';
import 'settings_provider.dart';
import 'stats_provider.dart';

final audioServiceProvider = Provider((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// How long a mismatched (or matched) pair stays visible before resolving.
const checkDelay = Duration(milliseconds: 700);

class GameConfig {
  const GameConfig({
    required this.boardSize,
    required this.category,
    this.levelNumber,
  });

  final BoardSize boardSize;
  final CardCategory category;
  final int? levelNumber;

  @override
  bool operator ==(Object other) =>
      other is GameConfig &&
      other.boardSize == boardSize &&
      other.category == category &&
      other.levelNumber == levelNumber;

  @override
  int get hashCode => Object.hash(boardSize, category, levelNumber);
}

class GameUiState {
  const GameUiState({
    required this.cards,
    required this.phase,
    required this.moves,
    required this.elapsedSeconds,
    required this.isComplete,
    required this.stars,
    required this.score,
    this.justMatchedPairId,
  });

  final List<MemoryCard> cards;
  final GamePhase phase;
  final int moves;
  final int elapsedSeconds;
  final bool isComplete;
  final int stars;
  final int score;
  final int? justMatchedPairId;

  GameUiState copyWith({
    List<MemoryCard>? cards,
    GamePhase? phase,
    int? moves,
    int? elapsedSeconds,
    bool? isComplete,
    int? stars,
    int? score,
    int? justMatchedPairId,
    bool clearJustMatched = false,
  }) {
    return GameUiState(
      cards: cards ?? this.cards,
      phase: phase ?? this.phase,
      moves: moves ?? this.moves,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isComplete: isComplete ?? this.isComplete,
      stars: stars ?? this.stars,
      score: score ?? this.score,
      justMatchedPairId: clearJustMatched
          ? null
          : (justMatchedPairId ?? this.justMatchedPairId),
    );
  }
}

class GameNotifier extends FamilyNotifier<GameUiState, GameConfig> {
  late GameStateMachine _machine;
  Timer? _ticker;
  int _matchesMade = 0;

  @override
  GameUiState build(GameConfig arg) {
    final cards = BoardGenerator.generate(
      boardSize: arg.boardSize,
      category: arg.category,
    );
    _machine = GameStateMachine(cards);
    ref.onDispose(() => _ticker?.cancel());
    return GameUiState(
      cards: cards,
      phase: GamePhase.idle,
      moves: 0,
      elapsedSeconds: 0,
      isComplete: false,
      stars: 0,
      score: 0,
    );
  }

  void _startTickerIfNeeded() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isComplete) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  Future<void> flipCard(int cardId) async {
    if (state.isComplete) return;
    _startTickerIfNeeded();

    final result = _machine.flipCard(cardId);
    state = state.copyWith(
      cards: result.cards,
      phase: result.phase,
      moves: result.moves,
      clearJustMatched: true,
    );
    _feedbackOnFlip();

    if (result.phase == GamePhase.checking) {
      await Future.delayed(checkDelay);
      _resolveCheck();
    }
  }

  void _resolveCheck() {
    final beforeMatched = _machine.cards.where((c) => c.isMatched).length;
    final result = _machine.resolveCheck();
    final afterMatched = result.cards.where((c) => c.isMatched).length;
    final didMatch = afterMatched > beforeMatched;

    int? matchedPairId;
    if (didMatch) {
      _matchesMade++;
      matchedPairId = result.cards.lastWhere((c) => c.isMatched).pairId;
      _feedbackOnMatch();
    }

    state = state.copyWith(
      cards: result.cards,
      phase: result.phase,
      moves: result.moves,
      justMatchedPairId: matchedPairId,
    );

    if (result.phase == GamePhase.won) {
      _completeGame();
    }
  }

  void _feedbackOnFlip() {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings?.vibrationOn ?? true) {
      HapticFeedback.selectionClick();
    }
    if (settings?.soundOn ?? true) {
      ref.read(audioServiceProvider).playFlip();
    }
  }

  void _feedbackOnMatch() {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings?.vibrationOn ?? true) {
      HapticFeedback.mediumImpact();
    }
    if (settings?.soundOn ?? true) {
      ref.read(audioServiceProvider).playMatch();
    }
  }

  Future<void> _completeGame() async {
    _ticker?.cancel();
    final stars = StarRating.calculate(
      boardSize: arg.boardSize,
      elapsedSeconds: state.elapsedSeconds,
      moves: state.moves,
    );
    final score = ScoreCalculator.calculate(
      boardSize: arg.boardSize,
      elapsedSeconds: state.elapsedSeconds,
      moves: state.moves,
    );
    state = state.copyWith(isComplete: true, stars: stars, score: score);

    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings?.soundOn ?? true) {
      ref.read(audioServiceProvider).playWin();
    }

    final statsNotifier = ref.read(statsProvider.notifier);
    await statsNotifier.recordGameCompletion(
      boardSize: arg.boardSize,
      category: arg.category,
      matches: _matchesMade,
      playSeconds: state.elapsedSeconds,
    );

    if (arg.levelNumber != null) {
      await ref
          .read(progressProvider.notifier)
          .recordLevelCompletion(arg.levelNumber!, stars);
    }

    await _checkAchievements();
  }

  Future<void> _checkAchievements() async {
    final progressNotifier = ref.read(progressProvider.notifier);
    if (arg.boardSize == BoardSize.size8x8) {
      await progressNotifier.unlockAchievement(Achievements.complete8x8.id);
    }
    if (arg.boardSize == BoardSize.size4x4 && state.elapsedSeconds < 30) {
      await progressNotifier.unlockAchievement(
        Achievements.under30Seconds4x4.id,
      );
    }
    final stats = ref.read(statsProvider).valueOrNull;
    if (stats != null && stats.stats.gamesPlayed >= 20) {
      await progressNotifier.unlockAchievement(Achievements.play20Games.id);
    }
  }
}

final gameProvider =
    NotifierProvider.family<GameNotifier, GameUiState, GameConfig>(
      GameNotifier.new,
    );
