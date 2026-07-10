import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';

import '../models/models.dart';
import 'ai_config_store.dart';
import 'api_service.dart';

/// OpenRouter(https://openrouter.ai)를 통해 AI 모델을 직접 호출하는 서비스.
///
/// OpenRouter는 OpenAI Chat Completions 호환 API로 여러 모델(GPT/Claude/Gemini 등)에
/// 접근할 수 있게 해줍니다. [ApiService]를 그대로 재사용하되 baseUrl만 OpenRouter로,
/// 인증은 `Authorization: Bearer <key>`(= [ApiService.setToken])로 보냅니다.
///
/// 주의: API 키가 클라이언트 앱에 직접 저장/전송되므로, 앱을 리버스 엔지니어링하면
/// 키가 노출될 수 있습니다. 실제 서비스에서는 이 호출을 자체 백엔드 프록시로 옮기는
/// 것을 권장합니다.
class OpenRouterService {
  static const _model = 'openai/gpt-4o-mini';

  final AiConfigStore _config;
  final ApiService _api;

  OpenRouterService(this._config)
      : _api = ApiService(baseUrl: 'https://openrouter.ai/api/v1');

  /// 온보딩 입력값(예산·인원·출발지·목적지·날짜·스타일)을 AI가 정리한 요약으로 변환.
  Future<TripSummary> summarizePlan(
    TripPlan plan, {
    required int totalBudget,
  }) async {
    debugPrint('[AI] 1) 요약 요청 시작 · model=$_model · budget=$totalBudget');
    if (!_config.isConfigured) {
      debugPrint('[AI] X) 키 미설정 - 중단');
      throw const ApiException(
          'OpenRouter API 키가 설정되지 않았어요. 프로필 > API 연결 설정에서 입력해주세요.');
    }
    _api.setToken(_config.apiKey);

    final Map<String, dynamic> res;
    try {
      res = await _api.post('/chat/completions', body: {
        'model': _model,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': _systemPrompt(totalBudget)},
          {'role': 'user', 'content': _userPrompt(plan, totalBudget)},
        ],
      });
    } catch (e) {
      debugPrint('[AI] X) 요청 실패: ${describeError(e)}');
      rethrow;
    }
    debugPrint('[AI] 2) 응답 수신 완료 · 파싱 시작');

    final content = _extractContent(res);
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      final summary = TripSummary.fromJson(json);
      debugPrint('[AI] 3) 파싱 완료 · title=${summary.title}');
      return summary;
    } catch (e) {
      debugPrint('[AI] X) JSON 파싱 실패: $e\n[AI]    원본 응답: $content');
      throw const ApiException('AI 응답 형식이 올바르지 않아요. 잠시 후 다시 시도해주세요.');
    }
  }

  String _systemPrompt(int totalBudget) => '''
너는 여행 예산 플래너 AI야. 사용자가 입력한 여행 계획을 검토하고 아래 JSON 스키마로만 답해(다른 설명 텍스트 금지):
{
  "title": "여행을 표현하는 짧고 매력적인 제목",
  "overview": "이 여행 계획을 1~2문장으로 정리한 요약",
  "highlights": ["예산/일정 관점에서 도움이 되는 인사이트 3~5개"],
  "budgetBreakdown": [
    {"category": "카테고리명", "amount": 0, "percent": 0}
  ]
}
budgetBreakdown 은 가능하면 "숙소", "항공·교통", "식비", "활동·관광", "쇼핑·기타" 카테고리를 사용하고,
amount 합계는 총예산 $totalBudget원과 같아야 하며 percent 합계는 100이어야 해.
amount 와 percent 는 반드시 소수점 없는 정수로만 작성해(예: 7.5 대신 8).
모든 텍스트는 한국어로 작성해.''';

  String _userPrompt(TripPlan plan, int totalBudget) {
    final fmt = DateFormat('yyyy-MM-dd');
    final dateRange = (plan.startDate != null && plan.endDate != null)
        ? '${fmt.format(plan.startDate!)} ~ ${fmt.format(plan.endDate!)}'
        : '미정';
    final styles = plan.styles.map((s) => s.label).join(', ');
    return '총예산: $totalBudget원\n'
        '인원: ${plan.travelers}명\n'
        '출발지: ${plan.origin}\n'
        '목적지: ${plan.destination}\n'
        '일정: $dateRange\n'
        '선호 스타일: ${styles.isEmpty ? '미선택' : styles}';
  }

  String _extractContent(Map<String, dynamic> res) {
    final choices = res['choices'] as List?;
    final message = (choices == null || choices.isEmpty)
        ? null
        : (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw const ApiException('AI 응답을 읽을 수 없어요. 잠시 후 다시 시도해주세요.');
    }
    return content;
  }
}
