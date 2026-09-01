import 'package:flutter/material.dart';

import '../app.dart';
import '../data/app_state_store.dart';

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  final _store = BrowserAppStateStore();
  late final Future<AppSnapshot> _snapshot = _store.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSnapshot>(
      future: _snapshot,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return BeerpongApp(snapshot: snapshot.data!, store: _store);
      },
    );
  }
}
