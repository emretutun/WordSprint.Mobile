import 'package:flutter/material.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn New Words")),
      body: const Center(
        child: Text("Learning Page (next step)"),
      ),
    );
  }
}
