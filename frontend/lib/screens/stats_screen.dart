import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Tutaj przechowujemy listę ćwiczeń
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/exercises'));
      // Uwaga: jeśli uruchamiasz na Android emulatorze, zamień 127.0.0.1 na 10.0.2.2

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Oczekujemy listy obiektów JSON
        if (data is List) {
          // data to np. [{"id":1,"exercise":"Bench_press","max_value":180}, ...]
          setState(() {
            _exercises = data.map<Map<String, dynamic>>((item) {
              return {
                "id": item["id"],
                "exercise": item["exercise"],
                "max_value": item["max_value"],
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Niepoprawny format odpowiedzi (spodziewano listy)';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Błąd połączenia. Kod odpowiedzi: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Wystąpił wyjątek: $e';
        _isLoading = false;
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
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage.isNotEmpty
                ? Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  )
                : ListView.builder(
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      final name = exercise['exercise'] ?? 'n/d';
                      final maxValue = exercise['max_value']?.toString() ?? 'n/d';
                      return ListTile(
                        title: Text(name),
                        subtitle: Text('1RM: $maxValue kg'),
                      );
                    },
                  ),
      ),
    );
  }
}
