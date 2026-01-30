import 'package:flutter/material.dart';

class RepeatPage extends StatelessWidget {
  const RepeatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Repeat")),
      body: const Center(
        child: Text("Repeat Page (next step)"),
      ),
    );
  }
}
