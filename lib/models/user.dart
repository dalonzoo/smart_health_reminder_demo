class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String gender;
  final int activityLevel; // 1-5 scale

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    int? age,
    double? weight,
    double? height,
    String? gender,
    int? activityLevel,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activityLevel': activityLevel,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      age: json['age'],
      weight: json['weight'],
      height: json['height'],
      gender: json['gender'],
      activityLevel: json['activityLevel'],
    );
  }

  // Calculate BMI
  double get bmi {
    // BMI = weight(kg) / (height(m) * height(m))
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) {
      return 'Underweight';
    } else if (bmiValue < 25) {
      return 'Normal';
    } else if (bmiValue < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Get daily calorie requirement
  int get dailyCalorieRequirement {
    // Basal Metabolic Rate (BMR) calculation using Mifflin-St Jeor Equation
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Adjusting for activity level
    final activityMultipliers = [1.2, 1.375, 1.55, 1.725, 1.9];
    final index = activityLevel - 1;
    if (index >= 0 && index < activityMultipliers.length) {
      return (bmr * activityMultipliers[index]).round();
    }

    return bmr.round();
  }
}

