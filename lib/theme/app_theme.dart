import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// 딥 네이비 기반 디자인 시스템.
///
/// 로고 톤앤매너(#0B4171)를 중심으로, 밝은 회청색 배경 위에 흰 카드와
/// 아주 부드러운 그림자로 구획을 나누는 현대적 B2B 대시보드 스타일.
/// (토큰 이름은 그대로 두고 값만 교체 → 전 화면에 일괄 반영)
class AppColors {
  // ── Brand ──
  static const primary = Color(0xFF0B4171); // 메인 딥 네이비
  static const primaryDark = Color(0xFF082F52); // 더 깊은 네이비(텍스트/헤더)
  static const accent = Color(0xFF2E6BB0); // 세련된 포인트 블루

  // ── Text (Slate scale) ──
  static const ink = Color(0xFF0F172A); // 타이틀/강조 숫자
  static const bodyText = Color(0xFF475569); // 본문
  static const subtleText = Color(0xFF94A3B8); // 캡션/보조/아이콘

  // ── Lines & Surfaces ──
  static const border = Color(0xFFE2E8F0); // 아주 연한 경계선
  static const track = Color(0xFFEEF2F6); // 프로그레스 트랙(밝음)
  static const trackAlt = Color(0xFFE7EDF3); // 프로그레스 트랙(보조)
  static const surface = Color(0xFFFFFFFF); // 카드
  static const canvas = Color(0xFFF8FAFC); // 페이지 배경
  static const canvasBlue = Color(0xFFEFF4FB); // 인포/프레임 배경 틴트

  // ── Status (채도를 살짝 낮춘 모던 톤) ──
  static const success = Color(0xFF10B981); // 승인/정상 (에메랄드)
  static const warning = Color(0xFFF59E0B); // 대기/검토 (앰버)
  static const danger = Color(0xFFEF4444); // 반려/위험 (로즈)

  // ── Brand buttons ──
  static const kakao = Color(0xFFFEE500);
  static const apple = Color(0xFF111111);

  /// 데이터 카테고리 구분용 팔레트 (인덱스 순환) — 네이비/블루 중심 모던 톤.
  static const List<Color> categoryPalette = [
    Color(0xFF0B4171), // navy
    Color(0xFF2E6BB0), // blue
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFF6366F1), // indigo
    Color(0xFFEF4444), // rose
    Color(0xFF14B8A6), // teal
    Color(0xFF8B5CF6), // violet
  ];

  static Color categoryColor(int index) =>
      categoryPalette[index % categoryPalette.length];
}

/// 그림자 토큰 — 투박한 보더 대신 부드러운 그림자로 층위(elevation)를 표현.
class AppShadow {
  /// 카드 기본. 0 1px 3px rgba(15,23,42,0.06) + 0 1px 2px rgba(...,0.04)
  static const card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F0F172A), // ~6%
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // ~4%
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// 살짝 더 떠 있는 요소(버튼/팝오버).
  static const raised = <BoxShadow>[
    BoxShadow(
      color: Color(0x140B4171), // navy tint ~8%
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

/// 모서리 반경 토큰 — 화면마다 제각각이던 BorderRadius 리터럴을 통일.
class AppRadius {
  static const chip = 12.0; // 입력창/칩/작은 버튼
  static const card = 16.0; // 카드/바텀시트
  static const pill = 9999.0; // 완전한 알약 모양(배지/필터칩)
}

/// 여백 토큰 — 화면 좌우 패딩, 하단 여백(FAB/바텀바 회피) 등 반복되던 값을 통일.
class AppSpacing {
  static const screenH = 16.0; // 화면 좌우 기본 패딩
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;

  /// 하단 내비게이션/FAB에 가려지지 않도록 스크롤 콘텐츠 하단에 주는 여백.
  static const listBottomInset = 96.0;

  /// 화면 본문의 표준 패딩(좌우 16 · 상단 24 · 하단은 리스트 여백 포함).
  static const screenPadding =
      EdgeInsets.fromLTRB(screenH, lg, screenH, listBottomInset);
}

class AppTheme {
  static ThemeData light() {
    // Pretendard / Inter 우선, 없으면 시스템 산세리프로 폴백.
    const fontFallback = ['Pretendard', 'Inter', 'Noto Sans KR', 'sans-serif'];
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      fontFamilyFallback: fontFallback,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.primary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.bodyText,
        displayColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.subtleText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// 자주 쓰는 텍스트 스타일 — 위계를 명확히 하고 숫자는 고정폭(tabular) 적용.
class AppText {
  static const _tnum = <FontFeature>[FontFeature.tabularFigures()];

  static const h1 = TextStyle(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.ink,
    fontFeatures: _tnum,
  );
  static const h2 = TextStyle(
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.ink,
    fontFeatures: _tnum,
  );
  static const h3 = TextStyle(
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.ink,
    fontFeatures: _tnum,
  );
  static const body = TextStyle(
    fontSize: 15,
    height: 24 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.bodyText,
    fontFeatures: _tnum,
  );
  static const label = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.bodyText,
    fontFeatures: _tnum,
  );
  static const caption = TextStyle(
    fontSize: 12.5,
    height: 18 / 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.subtleText,
    fontFeatures: _tnum,
  );
  static const logo = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.primary,
  );

  /// 예산 입력/요약에 쓰는 큰 금액 숫자(고정폭).
  static const money = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    color: AppColors.ink,
    fontFeatures: _tnum,
  );

  /// 대시보드용 큰 데이터 숫자(고정폭·강조).
  static const metric = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.ink,
    fontFeatures: _tnum,
  );
}
