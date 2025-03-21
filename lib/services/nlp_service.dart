// lib/services/nlp_service.dart
import 'package:flutter/material.dart';


import '../models/reminder.dart';
import '../providers/gamification_provider.dart';
import '../providers/health_provider.dart';
import '../providers/reminder_provider.dart';
import 'entity_extractor.dart';
import 'intent_classifier.dart';

class NLPService {
  final HealthProvider healthProvider;
  final ReminderProvider reminderProvider;
  final GamificationProvider gamificationProvider;

  // Add these fields
  final IntentClassifier _intentClassifier = IntentClassifier();
  final EntityExtractor _entityExtractor = EntityExtractor();

  NLPService({
    required this.healthProvider,
    required this.reminderProvider,
    required this.gamificationProvider,
  }) {
    // Initialize the intent classifier
    _intentClassifier.initialize();
  }

  // Update the processInput method to use intent classification
  Future<NLPResponse> processInput(String input) async {
    // Convert to lowercase for easier matching
    final normalizedInput = input.toLowerCase().trim();

    // Classify intent
    final intentResults = await _intentClassifier.classifyIntent(normalizedInput);

    // Get the top intent
    String topIntent = 'unknown';
    double topConfidence = 0.0;

    intentResults.forEach((intent, confidence) {
      if (confidence > topConfidence) {
        topIntent = intent;
        topConfidence = confidence;
      }

    });

      print("topcint : ${topIntent}");
      topIntent = topIntent.trim().toLowerCase();

    // Handle based on classified intent
      switch (topIntent) {
        case 'add_water':
          return await _handleWaterIntakeCommand(normalizedInput);
        case 'query_water':
          return await _handleWaterQuery(normalizedInput);
        case 'add_steps':
          return await _handleStepTrackingCommand(normalizedInput);
        case 'query_steps':
          return await _handleStepQuery(normalizedInput);
        case 'start_meditation':
          return await _handleMeditationCommand(normalizedInput);
        case 'query_meditation':
          return await _handleMeditationQuery(normalizedInput);
        case 'check_posture':
          return await _handlePostureCommand(normalizedInput);
        case 'query_posture':
          return await _handlePostureQuery(normalizedInput);
        case 'create_reminder':
          return await _handleReminderCreation(normalizedInput);
        case 'list_reminders':
          return await _handleReminderListing(normalizedInput);
        case 'query_achievements':
          return await _handleAchievementQuery(normalizedInput);
        case 'query_challenges':
          return await _handleChallengeQuery(normalizedInput);
        case 'query_points':
          return await _handlePointsQuery(normalizedInput);
        case 'query_summary':
          return await _handleSummaryQuery(normalizedInput);
        default:
        // Fall back to keyword matching
          print("ricevuto ${topIntent}");
          return await _handleUnknownIntent(normalizedInput);
      }


    // If no specific command is recognized
    return NLPResponse(
      success: false,
      message: "I'm sorry, I didn't understand that. Try asking about water, steps, meditation, posture, or reminders.",
      actionType: NLPActionType.unknown,
    );
  }

  // Add new methods for entity-based processing
  Future<NLPResponse> _handleWaterQuery(String input) async {
    final waterIntake = healthProvider.healthData.waterIntake;
    return NLPResponse(
      success: true,
      message: "You've had $waterIntake ml of water today.",
      actionType: NLPActionType.queryWaterIntake,
      data: {'amount': waterIntake},
    );
  }

  Future<NLPResponse> _handleStepQuery(String input) async {
    final steps = healthProvider.healthData.steps;
    return NLPResponse(
      success: true,
      message: "You've taken $steps steps today.",
      actionType: NLPActionType.querySteps,
      data: {'steps': steps},
    );
  }

  Future<NLPResponse> _handleMeditationQuery(String input) async {
    final meditationMinutes = healthProvider.healthData.meditationMinutes;
    return NLPResponse(
      success: true,
      message: "You've meditated for $meditationMinutes minutes today.",
      actionType: NLPActionType.queryMeditation,
      data: {'minutes': meditationMinutes},
    );
  }

