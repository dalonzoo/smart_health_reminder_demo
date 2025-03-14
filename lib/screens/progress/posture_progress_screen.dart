import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../providers/gamification_provider.dart';
import '../../providers/health_provider.dart';

class PostureProgressScreen extends StatefulWidget {
  const PostureProgressScreen({Key? key}) : super(key: key);

  @override
  State<PostureProgressScreen> createState() => _PostureProgressScreenState();
}

class _PostureProgressScreenState extends State<PostureProgressScreen> {
  int _postureChecks = 0;
  Timer? _timer;
  bool _isCheckingPosture = false;
  int _countdownSeconds = 3;

  @override
  void initState() {
    super.initState();
    _loadPostureChecks();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPostureChecks() async {
    // In a real app, this would load from a database or provider
    setState(() {
      _postureChecks = 5; // Example value
    });
  }

  void _startPostureCheck() {
    setState(() {
      _isCheckingPosture = true;
      _countdownSeconds = 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _completePostureCheck();
        }
      });
    });
  }

  void _completePostureCheck() {
    _timer?.cancel();

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);

    healthProvider.updatePostureCheck();

    setState(() {
      _isCheckingPosture = false;
      _postureChecks++;
    });

    // Check for posture achievements
    gamificationProvider.checkPostureAchievements(_postureChecks);

    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Posture check completed! Keep up the good work!'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final lastPostureCheck = healthProvider.healthData.lastPostureCheck;
    final timeSinceLastCheck = DateTime.now().difference(lastPostureCheck);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posture check card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Posture Check',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isCheckingPosture
                        ? Column(
                      children: [
                        const Text(
                          'Straighten your back and sit properly',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$_countdownSeconds',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            _timer?.cancel();
                            setState(() {
                              _isCheckingPosture = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    )
                        : Column(
                      children: [
                        Image.asset(
                          'assets/images/posture.png',
                          height: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.teal.withOpacity(0.1),
                              child: const Center(
                                child: Icon(
                                  Icons.accessibility_new,
                                  size: 80,
                                  color: Colors.teal,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Last check: ${_formatTimeSince(timeSinceLastCheck)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _startPostureCheck,
                          icon: const Icon(Icons.accessibility_new),
                          label: const Text('Check Posture Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
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
                      'Your Posture Stats',
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
                          'Total Checks',
                          '$_postureChecks',
                          Icons.check_circle,
                          Colors.teal,
                        ),
                        _buildStatItem(
                          context,
                          'Today',
                          '3', // This would be calculated in a real app
                          Icons.today,
                          Colors.teal,
                        ),
                        _buildStatItem(
                          context,
                          'Streak',
                          '4 days', // This would be calculated in a real app
                          Icons.local_fire_department,
                          Colors.teal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tips
            Card(
              color: Colors.teal.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Good Posture Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Keep your feet flat on the floor',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Align your back with the chair\'s backrest',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Keep your shoulders relaxed',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Position your screen at eye level',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Take regular breaks to stand and stretch',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reminder settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Posture Reminders'),
                      subtitle: const Text('Get reminded to check your posture'),
                      value: true, // This would be from settings in a real app
                      onChanged: (value) {
                        // Update settings
                      },
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications, color: Colors.teal),
                      ),
                    ),
                    ListTile(
                      title: const Text('Reminder Frequency'),
                      subtitle: const Text('Every 30 minutes'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to frequency settings
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.timer, color: Colors.teal),
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

  String _formatTimeSince(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
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
