import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_health_reminder_demo/models/achievement.dart';
import 'package:smart_health_reminder_demo/models/challenge.dart';

class GamificationProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  int _points = 0;
  int _streak = 0;
  List<Achievement> _achievements = [];
  List<Challenge> _challenges = [];

  GamificationProvider(this._prefs) {
    _loadGamificationData();
    _initializeAchievements();
    _initializeChallenges();
  }

  int get points => _points;
  int get streak => _streak;
  List<Achievement> get achievements => _achievements;
  List<Challenge> get challenges => _challenges;
  List<Achievement> get unlockedAchievements => 
      _achievements.where((achievement) => achievement.isUnlocked).toList();

  Future<void> _loadGamificationData() async {
    _points = _prefs.getInt('points') ?? 0;
    _streak = _prefs.getInt('streak') ?? 0;
    notifyListeners();
  }

  Future<void> _saveGamificationData() async {
    await _prefs.setInt('points', _points);
    await _prefs.setInt('streak', _streak);
    
    // Save achievements
    final List<String> unlockedAchievementIds = _achievements
        .where((a) => a.isUnlocked)
        .map((a) => a.id)
        .toList();
    await _prefs.setStringList('unlockedAchievements', unlockedAchievementIds);
    
    // Save challenges progress
    for (final challenge in _challenges) {
      await _prefs.setInt('challenge_${challenge.id}_progress', challenge.currentProgress);
    }
  }

  void _initializeAchievements() {
    final List<String> unlockedAchievementIds = 
        _prefs.getStringList('unlockedAchievements') ?? [];
    
    _achievements = [
      Achievement(
        id: 'water_beginner',
        title: 'Hydration Beginner',
        description: 'Drink water 3 days in a row',
        points: 50,
        isUnlocked: unlockedAchievementIds.contains('water_beginner'),
      ),
      Achievement(
        id: 'water_master',
        title: 'Hydration Master',
        description: 'Drink water 10 days in a row',
        points: 200,
        isUnlocked: unlockedAchievementIds.contains('water_master'),
      ),
      Achievement(
        id: 'steps_5k',
        title: '5K Stepper',
        description: 'Walk 5,000 steps in a day',
        points: 100,
        isUnlocked: unlockedAchievementIds.contains('steps_5k'),
      ),
      Achievement(
        id: 'steps_10k',
        title: '10K Stepper',
        description: 'Walk 10,000 steps in a day',
        points: 200,
        isUnlocked: unlockedAchievementIds.contains('steps_10k'),
      ),
      Achievement(
        id: 'meditation_beginner',
        title: 'Meditation Beginner',
        description: 'Meditate for 5 days in a row',
        points: 150,
        isUnlocked: unlockedAchievementIds.contains('meditation_beginner'),
      ),
      Achievement(
        id: 'posture_aware',
        title: 'Posture Aware',
        description: 'Check your posture 10 times',
        points: 100,
        isUnlocked: unlockedAchievementIds.contains('posture_aware'),
      ),
    ];
  }

  void _initializeChallenges() {
    _challenges = [
      Challenge(
        id: 'water_week',
        title: 'Water Week',
        description: 'Drink 2L of water every day for a week',
        targetProgress: 7,
        currentProgress: _prefs.getInt('challenge_water_week_progress') ?? 0,
        points: 300,
      ),
      Challenge(
        id: 'step_master',
        title: 'Step Master',
        description: 'Walk 50,000 steps in a week',
        targetProgress: 50000,
        currentProgress: _prefs.getInt('challenge_step_master_progress') ?? 0,
        points: 500,
      ),
      Challenge(
        id: 'meditation_month',
        title: 'Meditation Month',
        description: 'Meditate for 10 minutes every day for a month',
        targetProgress: 30,
        currentProgress: _prefs.getInt('challenge_meditation_month_progress') ?? 0,
        points: 1000,
      ),
    ];
  }

  Future<void> addPoints(int amount) async {
    _points += amount;
    await _saveGamificationData();
    notifyListeners();
  }

  Future<void> incrementStreak() async {
    _streak += 1;
    await _saveGamificationData();
    notifyListeners();
    
    // Check for streak-based achievements
    checkAchievements();
  }

  Future<void> resetStreak() async {
    _streak = 0;
    await _saveGamificationData();
    notifyListeners();
  }

  Future<void> unlockAchievement(String achievementId) async {
    final achievementIndex = _achievements.indexWhere((a) => a.id == achievementId);
    if (achievementIndex != -1 && !_achievements[achievementIndex].isUnlocked) {
      _achievements[achievementIndex] = _achievements[achievementIndex].copyWith(isUnlocked: true);
      await addPoints(_achievements[achievementIndex].points);
      await _saveGamificationData();
      notifyListeners();
    }
  }

  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      final challenge = _challenges[challengeIndex];
      final newProgress = challenge.currentProgress + progress;
      
      _challenges[challengeIndex] = challenge.copyWith(
        currentProgress: newProgress > challenge.targetProgress 
            ? challenge.targetProgress 
            : newProgress,
      );
      
      // Check if challenge is completed
      if (_challenges[challengeIndex].isCompleted && 
          _challenges[challengeIndex].currentProgress == progress + challenge.currentProgress) {
        await addPoints(challenge.points);
      }
      
      await _saveGamificationData();
      notifyListeners();
    }
  }

  void checkAchievements() {
    // Check water achievements
    if (_streak >= 3) {
      unlockAchievement('water_beginner');
    }
    if (_streak >= 10) {
      unlockAchievement('water_master');
    }
  }

  void checkStepAchievements(int steps) {
    if (steps >= 5000) {
      unlockAchievement('steps_5k');
    }
    if (steps >= 10000) {
      unlockAchievement('steps_10k');
    }
  }

  void checkMeditationAchievements(int days) {
    if (days >= 5) {
      unlockAchievement('meditation_beginner');
    }
  }

  void checkPostureAchievements(int checks) {
    if (checks >= 10) {
      unlockAchievement('posture_aware');
    }
  }
}

