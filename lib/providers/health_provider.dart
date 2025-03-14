import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_health_reminder_demo/models/health_data.dart';

class HealthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  HealthData _healthData = HealthData(
    waterIntake: 0,
    steps: 0,
    meditationMinutes: 0,
    lastPostureCheck: DateTime.now(),
  );

  HealthProvider(this._prefs) {
    _loadHealthData();
  }

  HealthData get healthData => _healthData;

  Future<void> _loadHealthData() async {
    _healthData = HealthData(
      waterIntake: _prefs.getInt('waterIntake') ?? 0,
      steps: _prefs.getInt('steps') ?? 0,
      meditationMinutes: _prefs.getInt('meditationMinutes') ?? 0,
      lastPostureCheck: DateTime.fromMillisecondsSinceEpoch(
        _prefs.getInt('lastPostureCheck') ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
    notifyListeners();
  }

  Future<void> _saveHealthData() async {
    await _prefs.setInt('waterIntake', _healthData.waterIntake);
    await _prefs.setInt('steps', _healthData.steps);
    await _prefs.setInt('meditationMinutes', _healthData.meditationMinutes);
    await _prefs.setInt('lastPostureCheck', _healthData.lastPostureCheck.millisecondsSinceEpoch);
  }

  Future<void> addWaterIntake(int amount) async {
    _healthData = _healthData.copyWith(
      waterIntake: _healthData.waterIntake + amount,
    );
    await _saveHealthData();
    notifyListeners();
  }

  Future<void> resetWaterIntake() async {
    _healthData = _healthData.copyWith(waterIntake: 0);
    await _saveHealthData();
    notifyListeners();
  }

  Future<void> addSteps(int steps) async {
    _healthData = _healthData.copyWith(
      steps: _healthData.steps + steps,
    );
    await _saveHealthData();
    notifyListeners();
  }

  Future<void> resetSteps() async {
    _healthData = _healthData.copyWith(steps: 0);
    await _saveHealthData();
    notifyListeners();
  }

  Future<void> addMeditationMinutes(int minutes) async {
    _healthData = _healthData.copyWith(
      meditationMinutes: _healthData.meditationMinutes + minutes,
    );
    await _saveHealthData();
    notifyListeners();
  }

  Future<void> updatePostureCheck() async {
    _healthData = _healthData.copyWith(
      lastPostureCheck: DateTime.now(),
    );
    await _saveHealthData();
    notifyListeners();
  }

  // Calculate recommended water intake based on temperature and activity
  int getRecommendedWaterIntake({required double temperatureCelsius, required int activityLevel}) {
    // Base recommendation: 2000ml
    int baseIntake = 2000;
    
    // Adjust for temperature: +200ml for every 5°C above 25°C
    if (temperatureCelsius > 25) {
      baseIntake += ((temperatureCelsius - 25) / 5).floor() * 200;
    }
    
    // Adjust for activity level (1-5 scale)
    baseIntake += activityLevel * 200;
    
    return baseIntake;
  }
}

