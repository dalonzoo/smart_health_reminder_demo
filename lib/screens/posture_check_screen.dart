import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/gamification_provider.dart';
import '../providers/health_provider.dart';

class PostureCheckScreen extends StatefulWidget {
  const PostureCheckScreen({Key? key}) : super(key: key);

  @override
  State<PostureCheckScreen> createState() => _PostureCheckScreenState();
}

class _PostureCheckScreenState extends State<PostureCheckScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCheckComplete = false;
  int _postureCheckCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completePostureCheck();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startPostureCheck() async {
    setState(() {
      _isCheckComplete = false;
    });

    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _completePostureCheck() async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);

    // Update posture check time
    await healthProvider.updatePostureCheck();

    // Add points
    await gamificationProvider.addPoints(10);

    // Increment counter for achievement tracking
    setState(() {
      _postureCheckCount++;
      _isCheckComplete = true;
    });

    // Check achievements
    if (_postureCheckCount >= 10) {
      gamificationProvider.checkPostureAchievements(10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final lastPostureCheck = healthProvider.healthData.lastPostureCheck;
    final timeSinceCheck = DateTime.now().difference(lastPostureCheck);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture Check'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Posture Animation Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        _isCheckComplete
                            ? 'Great Job!'
                            : 'Adjust Your Posture',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isCheckComplete
                            ? 'Your posture has been checked and corrected.'
                            : 'Follow the guidelines below for correct posture.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Posture Animation
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCheckComplete
                                  ? Colors.green.withOpacity(0.2)
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.1 + (_animation.value * 0.2)),
                              border: Border.all(
                                color: _isCheckComplete
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _isCheckComplete ? Icons.check : Icons.accessibility_new,
                                size: 100,
                                color: _isCheckComplete
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Start Button
                      if (!_isCheckComplete && !_animationController.isAnimating)
                        ElevatedButton.icon(
                          onPressed: _startPostureCheck,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Posture Check'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        )
                      else if (_animationController.isAnimating)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: _animation.value,
                              backgroundColor: Colors.grey[200],
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Straighten your back, align your head, and relax your shoulders...',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _startPostureCheck,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check Again'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Last Check Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Posture Check',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.access_time,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time since last check:',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                timeSinceCheck.inMinutes < 60
                                    ? '${timeSinceCheck.inMinutes} minutes ago'
                                    : timeSinceCheck.inHours < 24
                                    ? '${timeSinceCheck.inHours} hours ago'
                                    : '${timeSinceCheck.inDays} days ago',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: timeSinceCheck.inHours > 1
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Posture Tips',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem(
                        context,
                        Icons.chair,
                        'Sit with your back straight and shoulders relaxed.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.height,
                        'Keep your feet flat on the floor and knees at hip level.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.monitor,
                        'Position your screen at eye level to avoid neck strain.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.schedule,
                        'Take a posture break every hour when sitting for long periods.',
                      ),
                      _buildTipItem(
                        context,
                        Icons.fitness_center,
                        'Strengthen your core muscles to help maintain good posture.',
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

