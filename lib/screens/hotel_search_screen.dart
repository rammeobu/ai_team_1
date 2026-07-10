import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// 호텔 추천 및 예약.
/// 홈의 "숙소" 빠른 버튼에서 진입합니다.
class HotelSearchScreen extends StatefulWidget {
  static const route = '/hotel';
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final _won = NumberFormat.decimalPattern('ko');
  int _filter = 0; // 0: 전체, 1: 가성비, 2: 고급, 3: 위치
  final Set<String> _amenities = {}; // 편의시설 다중 필터
  _Sort _sort = _Sort.ai; // 정렬 기준

  static const _filters = ['전체', '가성비', '고급', '위치 좋은'];
  static const _filterIcons = [
    Icons.apps_rounded,
    Icons.savings_outlined,
    Icons.diamond_outlined,
    Icons.location_on_outlined,
  ];
  static const _amenityOptions = ['조식', '수영장', '스파', '무료 WiFi'];

  /// 총예산의 35%를 숙박(4박 기준)에 배정한다고 가정한 1박 권장 예산 비율.
  static const _nightlyBudgetRatio = 0.35 / 4;

  // 데모 호텔 목록. price = 1박 요금.
  static const _hotels = <_Hotel>[
    _Hotel('시티 센트럴 호텔', '난바 · 도보 5분', 4.6, 1280, 78000, ['조식', '무료 WiFi'], 1),
    _Hotel(
        '그랜드 뷰 리조트', '베이 에어리어 · 오션뷰', 4.8, 950, 154000, ['수영장', '스파', '조식'], 2),
    _Hotel('스마트 캡슐 스테이', '역세권 · 도보 2분', 4.3, 2100, 39000, ['무료 WiFi'], 1),
    _Hotel('부티크 하우스', '구시가지 · 감성 숙소', 4.7, 640, 112000, ['조식', '테라스'], 3),
    _Hotel('스카이라인 호텔', '중심가 · 야경 뷰', 4.5, 1720, 96000, ['수영장', '무료 WiFi', '조식'],
        2),
    _Hotel('트래블러스 인', '공항 근처 · 셔틀', 4.1, 430, 52000, ['무료 WiFi', '조식'], 1),
  ];

  /// AI 추천 점수 (평점·리뷰수는 가점, 가격은 감점).
  double _aiScore(_Hotel h) =>
      h.rating * 2 + h.reviews / 1000 - h.price / 100000;

