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
      List<Map<String, dynamic>> exercises = await _apiService.fetchExercises();
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
                      return ListTile(
                        title: Text(exercise['exercise'] ?? 'n/d'),
                        subtitle: Text('1RM: ${exercise['max_value'] ?? 'n/d'} kg'),
                      );
                    },
                  ),
      ),
    );
  }
}
