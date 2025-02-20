import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_training/models/training_model.dart';
import 'constants.dart';

class ApiService {
// Funkcje dla ćwiczeń one rep max

  Future<List<Map<String, dynamic>>> fetchExercises() async {
    try {
      final response =
          await http.get(Uri.parse('$BASE_URL$EXERCISES_ENDPOINT'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map<Map<String, dynamic>>((item) {
            return {
              "id": item["id"],
              "exercise": item["exercise"],
              "max_value": item["max_value"],
            };
          }).toList();
        } else {
          throw Exception('Niepoprawny format odpowiedzi (spodziewano listy)');
        }
      } else {
        throw Exception(
            'Błąd połączenia. Kod odpowiedzi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Wystąpił wyjątek: $e');
    }
  }

  Future<void> addExercise(String name, int maxValue) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/exercises'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "exercise": name,
        "max_value": maxValue,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Błąd: ${response.statusCode}, treść: ${response.body}');
    }
  }

  Future<void> updateExercise(int exerciseId, int newValue) async {
    final url = Uri.parse('$BASE_URL/exercises/$exerciseId');
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"max_value": newValue}),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Update error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteExercise(int exerciseId) async {
    final url = Uri.parse('$BASE_URL/exercises/$exerciseId');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception(
          'Delete error: ${response.statusCode} - ${response.body}');
    }
  }


  /// GET: Pobiera wszystkie tygodnie treningowe
  Future<List<TrainingPlan>> fetchTrainingPlans() async {
    final response = await http.get(Uri.parse('$BASE_URL/training/plans'));
    if (response.statusCode == 200) {
      // final decodedJson = utf8.decode(response.bodyBytes); // 🔥 Dekodowanie UTF-8
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TrainingPlan.fromJson(json)).toList();
    } else {
      throw Exception('Nie udało się pobrać planu treningowego');
    }
  }

  /// GET: Pobiera plan treningowy dla konkretnego tygodnia
  Future<TrainingPlan> fetchTrainingPlanByWeek(int week) async {
    final response = await http.get(Uri.parse('$BASE_URL/training/plans/$week'));
    if (response.statusCode == 200) {
      return TrainingPlan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Nie udało się pobrać planu dla tygodnia $week');
    }
  }

  Future<void> patchAddWeight({
    required int weekNumber,
    required String exerciseName,
    required int actualReps,
    double addKg = 5.0,
  }) async {
    final url = Uri.parse(
        '$BASE_URL/training/week/$weekNumber/exercise/$exerciseName/add_weight?actual_reps=$actualReps&add_kg=$addKg');
    final response = await http.patch(url);
    if (response.statusCode != 200) {
      throw Exception('Aktualizacja ciężaru dla ćwiczenia $exerciseName nie powiodła się');
    }
  }
}
