import 'package:flutter/material.dart';

import '../models/reminder.dart';

class NextReminderCard extends StatelessWidget {
  final Reminder? reminder;

  const NextReminderCard({Key? key, this.reminder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reminder == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                const Text(
                  'No upcoming reminders',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getReminderColor(reminder!.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getReminderIcon(reminder!.type),
                    color: _getReminderColor(reminder!.type),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reminder!.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      reminder!.time.format(context),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyText(reminder!.frequency),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle reminder action

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getReminderColor(reminder!.type),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.posture:
        return Icons.accessibility_new;
      case ReminderType.steps:
        return Icons.directions_walk;
      case ReminderType.meditation:
        return Icons.self_improvement;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  Color _getReminderColor(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Colors.blue;
      case ReminderType.posture:
        return Colors.purple;
      case ReminderType.steps:
        return Colors.green;
      case ReminderType.meditation:
        return Colors.orange;
      case ReminderType.custom:
        return Colors.grey;
    }
  }

  String _getFrequencyText(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.hourly:
        return 'Hourly';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }
}

