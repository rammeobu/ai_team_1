import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'budget_management_screen.dart';

/// 예산 상세보기 화면.
/// 홈의 진행 중 여행 카드에서 "자세히 보기"를 누르면 진입합니다.
/// 모든 예산 수치는 TripStore(단일 진실 공급원)에서 파생됩니다.
class BudgetDetailScreen extends StatelessWidget {
  static const route = '/budget/detail';
  const BudgetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripStore>();
    final won = NumberFormat.decimalPattern('ko');
    final cats = trip.categories;

    return Scaffold(
      appBar: const BrandAppBar(showBack: true),
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.hasTrip ? trip.title : '예산 상세', style: AppText.h1),
            const SizedBox(height: 4),
            Text(trip.dateRange, style: AppText.body.copyWith(fontSize: 14)),
            const SizedBox(height: 24),

            // 요약 카드
            _SummaryCard(trip: trip, won: won),
            const SizedBox(height: 24),

            // 카테고리별 지출
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('카테고리별 지출', style: AppText.h3),
                IconButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(BudgetManagementScreen.route),
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.primary),
                  tooltip: '카테고리 추가·삭제·금액 수정',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < cats.length; i++) ...[
                    CategoryRow(
                      name: cats[i].name,
                      spent: cats[i].spent,
                      color: AppColors.categoryColor(i),
                      percent: trip.percentOfTotal(cats[i].spent),
                      totalBudget: trip.totalBudget,
                      won: won,
                    ),
                    if (i != cats.length - 1)
                      const Divider(height: 24, color: AppColors.track),
                  ],
                  if (cats.isEmpty) Text('카테고리가 없습니다.', style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TripStore trip;
  final NumberFormat won;
  const _SummaryCard({required this.trip, required this.won});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('총 예산', style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text('${won.format(trip.totalBudget)}원', style: AppText.money),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: trip.progress,
              minHeight: 10,
              backgroundColor: AppColors.trackAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 8),
          Text('${trip.progressPercent}% 사용', style: AppText.caption),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '사용',
                  value: '${won.format(trip.usedBudget)}원',
                  color: AppColors.primary,
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.track),
              Expanded(
                child: _Metric(
                  label: '잔여',
                  value: '${won.format(trip.remaining)}원',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Metric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            )),
      ],
    );
  }
}
