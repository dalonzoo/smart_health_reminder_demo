class Challenge {
  final String id;
  final String title;
  final String description;
  final int targetProgress;
  final int currentProgress;
  final int points;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetProgress,
    required this.currentProgress,
    required this.points,
  });

  bool get isCompleted => currentProgress >= targetProgress;
  double get progressPercentage => currentProgress / targetProgress;

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? targetProgress,
    int? currentProgress,
    int? points,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetProgress: targetProgress ?? this.targetProgress,
      currentProgress: currentProgress ?? this.currentProgress,
      points: points ?? this.points,
    );
  }
}

