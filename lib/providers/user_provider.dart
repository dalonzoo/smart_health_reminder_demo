import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  User? _currentUser;
  bool _isAuthenticated = false;

  UserProvider(this._prefs) {
    _loadUser();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _loadUser() async {
    final String? userString = _prefs.getString('currentUser');
    if (userString != null) {
      _currentUser = User.fromJson(jsonDecode(userString));
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      await _prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required int activityLevel,
  }) async {
    // In a real app, you would validate email uniqueness and store user with secure password
    // For simplicity, we'll just store user details locally

    // Check if email already exists
    final String? userString = _prefs.getString('user_$email');
    if (userString != null) {
      return false; // Email already registered
    }

    // Create and save new user
    final user = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      activityLevel: activityLevel,
    );

    await _prefs.setString('user_$email', jsonEncode(user.toJson()));
    await _prefs.setString('password_$email', password); // Not secure, just for demo

    // Log in the user
    return login(email: email, password: password);
  }

  Future<bool> login({required String email, required String password}) async {
    final String? userString = _prefs.getString('user_$email');
    final String? storedPassword = _prefs.getString('password_$email');

    if (userString != null && storedPassword == password) {
      _currentUser = User.fromJson(jsonDecode(userString));
      _isAuthenticated = true;
      await _saveUser();
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await _prefs.remove('currentUser');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    if (_currentUser != null) {
      _currentUser = updatedUser;
      await _saveUser();

      // Also update in the user storage
      await _prefs.setString('user_${updatedUser.email}', jsonEncode(updatedUser.toJson()));

      notifyListeners();
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(photoUrl: photoUrl);
      await _saveUser();
      notifyListeners();
    }
  }
}

