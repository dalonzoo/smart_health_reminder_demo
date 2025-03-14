import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/gamification_provider.dart';
import '../providers/health_provider.dart';
import '../providers/user_provider.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({Key? key}) : super(key: key);

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int _amountToAdd = 250; // Default amount in ml
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final user = userProvider.currentUser;
    final waterIntake = healthProvider.healthData.waterIntake;

    // Recommended daily water intake (2500ml is a general baseline)
    final recommendedWaterIntake = user != null
        ? healthProvider.getRecommendedWaterIntake(
      temperatureCelsius: 25, // Could be fetched from a weather API
      activityLevel: user.activityLevel,
    )
        : 2500;

    // Progress percentage
    final progressPercentage = waterIntake / recommendedWaterIntake;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Water Intake Progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Daily Water Intake',
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
                                backgroundColor: Colors.blue.shade100,
                                color: Colors.blue,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$waterIntake ml',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'of $recommendedWaterIntake ml',
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

                      // Add water intake options
                      const Text(
                        'Add Water Intake:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Pre-defined amounts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildWaterAmountButton(context, 100),
                          _buildWaterAmountButton(context, 250),
                          _buildWaterAmountButton(context, 500),
                          _buildWaterAmountButton(context, 750),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Custom amount
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _amountToAdd.toDouble(),
                              min: 50,
                              max: 1000,
                              divisions: 19,
                              label: '$_amountToAdd ml',
                              onChanged: (value) {
                                setState(() {
                                  _amountToAdd = value.round();
                                });
                              },
                            ),
                          ),
                          Text(
                            '$_amountToAdd ml',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Add Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          await healthProvider.addWaterIntake(_amountToAdd);

                          // Add points for tracking water
                          await gamificationProvider.addPoints(5);

                          // Update challenge progress
                          if (waterIntake >= 2000) {
                            await gamificationProvider.updateChallengeProgress('water_week', 1);
                          }

                          // Show confirmation animation
                          setState(() {
                            _showConfetti = true;
                          });

                          // Hide animation after 2 seconds
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() {
                                _showConfetti = false;
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Water', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hydration Tips',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem(
                        context,
                        Icons.lightbulb_outline,
                        'Drink a glass of water as soon as you wake up to rehydrate.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.schedule,
                        'Set regular reminders throughout the day.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.fitness_center,
                        'Drink more water before, during, and after exercise.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.wb_sunny,
                        'Increase your intake during hot weather.',
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
                            maxY: recommendedWaterIntake.toDouble(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.round()} ml',
                                    const TextStyle(
                                      color: Colors.white,
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
                                    if (value % 500 == 0) {
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
                              horizontalInterval: 500,
                            ),
                            barGroups: [
                              // Sample data - would be replaced with actual weekly data
                              _createBarGroup(0, 1800, recommendedWaterIntake),
                              _createBarGroup(1, 2100, recommendedWaterIntake),
                              _createBarGroup(2, 1900, recommendedWaterIntake),
                              _createBarGroup(3, 2300, recommendedWaterIntake),
                              _createBarGroup(4, 2000, recommendedWaterIntake),
                              _createBarGroup(5, 1700, recommendedWaterIntake),
                              _createBarGroup(6, waterIntake.toDouble(), recommendedWaterIntake),
                            ],
                          ),
                        ),
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
                        title: const Text('Reset Water Intake'),
                        content: const Text('Are you sure you want to reset your water intake for today?'),
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
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Today\'s Water Intake'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterAmountButton(BuildContext context, int amount) {
    return InkWell(
      onTap: () {
        setState(() {
          _amountToAdd = amount;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _amountToAdd == amount
              ? Colors.blue
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _amountToAdd == amount ? Colors.white : Colors.blue,
              ),
            ),
            Text(
              'ml',
              style: TextStyle(
                fontSize: 12,
                color: _amountToAdd == amount ? Colors.white : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double y, int recommendedIntake) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y >= recommendedIntake ? Colors.green : Colors.blue,
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