  Future<NLPResponse> _handlePostureQuery(String input) async {
    final lastPostureCheck = healthProvider.healthData.lastPostureCheck;
    final timeSinceCheck = DateTime.now().difference(lastPostureCheck);

    String timeMessage;
    if (timeSinceCheck.inMinutes < 60) {
      timeMessage = "${timeSinceCheck.inMinutes} minutes ago";
    } else if (timeSinceCheck.inHours < 24) {
      timeMessage = "${timeSinceCheck.inHours} hours ago";
    } else {
      timeMessage = "${timeSinceCheck.inDays} days ago";
    }

    return NLPResponse(
      success: true,
      message: "Your last posture check was $timeMessage.",
      actionType: NLPActionType.queryPosture,
      data: {'lastCheck': lastPostureCheck.toIso8601String()},
    );
  }

  Future<NLPResponse> _handleReminderCreation(String input) async {
    // Extract reminder type
    ReminderType? type;
    if (input.contains('water')) type = ReminderType.water;
    else if (input.contains('posture')) type = ReminderType.posture;
    else if (input.contains('step') || input.contains('walk')) type = ReminderType.steps;
    else if (input.contains('meditat')) type = ReminderType.meditation;
    else type = ReminderType.custom;

    // Extract time if present
    final timeEntity = _entityExtractor.extractTime(input);
    TimeOfDay? time;
    if (timeEntity != null) {
      time = TimeOfDay(hour: timeEntity.hour, minute: timeEntity.minute);
    }

    // Extract frequency if present
    ReminderFrequency? frequency;
    if (input.contains('hourly')) frequency = ReminderFrequency.hourly;
    else if (input.contains('daily')) frequency = ReminderFrequency.daily;
    else if (input.contains('weekly')) frequency = ReminderFrequency.weekly;
    else frequency = ReminderFrequency.daily; // Default

    return NLPResponse(
      success: true,
      message: "I'll help you set up a reminder. Please confirm the details on the next screen.",
      actionType: NLPActionType.createReminder,
      data: {
        'type': type.index,
        'time': time != null ? '${time.hour}:${time.minute}' : null,
        'frequency': frequency.index,
      },
    );
  }

  Future<NLPResponse> _handleReminderListing(String input) async {
    final reminders = reminderProvider.reminders;
    final activeReminders = reminderProvider.activeReminders;

    return NLPResponse(
      success: true,
      message: "You have ${activeReminders.length} active reminders out of ${reminders.length} total reminders.",
      actionType: NLPActionType.listReminders,
    );
  }

  Future<NLPResponse> _handleAchievementQuery(String input) async {
    final achievements = gamificationProvider.achievements;
    final unlockedAchievements = gamificationProvider.unlockedAchievements;

    return NLPResponse(
      success: true,
      message: "You've unlocked ${unlockedAchievements.length} out of ${achievements.length} achievements.",
      actionType: NLPActionType.queryAchievements,
      data: {
        'unlocked': unlockedAchievements.length,
        'total': achievements.length,
      },
    );
  }

  Future<NLPResponse> _handleChallengeQuery(String input) async {
    final challenges = gamificationProvider.challenges;
    final completedChallenges = challenges.where((c) => c.isCompleted).length;

    return NLPResponse(
      success: true,
      message: "You've completed $completedChallenges out of ${challenges.length} challenges.",
      actionType: NLPActionType.queryChallenges,
      data: {
        'completed': completedChallenges,
        'total': challenges.length,
      },
    );
  }

  Future<NLPResponse> _handlePointsQuery(String input) async {
    final points = gamificationProvider.points;
    return NLPResponse(
      success: true,
      message: "You currently have $points points.",
      actionType: NLPActionType.queryPoints,
      data: {'points': points},
    );
  }

  Future<NLPResponse> _handleSummaryQuery(String input) async {
    final waterIntake = healthProvider.healthData.waterIntake;
    final steps = healthProvider.healthData.steps;
    final points = gamificationProvider.points;

    return NLPResponse(
      success: true,
      message: "Today's summary: $waterIntake ml of water, $steps steps, and you have $points points in total.",
      actionType: NLPActionType.querySummary,
      data: {
        'water': waterIntake,
        'steps': steps,
        'points': points,
      },
    );
  }

