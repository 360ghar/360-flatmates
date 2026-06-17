part of 'swipe_deck_page.dart';

extension _SwipeDeckActions on _SwipeDeckPageState {
  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMatchCelebration({
    required String peerName,
    required String? peerImageUrl,
    required int? conversationId,
  }) {
    final userProfile = ref
        .read(bootstrapControllerProvider)
        .valueOrNull
        ?.profile;
    final locale = AppLocalizations.of(context);
    pushMatchCelebration(
      context,
      userName: userProfile?.fullName ?? locale.matchSelfFallbackName,
      userImageUrl: userProfile?.profileImageUrl,
      peerName: peerName,
      peerImageUrl: peerImageUrl,
      conversationId: conversationId,
    );
  }
}
