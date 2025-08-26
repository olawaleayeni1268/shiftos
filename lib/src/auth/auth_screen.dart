import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  bool _busy = false;
  String? _msg;

  String get _redirect {
    // Web uses fixed port; mobile uses app scheme.
    return kIsWeb ? 'http://localhost:5555' : 'shiftos://auth-callback';
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this); // Create / Sign in / Forgot
  }

  @override
  void dispose() {
    _tab.dispose();
    _email.dispose();
    _pwd.dispose();
    _pwd2.dispose();
    super.dispose();
  }

  Future<void> _withBusy(Future<void> Function() fn) async {
    setState(() { _busy = true; _msg = null; });
    try {
      await fn();
    } on AuthApiException catch (e) {
      if (e.statusCode == 429) {
        setState(() => _msg = 'Too many requests. Wait ~60s, then try again.');
      } else {
        setState(() => _msg = e.message ?? 'Authentication error.');
      }
    } catch (e) {
      setState(() => _msg = 'Error: $e');
    } finally {
      setState(() { _busy = false; });
    }
  }

  Future<void> _createAccount() async {
    await _withBusy(() async {
      final email = _email.text.trim();
      final p1 = _pwd.text.trim();
      final p2 = _pwd2.text.trim();
      if (p1 != p2) {
        setState(() => _msg = 'Passwords do not match.');
        return;
      }
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: p1,
        emailRedirectTo: _redirect, // returns here after confirm
      );
      setState(() => _msg = 'Confirmation email sent. Open it and click the link to finish sign-up, then come back here and Sign in.');
    });
  }

  Future<void> _signInPassword() async {
    await _withBusy(() async {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _pwd.text.trim(),
      );
      setState(() => _msg = 'Signed in.');
    });
  }

  Future<void> _forgotPassword() async {
    await _withBusy(() async {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _email.text.trim(),
        redirectTo: _redirect,
      );
      setState(() => _msg = 'Reset link sent. Open it, return here, and set a new password.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in to ShiftOS')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TabBar(
                  controller: _tab,
                  tabs: const [
                    Tab(text: 'Create Account'),
                    Tab(text: 'Sign In'),
                    Tab(text: 'Forgot Password'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _createTab(),
                      _signInTab(),
                      _forgotTab(),
                    ],
                  ),
                ),
                if (_msg != null) ...[
                  const SizedBox(height: 8),
                  Text(_msg!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.teal)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createTab() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Email'),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 12),
        const Text('Password'),
        TextField(controller: _pwd, obscureText: true),
        const SizedBox(height: 12),
        const Text('Confirm Password'),
        TextField(controller: _pwd2, obscureText: true),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _createAccount,
          child: _busy ? const CircularProgressIndicator() : const Text('Create account'),
        ),
        const SizedBox(height: 8),
        const Text(
          'You must confirm your email. Check your inbox after creating the account.',
          style: TextStyle(fontSize: 12),
        ),
      ]),
    );
  }

  Widget _signInTab() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Email'),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 12),
        const Text('Password'),
        TextField(controller: _pwd, obscureText: true),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _signInPassword,
          child: _busy ? const CircularProgressIndicator() : const Text('Sign in'),
        ),
        const SizedBox(height: 8),
        const Text(
          'If you see “Email not confirmed”, open the confirmation email first, then sign in.',
          style: TextStyle(fontSize: 12),
        ),
      ]),
    );
  }

  Widget _forgotTab() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Email'),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _forgotPassword,
          child: _busy ? const CircularProgressIndicator() : const Text('Send reset link'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Click the link in the email. When you return, the app will ask for a new password.',
          style: TextStyle(fontSize: 12),
        ),
      ]),
    );
  }
}
