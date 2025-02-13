import 'package:flutter/material.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Treningi")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Tu dodamy logikę zapisywania treningów
          },
          child: const Text("Dodaj trening"),
        ),
      ),
    );
  }
}
