import '../models/training_model.dart';
List<TrainingSet> calculateWeights(List<TrainingSet> sets, double oneRepMax) {
  return sets.map((set) {
    double calculatedWeight = (oneRepMax * (set.percentage / 100)).roundToDouble();

    int? recommendedReps;
    if (set.isAMRAP) {
      if (set.reps == 6) recommendedReps = 12;
      if (set.reps == 4) recommendedReps = 8;
      if (set.reps == 2) recommendedReps = 4;
    }

    return TrainingSet(
      reps: set.reps,
      percentage: set.percentage,
      isAMRAP: set.isAMRAP,
      recommendedReps: recommendedReps,
      weight: calculatedWeight,
    );
  }).toList();
}
