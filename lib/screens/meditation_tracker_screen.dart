import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/gamification_provider.dart';
import '../providers/health_provider.dart';

class MeditationTrackerScreen extends StatefulWidget {
  const MeditationTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MeditationTrackerScreen> createState() => _MeditationTrackerScreenState();
}

class _MeditationTrackerScreenState extends State<MeditationTrackerScreen> {
  bool _isSessionActive = false;
  Timer? _timer;
  int _sessionSeconds = 0;
  int _selectedDuration = 5; // Default 5 minutes
  final List<int> _durationOptions = [1, 3, 5, 10, 15, 20];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _sessionSeconds = _selectedDuration * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_sessionSeconds > 0) {
          _sessionSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseSession() {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
      _sessionSeconds = 0;
    });
  }

  Future<void> _completeSession() async {
    _timer?.cancel();

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);

    // Add meditation minutes
    await healthProvider.addMeditationMinutes(_selectedDuration);

    // Add points
    await gamificationProvider.addPoints(_selectedDuration * 10);

    // Update challenge progress
    await gamificationProvider.updateChallengeProgress('meditation_month', 1);

    setState(() {
      _isSessionActive = false;
      _sessionSeconds = 0;
    });

    if (mounted) {
      // Show completion dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Meditation Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                'Great job! You completed a $_selectedDuration minute meditation session.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You earned ${_selectedDuration * 10} points!',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final totalMeditationMinutes = healthProvider.healthData.meditationMinutes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Tracker'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Meditation Timer Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Session Timer Display
                      Text(
                        _isSessionActive ? 'Meditation in Progress' : 'Ready to Meditate?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 32),

                      // Timer Circle
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isSessionActive
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          border: Border.all(
                            color: _isSessionActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _isSessionActive
                                ? _formatTime(_sessionSeconds)
                                : '$_selectedDuration:00',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isSessionActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Duration Selection (when not in session)
                      if (!_isSessionActive)
                        Column(
                          children: [
                            const Text(
                              'Select Duration:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: _durationOptions.map((duration) {
                                return ChoiceChip(
                                  label: Text('$duration min'),
                                  selected: _selectedDuration == duration,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedDuration = duration;
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Control Buttons
                      if (_isSessionActive)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pauseSession,
                              icon: const Icon(Icons.pause),
                              label: const Text('Pause'),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: _stopSession,
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _startSession,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Meditation'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stats Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Meditation Stats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        context,
                        Icons.timer,
                        'Total Meditation Time',
                        '$totalMeditationMinutes minutes',
                      ),
                      _buildStatRow(
                        context,
                        Icons.calendar_today,
                        'Meditation Streak',
                        '${Provider.of<GamificationProvider>(context).streak} days',
                      ),
                      _buildStatRow(
                        context,
                        Icons.star,
                        'Points Earned from Meditation',
                        '${totalMeditationMinutes * 10} points',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Meditation Tips
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meditation Tips',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem(
                        context,
                        Icons.schedule,
                        'Meditate at the same time each day to build a habit.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.chair,
                        'Sit in a comfortable position with your back straight.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.air,
                        'Focus on your breath. Notice the sensation of breathing in and out.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.psychology,
                        'When your mind wanders, gently bring your attention back to your breath.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.timer_outlined,
                        'Start with short sessions and gradually increase the duration.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

