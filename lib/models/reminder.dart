import 'package:flutter/material.dart';

enum ReminderType {
  water,
  posture,
  steps,
  meditation,
  custom,
}

enum ReminderFrequency {
  hourly,
  daily,
  weekly,
  custom,
}

class Reminder {
  final String id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderFrequency frequency;
  final TimeOfDay time;
  final bool isActive;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    required this.time,
    required this.isActive,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    ReminderFrequency? frequency,
    TimeOfDay? time,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'frequency': frequency.index,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'isActive': isActive,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ReminderType.values[json['type']],
      frequency: ReminderFrequency.values[json['frequency']],
      time: TimeOfDay(hour: json['timeHour'], minute: json['timeMinute']),
      isActive: json['isActive'],
    );
  }
}

