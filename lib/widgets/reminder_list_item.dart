import 'package:flutter/material.dart';

import '../models/reminder.dart';

class ReminderListItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderListItem({
    Key? key,
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getReminderColor(reminder.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getReminderIcon(reminder.type),
                    color: _getReminderColor(reminder.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: reminder.isActive ? null : Colors.grey,
                        ),
                      ),
                      Text(
                        reminder.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: reminder.isActive ? Colors.grey[600] : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: _getReminderColor(reminder.type),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      reminder.time.format(context),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: reminder.isActive ? null : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyText(reminder.frequency),
                      style: TextStyle(
                        fontSize: 14,
                        color: reminder.isActive ? null : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                      color: Colors.red,
                    ),
                  ],
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