  List<_Hotel> get _visible {
    // 1) 카테고리 필터
    var list = _hotels.where((h) {
      switch (_filter) {
        case 1:
          return h.price <= 80000;
        case 2:
          return h.price >= 120000;
        case 3:
          return h.tier == 1 || h.tier == 3;
        default:
          return true;
      }
    });
    // 2) 편의시설 필터 (선택한 항목을 모두 포함)
    if (_amenities.isNotEmpty) {
      list = list.where((h) => _amenities.every(h.amenities.contains));
    }
    final result = list.toList();
    // 3) 정렬
    switch (_sort) {
      case _Sort.ai:
        result.sort((a, b) => _aiScore(b).compareTo(_aiScore(a)));
        break;
      case _Sort.reviews:
        result.sort((a, b) => b.reviews.compareTo(a.reviews));
        break;
      case _Sort.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _Sort.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
    return result;
  }

  void _book(_Hotel h) {
    showActionSheet(
      context,
      title: h.name,
      subtitle: h.location,
      priceLabel: '1박 요금',
      priceValue: '${_won.format(h.price)}원',
      buttonLabel: '예약하기',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${h.name} 예약을 진행합니다.')),
        );
      },
    );
  }

  String _sortLabel(_Sort s) {
    switch (s) {
      case _Sort.ai:
        return 'AI 추천';
      case _Sort.reviews:
        return '리뷰 많은순';
      case _Sort.priceHigh:
        return '가격 높은순';
      case _Sort.priceLow:
        return '가격 낮은순';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripStore>();
    final dest = trip.title.replaceAll(' 여행', '').trim();
    final hotels = _visible;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const BrandAppBar(showBack: true),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const Text('호텔 추천', style: AppText.h1),
          const SizedBox(height: 4),
          Text(
              dest.isNotEmpty
                  ? '$dest · ${trip.dateRange}'
                  : '예산에 맞는 숙소를 추천해 드려요.',
              style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 16),

          // 예산 안내 배지
          if (trip.totalBudget > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InfoBadge(
                icon: Icons.savings_outlined,
                iconColor: AppColors.primary,
                background: AppColors.primary.withOpacity(0.08),
                title:
                    '숙소 권장 예산: 1박 ${_won.format((trip.totalBudget * _nightlyBudgetRatio).round())}원 내외',
              ),
            ),

          // 카테고리 탭 (아이콘 + 라벨, 다른 여행 앱의 카테고리 탐색 스타일)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (_, i) => _CategoryTab(
                icon: _filterIcons[i],
                label: _filters[i],
                selected: _filter == i,
                onTap: () => setState(() => _filter = i),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 편의시설 필터 (다중 선택)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in _amenityOptions)
                FilterChip(
                  label: Text(a),
                  selected: _amenities.contains(a),
                  showCheckmark: false,
                  onSelected: (sel) => setState(() {
                    if (sel) {
                      _amenities.add(a);
                    } else {
                      _amenities.remove(a);
                    }
                  }),
                  labelStyle: AppText.caption.copyWith(
                    color: _amenities.contains(a)
                        ? AppColors.primary
                        : AppColors.bodyText,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: AppColors.primary.withOpacity(0.12),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: _amenities.contains(a)
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 결과 수 + 정렬
          Row(
            children: [
              Text('숙소 ${hotels.length}곳',
                  style: AppText.label.copyWith(color: AppColors.bodyText)),
              const Spacer(),
              PopupMenuButton<_Sort>(
                initialValue: _sort,
                onSelected: (s) => setState(() => _sort = s),
                itemBuilder: (_) => [
                  for (final s in _Sort.values)
                    PopupMenuItem(value: s, child: Text(_sortLabel(s))),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_vert,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(_sortLabel(_sort),
                        style:
                            AppText.label.copyWith(color: AppColors.primary)),
                    const Icon(Icons.arrow_drop_down,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          for (var i = 0; i < hotels.length; i++) ...[
            _HotelCard(
              hotel: hotels[i],
              won: _won,
              recommended: _sort == _Sort.ai && i == 0,
              onTap: () => _book(hotels[i]),
            ),
            const SizedBox(height: 16),
          ],
          if (hotels.isEmpty) const EmptyState('조건에 맞는 숙소가 없어요.'),
        ],
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final _Hotel hotel;
  final NumberFormat won;
  final bool recommended;
  final VoidCallback onTap;
  const _HotelCard(
      {required this.hotel,
      required this.won,
      required this.onTap,
      this.recommended = false});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 숙소 사진 (실제 사진 에셋이 없어 이름 기반 플레이스홀더 사진 사용)
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.chip)),
            child: SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkPhoto.seeded(hotel.name, fallbackIcon: Icons.hotel),
                  // 배지 가독성을 위한 하단 그라디언트 오버레이.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black38],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              size: 13, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text('${hotel.rating}',
                              style: AppText.caption
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  if (recommended)
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: AiRibbonBadge(),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: AppText.h3),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: AppColors.subtleText),
                    const SizedBox(width: 4),
                    Text(hotel.location, style: AppText.caption),
                    const SizedBox(width: 8),
                    Text('· 후기 ${won.format(hotel.reviews)}',
                        style: AppText.caption),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final a in hotel.amenities) TagChip(a),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppText.h3.copyWith(color: AppColors.ink),
                          children: [
                            TextSpan(text: '${won.format(hotel.price)}원'),
                            TextSpan(
                              text: ' / 1박',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                      ),
                      child: const Text('예약'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hotel {
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final int price;
  final List<String> amenities;
  final int tier; // 1 저가, 2 고급, 3 부티크
  const _Hotel(this.name, this.location, this.rating, this.reviews, this.price,
      this.amenities, this.tier);
}

/// 정렬 기준: AI 추천 / 리뷰 많은순 / 가격 높은순 / 가격 낮은순.
enum _Sort { ai, reviews, priceHigh, priceLow }

/// 아이콘 위 + 라벨 아래, 선택 시 밑줄로 표시하는 카테고리 탭(여행 앱에서 흔한 스타일).
class _CategoryTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.subtleText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(label,
                style: AppText.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                )),
            const SizedBox(height: 6),
            Container(
              width: 28,
              height: 2,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
