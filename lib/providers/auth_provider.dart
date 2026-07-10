import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  AuthProvider(this._service);

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  /// 소셜 로그인(구글/카카오/애플). 브라우저를 열어 백엔드 OAuth 인증을 진행합니다.
  Future<bool> signInWithOAuth(SocialProvider provider) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.signInWithOAuth(provider);
      return true;
    } catch (e) {
      _error = describeError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 앱 시작 시 저장된 토큰으로 자동 로그인 시도. 성공하면 true.
  Future<bool> restoreSession() async {
    _user = await _service.restoreSession();
    notifyListeners();
    return _user != null;
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }
}
