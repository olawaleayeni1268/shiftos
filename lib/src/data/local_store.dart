import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _kStreak = 'streak';
  static const _kLastWin = 'lastWin';
  static const _kLastShiftIso = 'lastShiftIso'; // ISO-8601 date

  final SharedPreferences _prefs;
  LocalStore._(this._prefs);

  static Future<LocalStore> make() async {
    final p = await SharedPreferences.getInstance();
    return LocalStore._(p);
  }

  int getStreak() => _prefs.getInt(_kStreak) ?? 0;
  String? getLastWin() => _prefs.getString(_kLastWin);
  DateTime? getLastShiftDate() {
    final s = _prefs.getString(_kLastShiftIso);
    return (s == null) ? null : DateTime.tryParse(s);
  }

  Future<void> setStreak(int v) async => _prefs.setInt(_kStreak, v);
  Future<void> setLastWin(String? v) async {
    if (v == null || v.isEmpty) {
      await _prefs.remove(_kLastWin);
    } else {
      await _prefs.setString(_kLastWin, v);
    }
  }
  Future<void> setLastShiftDate(DateTime d) async =>
      _prefs.setString(_kLastShiftIso, d.toIso8601String());

  Future<void> resetAll() async {
    await _prefs.remove(_kStreak);
    await _prefs.remove(_kLastWin);
    await _prefs.remove(_kLastShiftIso);
  }
}
