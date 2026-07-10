// 앱 전역에서 쓰는 데이터 모델 모음.

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        photoUrl: json['photoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };
}

enum SocialProvider { google, apple, kakao }

/// 여행 스타일(4단계에서 선택).
enum TripStyle {
  healing('힐링'),
  sightseeing('관광'),
  foodie('맛집'),
  shopping('쇼핑'),
  activity('액티비티');

  final String label;
  const TripStyle(this.label);
}

/// 온보딩 4단계 동안 채워지는 여행 계획.
class TripPlan {
  final int budget; // 원 단위 총 예산
  final int travelers; // 인원 수
  final String origin; // 출발지
  final String destination; // 목적지
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<TripStyle> styles;

  const TripPlan({
    this.budget = 0,
    this.travelers = 1,
    this.origin = '',
    this.destination = '',
    this.startDate,
    this.endDate,
    this.styles = const {},
  });

  TripPlan copyWith({
    int? budget,
    int? travelers,
    String? origin,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    Set<TripStyle>? styles,
  }) {
    return TripPlan(
      budget: budget ?? this.budget,
      travelers: travelers ?? this.travelers,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      styles: styles ?? this.styles,
    );
  }

  Map<String, dynamic> toJson() => {
        'budget': budget,
        'travelers': travelers,
        'origin': origin,
        'destination': destination,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'styles': styles.map((s) => s.name).toList(),
      };
}

/// 홈 대시보드의 진행 중 여행 카드(메타 정보).
///
/// 예산 값은 여기에 두지 않습니다. 예산의 단일 진실 공급원은 [TripStore] 입니다.
class ActiveTrip {
  final String id;
  final String title;
  final String dateRange;

  const ActiveTrip({
    required this.id,
    required this.title,
    required this.dateRange,
  });

  factory ActiveTrip.fromJson(Map<String, dynamic> json) => ActiveTrip(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        dateRange: json['dateRange'] ?? '',
      );
}

/// 온보딩 완료 직후 AI가 정리한 여행 계획 요약.
class TripSummary {
  final String title; // AI가 만든 여행 제목
  final String overview; // 한 줄 요약
  final List<String> highlights; // AI 인사이트
  final List<BudgetAllocation> budgetBreakdown; // 카테고리별 추천 예산 배분

  const TripSummary({
    required this.title,
    required this.overview,
    required this.highlights,
    required this.budgetBreakdown,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) => TripSummary(
        title: json['title'] ?? '',
        overview: json['overview'] ?? '',
        highlights: (json['highlights'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        budgetBreakdown: (json['budgetBreakdown'] as List? ?? const [])
            .map((e) => BudgetAllocation.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// 카테고리별 AI 추천 예산 배분 항목.
class BudgetAllocation {
  final String category;
  final int amount;
  final int percent;

  const BudgetAllocation({
    required this.category,
    required this.amount,
    required this.percent,
  });

  factory BudgetAllocation.fromJson(Map<String, dynamic> json) =>
      BudgetAllocation(
        category: json['category'] ?? '',
        amount: _asInt(json['amount']),
        percent: _asInt(json['percent']),
      );

  /// AI가 amount/percent를 7.5 같은 소수(double)로 줄 때도 안전하게 정수로 변환.
  static int _asInt(dynamic value) =>
      value is num ? value.round() : int.tryParse('$value') ?? 0;
}

/// 예산별 AI 추천 여행지 카드.
class RecommendedTheme {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;

  const RecommendedTheme({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  factory RecommendedTheme.fromJson(Map<String, dynamic> json) =>
      RecommendedTheme(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        imageUrl: json['imageUrl'],
      );
}
