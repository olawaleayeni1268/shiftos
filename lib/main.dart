import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/theme/app_theme.dart';
import 'src/core/app_links.dart';          // mentorName, mentorChatUrl (already in your project)
import 'src/state/app_state.dart';
import 'src/screens/home_screen.dart';     // HomeTab (with callbacks)
import 'src/screens/shift_screen.dart';    // ShiftTab
import 'src/screens/settings_screen.dart'; // SettingsTab
import 'src/screens/mentor_screen.dart';   // openMentor(context)
import 'src/core/supa.dart';               // 🔧 Supabase seam
import 'src/screens/auth_page.dart';       // 🔐 Auth UI (email-only)

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supa.init(); // 🔧 Start Supabase SDK (uses --dart-define keys)
  runApp(const ShiftOSApp());
}

class ShiftOSApp extends StatefulWidget {
  const ShiftOSApp({super.key});
  @override
  State<ShiftOSApp> createState() => _ShiftOSAppState();
}

class _ShiftOSAppState extends State<ShiftOSApp> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supa.c.auth.onAuthStateChange.listen((data) async {
      // 🔔 Handle password recovery deep link
      if (data.event == AuthChangeEvent.passwordRecovery) {
        final ctx = navigatorKey.currentState?.overlay?.context;
        if (ctx != null) {
          final ctrl = TextEditingController();
          final newPass = await showDialog<String>(
            context: ctx,
            builder: (d) => AlertDialog(
              title: const Text('Set New Password'),
              content: TextField(
                controller: ctrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(d, ctrl.text), child: const Text('Update')),
              ],
            ),
          );
          if (newPass != null && newPass.isNotEmpty) {
            await Supa.updatePassword(newPass);
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Password updated. You can now sign in.')),
              );
            }
          }
        }
      }
      setState(() {}); // rebuild to reflect session changes (AuthGate)
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Supa.c.auth.currentSession;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..init()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'ShiftOS',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: session == null ? const AuthPage() : const _RootShell(), // 🔐 Gate: Auth → Dashboard
      ),
    );
  }
}

// === Root shell: your original bottom-nav landing structure ===
class _RootShell extends StatefulWidget {
  const _RootShell({Key? key}) : super(key: key);
  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeTab(
        onStartShift: () => setState(() => _index = 1), // go to Shift tab
        onAddWin: () => setState(() => _index = 1),     // collect win via Shift flow
      ),
      const ShiftTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShiftOS'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await Supa.c.auth.signOut();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out.')));
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openMentor(context), // your existing mentor action
        label: const Text('Open Mentor'),
        icon: const Icon(Icons.chat_bubble_outline),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Shift',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
