import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      debugPrint('AuthService: Attempting sign up for $email');
      final response = await _client.auth.signUp(email: email, password: password);
      debugPrint('AuthService: Sign up successful for ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('AuthService: AuthException during sign up: ${e.message} (Status: ${e.statusCode})');
      rethrow;
    } catch (e) {
      debugPrint('AuthService: Unexpected error during sign up: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  bool get isAuthenticated => _client.auth.currentSession != null;
}
