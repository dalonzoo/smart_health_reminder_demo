import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/gamification_provider.dart';
import '../../providers/health_provider.dart';
import 'MeditationChart.dart';

class StepsProgressScreen extends StatefulWidget {
  const StepsProgressScreen({Key? key}) : super(key: key);

  @override
  State<StepsProgressScreen> createState() => _StepsProgressScreenState();
}

class _StepsProgressScreenState extends State<StepsProgressScreen> {
  final _stepsController = TextEditingController();
  final int _dailyGoal = 10000; // This could be user-configurable

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final gamificationProvider = Provider.of<GamificationProvider>(context);

    final currentSteps = healthProvider.healthData.steps;
    final progress = currentSteps / _dailyGoal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Steps',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$currentSteps / $_dailyGoal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress > 1.0 ? 1.0 : progress,
                      minHeight: 10,
                      backgroundColor: Colors.green.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress >= 1.0
                          ? 'Goal achieved! 🎉'
                          : '${(progress * 100).toInt()}% of daily goal',
                      style: TextStyle(
                        color: progress >= 1.0 ? Colors.green : Colors.grey[600],
                        fontWeight: progress >= 1.0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Steps visualization
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

            // Manual entry
            const Text(
              'Manual Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Steps',
                      border: OutlineInputBorder(),
                      hintText: 'Enter steps manually',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final steps = int.tryParse(_stepsController.text) ?? 0;
                    if (steps > 0) {
                      await healthProvider.addSteps(steps);

                      // Update challenge progress
                      gamificationProvider.updateChallengeProgress('step_master', steps);

                      // Check for step achievements
                      gamificationProvider.checkStepAchievements(currentSteps + steps);

                      // Clear the text field
                      _stepsController.clear();

                      // Show success message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $steps steps!')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick add buttons
            const Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAddButton(500, healthProvider, gamificationProvider),
                _buildQuickAddButton(1000, healthProvider, gamificationProvider),
                _buildQuickAddButton(2000, healthProvider, gamificationProvider),
                _buildQuickAddButton(5000, healthProvider, gamificationProvider),
              ],
            ),

            const SizedBox(height: 24),

            // Tips
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Walking Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Take the stairs instead of the elevator',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Park farther away from your destination',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Take a walking break every hour',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Walk while talking on the phone',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reset button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Step Count'),
                      content: const Text('Are you sure you want to reset today\'s step count?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            healthProvider.resetSteps();
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: const Text(
                  'Reset Today\'s Steps',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(int steps, HealthProvider healthProvider, GamificationProvider gamificationProvider) {
    return ElevatedButton(
      onPressed: () async {
        await healthProvider.addSteps(steps);

        // Update challenge progress
        gamificationProvider.updateChallengeProgress('step_master', steps);

        // Check for step achievements
        gamificationProvider.checkStepAchievements(healthProvider.healthData.steps);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added $steps steps!')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      child: Text('$steps'),
    );
  }
}
