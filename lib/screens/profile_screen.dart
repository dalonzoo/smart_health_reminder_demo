import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_health_reminder_demo/screens/posture_check_screen.dart';
import 'package:smart_health_reminder_demo/screens/profile/edit_profile_screen.dart';
import 'package:smart_health_reminder_demo/screens/profile/settings_screen.dart';
import 'package:smart_health_reminder_demo/screens/water_tracker_screen.dart';

import '../models/user.dart';
import '../providers/gamification_provider.dart';
import '../providers/health_provider.dart';
import '../providers/user_provider.dart';
import 'exercise_tracker_screen.dart';
import 'meditation_tracker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            user != null
                ? _buildUserHeader(context, user, gamificationProvider)
                : _buildGuestHeader(context),

            const SizedBox(height: 24),

            // Health Trackers
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Trackers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTrackerItem(
                      context,
                      Icons.water_drop,
                      'Water Intake',
                      'Track your daily hydration',
                      Colors.blue,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WaterTrackerScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    _buildTrackerItem(
                      context,
                      Icons.directions_walk,
                      'Exercise & Steps',
                      'Log your physical activity',
                      Colors.green,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExerciseTrackerScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    _buildTrackerItem(
                      context,
                      Icons.self_improvement,
                      'Meditation',
                      'Track your mindfulness sessions',
                      Colors.orange,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MeditationTrackerScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    _buildTrackerItem(
                      context,
                      Icons.accessibility_new,
                      'Posture Check',
                      'Ensure you maintain good posture',
                      Colors.purple,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PostureCheckScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats section
            if (user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Stats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        context,
                        Icons.star,
                        'Total Points',
                        '${gamificationProvider.points}',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.local_fire_department,
                        'Current Streak',
                        '${gamificationProvider.streak} days',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.emoji_events,
                        'Achievements',
                        '${gamificationProvider.unlockedAchievements.length}/${gamificationProvider.achievements.length}',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.flag,
                        'Challenges Completed',
                        '${gamificationProvider.challenges.where((c) => c.isCompleted).length}/${gamificationProvider.challenges.length}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Health Stats section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Health Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        context,
                        Icons.monitor_weight,
                        'BMI',
                        '${user.bmi.toStringAsFixed(1)} (${user.bmiCategory})',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.restaurant,
                        'Daily Calories',
                        '${user.dailyCalorieRequirement} kcal',
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.water_drop,
                        'Water Goal',
                        '${Provider.of<HealthProvider>(context).getRecommendedWaterIntake(
                          temperatureCelsius: 25,
                          activityLevel: user.activityLevel,
                        )} ml',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // About section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Smart Health Reminder & Gamification App',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Developed for GSoC 2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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

  Widget _buildUserHeader(
      BuildContext context,
      User user,

      GamificationProvider gamificationProvider
      ) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Level ${(gamificationProvider.points / 1000).floor() + 1}',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Guest User',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please login to track your progress',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to login screen
          },
          icon: const Icon(Icons.login),
          label: const Text('Login'),
        ),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
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

  Widget _buildTrackerItem(
      BuildContext context,
      IconData icon,
      String title,
      String description,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

