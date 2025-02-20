class TrainingPlan {
  final int week;
  final List<Exercise> exercises;

  TrainingPlan({
    required this.week,
    required this.exercises,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      week: json['week'] as int,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
}

class Exercise {
  final String name;
  final List<TrainingSet> sets;

  Exercise({
    required this.name,
    required this.sets,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: (json['sets'] as List)
          .map((e) => TrainingSet.fromJson(e))
          .toList(),
    );
  }
}

class TrainingSet {
  final int reps;
  final double percentage;
  final bool isAMRAP;
  double? weight; // opcjonalne, jeśli chcesz przechowywać obliczony ciężar

  TrainingSet({
    required this.reps,
    required this.percentage,
    this.isAMRAP = false,
    this.weight,
  });

  factory TrainingSet.fromJson(Map<String, dynamic> json) {
    return TrainingSet(
      reps: json['reps'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      isAMRAP: json['isAMRAP'] as bool? ?? false,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    );
  }
}
