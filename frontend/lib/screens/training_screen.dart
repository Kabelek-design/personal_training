import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/training_data.dart';
import '../models/training_model.dart';
import '../utils/calculate_weights.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int selectedWeek = 1;
  late Box trainingBox;

  final Map<String, TextEditingController> oneRepMaxControllers = {};
  final Map<String, TextEditingController> amrapControllers = {};
  Map<String, double> oneRepMaxes = {
    "Przysiady": 100,
    "Martwy ciąg": 120,
    "Wyciskanie leżąc": 80,
  };

  @override
  void initState() {
    super.initState();
    trainingBox = Hive.box('training_data');
    _loadData();
  }

  void _loadData() {
    // Wczytywanie 1RM z bazy
    for (var exercise in oneRepMaxes.keys) {
      double value = trainingBox.get(exercise,
          defaultValue: oneRepMaxes[exercise]) as double;
      oneRepMaxes[exercise] = value;
      oneRepMaxControllers[exercise] =
          TextEditingController(text: value.toStringAsFixed(1));
    }

    // Wczytywanie wyników AMRAP z bazy
    for (var plan in trainingPlans) {
      for (var exercise in plan.exercises) {
        for (var set in exercise.sets) {
          if (set.isAMRAP) {
            String key = "${exercise.name}_${set.percentage}";
            int savedReps = trainingBox.get(key, defaultValue: 0) as int;
            amrapControllers[key] = TextEditingController(
              text: savedReps > 0 ? savedReps.toString() : "",
            );
          }
        }
      }
    }
  }

  void _saveOneRepMax(String exercise, String value) {
    double parsedValue = double.tryParse(value) ?? oneRepMaxes[exercise]!;
    setState(() {
      oneRepMaxes[exercise] = parsedValue;
      trainingBox.put(exercise, parsedValue);
    });
  }

  void _saveAmrapReps(String key, String value) {
    int reps = int.tryParse(value) ?? 0;
    trainingBox.put(key, reps);
  }

  /// Metoda obliczająca progresję TYLKO dla jednej serii (jednego ćwiczenia i procentu).
  /// Wywołujesz ją z małego przycisku obok TextFielda.
  void _calculateProgressionForSet(
    String exerciseName,
    double percentage,
    int? recommendedReps,
  ) {
    // Jeśli nie mamy rekomendowanych powtórzeń, to nic nie robimy.
    if (recommendedReps == null) return;

    // Odczytujemy liczbę powtórzeń z bazy (AMRAP).
    final String key = "${exerciseName}_$percentage";
    int userReps = trainingBox.get(key, defaultValue: 0) as int;

    // Jeśli użytkownik zrobił >= recommendedReps, zwiększamy ciężar na następny tydzień.
    if (userReps >= recommendedReps) {
      double increment = 0;
      if (exerciseName == "Przysiady" || exerciseName == "Martwy ciąg") {
        increment = 5.0;
      } else if (exerciseName == "Wyciskanie leżąc") {
        increment = 2.5;
      }
      // Można tu wywołać np. metodę aktualizującą "next_week_plan_2", "next_week_plan_3", itd.
      _updateNextWeekWeightForExercise(exerciseName, increment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Zwiększono ciężar dla $exerciseName o $increment kg!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nie osiągnięto wymaganej liczby powtórzeń.")),
      );
    }
  }

  /// Przykładowa metoda aktualizująca plan na następny tydzień (lub 1RM) dla konkretnego ćwiczenia.
  void _updateNextWeekWeightForExercise(String exerciseName, double increment) {
    int nextWeek = selectedWeek + 1;
    if (nextWeek > 3) return; // jeśli mamy tylko 3 tygodnie

    // W tym przykładzie kluczem jest "next_week_plan_$nextWeek".
    // Możesz przechowywać tam obiekt TrainingPlan lub np. same 1RM.
    TrainingPlan? nextPlan = trainingBox.get("next_week_plan_$nextWeek");

    // Jeśli jeszcze nie ma planu na kolejny tydzień, utwórz pusty.
    if (nextPlan == null) {
      nextPlan = TrainingPlan(week: nextWeek, exercises: []);
    }

    // Tutaj przykładowo podnosimy w bazie 1RM na następny tydzień,
    // albo dopisujemy "dodatkowe" kg do planu nextPlan.
    double currentOneRm = oneRepMaxes[exerciseName] ?? 0;
    double newOneRm = currentOneRm + increment;

    // Możesz zapisywać to w:
    // 1) nextPlan (jeśli masz taką strukturę) albo
    // 2) bezpośrednio w trainingBox (osobny klucz np. "exerciseName_nextWeek_1rm"),
    // 3) ustawiać w mapie oneRepMaxes, itp.

    // Przykładowo: zapisz do Hive, żebyś mógł to potem wczytać jako startowy 1RM na kolejny tydzień.
    trainingBox.put("${exerciseName}_1rm_week_$nextWeek", newOneRm);

    // Zaktualizuj i zapisz plan.
    trainingBox.put("next_week_plan_$nextWeek", nextPlan);
  }

  @override
  void dispose() {
    oneRepMaxControllers.values.forEach((controller) => controller.dispose());
    amrapControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TrainingPlan currentPlan =
        trainingPlans.firstWhere((plan) => plan.week == selectedWeek);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Twój plan treningowy"),
        actions: [
          DropdownButton<int>(
            value: selectedWeek,
            items: [1, 2, 3].map((week) {
              return DropdownMenuItem(
                value: week,
                child: Text("Tydzień $week"),
              );
            }).toList(),
            onChanged: (week) {
              if (week != null) {
                setState(() {
                  selectedWeek = week;
                });
              }
            },
          ),
        ],
      ),
      // USUWAMY floatingActionButton - nie będzie globalnego przycisku
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _calculateProgression,
      //   tooltip: "Oblicz progresję",
      //   child: const Icon(Icons.calculate),
      // ),
      body: Column(
        children: [
          // Pola do edycji 1RM
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: oneRepMaxes.keys.map((exerciseName) {
                return TextField(
                  controller: oneRepMaxControllers[exerciseName],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "1RM dla $exerciseName (kg)",
                  ),
                  onChanged: (value) => _saveOneRepMax(exerciseName, value),
                );
              }).toList(),
            ),
          ),
          // Lista ćwiczeń na wybrany tydzień
          Expanded(
            child: ListView.builder(
              itemCount: currentPlan.exercises.length,
              itemBuilder: (context, index) {
                final exercise = currentPlan.exercises[index];
                double oneRepMax = oneRepMaxes[exercise.name] ?? 100;
                // Oblicz zaktualizowane serie
                List<TrainingSet> updatedSets =
                    calculateWeights(exercise.sets, oneRepMax);

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: updatedSets.map((set) {
                      String key = "${exercise.name}_${set.percentage}";
                      if (set.isAMRAP && !amrapControllers.containsKey(key)) {
                        amrapControllers[key] = TextEditingController();
                      }

                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              "${set.reps} powtórzeń - ${set.percentage}% maksymalnego ciężaru",
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              "Ciężar: ${set.weight?.toStringAsFixed(1)} kg",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (set.isAMRAP) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "SERIA +",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Zalecane powtórzenia: ${set.recommendedReps}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: amrapControllers[key],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: "0",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: 5,
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          _saveAmrapReps(key, value),
                                    ),
                                  ),
                                  // DODAJEMY IKONKĘ, która liczy progresję TYLKO dla tej serii.
                                  IconButton(
                                    icon: const Icon(Icons.calculate),
                                    onPressed: () {
                                      _calculateProgressionForSet(
                                        exercise.name,
                                        set.percentage ?? 0,
                                        set.recommendedReps,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
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
