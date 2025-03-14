import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../providers/gamification_provider.dart';
import '../../providers/health_provider.dart';
import 'MeditationChart.dart';

class MeditationProgressScreen extends StatefulWidget {
  const MeditationProgressScreen({Key? key}) : super(key: key);

  @override
  State<MeditationProgressScreen> createState() => _MeditationProgressScreenState();
}

class _MeditationProgressScreenState extends State<MeditationProgressScreen> {
  bool _isSessionActive = false;
  int _sessionDuration = 5; // Default 5 minutes
  int _remainingSeconds = 0;
  Timer? _timer;
  final List<int> _durationOptions = [1, 5, 10, 15, 20, 30];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _remainingSeconds = _sessionDuration * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
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

  void _completeSession() {
    _timer?.cancel();

    // Calculate completed minutes (rounded up)
    final completedMinutes = (_sessionDuration * 60 - _remainingSeconds + 59) ~/ 60;

    // Update health data
    if (completedMinutes > 0) {
      final healthProvider = Provider.of<HealthProvider>(context, listen: false);
      final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);

      healthProvider.addMeditationMinutes(completedMinutes);

      // Update challenge progress
      gamificationProvider.updateChallengeProgress('meditation_month', 1);

      // Check for meditation achievements
      gamificationProvider.checkMeditationAchievements(5); // Assuming 5 days streak

      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meditation completed! Added $completedMinutes minutes.'),
          backgroundColor: Colors.purple,
        ),
      );
    }

    setState(() {
      _isSessionActive = false;
      _remainingSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final totalMinutes = healthProvider.healthData.meditationMinutes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meditation session card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Meditation Session',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isSessionActive
                        ? Column(
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _remainingSeconds / (_sessionDuration * 60),
                          minHeight: 8,
                          backgroundColor: Colors.purple.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pauseSession,
                              icon: const Icon(Icons.pause),
                              label: const Text('Pause'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _completeSession,
                              icon: const Icon(Icons.stop),
                              label: const Text('End'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                        : Column(
                      children: [
                        const Text(
                          'Select Duration',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _durationOptions.map((duration) {
                            return ChoiceChip(
                              label: Text('$duration min'),
                              selected: _sessionDuration == duration,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _sessionDuration = duration;
                                  });
                                }
                              },
                              selectedColor: Colors.purple,
                              labelStyle: TextStyle(
                                color: _sessionDuration == duration
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _startSession,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Meditation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Meditation Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Total Minutes',
                          '$totalMinutes',
                          Icons.access_time,
                          Colors.purple,
                        ),
                        _buildStatItem(
                          context,
                          'This Week',
                          '${totalMinutes}', // This would be calculated in a real app
                          Icons.calendar_today,
                          Colors.purple,
                        ),
                        _buildStatItem(
                          context,
                          'Streak',
                          '5 days', // This would be calculated in a real app
                          Icons.local_fire_department,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Meditation visualization
            const Text(
              'Weekly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: MeditationChart.withSampleData(),
            ),

            const SizedBox(height: 24),

            // Tips
            Card(
              color: Colors.purple.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          'Meditation Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Find a quiet place where you won\'t be disturbed',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Sit in a comfortable position with your back straight',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Focus on your breath, in and out',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• When your mind wanders, gently bring it back to your breath',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Start with short sessions and gradually increase',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
