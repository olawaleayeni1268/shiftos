import 'package:flutter/material.dart';
import '../data/local_store.dart';
import '../core/supa.dart'; // 🔧 call RPC when completing a shift

class AppState extends ChangeNotifier {
  int _streak = 0;
  DateTime? _lastShiftDate;
  String? _lastWin;
  LocalStore? _store;

  int get streak => _streak;
  String? get lastWin => _lastWin;

  bool get didShiftToday {
    final d = _lastShiftDate;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Future<void> init() async {
    _store = await LocalStore.make();
    try {
      _streak = _store!.getStreak();
    } catch (_) {/* keep default */}
    try {
      _lastWin = _store!.getLastWin();
    } catch (_) {/* keep default */}
    try {
      // if your LocalStore doesn't have this, the try/catch prevents crashes
      _lastShiftDate = _store!.getLastShiftDate();
    } catch (_) {/* keep default */}
    notifyListeners();
  }

  Future<void> completeShift({String? win}) async {
    // 🔧 SUPABASE: write today's row to DB first (secure, 1-per-day upsert)
    try {
      final clean = (win != null && win.trim().isNotEmpty) ? win.trim() : null;
      await Supa.upsertTodayShift(clean);
    } catch (_) {
      // If the network/DB write fails, still update local UI so flow feels smooth.
      // You can show a snackbar in the caller if desired.
    }

    // ⬇️ Existing local streak logic (kept intact)
    final now = DateTime.now();
    if (!didShiftToday) {
      if (_lastShiftDate != null) {
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final l = _lastShiftDate!;
        final wasYesterday = l.year == yesterday.year && l.month == yesterday.month && l.day == yesterday.day;
        _streak = wasYesterday ? _streak + 1 : 1;
      } else {
        _streak = 1;
      }
    }
    _lastShiftDate = now;
    if (win != null && win.trim().isNotEmpty) {
      _lastWin = win.trim();
    }

    await _persist();
    notifyListeners();
  }

  Future<void> resetAll() async {
    _streak = 0;
    _lastShiftDate = null;
    _lastWin = null;
    await _store?.resetAll();
    notifyListeners();
  }

  Future<void> _persist() async {
    final s = _store;
    if (s == null) return;
    await s.setStreak(_streak);
    await s.setLastWin(_lastWin);
    if (_lastShiftDate != null) {
      await s.setLastShiftDate(_lastShiftDate!);
    }
  }
}
