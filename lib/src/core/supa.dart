import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  /// Initialize Supabase from --dart-define values
  static Future<void> init() async {
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY');
    }
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Preferred accessor
  static SupabaseClient get client => Supabase.instance.client;

  /// 🔁 Back-compat alias so existing code `Supa.c...` still compiles
  static SupabaseClient get c => Supabase.instance.client;

  static Session? get session => client.auth.currentSession;

  static Future<void> signUp(String email, String password) async {
    await client.auth.signUp(email: email, password: password);
  }

  static Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  /// Reset password.
  /// - If a redirect is provided (old callsite), use it.
  /// - Else: on web use current origin; on mobile use app scheme.
  static Future<void> resetPassword(String email, {String? redirectTo}) async {
    final redirect = redirectTo ?? (kIsWeb ? Uri.base.origin : 'shiftos://auth-callback');
    await client.auth.resetPasswordForEmail(email, redirectTo: redirect);
  }

  static Future<void> updatePassword(String newPassword) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<void> signOut() => client.auth.signOut();

  /// Accepts nullable and safely coalesces to empty string
  static Future<void> upsertTodayShift(String? win) async {
    final value = (win ?? '').trim();
    await client.rpc('upsert_today_shift', params: {'p_win': value});
  }
}
