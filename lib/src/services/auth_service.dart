import 'package:supabase_flutter/supabase_flutter.dart';

/// Owns Supabase Auth operations and the current tenant identity.
class AuthService {
  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Initializes Supabase once, before constructing [AuthService].
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabasePublishableKey,
  }) {
    return Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  /// Registers a user with email and password.
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await _client.auth.signUp(email: email.trim(), password: password);
    } on AuthException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AuthServiceException('Unable to sign up', error),
        stackTrace,
      );
    }
  }

  /// Signs in an existing user with email and password.
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AuthServiceException('Unable to sign in', error),
        stackTrace,
      );
    }
  }

  /// Ends the current Supabase session.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AuthServiceException('Unable to sign out', error),
        stackTrace,
      );
    }
  }

  /// Returns the authenticated user's immutable Supabase ID.
  ///
  /// Throws rather than returning an empty string, preventing unauthenticated
  /// code from accidentally issuing a tenant-less request.
  String get currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null || id.isEmpty) {
      throw StateError('An authenticated user is required for this operation.');
    }
    return id;
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message, this.cause);

  final String message;
  final Object cause;

  @override
  String toString() => '$message: $cause';
}
