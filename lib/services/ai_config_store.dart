import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// OpenRouter API 키를 기기 보안 저장소(Keychain/Keystore)에 보관/관리하는 store.
///
/// 이 키는 과금이 붙는 제3자 시크릿이라 shared_preferences 평문이 아니라
/// [FlutterSecureStorage]에 저장합니다([TokenStorage]와 동일한 방식).
class AiConfigStore extends ChangeNotifier {
  static const _kApiKey = 'openrouter_api_key';

  final FlutterSecureStorage _storage;
  String? _apiKey;

  AiConfigStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  String get apiKey => _apiKey ?? '';
  bool get isConfigured => apiKey.isNotEmpty;

  /// 앱 시작 시 저장된 키를 불러옵니다. `main()`에서 `await`로 한 번 호출하세요.
  Future<void> load() async {
    _apiKey = await _storage.read(key: _kApiKey);
    notifyListeners();
  }

  Future<void> save(String key) async {
    final trimmed = key.trim();
    _apiKey = trimmed.isEmpty ? null : trimmed;
    if (_apiKey == null) {
      await _storage.delete(key: _kApiKey);
    } else {
      await _storage.write(key: _kApiKey, value: _apiKey);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    _apiKey = null;
    await _storage.delete(key: _kApiKey);
    notifyListeners();
  }
}
