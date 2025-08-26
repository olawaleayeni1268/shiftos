// lib/src/core/supa.dart
// PURPOSE: single seam for all Supabase calls used by your UI.

import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static SupabaseClient get c => Supabase.instance.client;

  static Future<void> init() async {
    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
      'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
    );

    // Newer supabase_flutter automatically persists/refreshes session on web.
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static Future<void> signUp(String email, String password) =>
      c.auth.signUp(email: email, password: password);

  static Future<void> signIn(String email, String password) =>
      c.auth.signInWithPassword(email: email, password: password);

  static Future<void> resetPassword(String email, {required String redirectTo}) =>
      c.auth.resetPasswordForEmail(email, redirectTo: redirectTo);

  static Future<void> updatePassword(String newPassword) =>
      c.auth.updateUser(UserAttributes(password: newPassword));

  static Future<Map<String, dynamic>?> upsertTodayShift(String? win) async {
    final res = await c.rpc('upsert_today_shift', params: {'p_win': win});
    if (res == null) return null;
    if (res is Map<String, dynamic>) return res;
    return Map<String, dynamic>.from(res as dynamic);
  }
}
