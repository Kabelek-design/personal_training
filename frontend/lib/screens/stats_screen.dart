import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _backendMessage = 'Ładowanie...';

  @override
  void initState() {
    super.initState();
    _fetchMessage();
  }

  Future<void> _fetchMessage() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _backendMessage = data['message'] ?? 'Brak pola "message" w odpowiedzi';
        });
      } else {
        setState(() {
          _backendMessage = 'Błąd połączenia: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _backendMessage = 'Wystąpił wyjątek: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statystyki"),
      ),
      body: Center(
        child: Text(
          _backendMessage,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
