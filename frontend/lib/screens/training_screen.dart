import 'package:flutter/material.dart';
import '../models/training_model.dart';
import '../utils/calculate_weights.dart';
import '../api_service.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int selectedWeek = 1;
  final ApiService _apiService = ApiService(); // API do pobierania danych

  TrainingPlan? _currentPlan; // Aktualny plan treningowy pobrany z backendu
  Map<String, double> oneRepMaxes = {}; // Przechowuje 1RM pobrane z backendu
  bool _isLoading = true;
  String _errorMessage = '';

  // Mapowanie nazw ćwiczeń (API -> Frontend)
  Map<String, String> nameMappingOneRepMax = {
    "Przysiady": "Squats",
    "Martwy ciąg": "Dead_lift",
    "Wyciskanie leżąc": "Bench_press",
  };

  Map<String, String> nameMappingTrainingPlan = {
  "squats": "Przysiady",
  "dead_lift": "Martwy ciąg",
  "bench_press": "Wyciskanie leżąc",
};


  // Kontrolery do wpisania faktycznych powtórzeń w serii plus
  Map<String, TextEditingController> plusControllers = {};

  @override
  void initState() {
    super.initState();
    _loadOneRepMaxes();
    _loadTrainingPlan();
  }

  /// Pobiera dane o 1RM z backendu i mapuje je na odpowiednie nazwy.
  Future<void> _loadOneRepMaxes() async {
    try {
      final exercises = await _apiService.fetchExercises();

      // Zbuduj mapę, np. "Bench_press" -> 180.0
      Map<String, double> fetchedMaxes = {
        for (var ex in exercises)
          ex['exercise']: (ex['max_value'] as num).toDouble()
      };

      setState(() {
        oneRepMaxes = fetchedMaxes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd pobierania 1RM: $e';
      });
    }
  }

  /// Pobiera plan treningowy dla wybranego tygodnia z backendu.
  Future<void> _loadTrainingPlan() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final plan = await _apiService.fetchTrainingPlanByWeek(selectedWeek);
      setState(() {
        _currentPlan = plan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd ładowania planu treningowego: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jeśli trwa ładowanie lub plan jeszcze nie został pobrany, pokaż loader
    if (_isLoading || _currentPlan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Twój plan treningowy"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentPlan = _currentPlan!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Twój plan treningowy"),
        actions: [
          // Wybór tygodnia w AppBar
          DropdownButton<int>(
            value: selectedWeek,
            items: [1, 2, 3, 4, 5, 6].map((week) {
              return DropdownMenuItem(
                value: week,
                child: Text("Tydzień $week"),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedWeek = val;
                });
                _loadTrainingPlan(); // Załaduj plan dla nowego tygodnia
              }
            },
          ),
        ],
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : Column(
              children: [
                // =======================
                // SEKCJA 1RM (Karty)
                // =======================
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Ustal ilość kart w rzędzie
                      int crossAxisCount = 3;
                      if (constraints.maxWidth < 600) {
                        crossAxisCount = 2;
                      }
                      if (constraints.maxWidth < 400) {
                        crossAxisCount = 1;
                      }

                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: oneRepMaxes.keys.map((exerciseKey) {
                          // Odszukaj nazwę frontową, np. "Przysiady"
                          String displayName = nameMappingOneRepMax.entries
                              .firstWhere(
                                (entry) => entry.value == exerciseKey,
                                orElse: () =>
                                    MapEntry(exerciseKey, exerciseKey),
                              )
                              .key;

                          // Oblicz szerokość karty
                          double cardWidth =
                              constraints.maxWidth / crossAxisCount - 12;

                          return SizedBox(
                            width: cardWidth,
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.blue.shade50,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${oneRepMaxes[exerciseKey]?.toStringAsFixed(1) ?? '-'} kg",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                // =======================
                // LISTA ĆWICZEŃ (Tygodniowa)
                // =======================
                Expanded(
                  child: ListView.builder(
                    itemCount: currentPlan.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = currentPlan.exercises[index];

                      // Mapujemy nazwę ćwiczenia (np. "Przysiady" -> "Squats")
                      String apiName =
                          nameMappingTrainingPlan[exercise.name] ?? exercise.name;
                      double oneRepMax = oneRepMaxes[apiName] ?? 100;

                      // Obliczamy serie – calculateWeights powinno przyjmować listę setów
                      // i na podstawie oneRepMax (pobranej z backendu) oraz procentu (percentage)
                      // obliczyć właściwy ciężar, np.: weight = oneRepMax * (set.percentage / 100) + increment
                      List<TrainingSet> updatedSets =
                          calculateWeights(exercise.sets, oneRepMax);

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text(
  apiName, // lub nameMappingTrainingPlan[exercise.name]
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),

                          children: updatedSets.asMap().entries.map((entry) {
                            // entry.key => index serii
                            // entry.value => TrainingSet
                            final i = entry.key;
                            final set = entry.value;

                            // Generujemy klucz do mapy plusControllers
                            String plusKey = "${exercise.name}_$i";

                            // Tworzymy TextEditingController dla serii plus, jeśli go nie ma
                            if (set.isAMRAP &&
                                !plusControllers.containsKey(plusKey)) {
                              plusControllers[plusKey] = TextEditingController();
                            }

                            // Określamy próg powtórzeń – wartość ta może być zdefiniowana według logiki Twojego planu
                            int neededReps = 999;
                            if (set.reps == 6) neededReps = 12;
                            if (set.reps == 4) neededReps = 7;
                            if (set.reps == 2) neededReps = 4;

                            return ListTile(
                              title: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text:
                                          "${set.reps} powtórzeń - ${set.percentage}% maksymalnego ciężaru",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    if (set.isAMRAP)
                                      const TextSpan(
                                        text: " (Seria +)",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                "Ciężar: ${set.weight?.toStringAsFixed(1)} kg",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              // Jeżeli seria plus, daj TextField do wpisania faktycznych powtórzeń
                              trailing: set.isAMRAP
                                  ? SizedBox(
                                      width: 60,
                                      child: TextField(
                                        controller: plusControllers[plusKey],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "Reps",
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (val) {
                                          int repsDone =
                                              int.tryParse(val) ?? 0;

                                          if (repsDone >= neededReps) {
                                            double increment =
                                                exercise.name == "Wyciskanie leżąc"
                                                    ? 2.5
                                                    : 5.0;

                                            double? oldWeight = set.weight;
                                            double newWeight =
                                                (oldWeight ?? 0) + increment;

                                            // Wywołanie metody PATCH na backendzie
                                            _apiService
                                                .patchAddWeight(
                                              weekNumber: selectedWeek,
                                              exerciseName: exercise.name,
                                              actualReps: repsDone,
                                              addKg: increment,
                                            )
                                                .then((_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Przekroczono próg dla ${exercise.name}!\n" +
                                                        "Stary ciężar: ${oldWeight?.toStringAsFixed(1)} kg, " +
                                                        "Zalecany: ${newWeight.toStringAsFixed(1)} kg",
                                                  ),
                                                ),
                                              );
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Błąd aktualizacji: $error'),
                                                ),
                                              );
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
