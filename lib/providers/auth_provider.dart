import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  User? _currentUser;
  bool _isAuthenticated = false;

  AuthProvider(this._prefs) {
    _loadUser();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _loadUser() async {
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        // Handle parsing error
        _currentUser = null;
        _isAuthenticated = false;
      }
    }
  }

  Future<void> _saveUser(User user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> register(String name, String email, String password) async {
    // In a real app, this would make an API call to register the user
    // For demo purposes, we'll just create a user locally

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if email already exists
    final existingUsers = _prefs.getStringList('users') ?? [];
    for (final userJson in existingUsers) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.email == email) {
        throw Exception('Email already in use');
      }
    }

    // Create new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      age: 99, weight: 99, height: 99, gender: '', activityLevel: 99,
    );

    // Save user to "database"
    existingUsers.add(jsonEncode(user.toJson()));
    await _prefs.setStringList('users', existingUsers);

    // Save password (in a real app, this would be hashed)
    await _prefs.setString('password_${user.id}', password);

    // Auto login
    _currentUser = user;
    _isAuthenticated = true;
    await _saveUser(user);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // In a real app, this would make an API call to authenticate the user
    // For demo purposes, we'll just check against stored users

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Find user by email
    final existingUsers = _prefs.getStringList('users') ?? [];
    User? foundUser;

    for (final userJson in existingUsers) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.email == email) {
        foundUser = user;
        break;
      }
    }

    if (foundUser == null) {
      throw Exception('User not found');
    }

    // Check password
    final storedPassword = _prefs.getString('password_${foundUser.id}');
    if (storedPassword != password) {
      throw Exception('Invalid password');
    }

    // Set as current user
    _currentUser = foundUser;
    _isAuthenticated = true;
    await _saveUser(foundUser);
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.remove('user');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Update user in "database"
    final existingUsers = _prefs.getStringList('users') ?? [];
    final updatedUsers = <String>[];

    for (final userJson in existingUsers) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.id == updatedUser.id) {
        updatedUsers.add(jsonEncode(updatedUser.toJson()));
      } else {
        updatedUsers.add(userJson);
      }
    }

    await _prefs.setStringList('users', updatedUsers);

    // Update current user
    _currentUser = updatedUser;
    await _saveUser(updatedUser);
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    // In a real app, this would send a reset email
    // For demo purposes, we'll just check if the user exists

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Find user by email
    final existingUsers = _prefs.getStringList('users') ?? [];
    bool userExists = false;

    for (final userJson in existingUsers) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.email == email) {
        userExists = true;
        break;
      }
    }

    if (!userExists) {
      throw Exception('User not found');
    }

    // In a real app, this would send an email with a reset link
    // For demo purposes, we'll just return success
  }
}