  Future<NLPResponse> _handleUnknownIntent(String input) async {
    // Try to extract entities to determine intent
    final quantityEntity = _entityExtractor.extractQuantity(input);
    if (quantityEntity != null) {
      final unit = quantityEntity.unit.toLowerCase();

      // Water-related units
      if (['ml', 'liter', 'liters', 'l', 'glass', 'glasses', 'cup', 'cups', 'oz'].contains(unit)) {
        int amount = quantityEntity.value.toInt();

        // Convert to ml
        switch (unit) {
          case 'liter':
          case 'liters':
          case 'l':
            amount *= 1000;
            break;
          case 'glass':
          case 'glasses':
          case 'cup':
          case 'cups':
            amount *= 250; // Assuming a standard glass/cup
            break;
          case 'oz':
            amount = (amount * 29.5735).round(); // Convert oz to ml
            break;
        }

        // Add water intake
        await healthProvider.addWaterIntake(amount);

        // Add points for tracking water
        await gamificationProvider.addPoints(5);

        return NLPResponse(
          success: true,
          message: "Added $amount ml of water to your daily intake!",
          actionType: NLPActionType.addWaterIntake,
          data: {'amount': amount},
        );
      }

      // Step-related units
      if (['step', 'steps'].contains(unit)) {
        int steps = quantityEntity.value.toInt();

        // Add steps
        await healthProvider.addSteps(steps);

        // Add points for tracking steps
        await gamificationProvider.addPoints(steps ~/ 100);

        // Check achievements
        gamificationProvider.checkStepAchievements(healthProvider.healthData.steps);

        return NLPResponse(
          success: true,
          message: "Added $steps steps to your daily count!",
          actionType: NLPActionType.addSteps,
          data: {'steps': steps},
        );
      }

      // Meditation-related units
      if (['minute', 'minutes', 'min'].contains(unit)) {
        int minutes = quantityEntity.value.toInt();

        // Add meditation minutes
        await healthProvider.addMeditationMinutes(minutes);

        // Add points
        await gamificationProvider.addPoints(minutes * 10);

        return NLPResponse(
          success: true,
          message: "Added a $minutes minute meditation session!",
          actionType: NLPActionType.addMeditation,
          data: {'minutes': minutes},
        );
      }
    }

    // If no entities found, return unknown response
    return NLPResponse(
      success: false,
      message: "I'm sorry, I didn't understand that. Try asking about water, steps, meditation, posture, or reminders.",
      actionType: NLPActionType.unknown,
    );
  }



  // Helper methods to identify command types
  bool _isWaterIntakeCommand(String input) {
    final waterKeywords = [
      'water', 'drink', 'hydrate', 'hydration', 'drank', 'glass', 'ml', 'liter'
    ];
    return _containsAnyKeyword(input, waterKeywords);
  }

  bool _isStepTrackingCommand(String input) {
    final stepKeywords = [
      'step', 'walk', 'walked', 'run', 'ran', 'exercise', 'move', 'movement'
    ];
    return _containsAnyKeyword(input, stepKeywords);
  }

  bool _isMeditationCommand(String input) {
    final meditationKeywords = [
      'meditate', 'meditation', 'mindfulness', 'breathe', 'relax', 'calm'
    ];
    return _containsAnyKeyword(input, meditationKeywords);
  }

  bool _isPostureCommand(String input) {
    final postureKeywords = [
      'posture', 'sit', 'sitting', 'stand', 'standing', 'back', 'straight'
    ];
    return _containsAnyKeyword(input, postureKeywords);
  }

  bool _isReminderCommand(String input) {
    final reminderKeywords = [
      'remind', 'reminder', 'alert', 'notification', 'schedule', 'set'
    ];
    return _containsAnyKeyword(input, reminderKeywords);
  }

  bool _isQueryCommand(String input) {
    final queryKeywords = [
      'how much', 'how many', 'what is', 'tell me', 'show', 'display', 'progress'
    ];
    return _containsAnyKeyword(input, queryKeywords);
  }

  bool _containsAnyKeyword(String input, List<String> keywords) {
    return keywords.any((keyword) => input.contains(keyword));
  }

