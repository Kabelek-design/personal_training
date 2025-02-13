import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statystyki")),
      body: Center(
        child: const Text("Tu będą wykresy postępów!"),
      ),
    );
  }
}
