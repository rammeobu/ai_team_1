import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/trip_service.dart';

class HomeProvider extends ChangeNotifier {
  final TripService _service;
  HomeProvider(this._service);

  bool _loading = false;
  ActiveTrip? _activeTrip;
  List<RecommendedTheme> _themes = const [];
  String? _error;

  bool get isLoading => _loading;
  ActiveTrip? get activeTrip => _activeTrip;
  List<RecommendedTheme> get themes => _themes;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchActiveTrip(),
        _service.fetchRecommendations(),
      ]);
      _activeTrip = results[0] as ActiveTrip?;
      _themes = results[1] as List<RecommendedTheme>;
    } catch (e) {
      _error = describeError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
