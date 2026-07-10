import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/onboarding_provider.dart';
import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'trip_summary_screen.dart';

/// 단계 4: 스타일 선택.
class StyleScreen extends StatelessWidget {
  static const route = '/onboarding/style';
  const StyleScreen({super.key});

  static const _icons = {
    TripStyle.healing: Icons.spa_outlined,
    TripStyle.sightseeing: Icons.photo_camera_outlined,
    TripStyle.foodie: Icons.restaurant_outlined,
    TripStyle.shopping: Icons.shopping_bag_outlined,
    TripStyle.activity: Icons.directions_run,
  };

  /// 입력값을 백엔드에 임시 저장(세션 토큰 발급)한 뒤 AI 요약 화면으로 이동.
  /// 임시 저장은 부가 기능이라, 실패해도(예: 백엔드에 아직 엔드포인트가 없는 경우)
  /// 경고만 보여주고 온보딩 진행 자체는 막지 않습니다.
  Future<void> _proceed(BuildContext context) async {
    final onboarding = context.read<OnboardingProvider>();
    final totalBudget = context.read<TripStore>().totalBudget;
    final ok = await onboarding.saveDraft(totalBudget: totalBudget);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('임시 저장 실패(계속 진행합니다): ${onboarding.draftError ?? ''}'),
        ),
      );
    }
    Navigator.of(context).pushNamed(TripSummaryScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();

    return Scaffold(
      appBar: const BrandAppBar(showBack: true),
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: StepProgressBar(step: 4, label: '단계 4'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('어떤 여행 스타일을\n선호하시나요?',
                      style: AppText.h1, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('여러 개 선택할 수 있어요',
                      style: AppText.body, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  // 2열 그리드 (마지막 액티비티는 전체 너비)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      for (final style in [
                        TripStyle.healing,
                        TripStyle.sightseeing,
                        TripStyle.foodie,
                        TripStyle.shopping,
                      ])
                        _StyleTile(
                          style: style,
                          icon: _icons[style]!,
                          selected: onboarding.isStyleSelected(style),
                          onTap: () => onboarding.toggleStyle(style),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StyleTile(
                    style: TripStyle.activity,
                    icon: _icons[TripStyle.activity]!,
                    selected: onboarding.isStyleSelected(TripStyle.activity),
                    horizontal: true,
                    onTap: () => onboarding.toggleStyle(TripStyle.activity),
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(
              label: 'AI 여행 계획 생성하기',
              trailingIcon: Icons.auto_awesome,
              loading: onboarding.isSavingDraft,
              onPressed:
                  onboarding.step4Valid ? () => _proceed(context) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  final TripStyle style;
  final IconData icon;
  final bool selected;
  final bool horizontal;
  final VoidCallback onTap;

  const _StyleTile({
    required this.style,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = horizontal
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(style.label, style: AppText.label),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(style.label, style: AppText.label),
            ],
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Container(
        height: horizontal ? 64 : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: selected ? AppShadow.raised : null,
        ),
        child: content,
      ),
    );
  }
}
