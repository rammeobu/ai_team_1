import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/onboarding_session_store.dart';
import '../services/trip_service.dart';

/// 온보딩 4단계(예산 → 인원 → 장소/일정 → 스타일)의 상태를 한곳에 모읍니다.
class OnboardingProvider extends ChangeNotifier {
  final TripService _service;
  final OnboardingSessionStore _sessionStore;
  OnboardingProvider(this._service, [OnboardingSessionStore? sessionStore])
      : _sessionStore = sessionStore ?? const OnboardingSessionStore();

  TripPlan _plan = const TripPlan(travelers: 1);
  bool _submitting = false;
  String? _error;
  TripSummary? _summary;
  bool _previewing = false;
  String? _previewError;
  bool _savingDraft = false;
  String? _draftError;

  TripPlan get plan => _plan;
  bool get isSubmitting => _submitting;
  String? get error => _error;
  TripSummary? get summary => _summary;
  bool get isPreviewing => _previewing;
  String? get previewError => _previewError;
  bool get isSavingDraft => _savingDraft;
  String? get draftError => _draftError;

  // 단계 1(예산)의 단일 진실 공급원은 TripStore 입니다. 여기서는 다루지 않습니다.

  // --- 단계 2: 인원 ---
  void incrementTravelers() {
    _plan = _plan.copyWith(travelers: _plan.travelers + 1);
    notifyListeners();
  }

  void decrementTravelers() {
    if (_plan.travelers > 1) {
      _plan = _plan.copyWith(travelers: _plan.travelers - 1);
      notifyListeners();
    }
  }

  // --- 단계 3: 장소 & 일정 ---
  void setOrigin(String v) {
    _plan = _plan.copyWith(origin: v);
    notifyListeners();
  }

  void setDestination(String v) {
    _plan = _plan.copyWith(destination: v);
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _plan = _plan.copyWith(startDate: start, endDate: end);
    notifyListeners();
  }

  // --- 단계 4: 스타일 ---
  void toggleStyle(TripStyle style) {
    final next = Set<TripStyle>.from(_plan.styles);
    next.contains(style) ? next.remove(style) : next.add(style);
    _plan = _plan.copyWith(styles: next);
    notifyListeners();
  }

  bool isStyleSelected(TripStyle s) => _plan.styles.contains(s);

  bool get step3Valid =>
      _plan.destination.trim().isNotEmpty &&
      _plan.startDate != null &&
      _plan.endDate != null;
  bool get step4Valid => _plan.styles.isNotEmpty;

  /// 스타일 선택 완료 직후 → 입력값을 백엔드에 임시 저장(웹의 httpOnly 쿠키에
  /// 대응하는 모바일 방식)하고, 발급받은 세션 토큰을 기기 보안 저장소에 보관합니다.
  /// 예산은 TripStore(단일 진실 공급원)에서 전달받아 함께 전송합니다.
  Future<bool> saveDraft({required int totalBudget}) async {
    _savingDraft = true;
    _draftError = null;
    _plan = _plan.copyWith(budget: totalBudget);
    notifyListeners();
    try {
      final token = await _service.saveDraft(_plan);
      await _sessionStore.saveToken(token);
      return true;
    } catch (e) {
      _draftError = describeError(e);
      return false;
    } finally {
      _savingDraft = false;
      notifyListeners();
    }
  }

  /// 스타일 선택 직후 → 저장 전에 AI가 정리한 요약을 미리 봅니다.
  /// 예산은 TripStore(단일 진실 공급원)에서 전달받아 함께 전송합니다.
  Future<bool> preview({required int totalBudget}) async {
    _previewing = true;
    _previewError = null;
    _plan = _plan.copyWith(budget: totalBudget);
    notifyListeners();
    try {
      _summary = await _service.previewPlan(_plan);
      return true;
    } catch (e) {
      _previewError = describeError(e);
      return false;
    } finally {
      _previewing = false;
      notifyListeners();
    }
  }

  /// 온보딩 완료 → 서버에 여행 계획 저장.
  /// 예산은 TripStore(단일 진실 공급원)에서 전달받아 백엔드 페이로드에 포함합니다.
  /// [saveDraft]에서 저장해둔 세션 토큰이 있으면 함께 전달하고, 성공하면 정리합니다.
  Future<String?> submit({required int totalBudget}) async {
    _submitting = true;
    _error = null;
    _plan = _plan.copyWith(budget: totalBudget);
    notifyListeners();
    try {
      final sessionToken = await _sessionStore.readToken();
      final tripId =
          await _service.createPlan(_plan, sessionToken: sessionToken);
      await _sessionStore.clear();
      return tripId;
    } catch (e) {
      _error = describeError(e);
      return null;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void reset() {
    _plan = const TripPlan(travelers: 1);
    _summary = null;
    _previewError = null;
    _draftError = null;
    notifyListeners();
  }
}