  // Command handlers
  Future<NLPResponse> _handleWaterIntakeCommand(String input) async {
    // Extract amount from input
    input = input.toLowerCase();
    final RegExp amountRegex = RegExp(r'(\d+)\s*(ml|liter|glass|cup|oz|l)');
    final match = amountRegex.firstMatch(input);

    if (match != null) {
      int amount = int.parse(match.group(1)!);
      String unit = match.group(2)!;

      // Convert to ml
      switch (unit) {
        case 'liter':
        case 'l':
          amount *= 1000;
          break;
        case 'glass':
        case 'cup':
          amount *= 250; // Assuming a standard glass/cup
          break;
        case 'oz':
          amount = (amount * 29.5735).round(); // Convert oz to ml
          break;
      }

      // Add water intake
      await healthProvider.addWaterIntake(amount);

      // Add points for tracking water
      await gamificationProvider.addPoints(5);

      return NLPResponse(
        success: true,
        message: "Added $amount ml of water to your daily intake!",
        actionType: NLPActionType.addWaterIntake,
        data: {'amount': amount},
      );
    } else {
      // Default amount if not specified

      return NLPResponse(
        success: true,
        message: "Please specify the quantity, or just say a liter,a glass of water",
        actionType: NLPActionType.unknown,
      );
    }
  }

  Future<NLPResponse> _handleStepTrackingCommand(String input) async {
    // Extract step count from input
    final RegExp stepsRegex = RegExp(r'(\d+)\s*(step|steps)');
    final match = stepsRegex.firstMatch(input);

    if (match != null) {
      int steps = int.parse(match.group(1)!);

      // Add steps
      await healthProvider.addSteps(steps);

      // Add points for tracking steps
      await gamificationProvider.addPoints(steps ~/ 100);

      // Check achievements
      gamificationProvider.checkStepAchievements(healthProvider.healthData.steps);

      return NLPResponse(
        success: true,
        message: "Added $steps steps to your daily count!",
        actionType: NLPActionType.addSteps,
        data: {'steps': steps},
      );
    } else if (input.contains('add') || input.contains('track') || input.contains('log')) {
      // If no specific step count, ask for clarification
      return NLPResponse(
        success: false,
        message: "How many steps would you like to add?",
        actionType: NLPActionType.requestStepCount,
      );
    } else {
      // Query about step count
      final steps = healthProvider.healthData.steps;
      return NLPResponse(
        success: true,
        message: "You've taken $steps steps today.",
        actionType: NLPActionType.querySteps,
        data: {'steps': steps},
      );
    }
  }

  Future<NLPResponse> _handleMeditationCommand(String input) async {
    // Extract meditation duration from input

      // Start meditation session
      return NLPResponse(
        success: true,
        message: "Let's start a meditation session.",
        actionType: NLPActionType.startMeditation,
      );


  }

  Future<NLPResponse> _handlePostureCommand(String input) async {



      return NLPResponse(
        success: true,
        message: "Ok, posture check starting!",
        actionType: NLPActionType.checkPosture,
      );

  }

