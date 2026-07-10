import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RestaurantScreen extends StatefulWidget {
  static const route = '/restaurants';
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _won = NumberFormat.decimalPattern('ko');
  String _filter = '전체';

  static const _filters = ['전체', '가성비', '현지맛집', '카페', '예약가능'];
  static const _restaurants = <_Restaurant>[
    _Restaurant('난바 타코야키 골목', '오사카 · 도보 맛집', '현지맛집', 4.7, 13800,
        '줄은 있지만 회전이 빨라요. 간식 예산으로 딱 좋아요.', true),
    _Restaurant('우메다 규카츠 하우스', '우메다 · 저녁 추천', '예약가능', 4.6, 26000,
        '대기 시간을 줄이려면 18시 전 예약을 추천해요.', true),
    _Restaurant('도톤보리 라멘 스탠드', '도톤보리 · 혼밥 가능', '가성비', 4.4, 11800,
        '늦은 밤에도 열어 일정 마지막에 넣기 좋아요.', false),
    _Restaurant('리버뷰 브런치 카페', '나카노시마 · 카페', '카페', 4.5, 18000,
        '강변 산책 코스와 묶으면 이동 동선이 깔끔해요.', true),
  ];

  List<_Restaurant> get _visible {
    if (_filter == '전체') return _restaurants;
    return _restaurants
        .where(
          (item) => item.tag == _filter || (_filter == '예약가능' && item.bookable),
        )
        .toList();
  }

  void _reserve(_Restaurant item) {
    showActionSheet(
      context,
      title: item.name,
      subtitle: '${item.area}\n${item.tip}',
      buttonLabel: item.bookable ? '예약 알림 받기' : '내 일정에 저장',
      buttonIcon:
          item.bookable ? Icons.notifications_active : Icons.bookmark,
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name}을 여행 일정에 담았어요.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripStore>();
    final dest = trip.title.replaceAll(' 여행', '').trim();
    final items = _visible;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const BrandAppBar(showBack: true),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const Text('맛집 추천', style: AppText.h1),
          const SizedBox(height: 4),
          Text(
            dest.isNotEmpty ? '$dest 예산 맞춤 맛집' : '예산과 동선에 맞는 맛집을 추천해요.',
            style: AppText.body.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (trip.totalBudget > 0)
            InfoBadge(
              icon: Icons.restaurant_menu,
              iconColor: AppColors.primary,
              title: 'AI 예산 팁',
              body:
                  '식비는 전체 예산의 약 20%인 ${_won.format((trip.totalBudget * 0.2).round())}원 안에서 잡으면 안정적이에요.',
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final filter = _filters[i];
                final selected = filter == _filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filter = filter),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: AppText.label.copyWith(
                    color: selected ? Colors.white : AppColors.bodyText,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    side: const BorderSide(color: AppColors.border),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          for (final item in items) ...[
            _RestaurantCard(
              item: item,
              won: _won,
              onTap: () => _reserve(item),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final _Restaurant item;
  final NumberFormat won;
  final VoidCallback onTap;

  const _RestaurantCard({
    required this.item,
    required this.won,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: NetworkPhoto.seeded(item.name,
                      fallbackIcon: Icons.restaurant),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppText.h3),
                    const SizedBox(height: 2),
                    Text(item.area, style: AppText.caption),
                  ],
                ),
              ),
              const Icon(Icons.star, size: 16, color: AppColors.accent),
              const SizedBox(width: 2),
              Text('${item.rating}', style: AppText.caption),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.tip, style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              TagChip('#${item.tag}'),
              const Spacer(),
              Text('1인 ${won.format(item.price)}원대',
                  style: AppText.label.copyWith(color: AppColors.ink)),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(item.bookable ? '담기' : '저장'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Restaurant {
  final String name;
  final String area;
  final String tag;
  final double rating;
  final int price;
  final String tip;
  final bool bookable;

  const _Restaurant(
    this.name,
    this.area,
    this.tag,
    this.rating,
    this.price,
    this.tip,
    this.bookable,
  );
}
