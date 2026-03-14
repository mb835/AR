import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exhibit.dart';

/// Service for loading and resolving exhibit data from local JSON.
class ExhibitService {
  static const String _exhibitsPath = 'assets/data/exhibits.json';

  List<Exhibit>? _exhibits;

  /// Loads exhibits from JSON. Call once at app startup.
  Future<void> loadExhibits() async {
    final String jsonString =
        await rootBundle.loadString(_exhibitsPath);
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    _exhibits = jsonList
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

  /// Returns tracking image path for given marker ID.
  /// Matches marker_id to assets/images/marker_{marker_id}.png
  String getTrackingImagePath(String markerId) {
    return 'assets/images/marker_$markerId.png';
  }
}
