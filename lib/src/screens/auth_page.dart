// lib/src/screens/auth_page.dart
// PURPOSE: email-only Auth screen that calls Supabase via Supa.
// NOTE: redirectUrl() uses the current page origin (works for localhost or LAN IP).

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supa.dart';

// Use the exact origin where the app is opened (e.g., http://localhost:5555 or http://192.168.x.y:5555)
String redirectUrl() => Uri.base.origin;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSigningIn = true;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_isSigningIn ? 'Sign in' : 'Create account',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : () async {
                      setState(() => _busy = true);
                      try {
                        if (_isSigningIn) {
                          await Supa.signIn(_email.text.trim(), _password.text);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in.')));
                        } else {
                          await Supa.signUp(_email.text.trim(), _password.text);
                          if (!mounted) return;
                          // Confirmation email will use Supabase "Site URL" setting.
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your inbox to confirm your email.')));
                        }
                        setState(() {});
                      } on AuthException catch (e) {
                        _err(e.message);
                      } catch (e) {
                        _err(e.toString());
                      } finally {
                        setState(() => _busy = false);
                      }
                    },
                    child: Text(_isSigningIn ? 'Sign in' : 'Sign up'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _busy ? null : () => setState(() => _isSigningIn = !_isSigningIn),
                        child: Text(_isSigningIn ? 'Create account' : 'Have an account? Sign in'),
                      ),
                      TextButton(
                        onPressed: _busy ? null : () async {
                          try {
                            await Supa.resetPassword(_email.text.trim(), redirectTo: redirectUrl());
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
                          } on AuthException catch (e) {
                            _err(e.message);
                          } catch (e) {
                            _err(e.toString());
                          }
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}
