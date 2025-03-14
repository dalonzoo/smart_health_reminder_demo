import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late int _age;
  late double _weight;
  late double _height;
  late String _gender;
  late int _activityLevel;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _emailController = TextEditingController(text: user.email);
      _age = user.age;
      _weight = user.weight;
      _height = user.height;
      _gender = user.gender;
      _activityLevel = user.activityLevel;
    } else {
      // Default values if user is somehow null
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _age = 30;
      _weight = 70.0;
      _height = 170.0;
      _gender = 'Male';
      _activityLevel = 3;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getActivityLevelDescription(int level) {
    switch (level) {
      case 1: return 'Sedentary (little to no exercise)';
      case 2: return 'Lightly active (light exercise 1-3 days/week)';
      case 3: return 'Moderately active (moderate exercise 3-5 days/week)';
      case 4: return 'Very active (hard exercise 6-7 days/week)';
      case 5: return 'Super active (physical job & training 2x/day)';
      default: return 'Unknown';
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        final updatedUser = User(
          id: currentUser.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          photoUrl: currentUser.photoUrl,
          age: _age,
          weight: _weight,
          height: _height,
          gender: _gender,
          activityLevel: _activityLevel,
        );

        await userProvider.updateUser(updatedUser);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error updating profile. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Basic Information
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  enabled: false, // Can't change email as it's used as identifier
                ),

                const SizedBox(height: 24),

                // Health Information
                const Text(
                  'Health Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Age Field
                Row(
                  children: [
                    const Icon(Icons.cake, color: Colors.grey),
                    const SizedBox(width: 16),
                    const Text('Age:', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Slider(
                        value: _age.toDouble(),
                        min: 12,
                        max: 100,
                        divisions: 88,
                        label: _age.toString(),
                        onChanged: (value) {
                          setState(() {
                            _age = value.round();
                          });
                        },
                      ),
                    ),
                    Text(
                      '$_age years',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 16),

                // Weight Field
                Row(
                  children: [
                    const Icon(Icons.monitor_weight, color: Colors.grey),
                    const SizedBox(width: 16),
                    const Text('Weight:', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Slider(
                        value: _weight,
                        min: 30,
                        max: 150,
                        divisions: 120,
                        label: _weight.toString(),
                        onChanged: (value) {
                          setState(() {
                            _weight = double.parse(value.toStringAsFixed(1));
                          });
                        },
                      ),
                    ),
                    Text(
                      '${_weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 16),

                // Height Field
                Row(
                  children: [
                    const Icon(Icons.height, color: Colors.grey),
                    const SizedBox(width: 16),
                    const Text('Height:', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Slider(
                        value: _height,
                        min: 120,
                        max: 220,
                        divisions: 100,
                        label: _height.toString(),
                        onChanged: (value) {
                          setState(() {
                            _height = double.parse(value.toStringAsFixed(1));
                          });
                        },
                      ),
                    ),
                    Text(
                      '${_height.toStringAsFixed(1)} cm',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 16),

                // Gender Selection
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.grey),
                    const SizedBox(width: 16),
                    const Text('Gender:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _gender = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Activity Level Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.grey),
                        const SizedBox(width: 16),
                        const Text('Activity Level:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_activityLevel - ${_getActivityLevelDescription(_activityLevel)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _activityLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _activityLevel.toString(),
                      onChanged: (value) {
                        setState(() {
                          _activityLevel = value.round();
                        });
                      },
                    ),
                  ],
                ),

                // Error Message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Update Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Update Profile', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

