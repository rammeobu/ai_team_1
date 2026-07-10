import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 온보딩 임시 저장(draft) 세션 토큰을 기기 보안 저장소(Keychain/Keystore)에 보관.
///
/// 웹의 httpOnly 쿠키와 같은 목적(클라이언트 코드가 값을 함부로 들고 다니지 않고,
/// 서버가 발급한 세션만 식별자로 사용)을 모바일에서 구현한 것입니다.
/// [TokenStorage]와 동일한 방식입니다.
class OnboardingSessionStore {
  static const _kSessionToken = 'onboarding_session_token';

  final FlutterSecureStorage _storage;
  const OnboardingSessionStore([this._storage = const FlutterSecureStorage()]);

  Future<void> saveToken(String token) =>
      _storage.write(key: _kSessionToken, value: token);

  Future<String?> readToken() => _storage.read(key: _kSessionToken);

  Future<void> clear() => _storage.delete(key: _kSessionToken);
}
