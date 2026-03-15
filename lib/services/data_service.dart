import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exhibit.dart';

/// Service for loading and resolving exhibit data from local JSON.
class DataService {
  static const String _exhibitsPath = 'assets/data/exhibits.json';

  List<Exhibit>? _exhibits;

  /// Loads exhibits from JSON. Call once at app startup.
  Future<void> loadExhibits() async {
    final String jsonString = await rootBundle.loadString(_exhibitsPath);
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    final List<dynamic> exhibitsList = json['exhibits'] as List<dynamic>;
    _exhibits = exhibitsList
        .map((e) => Exhibit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns exhibit for given ID, or null if not found.
  Exhibit? getExhibitById(String id) {
    if (_exhibits == null) return null;
    try {
      return _exhibits!.firstWhere((e) => e.id == id);
    } on StateError {
      return null;
    }
  }
}
