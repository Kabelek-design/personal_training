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
  Map<String, double> oneRepMaxes = {
    "Przysiady": 100,
    "Martwy ciąg": 120,
    "Wyciskanie leżąc": 80,
  };

  @override
  void initState() {
    super.initState();
    trainingBox = Hive.box('training_data');
    _loadOneRepMax();
  }

  /// 🔹 Wczytywanie zapisanych wartości 1RM
  void _loadOneRepMax() {
    for (var exercise in oneRepMaxes.keys) {
      double value = trainingBox.get(exercise, defaultValue: oneRepMaxes[exercise]) as double;
      oneRepMaxes[exercise] = value;
      oneRepMaxControllers[exercise] = TextEditingController(text: value.toStringAsFixed(1)); // Ustawienie wartości w polach input
    }
  }

  /// 🔹 Zapisywanie wartości 1RM do Hive
  void _saveOneRepMax(String exercise, String value) {
    double parsedValue = double.tryParse(value) ?? oneRepMaxes[exercise]!;
    setState(() {
      oneRepMaxes[exercise] = parsedValue;
      trainingBox.put(exercise, parsedValue);
    });
  }

  @override
  void dispose() {
    oneRepMaxControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TrainingPlan currentPlan = trainingPlans.firstWhere((plan) => plan.week == selectedWeek);

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
      body: Column(
        children: [
          // 🔹 Pola do wpisania 1RM (teraz pamiętają wartości!)
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

          Expanded(
            child: ListView.builder(
              itemCount: currentPlan.exercises.length,
              itemBuilder: (context, index) {
                final exercise = currentPlan.exercises[index];
                double oneRepMax = oneRepMaxes[exercise.name] ?? 100;
                List<TrainingSet> updatedSets = calculateWeights(exercise.sets, oneRepMax);

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    children: updatedSets.map((set) {
                      return ListTile(
                        title: Text("${set.reps} powtórzeń - ${set.percentage}% maksymalnego ciężaru"),
                        subtitle: Text("Ciężar: ${set.weight?.toStringAsFixed(1)} kg"),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _calculateProgression,
        child: const Icon(Icons.calculate),
      ),
    );
  }

  /// 🔹 Obliczanie progresji na podstawie AMRAP
  void _calculateProgression() {
    for (var plan in trainingPlans) {
      for (var exercise in plan.exercises) {
        double oneRepMax = oneRepMaxes[exercise.name] ?? 100;

        for (var set in exercise.sets) {
          if (set.isAMRAP && set.actualReps != null) {
            int reps = set.actualReps!;
            double progression = 0;

            if (set.reps == 6 && reps >= 12) progression = 2.5;
            if (set.reps == 4 && reps >= 8) progression = 2.5;
            if (set.reps == 2 && reps >= 4) progression = 2.5;
            if (progression == 0) progression = 1.25;

            oneRepMaxes[exercise.name] = (oneRepMaxes[exercise.name] ?? 0) + progression * 2;
            trainingBox.put(exercise.name, oneRepMaxes[exercise.name]);

            print("${exercise.name} - Seria AMRAP ${set.percentage}%: ${reps} powtórzeń. Sugestia: +${progression}kg na stronę.");
          }
        }
      }
    }
  }
}
