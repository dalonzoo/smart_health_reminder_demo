class HealthData {
  final int waterIntake; // in ml
  final int steps;
  final int meditationMinutes;
  final DateTime lastPostureCheck;

  HealthData({
    required this.waterIntake,
    required this.steps,
    required this.meditationMinutes,
    required this.lastPostureCheck,
  });

  HealthData copyWith({
    int? waterIntake,
    int? steps,
    int? meditationMinutes,
    DateTime? lastPostureCheck,
  }) {
    return HealthData(
      waterIntake: waterIntake ?? this.waterIntake,
      steps: steps ?? this.steps,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      lastPostureCheck: lastPostureCheck ?? this.lastPostureCheck,
    );
  }
}

