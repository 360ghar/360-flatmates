import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/error_presenter.dart';
import 'auth_controller.dart';
import 'data/auth_repository.dart';

enum PasswordResetStep { idle, sendingOtp, otpSent, verifying, success, error }

class PasswordResetState {
  final PasswordResetStep step;
  final String? phone;
  final AppFailure? failure;

  const PasswordResetState({
    this.step = PasswordResetStep.idle,
    this.phone,
    this.failure,
  });

  PasswordResetState copyWith({
    PasswordResetStep? step,
    String? phone,
    AppFailure? failure,
    bool clearFailure = false,
  }) => PasswordResetState(
    step: step ?? this.step,
    phone: phone ?? this.phone,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

class PasswordResetController extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  void clearError() {
    if (state.step == PasswordResetStep.error) {
      state = state.copyWith(
        step: PasswordResetStep.otpSent,
        clearFailure: true,
      );
    }
  }

  Future<void> sendOtp(String phone) async {
    state = PasswordResetState(
      step: PasswordResetStep.sendingOtp,
      phone: phone,
    );
    try {
      await _repository.sendPasswordResetOtp(phone);
      state = PasswordResetState(step: PasswordResetStep.otpSent, phone: phone);
    } catch (e, st) {
      final failure = _toFailure(e, st);
      debugPrint('PasswordResetController.sendOtp failed: ${failure.label}');
      state = PasswordResetState(
        step: PasswordResetStep.error,
        phone: phone,
        failure: failure,
      );
    }
  }

  Future<bool> verifyOtpAndSetPassword({
    required String otp,
    required String newPassword,
  }) async {
    final phone = state.phone;
    if (phone == null) return false;

    state = state.copyWith(step: PasswordResetStep.verifying);
    try {
      await _repository.verifyPasswordResetOtp(phone: phone, otp: otp);
      await _repository.changePassword(newPassword);
      // Sign out the temporary session created by OTP verification
      await _repository.signOut();
      state = state.copyWith(step: PasswordResetStep.success);
      return true;
    } catch (e, st) {
      final failure = _toFailure(e, st);
      debugPrint(
        'PasswordResetController.verifyOtpAndSetPassword failed: ${failure.label}',
      );
      // Clean up the temporary session if it was created
      try {
        await _repository.signOut();
      } catch (cleanupErr) {
        debugPrint(
          'PasswordResetController.verifyOtpAndSetPassword signOut cleanup failed: $cleanupErr',
        );
      }
      state = state.copyWith(step: PasswordResetStep.error, failure: failure);
      return false;
    }
  }

  AppFailure _toFailure(Object e, StackTrace st) {
    if (e is AppFailure) return e;
    if (e is DioException) return ErrorPresenter.fromDio(e, st);
    return UnknownFailure(underlyingError: e, stackTrace: st);
  }
}

final passwordResetControllerProvider =
    NotifierProvider<PasswordResetController, PasswordResetState>(
      PasswordResetController.new,
    );
