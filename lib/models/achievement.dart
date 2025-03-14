class Achievement {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.isUnlocked,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

