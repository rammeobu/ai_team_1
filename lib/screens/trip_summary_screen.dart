import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';
import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

/// AI 요약 확인 화면.
/// 스타일 선택 직후 진입해, 입력한 예산·인원·일정·스타일을 AI가 정리한 내용을
/// 확인하고 확정하면 그때 서버에 여행 계획을 저장합니다.
class TripSummaryScreen extends StatefulWidget {
  static const route = '/onboarding/summary';
  const TripSummaryScreen({super.key});

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  final _won = NumberFormat.decimalPattern('ko');
  final _dateFmt = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 이전 화면(스타일 선택)의 임시 저장 실패 스낵바가 화면 전환 후에도
      // 남아있을 수 있어(ScaffoldMessenger는 앱 전체에서 하나 공유) 정리합니다.
      ScaffoldMessenger.of(context).clearSnackBars();
      _loadPreview();
    });
  }

  void _loadPreview() {
    final totalBudget = context.read<TripStore>().totalBudget;
    context.read<OnboardingProvider>().preview(totalBudget: totalBudget);
  }

  /// 서버 저장(POST /trips)이 실패해도(예: 백엔드에 아직 엔드포인트가 없는 경우)
  /// 경고만 보여주고 홈 화면으로는 진행합니다. 여행 정보 자체는 TripStore에
  /// 로컬로 반영되므로 홈 카드는 정상적으로 보입니다.
  Future<void> _confirm(BuildContext context) async {
    final onboarding = context.read<OnboardingProvider>();
    final tripStore = context.read<TripStore>();
    final plan = onboarding.plan;

    final tripId = await onboarding.submit(totalBudget: tripStore.totalBudget);
    if (!context.mounted) return;
    if (tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패(계속 진행합니다): ${onboarding.error ?? ''}'),
        ),
      );
    }

    final dateRange = (plan.startDate != null && plan.endDate != null)
        ? '${_dateFmt.format(plan.startDate!)} - ${_dateFmt.format(plan.endDate!)}'
        : tripStore.dateRange;
    await tripStore.startTrip(
      title: plan.destination.isNotEmpty
          ? '${plan.destination} 여행'
          : tripStore.title,
      dateRange: dateRange,
    );
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(HomeScreen.route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final trip = context.watch<TripStore>();

    return Scaffold(
      appBar: const BrandAppBar(showBack: true),
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Expanded(child: _body(context, onboarding, trip)),
          if (onboarding.summary != null)
            BottomActionBar(
              child: PrimaryButton(
                label: '확정하고 시작하기',
                trailingIcon: Icons.check,
                loading: onboarding.isSubmitting,
                onPressed: () => _confirm(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(
      BuildContext context, OnboardingProvider onboarding, TripStore trip) {
    if (onboarding.isPreviewing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (onboarding.previewError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 40, color: AppColors.danger),
              const SizedBox(height: 12),
              Text('AI 요약을 불러오지 못했어요.', style: AppText.h3),
              const SizedBox(height: 4),
              Text(onboarding.previewError!,
                  style: AppText.body, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadPreview,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = onboarding.summary;
    if (summary == null) return const SizedBox.shrink();

    final plan = onboarding.plan;
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary.title, style: AppText.h1),
          const SizedBox(height: 8),
          Text(summary.overview, style: AppText.body),
          const SizedBox(height: 24),
          const Text('여행 정보', style: AppText.h3),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('예산', '${_won.format(trip.totalBudget)}원'),
                _infoRow('인원', '${plan.travelers}명'),
                _infoRow('구간', '${plan.origin} → ${plan.destination}'),
                if (plan.startDate != null && plan.endDate != null)
                  _infoRow('일정',
                      '${_dateFmt.format(plan.startDate!)} - ${_dateFmt.format(plan.endDate!)}'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final style in plan.styles)
                      PillBadge(icon: Icons.auto_awesome, label: style.label),
                  ],
                ),
              ],
            ),
          ),
          if (summary.highlights.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('AI 인사이트', style: AppText.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < summary.highlights.length; i++) ...[
                    if (i != 0) const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              Text(summary.highlights[i], style: AppText.body),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (summary.budgetBreakdown.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('추천 예산 배분', style: AppText.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < summary.budgetBreakdown.length; i++) ...[
                    CategoryRow(
                      name: summary.budgetBreakdown[i].category,
                      spent: summary.budgetBreakdown[i].amount,
                      color: AppColors.categoryColor(i),
                      percent: summary.budgetBreakdown[i].percent,
                      totalBudget: trip.totalBudget,
                      won: _won,
                    ),
                    if (i != summary.budgetBreakdown.length - 1)
                      const Divider(height: 24, color: AppColors.track),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.caption),
          Text(value, style: AppText.label.copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}
