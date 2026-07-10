import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// 백엔드 연결 설정(Base URL · API 키)을 저장/관리하는 store.
///
/// 값은 shared_preferences 에 저장되어 앱을 다시 열어도 유지되고,
/// 변경 시 즉시 [ApiService] 에 반영됩니다.
class ApiConfigStore extends ChangeNotifier {
  static const _kBaseUrl = 'api_base_url';
  static const _kApiKey = 'api_key';

  final SharedPreferences _prefs;
  final ApiService _api;

  ApiConfigStore(this._prefs, this._api) {
    // 저장된 설정이 있으면 시작 시 적용.
    final url = _prefs.getString(_kBaseUrl);
    final key = _prefs.getString(_kApiKey);
    if (url != null && url.isNotEmpty) _api.setBaseUrl(url);
    if (key != null && key.isNotEmpty) _api.setApiKey(key);
  }

  String get baseUrl => _api.baseUrl;
  String get apiKey => _api.apiKey ?? '';
  bool get isConfigured => apiKey.isNotEmpty;

  Future<void> save({required String baseUrl, required String apiKey}) async {
    final url = baseUrl.trim();
    final key = apiKey.trim();
    _api.setBaseUrl(url);
    _api.setApiKey(key);
    await _prefs.setString(_kBaseUrl, url);
    await _prefs.setString(_kApiKey, key);
    notifyListeners();
  }

  Future<void> clear() async {
    _api.setApiKey(null);
    await _prefs.remove(_kApiKey);
    notifyListeners();
  }
}
