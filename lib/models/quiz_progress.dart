// models/quiz_progress.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProgress {
  int currentLevel;
  Map<int, int> levelScores; // level -> score
  Map<int, bool> levelPassed; // level -> pass status

  QuizProgress({
    this.currentLevel = 1,
    Map<int, int>? levelScores,
    Map<int, bool>? levelPassed,
  })  : levelScores = levelScores ?? {},
        levelPassed = levelPassed ?? {};

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'levelScores': levelScores.map((k, v) => MapEntry(k.toString(), v)),
      'levelPassed': levelPassed.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  // Create from JSON
  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      currentLevel: json['currentLevel'] ?? 1,
      levelScores: (json['levelScores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},
      levelPassed: (json['levelPassed'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as bool)) ??
          {},
    );
  }

  // Reset all progress to Level 1
  void reset() {
    currentLevel = 1;
    levelScores.clear();
    levelPassed.clear();
  }

  // Save to SharedPreferences
  Future<void> save({String key = 'quiz_progress'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(toJson());
      await prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('Error saving quiz progress: $e');
    }
  }

  // Load from SharedPreferences
  static Future<QuizProgress> load({String key = 'quiz_progress'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return QuizProgress.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading quiz progress: $e');
    }
    return QuizProgress(); // Return default (Level 1)
  }

  // Clear all progress
  static Future<void> clear({String key = 'quiz_progress'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      debugPrint('Error clearing quiz progress: $e');
    }
  }
}
