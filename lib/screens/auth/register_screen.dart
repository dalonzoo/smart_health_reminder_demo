import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _age = 30;
  double _weight = 70.0;
  double _height = 170.0;
  String _gender = 'Male';
  int _activityLevel = 3;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        age: _age,
        weight: _weight,
        height: _height,
        gender: _gender,
        activityLevel: _activityLevel,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Email is already registered. Please use a different email or login.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
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

                // Register Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Account', style: TextStyle(fontSize: 16)),
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

