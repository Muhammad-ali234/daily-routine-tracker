import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user';
  
  late Box<User> _box;
  // Initialize with a default user immediately
  User _user = User(
    id: const Uuid().v4(),
    name: 'Default User',
    email: 'default@example.com',
    profileImageUrl: null,
    bio: 'This is a default user created when the app starts.',
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
    preferences: {
      'dailyTaskGoal': 3,
      'workStartTime': '09:00',
      'workEndTime': '17:00',
    },
  );
  bool _isInitializing = true;
  bool _useHive = false;  // Flag to control if we should use Hive
  
  User get user => _user;
  bool get isLoggedIn => true;  // Always logged in with default user
  bool get isInitializing => _isInitializing;
  
  UserProvider() {
    _initSetup();
  }
  
  Future<void> _initSetup() async {
    debugPrint('Initializing user provider with default data');
    // Just notify listeners that we have a default user
    _isInitializing = false;
    notifyListeners();
    
    // Try to initialize Hive in the background
    _initHive().then((_) {
      debugPrint('Hive initialization completed');
    }).catchError((e) {
      debugPrint('Error initializing Hive: $e');
    });
  }
  
  Future<void> _initHive() async {
    try {
      _box = await Hive.openBox<User>(_boxName);
      // Only try to load from Hive if we're using it
      if (_useHive) {
        _loadUser();
      }
    } catch (e) {
      debugPrint('Error in _initHive: $e');
      // Keep using the default user
    }
  }
  
  void _loadUser() {
    try {
      final hiveUser = _box.get(_currentUserKey);
      if (hiveUser != null) {
        _user = hiveUser;
        debugPrint('User loaded from box: ${_user.name}');
        notifyListeners();
      } else {
        debugPrint('No user found in Hive, keeping default user');
      }
    } catch (e) {
      debugPrint('Error in _loadUser: $e');
      // Keep using the default user
    }
  }
  
  Future<void> _createDefaultUser() async {
    final now = DateTime.now();
    final uuid = const Uuid().v4();
    
    _user = User(
      id: uuid,
      name: 'Demo User',
      email: 'demo@example.com',
      profileImageUrl: null,
      bio: 'Welcome to Deep Work Planner! This is a demo user.',
      createdAt: now,
      lastLoginAt: now,
      preferences: {
        'dailyTaskGoal': 5,
        'workStartTime': '09:00',
        'workEndTime': '17:00',
      },
    );
    
    if (_useHive) {
      await _saveUser();
    }
    debugPrint('Default user created: ${_user.name}');
    notifyListeners();
  }
  
  Future<void> _saveUser() async {
    if (_useHive) {
      try {
        await _box.put(_currentUserKey, _user);
        debugPrint('User saved to Hive: ${_user.name}');
      } catch (e) {
        debugPrint('Error saving user to Hive: $e');
      }
    }
  }
  
  Future<void> createUser({
    required String id,
    required String name,
    required String email,
    String? profileImageUrl,
    String? bio,
  }) async {
    final now = DateTime.now();
    _user = User(
      id: id,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      bio: bio,
      createdAt: now,
      lastLoginAt: now,
      preferences: {},
    );
    
    if (_useHive) {
      await _saveUser();
    }
    notifyListeners();
  }
  
  Future<void> updateUser({
    String? name,
    String? email,
    String? bio,
    File? profileImageFile,
    Map<String, dynamic>? preferences,
  }) async {
    String? profileImageUrl = _user.profileImageUrl;
    if (profileImageFile != null) {
      // TODO: Implement file upload to storage service
      // For now, we'll just use a placeholder URL
      profileImageUrl = 'https://example.com/profile_image.jpg';
    }

    _user = User(
      id: _user.id,
      name: name ?? _user.name,
      email: email ?? _user.email,
      bio: bio ?? _user.bio,
      profileImageUrl: profileImageUrl,
      createdAt: _user.createdAt,
      lastLoginAt: _user.lastLoginAt,
      preferences: preferences ?? _user.preferences,
    );
    
    if (_useHive) {
      await _saveUser();
    }
    notifyListeners();
  }
  
  Future<void> updateLastLogin() async {
    _user = User(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      bio: _user.bio,
      profileImageUrl: _user.profileImageUrl,
      createdAt: _user.createdAt,
      lastLoginAt: DateTime.now(),
      preferences: _user.preferences,
    );
    
    if (_useHive) {
      await _saveUser();
    }
    notifyListeners();
  }
  
  Future<void> updatePreference(String key, dynamic value) async {
    final newPreferences = Map<String, dynamic>.from(_user.preferences);
    newPreferences[key] = value;
    
    _user = User(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      bio: _user.bio,
      profileImageUrl: _user.profileImageUrl,
      createdAt: _user.createdAt,
      lastLoginAt: _user.lastLoginAt,
      preferences: newPreferences,
    );
    
    if (_useHive) {
      await _saveUser();
    }
    notifyListeners();
  }
  
  Future<void> logout() async {
    // Instead of actually logging out, just reset to the default user
    _user = User(
      id: const Uuid().v4(),
      name: 'Default User',
      email: 'default@example.com',
      profileImageUrl: null,
      bio: 'This is a default user created when the app starts.',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: {
        'dailyTaskGoal': 3,
        'workStartTime': '09:00',
        'workEndTime': '17:00',
      },
    );
    notifyListeners();
  }
  
  Future<void> deleteAccount() async {
    // Instead of actually deleting, just reset to the default user
    _user = User(
      id: const Uuid().v4(),
      name: 'Default User',
      email: 'default@example.com',
      profileImageUrl: null,
      bio: 'This is a default user created when the app starts.',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: {
        'dailyTaskGoal': 3,
        'workStartTime': '09:00',
        'workEndTime': '17:00',
      },
    );
    notifyListeners();
  }
  
  Future<void> deleteAllUsers() async {
    // No actual deletion, just reset to default
    _user = User(
      id: const Uuid().v4(),
      name: 'Default User',
      email: 'default@example.com',
      profileImageUrl: null,
      bio: 'This is a default user created when the app starts.',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: {
        'dailyTaskGoal': 3,
        'workStartTime': '09:00',
        'workEndTime': '17:00',
      },
    );
    notifyListeners();
  }
  
  // Method to enable Hive usage if needed later
  void enableHive() {
    _useHive = true;
    _initHive();
  }
}