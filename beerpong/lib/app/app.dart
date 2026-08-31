import 'package:flutter/material.dart';

import 'app_shell.dart';

class BeerpongApp extends StatelessWidget {
  const BeerpongApp({super.key});

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
      home: const AppShell(),
    );
  }
}
