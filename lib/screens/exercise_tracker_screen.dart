import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/gamification_provider.dart';
import '../providers/health_provider.dart';

class ExerciseTrackerScreen extends StatefulWidget {
  const ExerciseTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseTrackerScreen> createState() => _ExerciseTrackerScreenState();
}

class _ExerciseTrackerScreenState extends State<ExerciseTrackerScreen> {
  final TextEditingController _stepsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final gamificationProvider = Provider.of<GamificationProvider>(context);

    final steps = healthProvider.healthData.steps;
    // General recommendation is 10,000 steps
    const targetSteps = 10000;
    final progressPercentage = steps / targetSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Tracker'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Daily Steps',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Progress circle
                      SizedBox(
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: progressPercentage > 1 ? 1 : progressPercentage,
                                strokeWidth: 15,
                                backgroundColor: Colors.green.shade100,
                                color: Colors.green,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$steps',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'of $targetSteps steps',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  '${(progressPercentage * 100).toInt()}%',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Add steps
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stepsController,
                              decoration: const InputDecoration(
                                labelText: 'Enter Steps',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_walk),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (_stepsController.text.isEmpty) return;

                              final stepsToAdd = int.tryParse(_stepsController.text);
                              if (stepsToAdd == null || stepsToAdd <= 0) return;

                              setState(() {
                                _isLoading = true;
                              });

                              // Add steps
                              await healthProvider.addSteps(stepsToAdd);

                              // Add points for tracking steps
                              await gamificationProvider.addPoints(stepsToAdd ~/ 100);

                              // Check achievements
                              gamificationProvider.checkStepAchievements(steps + stepsToAdd);

                              // Update challenge progress
                              await gamificationProvider.updateChallengeProgress('step_master', stepsToAdd);

                              setState(() {
                                _isLoading = false;
                                _stepsController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2)
                            )
                                : const Text('Add'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Quick add buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickAddButton(context, 500, healthProvider, gamificationProvider),
                            _buildQuickAddButton(context, 1000, healthProvider, gamificationProvider),
                            _buildQuickAddButton(context, 2000, healthProvider, gamificationProvider),
                            _buildQuickAddButton(context, 5000, healthProvider, gamificationProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Weekly Progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: targetSteps.toDouble(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.round()} steps',
                                    const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                    return Text(
                                      days[value.toInt() % days.length],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 2000 == 0) {
                                      return Text(
                                        '${value.toInt()}',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: 2000,
                            ),
                            barGroups: [
                              // Sample data - would be replaced with actual weekly data
                              _createBarGroup(0, 6500),
                              _createBarGroup(1, 7800),
                              _createBarGroup(2, 8200),
                              _createBarGroup(3, 9500),
                              _createBarGroup(4, 7200),
                              _createBarGroup(5, 6800),
                              _createBarGroup(6, steps.toDouble()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise Tips',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem(
                        context,
                        Icons.timer,
                        'Take a short walk every hour to break up sitting time.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.stairs,
                        'Use stairs instead of elevators when possible.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.directions_walk,
                        'Aim for 10,000 steps a day for optimal health benefits.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.directions_run,
                        'Mix in some brisk walking or jogging to increase intensity.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Reset Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Step Count'),
                        content: const Text('Are you sure you want to reset your step count for today?'),
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
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Today\'s Steps'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(
      BuildContext context,
      int steps,
      HealthProvider healthProvider,
      GamificationProvider gamificationProvider,
      ) {
    return OutlinedButton(
      onPressed: () async {
        // Add steps
        await healthProvider.addSteps(steps);

        // Add points for tracking steps
        await gamificationProvider.addPoints(steps ~/ 100);

        // Check achievements
        gamificationProvider.checkStepAchievements(healthProvider.healthData.steps);

        // Update challenge progress
        await gamificationProvider.updateChallengeProgress('step_master', steps);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.green,
      ),
      child: Text('+$steps'),
    );
  }

  Widget _buildTipItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y >= 10000 ? Colors.green : Colors.green.shade300,
          width: 15,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}

