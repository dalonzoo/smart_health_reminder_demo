import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../providers/gamification_provider.dart';
import '../../providers/health_provider.dart';
import 'MeditationChart.dart';

class WaterProgressScreen extends StatefulWidget {
  const WaterProgressScreen({Key? key}) : super(key: key);

  @override
  State<WaterProgressScreen> createState() => _WaterProgressScreenState();
}

class _WaterProgressScreenState extends State<WaterProgressScreen> {
  final List<int> _quickAddOptions = [100, 200, 300, 500];
  int _customAmount = 0;
  final _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final gamificationProvider = Provider.of<GamificationProvider>(context);

    // Get recommended water intake based on temperature and activity level
    final recommendedWaterIntake = healthProvider.getRecommendedWaterIntake(
      temperatureCelsius: 25, // This would come from a weather API in a real app
      activityLevel: 3, // This would be calculated based on user's activity
    );

    final currentWaterIntake = healthProvider.healthData.waterIntake;
    final progress = currentWaterIntake / recommendedWaterIntake;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
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
                          'Today\'s Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$currentWaterIntake / $recommendedWaterIntake ml',
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
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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

            // Water intake visualization
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

            // Quick add options
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
                for (final amount in _quickAddOptions)
                  ElevatedButton(
                    onPressed: () async {
                      await healthProvider.addWaterIntake(amount);

                      // Update challenge progress
                      gamificationProvider.updateChallengeProgress('water_week', 1);

                      // Check if daily goal is met
                      if (healthProvider.healthData.waterIntake >= recommendedWaterIntake &&
                          healthProvider.healthData.waterIntake - amount < recommendedWaterIntake) {
                        gamificationProvider.incrementStreak();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Daily water goal achieved! 🎉')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('$amount ml'),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Custom amount
            const Text(
              'Custom Amount',
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
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (ml)',
                      border: OutlineInputBorder(),
                      suffixText: 'ml',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _customAmount = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _customAmount > 0
                      ? () async {
                    await healthProvider.addWaterIntake(_customAmount);

                    // Update challenge progress
                    gamificationProvider.updateChallengeProgress('water_week', 1);

                    // Check if daily goal is met
                    if (healthProvider.healthData.waterIntake >= recommendedWaterIntake &&
                        healthProvider.healthData.waterIntake - _customAmount < recommendedWaterIntake) {
                      gamificationProvider.incrementStreak();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Daily water goal achieved! 🎉')),
                      );
                    }

                    // Clear the text field
                    _customAmountController.clear();
                    setState(() {
                      _customAmount = 0;
                    });
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tips
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Hydration Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Drink a glass of water when you wake up',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Keep a water bottle with you throughout the day',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Set reminders to drink water regularly',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Drink water before, during, and after exercise',
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
                      title: const Text('Reset Water Intake'),
                      content: const Text('Are you sure you want to reset today\'s water intake?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            healthProvider.resetWaterIntake();
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
                  'Reset Today\'s Intake',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
