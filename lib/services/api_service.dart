import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// REST API 통신을 담당하는 얇은 래퍼.
///
/// [baseUrl] 은 서버 주소, [apiKey] 는 백엔드 API 키입니다. 둘 다 앱 실행 중
/// [setBaseUrl] / [setApiKey] 로 바꿀 수 있어요(설정 화면에서 입력).
/// 로그인 토큰은 [setToken] 으로 주입하면 이후 요청 헤더에 자동으로 붙습니다.
class ApiService {
  final Dio _dio;
  String? _token;
  String? _apiKey;

  ApiService({required String baseUrl, String? apiKey, Dio? dio})
      : _apiKey = apiKey,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              contentType: 'application/json',
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 백엔드 API 키 (헤더). 서버 규격에 따라 키 이름을 맞추세요.
          if (_apiKey != null && _apiKey!.isNotEmpty) {
            options.headers['X-API-Key'] = _apiKey;
          }
          // 로그인 세션 토큰.
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ApiException(_messageFor(error)),
            ),
          );
        },
      ),
    );

    // 디버그 빌드에서만 요청/응답 본문을 콘솔에 출력(테스트용). 헤더는 API
    // 키·토큰이 들어있어 찍지 않음. 릴리스 빌드에는 포함되지 않습니다.
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[HTTP] $obj'),
      ));
    }
  }

  /// [DioException]을 화면에 그대로 보여줄 수 있는 한국어 메시지로 변환.
  /// 서버가 응답 본문에 에러 메시지를 담아 보냈다면 그걸 우선 사용해
  /// (예: OpenRouter의 "Invalid API key"/"Insufficient credits") 실제 원인을 보여줍니다.
  String _messageFor(DioException error) {
    final serverMessage = _extractServerMessage(error.response?.data);
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '서버 응답이 지연되고 있어요. 잠시 후 다시 시도해주세요.';
      case DioExceptionType.connectionError:
        return '네트워크에 연결할 수 없어요. 인터넷 연결을 확인해주세요.';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401 || status == 403) {
          return serverMessage ?? '로그인이 필요하거나 권한이 없어요.';
        }
        if (status != null && status >= 500) {
          return serverMessage ?? '서버에 문제가 발생했어요. 잠시 후 다시 시도해주세요.';
        }
        return serverMessage ?? '요청을 처리할 수 없어요. (오류 코드: $status)';
      case DioExceptionType.cancel:
        return '요청이 취소되었어요.';
      default:
        return serverMessage ?? '알 수 없는 오류가 발생했어요.';
    }
  }

  /// 응답 본문에서 흔히 쓰이는 에러 메시지 필드를 뽑아낸다.
  /// (예: `{"error": {"message": "..."}}`, `{"error": "..."}`, `{"message": "..."}`)
  String? _extractServerMessage(dynamic data) {
    if (data is! Map) return null;
    final err = data['error'];
    if (err is Map && err['message'] is String) {
      return err['message'] as String;
    }
    if (err is String && err.isNotEmpty) return err;
    if (data['message'] is String) return data['message'] as String;
    return null;
  }

  // ── 설정 ──
  String get baseUrl => _dio.options.baseUrl;
  String? get apiKey => _apiKey;

  void setBaseUrl(String url) => _dio.options.baseUrl = url.trim();
  void setApiKey(String? key) => _apiKey = (key == null || key.trim().isEmpty)
      ? null
      : key.trim();

  void setToken(String? token) => _token = token;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
  }) async {
    try {
      final res = await _dio.post(path, data: body);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// onError 인터셉터가 심어둔 [ApiException]을 꺼내거나, 없으면 새로 만든다.
  ApiException _unwrap(DioException e) => e.error is ApiException
      ? e.error as ApiException
      : ApiException(_messageFor(e));

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    return {'data': data};
  }
}

/// API 호출 실패를 화면에 보여줄 수 있는 메시지와 함께 표현하는 예외.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

/// Provider 들이 잡은 예외를 사용자에게 보여줄 메시지로 변환.
/// [ApiException]이면 미리 다듬어진 메시지를, 아니면 원본 문자열을 사용.
String describeError(Object error) =>
    error is ApiException ? error.message : error.toString();
