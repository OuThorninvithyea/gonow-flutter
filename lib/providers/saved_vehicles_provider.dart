import 'package:flutter/foundation.dart';

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
