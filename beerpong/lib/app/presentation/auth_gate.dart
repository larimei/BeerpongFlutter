import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/app_state_store.dart';
import 'bootstrap_app.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _useGuestMode = false;

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    initialData: AuthState(
      AuthChangeEvent.initialSession,
      Supabase.instance.client.auth.currentSession,
    ),
    builder: (context, snapshot) {
      if (snapshot.data?.session != null) {
        return BootstrapApp(
          store: SupabaseAppStateStore(Supabase.instance.client),
          onSignOut: Supabase.instance.client.auth.signOut,
        );
      }
      if (_useGuestMode) {
        return BootstrapApp(
          store: const BrowserAppStateStore(),
          onOpenLogin: () => setState(() => _useGuestMode = false),
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(
          onUseGuestMode: () => setState(() => _useGuestMode = true),
        ),
      );
    },
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onUseGuestMode});

  final VoidCallback onUseGuestMode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _invitation = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _invitation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _username.text.trim().toLowerCase();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_register) {
        await Supabase.instance.client.functions.invoke(
          'register-with-invite',
          body: {
            'username': username,
            'password': _password.text,
            'invitationCode': _invitation.text,
          },
        );
        if (!mounted) return;
        setState(() {
          _register = false;
          _error = 'Account created. Please sign in.';
        });
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: '$username@users.invalid',
          password: _password.text,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } on FunctionException catch (error) {
      if (mounted) {
        setState(
          () => _error =
              error.details?.toString() ??
              error.reasonPhrase ??
              'Registration failed.',
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Request failed.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmGuestMode() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue as guest?'),
        content: const Text(
          'Your data is stored only in this browser. If you switch browsers '
          'or clear this browser\'s website data, it will be lost. Sign in to '
          'store your data safely in an account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue anyway'),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) widget.onUseGuestMode();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _register ? 'Create account' : 'Sign in',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              if (_register)
                TextField(
                  controller: _invitation,
                  decoration: const InputDecoration(
                    labelText: 'Invitation code',
                  ),
                ),
              TextField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Passwort'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_register ? 'Register' : 'Sign in'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _register = !_register;
                        _error = null;
                      }),
                child: Text(
                  _register
                      ? 'I already have an account'
                      : 'Create an account with an invitation',
                ),
              ),
              TextButton(
                onPressed: _busy ? null : _confirmGuestMode,
                child: const Text('Continue without an account'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
