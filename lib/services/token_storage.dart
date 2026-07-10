import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 로그인 세션 토큰을 기기 보안 저장소(Keychain/Keystore)에 안전하게 보관.
///
/// shared_preferences 와 달리 암호화되어 저장되므로 액세스 토큰처럼
/// 민감한 값을 두기에 적합합니다.
class TokenStorage {
  static const _kAccessToken = 'accessToken';

  final FlutterSecureStorage _storage;
  const TokenStorage([this._storage = const FlutterSecureStorage()]);

  Future<void> saveToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<String?> readToken() => _storage.read(key: _kAccessToken);

  Future<void> clear() => _storage.delete(key: _kAccessToken);
}
