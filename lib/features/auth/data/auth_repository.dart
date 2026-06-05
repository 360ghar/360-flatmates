import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/constants.dart';
import '../../../core/config/endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_token_storage.dart';

final class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required AuthTokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  SupabaseClient get _supabase => Supabase.instance.client;

  Session? get currentSession => _supabase.auth.currentSession;
  String? get currentPhone => currentSession?.user.phone;

  Future<void> requestOtp(String phone) async {
    await _supabase.auth.signInWithOtp(phone: phone);
  }

  Future<void> signInWithPassword({
    required String phone,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
    final session = response.session ?? _supabase.auth.currentSession;
    if (session == null) {
      throw StateError('Session missing after sign in.');
    }
    await _tokenStorage.save(session.accessToken);
    await _apiClient.get(FlatmatesEndpoints.me);
  }

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: kGoogleWebClientId,
      scopes: ['openid', 'email', 'profile'],
    );

    final GoogleSignInAccount? account;
    try {
      account = await googleSignIn.signIn();
    } on PlatformException catch (e) {
      if (e.code == 'network_error' || e.code == 'internal_error') {
        throw StateError('Google Sign-In is not available. Please try again.');
      }
      rethrow;
    }

    if (account == null) {
      return;
    }

    final GoogleSignInAuthentication auth;
    try {
      auth = await account.authentication;
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        throw StateError('Network error during Google Sign-In. Please try again.');
      }
      rethrow;
    }

    final idToken = auth.idToken;
    if (idToken == null) {
      throw StateError('Google Sign-In failed: missing ID token.');
    }

    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    final session = response.session ?? _supabase.auth.currentSession;
    if (session == null) {
      throw StateError('Session missing after Google sign in.');
    }
    await _tokenStorage.save(session.accessToken);
    await _apiClient.get(FlatmatesEndpoints.me);
  }

  Future<void> signUpWithPassword({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    final response = await _supabase.auth.signUp(
      phone: phone,
      password: password,
      data: {
        'full_name': fullName,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      },
    );
    final session = response.session ?? _supabase.auth.currentSession;
    if (session != null) {
      await _tokenStorage.save(session.accessToken);
      await _apiClient.get(FlatmatesEndpoints.me);
    }
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    final response = await _supabase.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
    final session = response.session ?? _supabase.auth.currentSession;
    if (session == null) {
      throw StateError('Session missing after OTP verification.');
    }
    await _tokenStorage.save(session.accessToken);
    await _apiClient.get(FlatmatesEndpoints.me);
  }

  Future<void> sendPasswordResetOtp(String phone) async {
    await _supabase.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
  }

  Future<void> verifyPasswordResetOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _supabase.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
    final session = response.session ?? _supabase.auth.currentSession;
    if (session == null) {
      throw StateError(
        'Session missing after password reset OTP verification.',
      );
    }
    await _tokenStorage.save(session.accessToken);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _tokenStorage.clear();
  }

  Future<void> changePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
