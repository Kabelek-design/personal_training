import 'package:flutter/material.dart';
import 'package:personal_training/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _apiService.fetchExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Funkcja do dodawania nowego ćwiczenia
  Future<void> _addNewExercise() async {
    final TextEditingController exerciseCtrl = TextEditingController();
    final TextEditingController maxValueCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj nowe ćwiczenie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exerciseCtrl,
                decoration: const InputDecoration(labelText: 'Nazwa ćwiczenia'),
              ),
              TextField(
                controller: maxValueCtrl,
                decoration: const InputDecoration(labelText: 'Maksymalny ciężar (kg)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () async {
                final name = exerciseCtrl.text.trim();
                final maxText = maxValueCtrl.text.trim();
                if (name.isNotEmpty && maxText.isNotEmpty) {
                  final maxVal = int.tryParse(maxText) ?? 0;
                  try {
                    await _apiService.addExercise(name, maxVal);
                    Navigator.pop(context);
                    _loadExercises(); // Odśwież listę po dodaniu
                  } catch (e) {
                    setState(() => _errorMessage = e.toString());
                  }
                }
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  // Funkcja do usuwania ćwiczenia
  Future<void> _deleteExercise(int id) async {
    try {
      await _apiService.deleteExercise(id);
      _loadExercises(); // Odświeżenie po usunięciu
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  // Funkcja do aktualizacji max_value ćwiczenia
  Future<void> _editExercise(int id, String name, int currentValue) async {
    final TextEditingController maxValueCtrl = TextEditingController(text: currentValue.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edytuj $name'),
          content: TextField(
            controller: maxValueCtrl,
            decoration: const InputDecoration(labelText: 'Nowy max (kg)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final maxText = maxValueCtrl.text.trim();
                if (maxText.isNotEmpty) {
                  final maxVal = int.tryParse(maxText) ?? 0;
                  try {
                    await _apiService.updateExercise(id, maxVal);
                    Navigator.pop(context);
                    _loadExercises(); // Odśwież listę po edycji
                  } catch (e) {
                    setState(() => _errorMessage = e.toString());
                  }
                }
              },
              child: const Text('Zapisz'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statystyki")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage.isNotEmpty
                ? Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16))
                : ListView.builder(
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Card(
                          child: ListTile(
                            title: Text(
                              exercise['exercise'] ?? 'n/d',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              '1RM: ${exercise['max_value'] ?? 'n/d'} kg',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editExercise(
                                    exercise['id'],
                                    exercise['exercise'],
                                    exercise['max_value'],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteExercise(exercise['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}
