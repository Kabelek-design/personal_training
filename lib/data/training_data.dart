import '../models/training_model.dart';

final List<TrainingPlan> trainingPlans = [
  // 🔹 TYDZIEŃ 1
  TrainingPlan(
    week: 1,
    exercises: [
      Exercise(
        name: "Przysiady",
        sets: [
          TrainingSet(reps: 6, percentage: 62.5),
          TrainingSet(reps: 6, percentage: 70),
          TrainingSet(reps: 6, percentage: 70),
          TrainingSet(reps: 6, percentage: 70, isAMRAP: true), // Seria "+"
        ],
      ),
      Exercise(
        name: "Martwy ciąg",
        sets: [
          TrainingSet(reps: 4, percentage: 70),
          TrainingSet(reps: 4, percentage: 75),
          TrainingSet(reps: 4, percentage: 80),
          TrainingSet(reps: 4, percentage: 80),
          TrainingSet(reps: 4, percentage: 80, isAMRAP: true), // Seria "+"
        ],
      ),
      Exercise(
        name: "Wyciskanie leżąc",
        sets: [
          TrainingSet(reps: 6, percentage: 65),
          TrainingSet(reps: 4, percentage: 75),
          TrainingSet(reps: 2, percentage: 85),
          TrainingSet(reps: 2, percentage: 90),
          TrainingSet(reps: 2, percentage: 90, isAMRAP: true), // Seria "+"
          TrainingSet(reps: 4, percentage: 75),
        ],
      ),
    ],
  ),

  // 🔹 TYDZIEŃ 2
  TrainingPlan(
    week: 2,
    exercises: [
      Exercise(
        name: "Przysiady",
        sets: [
          TrainingSet(reps: 6, percentage: 65),
          TrainingSet(reps: 4, percentage: 75),
          TrainingSet(reps: 2, percentage: 85),
          TrainingSet(reps: 2, percentage: 90),
          TrainingSet(reps: 2, percentage: 90, isAMRAP: true), // Seria "+"
          TrainingSet(reps: 4, percentage: 75),
        ],
      ),
      Exercise(
        name: "Martwy ciąg",
        sets: [
          TrainingSet(reps: 6, percentage: 62.5),
          TrainingSet(reps: 6, percentage: 70),
          TrainingSet(reps: 6, percentage: 70),
          TrainingSet(reps: 6, percentage: 70, isAMRAP: true), // Seria "+"
        ],
      ),
      Exercise(
        name: "Wyciskanie leżąc",
        sets: [
          TrainingSet(reps: 4, percentage: 70),
          TrainingSet(reps: 4, percentage: 75),
          TrainingSet(reps: 4, percentage: 80),
          TrainingSet(reps: 4, percentage: 80),
          TrainingSet(reps: 4, percentage: 80, isAMRAP: true), // Seria "+"
        ],
      ),
    ],
  ),

  // 🔹 TYDZIEŃ 3
  TrainingPlan(
    week: 3,
    exercises: [
      Exercise(
        name: "Przysiady",
        sets: [
          TrainingSet(reps: 4, percentage: 70),
          TrainingSet(reps: 4, percentage: 75),
          TrainingSet(reps: 4, percentage: 80),
          TrainingSet(reps: 4, percentage: 80),
          TrainingSet(reps: 4, percentage: 80, isAMRAP: true), // Seria "+"
        ],
      ),
      Exercise(
        name: "Martwy ciąg",
        sets: [
          TrainingSet(reps: 6, percentage: 65),
          TrainingSet(reps: 4, percentage: 75),
          TrainingSet(reps: 2, percentage: 85),
          TrainingSet(reps: 2, percentage: 90),
          TrainingSet(reps: 2, percentage: 90, isAMRAP: true), // Seria "+"
          TrainingSet(reps: 4, percentage: 75),
        ],
      ),
      Exercise(
        name: "Wyciskanie leżąc",
        sets: [
          TrainingSet(reps: 6, percentage: 62.5),
          TrainingSet(reps: 6, percentage: 70),
          TrainingSet(reps: 6, percentage: 70),
          TrainingSet(reps: 6, percentage: 70, isAMRAP: true), // Seria "+"
        ],
      ),
    ],
  ),
];
