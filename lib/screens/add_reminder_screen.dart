import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';
import '../providers/reminder_provider.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({Key? key, this.reminder}) : super(key: key);

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late ReminderType _type;
  late ReminderFrequency _frequency;
  late TimeOfDay _time;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _title = widget.reminder?.title ?? '';
    _description = widget.reminder?.description ?? '';
    _type = widget.reminder?.type ?? ReminderType.water;
    _frequency = widget.reminder?.frequency ?? ReminderFrequency.daily;
    _time = widget.reminder?.time ?? TimeOfDay.now();
    _isActive = widget.reminder?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) {
                _description = value!;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReminderType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: ReminderType.values.map((type) {
                return DropdownMenuItem<ReminderType>(
                  value: type,
                  child: Text(_getReminderTypeText(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReminderFrequency>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: ReminderFrequency.values.map((frequency) {
                return DropdownMenuItem<ReminderFrequency>(
                  value: frequency,
                  child: Text(_getReminderFrequencyText(frequency)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Time'),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.access_time),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (pickedTime != null) {
                  setState(() {
                    _time = pickedTime;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  final reminder = Reminder(
                    id: widget.reminder?.id ?? const Uuid().v4(),
                    title: _title,
                    description: _description,
                    type: _type,
                    frequency: _frequency,
                    time: _time,
                    isActive: _isActive,
                  );
                  
                  if (widget.reminder == null) {
                    reminderProvider.addReminder(reminder);
                  } else {
                    reminderProvider.updateReminder(reminder);
                  }
                  
                  Navigator.pop(context);
                }
              },
              child: Text(widget.reminder == null ? 'Add Reminder' : 'Update Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  String _getReminderTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return 'Water';
      case ReminderType.posture:
        return 'Posture';
      case ReminderType.steps:
        return 'Steps';
      case ReminderType.meditation:
        return 'Meditation';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String _getReminderFrequencyText(ReminderFrequency frequency) {
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

