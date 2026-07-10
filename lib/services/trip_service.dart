import '../models/models.dart';
import 'api_service.dart';
import 'openrouter_service.dart';

/// 여행 계획 저장 + 홈 대시보드 데이터 조회.
class TripService {
  final ApiService api;
  final OpenRouterService openRouter;
  TripService(this.api, this.openRouter);

  /// 스타일 선택 완료 직후 - 온보딩 입력값을 백엔드에 임시 저장하고 세션 토큰을 받습니다.
  /// (웹의 httpOnly 쿠키에 대응하는 모바일 방식. 토큰은 [OnboardingSessionStore]에 저장됩니다.)
  ///
  /// 서버 계약: POST /onboarding/draft  (TripPlan.toJson())  -> { sessionToken }
  Future<String> saveDraft(TripPlan plan) async {
    final res = await api.post('/onboarding/draft', body: plan.toJson());
    return res['sessionToken'] as String;
  }

  /// 온보딩 완료 시 여행 계획을 서버에 저장하고 AI 추천 여행 ID 를 받습니다.
  /// [sessionToken]이 있으면 위 임시 저장([saveDraft])과 같은 세션임을 함께 전달합니다.
  ///
  /// 서버 계약: POST /trips  (TripPlan.toJson() + sessionToken)  -> { tripId }
  Future<String> createPlan(TripPlan plan, {String? sessionToken}) async {
    final body = plan.toJson();
    if (sessionToken != null) body['sessionToken'] = sessionToken;
    final res = await api.post('/trips', body: body);
    return res['tripId'] as String;
  }

  /// 스타일 선택 직후 - 저장 전에 AI가 입력값을 정리/전처리한 요약을 미리 봅니다.
  ///
  /// 백엔드가 아니라 클라이언트에서 OpenRouter를 직접 호출합니다
  /// ([OpenRouterService] 참고). 키는 프로필 > API 연결 설정에서 입력합니다.
  Future<TripSummary> previewPlan(TripPlan plan) {
    return openRouter.summarizePlan(plan, totalBudget: plan.budget);
  }

  /// 홈 화면 - 진행 중인 여행.
  /// 서버 계약: GET /trips/active -> { trip: {...} | null }
  Future<ActiveTrip?> fetchActiveTrip() async {
    final res = await api.get('/trips/active');
    final trip = res['trip'];
    if (trip == null) return null;
    return ActiveTrip.fromJson(trip as Map<String, dynamic>);
  }

  /// 홈 화면 - 예산별 AI 추천 여행지.
  /// 서버 계약: GET /recommendations -> { items: [...] }
  Future<List<RecommendedTheme>> fetchRecommendations() async {
    final res = await api.get('/recommendations');
    final items = res['items'] as List? ?? const [];
    return items
        .map((e) => RecommendedTheme.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
