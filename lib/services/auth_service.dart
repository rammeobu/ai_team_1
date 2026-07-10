import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../models/models.dart';
import 'api_service.dart';
import 'token_storage.dart';

/// 백엔드 딥링크 콜백 스킴. AndroidManifest.xml / iOS Info.plist 에 등록한 값과
/// 반드시 동일해야 합니다. (백엔드가 리다이렉트하는 스킴)
const kOAuthCallbackScheme = 'withact';

/// 인증 관련 API.
///
/// 소셜 로그인은 백엔드의 OAuth2 엔드포인트로 브라우저를 열고,
/// 콜백(withact://...?token=...)으로 돌아온 토큰을 보안 저장소에 저장합니다.
class AuthService {
  final ApiService _api;
  final TokenStorage _tokens;

  AuthService(this._api, [TokenStorage? tokens])
      : _tokens = tokens ?? const TokenStorage();

  /// provider → 백엔드 OAuth2 경로. 서버 라우팅과 맞춰야 합니다.
  String _providerPath(SocialProvider provider) => switch (provider) {
        SocialProvider.google => 'google',
        SocialProvider.kakao => 'kakao',
        SocialProvider.apple => 'apple',
      };

  /// 열어야 할 OAuth 시작 URL.
  ///
  /// 모바일: `${baseUrl}/oauth2/authorization/{provider}` → 백엔드가 withact:// 로 리다이렉트.
  /// 웹: 브라우저는 커스텀 스킴을 못 여니, 백엔드가 웹 앱 주소(/auth.html)로
  ///     토큰을 돌려주도록 redirect_uri 를 함께 전달합니다.
  ///     (백엔드가 이 파라미터를 존중해야 하며, 파라미터 이름은 서버 규격에 맞추세요.)
  String _buildAuthUrl(SocialProvider provider) {
    final base =
        '${_api.baseUrl}/oauth2/authorization/${_providerPath(provider)}';
    if (!kIsWeb) return base;
    final redirectUri = '${Uri.base.origin}/auth.html';
    return Uri.parse(base).replace(
      queryParameters: {'redirect_uri': redirectUri},
    ).toString();
  }

  /// 실제 OAuth 로그인.
  ///
  /// 1) `${baseUrl}/oauth2/authorization/{provider}` 를 브라우저로 연다
  /// 2) 로그인 완료 후 백엔드가 `withact://...?token=...` 로 리다이렉트
  /// 3) token 을 보안 저장소에 저장하고 이후 API 요청 헤더에 자동 첨부
  Future<AppUser> signInWithOAuth(SocialProvider provider) async {
    final url = _buildAuthUrl(provider);
    debugPrint('[OAuth] 1) authenticate 시작 · scheme=$kOAuthCallbackScheme');
    debugPrint('[OAuth]    url=$url');

    final String result;
    try {
      result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: kOAuthCallbackScheme,
      );
    } catch (e) {
      // 사용자가 취소했거나 브라우저에서 돌아오지 못한 경우.
      debugPrint('[OAuth] X authenticate 실패/취소: $e');
      rethrow;
    }
    debugPrint('[OAuth] 2) 콜백 수신: $result');

    final token = Uri.parse(result).queryParameters['token'];
    debugPrint('[OAuth] 3) token 파싱: ${token == null ? "없음" : "OK(${token.length}자)"}');
    if (token == null || token.isEmpty) {
      throw const ApiException('로그인 토큰을 받지 못했어요. (콜백 URL에 token 파라미터 없음)');
    }

    await _tokens.saveToken(token);
    _api.setToken(token);
    debugPrint('[OAuth] 4) 토큰 저장 완료 · /auth/me 조회');
    final user = await _fetchMe(fallbackName: '여행자');
    debugPrint('[OAuth] 5) 로그인 완료 · user=${user.name}');
    return user;
  }

  /// 앱 시작 시 저장된 토큰이 있으면 세션을 복원. 없으면 null.
  Future<AppUser?> restoreSession() async {
    final token = await _tokens.readToken();
    if (token == null || token.isEmpty) return null;
    _api.setToken(token);
    try {
      return await _fetchMe(fallbackName: '여행자');
    } catch (_) {
      // 토큰 만료 등 → 정리하고 로그아웃 상태로.
      await signOut();
      return null;
    }
  }

  /// 현재 로그인한 사용자 프로필 조회. 서버 규격에 맞게 경로/파싱을 조정하세요.
  ///   GET /auth/me -> { user: { id, name, email, photoUrl } } 또는 { ... }
  Future<AppUser> _fetchMe({required String fallbackName}) async {
    try {
      final res = await _api.get('/auth/me');
      final raw = (res['user'] ?? res) as Map<String, dynamic>;
      return AppUser.fromJson(raw);
    } catch (e) {
      // 프로필 API 가 아직 없더라도 토큰 로그인 자체는 성공으로 처리.
      debugPrint('[OAuth]    /auth/me 조회 실패(무시하고 진행): $e');
      return AppUser(id: 'me', name: fallbackName, email: '', photoUrl: null);
    }
  }

  Future<void> signOut() async {
    _api.setToken(null);
    await _tokens.clear();
    // await _api.post('/auth/signout');
  }
}
