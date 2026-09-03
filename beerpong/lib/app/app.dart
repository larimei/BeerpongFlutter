import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'data/app_state_store.dart';

class BeerpongApp extends StatelessWidget {
  const BeerpongApp({
    super.key,
    this.snapshot = const AppSnapshot.empty(),
    this.store = const BrowserAppStateStore(),
    this.onSignOut,
    this.onOpenLogin,
  });

  final AppSnapshot snapshot;
  final AppStateStore store;
  final Future<void> Function()? onSignOut;
  final VoidCallback? onOpenLogin;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beer Pong Tournaments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 103, 146, 240),
        ),
        useMaterial3: true,
      ),
      home: AppShell(
        snapshot: snapshot,
        store: store,
        onSignOut: onSignOut,
        onOpenLogin: onOpenLogin,
      ),
    );
  }
}
