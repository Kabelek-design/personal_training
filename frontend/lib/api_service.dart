import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiService {



  Future<List<Map<String, dynamic>>> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL$EXERCISES_ENDPOINT'));

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
        throw Exception('Błąd połączenia. Kod odpowiedzi: ${response.statusCode}');
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
  // Jeśli wszystko ok, możesz np. zwrócić response lub przerobić go na obiekt
}

}
