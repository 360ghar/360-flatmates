import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeQuotaState {
  const SwipeQuotaState({
    required this.swipesToday,
    required this.superLikesRemaining,
    this.isReady = false,
  });

  final int swipesToday;
  final int superLikesRemaining;
  final bool isReady;

  static const int swipesPerDayCap = 100;
  static const int defaultSuperLikes = 3;

  int get swipesRemaining => swipesPerDayCap - swipesToday;
  bool get isCapped => swipesToday >= swipesPerDayCap;

  SwipeQuotaState copyWith({
    int? swipesToday,
    int? superLikesRemaining,
    bool? isReady,
  }) {
    return SwipeQuotaState(
      swipesToday: swipesToday ?? this.swipesToday,
      superLikesRemaining: superLikesRemaining ?? this.superLikesRemaining,
      isReady: isReady ?? this.isReady,
    );
  }
}

class SwipeQuotaController extends Notifier<SwipeQuotaState> {
  static const _prefKeySwipesDate = 'swipe_cap_date';
  static const _prefKeySwipesCount = 'swipe_cap_count';
  static const _prefKeySuperLikes = 'swipe_super_likes_remaining';

  Future<void>? _hydration;

  @override
  SwipeQuotaState build() {
    _hydration ??= _loadSwipeCaps();
    return const SwipeQuotaState(
      swipesToday: 0,
      superLikesRemaining: SwipeQuotaState.defaultSuperLikes,
    );
  }

  // Awaitable hydration gate. Callers that act on quota (e.g. swipe handlers)
  // should await this before reading state, otherwise they may evaluate
  // `isCapped` against the default swipesToday=0 during the prefs load window
  // and let the user exceed yesterday's persisted count.
  Future<void> ensureReady() async {
    final hydration = _hydration;
    if (hydration != null) await hydration;
  }

  Future<void> _loadSwipeCaps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_prefKeySwipesDate);
    int swipesToday = 0;
    bool isNewDay = savedDate != today;
    if (!isNewDay) {
      swipesToday = prefs.getInt(_prefKeySwipesCount) ?? 0;
    } else {
      await prefs.setString(_prefKeySwipesDate, today);
      await prefs.setInt(_prefKeySwipesCount, 0);
    }
    final superLikesRemaining = isNewDay
        ? SwipeQuotaState.defaultSuperLikes
        : (prefs.getInt(_prefKeySuperLikes) ??
              SwipeQuotaState.defaultSuperLikes);
    if (isNewDay) {
      await prefs.setInt(_prefKeySuperLikes, SwipeQuotaState.defaultSuperLikes);
    }
    state = SwipeQuotaState(
      swipesToday: swipesToday,
      superLikesRemaining: superLikesRemaining,
      isReady: true,
    );
  }

  Future<void> recordSwipe({required bool isSuperLike}) async {
    await ensureReady();
    final prefs = await SharedPreferences.getInstance();
    final newSwipesToday = state.swipesToday + 1;
    final newSuperLikes = isSuperLike
        ? (state.superLikesRemaining - 1).clamp(0, double.infinity).toInt()
        : state.superLikesRemaining;
    await prefs.setInt(_prefKeySwipesCount, newSwipesToday);
    await prefs.setInt(_prefKeySuperLikes, newSuperLikes);
    state = state.copyWith(
      swipesToday: newSwipesToday,
      superLikesRemaining: newSuperLikes,
    );
  }

  Future<void> resetForNewDay() async {
    await ensureReady();
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_prefKeySwipesDate, today);
    await prefs.setInt(_prefKeySwipesCount, 0);
    await prefs.setInt(_prefKeySuperLikes, SwipeQuotaState.defaultSuperLikes);
    state = state.copyWith(
      swipesToday: 0,
      superLikesRemaining: SwipeQuotaState.defaultSuperLikes,
    );
  }
}

final swipeQuotaControllerProvider =
    NotifierProvider<SwipeQuotaController, SwipeQuotaState>(
      SwipeQuotaController.new,
    );
