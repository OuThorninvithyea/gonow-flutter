import 'package:flutter/foundation.dart';

/// Tracks which vehicle ids the rider has saved/favorited.
///
/// In-memory only for now — swap for persisted storage once a backend
/// exists. Shared across the home feed, the "Choose your ride" browse
/// screen, and the Saved tab so a heart tap is reflected everywhere.
class SavedVehiclesProvider extends ChangeNotifier {
  final Set<String> _savedIds = {};

  bool isSaved(String vehicleId) => _savedIds.contains(vehicleId);

  void toggle(String vehicleId) {
    if (!_savedIds.add(vehicleId)) {
      _savedIds.remove(vehicleId);
    }
    notifyListeners();
  }

  List<String> get savedIds => List.unmodifiable(_savedIds);
}
