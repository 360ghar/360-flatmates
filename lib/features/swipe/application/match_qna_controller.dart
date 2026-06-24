import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/providers.dart';

/// Controller for submitting match Q&A ice-breaker answers.
///
/// Extracts the `apiClientProvider` POST out of the widget layer so the
/// widget stays a pure presentation component (AGENTS.md: no
/// `apiClientProvider` in page/widget files).
class MatchQnAController extends Notifier<bool> {
  @override
  bool build() => false; // isSubmitting

  /// Submits the 3 Q&A answers. Returns `true` on success, `false` on
  /// failure (error is logged; the caller shows a toast).
  Future<bool> submitAnswers({
    required int conversationId,
    required String q1,
    required String q2,
    required String q3,
  }) async {
    if (state) return false;
    state = true;
    try {
      await ref
          .read(apiClientProvider)
          .post(
            FlatmatesEndpoints.conversationQnA(conversationId),
            data: {
              'answers': {'0': q1, '1': q2, '2': q3},
            },
          );
      return true;
    } catch (e) {
      debugPrint(
        'MatchQnAController.submitAnswers failed for conversation '
        '$conversationId: $e',
      );
      return false;
    } finally {
      state = false;
    }
  }
}

final matchQnAControllerProvider = NotifierProvider<MatchQnAController, bool>(
  MatchQnAController.new,
);
