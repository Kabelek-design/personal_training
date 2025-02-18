class TrainingPlan {
  final int week;
  final List<Exercise> exercises;

  TrainingPlan({required this.week, required this.exercises});
}

class Exercise {
  final String name;
  final List<TrainingSet> sets;

  Exercise({required this.name, required this.sets});
}

class TrainingSet {
  final int reps;
  final double percentage;
  final bool isAMRAP; // Czy to seria "+"
  int? actualReps; // Liczba faktycznie wykonanych powtórzeń (użytkownik wpisuje)
  final int? recommendedReps; // Dla serii "+" sugerowana ilość powtórzeń
   double? weight; // Obliczony ciężar

  TrainingSet({
    required this.reps,
    required this.percentage,
    this.isAMRAP = false,
    this.actualReps,
    this.recommendedReps,
    this.weight,
  });
}