  Future<NLPResponse> _handleReminderCommand(String input) async {
    if (input.contains('create') || input.contains('add') || input.contains('set')) {
      // Extract reminder type
      ReminderType? type;
      if (input.contains('water')) type = ReminderType.water;
      else if (input.contains('posture')) type = ReminderType.posture;
      else if (input.contains('step') || input.contains('walk')) type = ReminderType.steps;
      else if (input.contains('meditat')) type = ReminderType.meditation;
      else type = ReminderType.custom;

      // Extract time if present
      TimeOfDay? time;
      final RegExp timeRegex = RegExp(r'(\d+):(\d+)');
      final match = timeRegex.firstMatch(input);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        time = TimeOfDay(hour: hour, minute: minute);
      }

      // Extract frequency if present
      ReminderFrequency? frequency;
      if (input.contains('hourly')) frequency = ReminderFrequency.hourly;
      else if (input.contains('daily')) frequency = ReminderFrequency.daily;
      else if (input.contains('weekly')) frequency = ReminderFrequency.weekly;
      else frequency = ReminderFrequency.daily; // Default

      return NLPResponse(
        success: true,
        message: "I'll help you set up a reminder. Please confirm the details on the next screen.",
        actionType: NLPActionType.createReminder,
        data: {
          'type': type.index,
          'time': time != null ? '${time.hour}:${time.minute}' : null,
          'frequency': frequency.index,
        },
      );
    } else {
      // List reminders
      final reminders = reminderProvider.reminders;
      final activeReminders = reminderProvider.activeReminders;

      return NLPResponse(
        success: true,
        message: "You have ${activeReminders.length} active reminders out of ${reminders.length} total reminders.",
        actionType: NLPActionType.listReminders,
      );
    }
  }

  Future<NLPResponse> _handleQueryCommand(String input) async {
    if (input.contains('water')) {
      final waterIntake = healthProvider.healthData.waterIntake;
      return NLPResponse(
        success: true,
        message: "You've had $waterIntake ml of water today.",
        actionType: NLPActionType.queryWaterIntake,
        data: {'amount': waterIntake},
      );
    } else if (input.contains('step')) {
      final steps = healthProvider.healthData.steps;
      return NLPResponse(
        success: true,
        message: "You've taken $steps steps today.",
        actionType: NLPActionType.querySteps,
        data: {'steps': steps},
      );
    } else if (input.contains('meditat')) {
      final meditationMinutes = healthProvider.healthData.meditationMinutes;
      return NLPResponse(
        success: true,
        message: "You've meditated for $meditationMinutes minutes today.",
        actionType: NLPActionType.queryMeditation,
        data: {'minutes': meditationMinutes},
      );
    } else if (input.contains('posture')) {
      final lastPostureCheck = healthProvider.healthData.lastPostureCheck;
      final timeSinceCheck = DateTime.now().difference(lastPostureCheck);

      String timeMessage;
      if (timeSinceCheck.inMinutes < 60) {
        timeMessage = "${timeSinceCheck.inMinutes} minutes ago";
      } else if (timeSinceCheck.inHours < 24) {
        timeMessage = "${timeSinceCheck.inHours} hours ago";
      } else {
        timeMessage = "${timeSinceCheck.inDays} days ago";
      }

      return NLPResponse(
        success: true,
        message: "Your last posture check was $timeMessage.",
        actionType: NLPActionType.queryPosture,
        data: {'lastCheck': lastPostureCheck.toIso8601String()},
      );
    } else if (input.contains('point') || input.contains('score')) {
      final points = gamificationProvider.points;
      return NLPResponse(
        success: true,
        message: "You currently have $points points.",
        actionType: NLPActionType.queryPoints,
        data: {'points': points},
      );
    } else if (input.contains('achievement')) {
      final achievements = gamificationProvider.achievements;
      final unlockedAchievements = gamificationProvider.unlockedAchievements;

      return NLPResponse(
        success: true,
        message: "You've unlocked ${unlockedAchievements.length} out of ${achievements.length} achievements.",
        actionType: NLPActionType.queryAchievements,
        data: {
          'unlocked': unlockedAchievements.length,
          'total': achievements.length,
        },
      );
    } else if (input.contains('challenge')) {
      final challenges = gamificationProvider.challenges;
      final completedChallenges = challenges.where((c) => c.isCompleted).length;

      return NLPResponse(
        success: true,
        message: "You've completed $completedChallenges out of ${challenges.length} challenges.",
        actionType: NLPActionType.queryChallenges,
        data: {
          'completed': completedChallenges,
          'total': challenges.length,
        },
      );
    } else {
      // General status query
      final waterIntake = healthProvider.healthData.waterIntake;
      final steps = healthProvider.healthData.steps;
      final points = gamificationProvider.points;

      return NLPResponse(
        success: true,
        message: "Today's summary: $waterIntake ml of water, $steps steps, and you have $points points in total.",
        actionType: NLPActionType.querySummary,
        data: {
          'water': waterIntake,
          'steps': steps,
          'points': points,
        },
      );
    }
  }
}

// Enum to categorize the type of action to take based on NLP processing
enum NLPActionType {
  addWaterIntake,
  queryWaterIntake,
  addSteps,
  querySteps,
  requestStepCount,
  addMeditation,
  startMeditation,
  queryMeditation,
  checkPosture,
  queryPosture,
  createReminder,
  listReminders,
  queryPoints,
  queryAchievements,
  queryChallenges,
  querySummary,
  unknown,
}

// Response class to standardize NLP processing results
class NLPResponse {
  final bool success;
  final String message;
  final NLPActionType actionType;
  final Map<String, dynamic>? data;

  NLPResponse({
    required this.success,
    required this.message,
    required this.actionType,
    this.data,
  });
}