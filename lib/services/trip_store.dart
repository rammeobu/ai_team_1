import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 예산 카테고리 (이름 + 지출액).
class BudgetCategory {
  final String name;
  final int spent;
  const BudgetCategory(this.name, this.spent);

  Map<String, dynamic> toJson() => {'name': name, 'spent': spent};
  factory BudgetCategory.fromJson(Map<String, dynamic> j) =>
      BudgetCategory(j['name'] as String, (j['spent'] ?? 0) as int);
}

/// 현재 여행의 예산에 대한 **단일 진실 공급원(single source of truth)**.
///
/// 총예산과 카테고리 목록(추가/삭제 가능)을 보관하며, 사용 금액(usedBudget)은
/// 카테고리 지출의 합계로 파생됩니다. 값은 shared_preferences 에 저장됩니다.
class TripStore extends ChangeNotifier {
  static const int maxBudget = 10000000; // 슬라이더 상한 (1,000만원)

  static const _kTotal = 'trip_total_budget';
  static const _kTitle = 'trip_title';
  static const _kDateRange = 'trip_date_range';
  static const _kHasTrip = 'trip_has_trip';
  static const _kCats = 'trip_categories_json';

  final SharedPreferences _prefs;

  int _totalBudget = 0;
  List<BudgetCategory> _cats = [];
  String _title = '';
  String _dateRange = '';
  bool _hasTrip = false;

  TripStore(this._prefs) {
    _restore();
  }

  // ── 읽기 ──
  int get totalBudget => _totalBudget;

  List<BudgetCategory> get categories => List.unmodifiable(_cats);
  List<String> get categoryNames => _cats.map((c) => c.name).toList();

  int get usedBudget => _cats.fold(0, (sum, c) => sum + c.spent);

  int categorySpent(String name) => _cats
      .firstWhere((c) => c.name == name,
          orElse: () => const BudgetCategory('', 0))
      .spent;

  String get title => _title;
  String get dateRange => _dateRange;
  bool get hasTrip => _hasTrip;

  /// [dateRange]("2026.08.12 - 08.16")에서 출발일을 파싱. 형식이 다르면 null.
  DateTime? get departureDate {
    final head = _dateRange.split('-').first.trim();
    try {
      return DateFormat('yyyy.MM.dd').parseStrict(head);
    } catch (_) {
      return null;
    }
  }

  double get budgetRatio =>
      maxBudget == 0 ? 0.0 : (_totalBudget / maxBudget).clamp(0.0, 1.0);

  double get progress =>
      _totalBudget == 0 ? 0.0 : (usedBudget / _totalBudget).clamp(0.0, 1.0);

  int get progressPercent => (progress * 100).round();

  int get remaining => (_totalBudget - usedBudget).clamp(0, _totalBudget);

  /// 총예산 대비 특정 지출액의 퍼센트.
  int percentOfTotal(int amount) =>
      _totalBudget == 0 ? 0 : ((amount / _totalBudget) * 100).round();

  // ── 쓰기 ──

  Future<void> setTotalBudget(int value) async {
    final v = value.clamp(0, maxBudget);
    if (v == _totalBudget) return;
    _totalBudget = v;
    await _prefs.setInt(_kTotal, _totalBudget);
    notifyListeners();
  }

  /// 카테고리 지출액 설정 (숫자 입력).
  Future<void> setCategorySpent(String name, int value) async {
    final v = value < 0 ? 0 : value;
    final idx = _cats.indexWhere((c) => c.name == name);
    if (idx == -1) return;
    _cats[idx] = BudgetCategory(name, v);
    await _persistCats();
    notifyListeners();
  }

  /// 카테고리 추가. 중복 이름은 무시.
  Future<void> addCategory(String name, {int spent = 0}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_cats.any((c) => c.name == trimmed)) return;
    _cats.add(BudgetCategory(trimmed, spent < 0 ? 0 : spent));
    await _persistCats();
    notifyListeners();
  }

  /// 카테고리 삭제.
  Future<void> removeCategory(String name) async {
    _cats.removeWhere((c) => c.name == name);
    await _persistCats();
    notifyListeners();
  }

  Future<void> _persistCats() async {
    await _prefs.setString(
        _kCats, jsonEncode(_cats.map((c) => c.toJson()).toList()));
  }

  Future<void> startTrip({
    required String title,
    required String dateRange,
    int? totalBudget,
  }) async {
    _title = title;
    _dateRange = dateRange;
    _hasTrip = true;
    if (totalBudget != null) {
      _totalBudget = totalBudget.clamp(0, maxBudget);
      await _prefs.setInt(_kTotal, _totalBudget);
    }
    await _prefs.setString(_kTitle, _title);
    await _prefs.setString(_kDateRange, _dateRange);
    await _prefs.setBool(_kHasTrip, true);
    notifyListeners();
  }

  void _restore() {
    _totalBudget = _prefs.getInt(_kTotal) ?? 2000000;
    _title = _prefs.getString(_kTitle) ?? '오사카 미식 여행';
    _dateRange = _prefs.getString(_kDateRange) ?? '2026.08.12 - 08.16';
    _hasTrip = _prefs.getBool(_kHasTrip) ?? true;

    final raw = _prefs.getString(_kCats);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _cats = list
            .map((e) => BudgetCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      } catch (_) {
        // 손상 시 기본값으로.
      }
    }
    // 최초 실행 기본 카테고리 (합계 800,000원).
    _cats = const [
      BudgetCategory('숙소', 280000),
      BudgetCategory('항공·교통', 200000),
      BudgetCategory('식비', 160000),
      BudgetCategory('활동·관광', 96000),
      BudgetCategory('쇼핑·기타', 64000),
    ].toList();
  }
}
