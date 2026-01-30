import 'package:flutter/material.dart';
import 'features/auth/pages/auth_gate.dart';

void main() {
  runApp(const WordSprintApp());
}

class WordSprintApp extends StatelessWidget {
  const WordSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordSprint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
