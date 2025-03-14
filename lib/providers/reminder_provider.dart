import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_health_reminder_demo/models/reminder.dart';
import 'dart:convert';

class ReminderProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<Reminder> _reminders = [];

  ReminderProvider(this._prefs) {
    _loadReminders();
  }

  List<Reminder> get reminders => _reminders;
  List<Reminder> get activeReminders => _reminders.where((r) => r.isActive).toList();

  Future<void> _loadReminders() async {
    final List<String>? reminderStrings = _prefs.getStringList('reminders');
    if (reminderStrings != null) {
      _reminders = reminderStrings
          .map((str) => Reminder.fromJson(jsonDecode(str)))
          .toList();
    } else {
      // Initialize with default reminders if none exist
      _reminders = [
        Reminder(
          id: 'water',
          title: 'Drink Water',
          description: 'Stay hydrated throughout the day',
          type: ReminderType.water,
          frequency: ReminderFrequency.hourly,
          time: const TimeOfDay(hour: 9, minute: 0),
          isActive: true,
        ),
        Reminder(
          id: 'posture',
          title: 'Check Posture',
          description: 'Maintain good posture while sitting',
          type: ReminderType.posture,
          frequency: ReminderFrequency.hourly,
          time: const TimeOfDay(hour: 9, minute: 30),
          isActive: true,
        ),
        Reminder(
          id: 'steps',
          title: 'Move Around',
          description: 'Take a short walk to reach your step goal',
          type: ReminderType.steps,
          frequency: ReminderFrequency.daily,
          time: const TimeOfDay(hour: 14, minute: 0),
          isActive: true,
        ),
        Reminder(
          id: 'meditation',
          title: 'Meditation Time',
          description: 'Take a moment to breathe and relax',
          type: ReminderType.meditation,
          frequency: ReminderFrequency.daily,
          time: const TimeOfDay(hour: 18, minute: 0),
          isActive: true,
        ),
      ];
      await _saveReminders();
    }
    notifyListeners();
  }

  Future<void> _saveReminders() async {
    final List<String> reminderStrings = _reminders
        .map((reminder) => jsonEncode(reminder.toJson()))
        .toList();
    await _prefs.setStringList('reminders', reminderStrings);
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _saveReminders();
      notifyListeners();
    }
  }

  Future<void> toggleReminderActive(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        isActive: !_reminders[index].isActive,
      );
      await _saveReminders();
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    notifyListeners();
  }

  // Get next reminder based on current time
  Reminder? getNextReminder() {
    final now = DateTime.now();
    final currentTimeOfDay = TimeOfDay.fromDateTime(now);
    
    // Sort reminders by time
    final sortedReminders = [...activeReminders];
    sortedReminders.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    
    // Find next reminder
    for (final reminder in sortedReminders) {
      final reminderMinutes = reminder.time.hour * 60 + reminder.time.minute;
      final currentMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;
      
      if (reminderMinutes > currentMinutes) {
        return reminder;
      }
    }
    
    // If no reminder found for today, return the first reminder for tomorrow
    return sortedReminders.isNotEmpty ? sortedReminders.first : null;
  }

  // Calculate smart water reminder based on temperature and activity
  int getWaterReminderInterval({required double temperatureCelsius, required int activityLevel}) {
    // Base interval: 60 minutes
    int baseInterval = 60;
    
    // Adjust for temperature: -5 minutes for every 5°C above 25°C
    if (temperatureCelsius > 25) {
      baseInterval -= ((temperatureCelsius - 25) / 5).floor() * 5;
    }
    
    // Adjust for activity level (1-5 scale)
    baseInterval -= activityLevel * 5;
    
    // Ensure minimum interval of 30 minutes
    return baseInterval < 30 ? 30 : baseInterval;
  }
}

