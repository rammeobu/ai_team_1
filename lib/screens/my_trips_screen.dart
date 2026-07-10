import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'budget_detail_screen.dart';
import 'budget_screen.dart';

/// 내 여행 목록 (My Trips).
/// 홈 하단 네비게이션의 "내 여행" 탭에서 진입합니다.
/// 진행 중 여행은 TripStore(단일 진실 공급원)에서 실시간으로 가져옵니다.
class MyTripsScreen extends StatelessWidget {
  static const route = '/my-trips';
  const MyTripsScreen({super.key});

  // 데모용 지난 여행 목록.
  static const _pastTrips = <_PastTrip>[
    _PastTrip('제주 힐링 여행', '2026.03.10 - 03.13', 1200000, 1150000),
    _PastTrip('후쿠오카 미식 투어', '2025.11.02 - 11.05', 1500000, 1420000),
    _PastTrip('강릉 바다 여행', '2025.09.20 - 09.22', 700000, 680000),
  ];

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripStore>();
    final won = NumberFormat.decimalPattern('ko');

    return Scaffold(
      appBar: const BrandAppBar(showBack: true),
      backgroundColor: AppColors.canvas,
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const Text('내 여행', style: AppText.h1),
          const SizedBox(height: 4),
          Text('진행 중이거나 지난 여행을 확인하세요.',
              style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 24),

          // 진행 중 여행 (TripStore)
          if (trip.hasTrip) ...[
            Row(
              children: const [
                Icon(Icons.play_circle_fill,
                    size: 16, color: AppColors.success),
                SizedBox(width: 6),
                Text('진행 중', style: AppText.h3),
              ],
            ),
            const SizedBox(height: 12),
            _ActiveTripTile(trip: trip, won: won),
            const SizedBox(height: 24),
          ],

          // 지난 여행
          const Text('지난 여행', style: AppText.h3),
          const SizedBox(height: 12),
          for (var i = 0; i < _pastTrips.length; i++) ...[
            _PastTripTile(trip: _pastTrips[i], won: won),
            if (i != _pastTrips.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(BudgetScreen.route),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('새 여행', style: AppText.label.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _ActiveTripTile extends StatelessWidget {
  final TripStore trip;
  final NumberFormat won;
  const _ActiveTripTile({required this.trip, required this.won});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.trackAlt,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: () => Navigator.of(context).pushNamed(BudgetDetailScreen.route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.title, style: AppText.h3),
                      const SizedBox(height: 4),
                      Text(trip.dateRange,
                          style: AppText.body.copyWith(fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text('진행 중',
                      style:
                          AppText.caption.copyWith(color: AppColors.success)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('사용 예산', style: AppText.body.copyWith(fontSize: 14)),
                Text(
                    '${won.format(trip.usedBudget)} / ${won.format(trip.totalBudget)}원',
                    style: const TextStyle(fontSize: 15, color: AppColors.ink)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: trip.progress,
                minHeight: 8,
                backgroundColor: AppColors.trackAlt,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${trip.progressPercent}% 사용', style: AppText.caption),
                Text('잔여 ${won.format(trip.remaining)}원',
                    style: AppText.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PastTripTile extends StatelessWidget {
  final _PastTrip trip;
  final NumberFormat won;
  const _PastTripTile({required this.trip, required this.won});

  @override
  Widget build(BuildContext context) {
    final ratio =
        trip.budget == 0 ? 0.0 : (trip.spent / trip.budget).clamp(0.0, 1.0);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.trackAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.luggage, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.title,
                    style: AppText.body
                        .copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(trip.dateRange, style: AppText.caption),
                const SizedBox(height: 6),
                Text(
                    '${won.format(trip.spent)} / ${won.format(trip.budget)}원 사용',
                    style: AppText.caption.copyWith(color: AppColors.bodyText)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${(ratio * 100).round()}%',
              style: AppText.label.copyWith(color: AppColors.subtleText)),
        ],
      ),
    );
  }
}

class _PastTrip {
  final String title;
  final String dateRange;
  final int budget;
  final int spent;
  const _PastTrip(this.title, this.dateRange, this.budget, this.spent);
}
