import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// 항공편 검색 및 예약.
/// 홈의 "항공권" 빠른 버튼에서 진입합니다.
/// AI가 날짜별 최저가를 찾아 가장 저렴한 날짜와 항공편을 추천합니다.
class FlightSearchScreen extends StatefulWidget {
  static const route = '/flight';
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final _won = NumberFormat.decimalPattern('ko');

  late final String _originCode;
  late final String _originCity;
  late final String _destCode;
  late final String _destCity;

  late final List<_DayFare> _days; // 날짜별 최저가
  late int _selectedDay; // 선택된 날짜 index
  late final int _bestDay; // AI 추천(최저가) 날짜 index

  // 목적지명 → 공항코드/도시 (데모). 실제로는 백엔드/항공 API 로 대체.
  static const _airports = {
    '오사카': ('KIX', '오사카'),
    '도쿄': ('NRT', '도쿄'),
    '다낭': ('DAD', '다낭'),
    '방콕': ('BKK', '방콕'),
    '후쿠오카': ('FUK', '후쿠오카'),
    '타이베이': ('TPE', '타이베이'),
    '세부': ('CEB', '세부'),
  };

  // 왕복 항공편 템플릿 (편도 시각/소요/직항여부 + 기준가).
  static const _templates = <_FlightTpl>[
    _FlightTpl('대한항공', '08:15', '10:00', '1h 45m', '18:30', '20:25', '1h 55m',
        0, 185000),
    _FlightTpl('아시아나', '11:00', '12:40', '1h 40m', '16:15', '18:15', '2h 00m',
        0, 192000),
    _FlightTpl('제주항공', '19:20', '21:10', '1h 50m', '07:05', '09:00', '1h 55m',
        0, 168000),
    _FlightTpl('피치항공', '06:40', '10:30', '3h 50m', '22:10', '02:00', '3h 50m',
        1, 132000),
  ];

  @override
  void initState() {
    super.initState();
    final title = context.read<TripStore>().title.replaceAll(' 여행', '').trim();
    _originCode = 'ICN';
    _originCity = '서울';
    final match = _airports[title];
    _destCode = match?.$1 ?? 'KIX';
    _destCity = match?.$2 ?? (title.isEmpty ? '오사카' : title);

    // 날짜별 최저가 생성 (데모). 특정 날짜가 가장 저렴하도록 델타 적용.
    final base = DateTime.now().add(const Duration(days: 21));
    const deltas = [0, -33000, 12000, -6000, 20000, 4000, -12000];
    _days = List.generate(deltas.length, (i) {
      final date = base.add(Duration(days: i));
      final minPrice = _templates
          .map((t) => t.basePrice + deltas[i])
          .reduce((a, b) => a < b ? a : b);
      return _DayFare(date, deltas[i], minPrice);
    });
    // AI 추천 = 최저가 날짜.
    var best = 0;
    for (var i = 1; i < _days.length; i++) {
      if (_days[i].minPrice < _days[best].minPrice) best = i;
    }
    _bestDay = best;
    _selectedDay = best; // 처음엔 추천 날짜 선택.
  }

  List<_FlightOption> _optionsForSelectedDay() {
    final delta = _days[_selectedDay].delta;
    final list = _templates
        .map((t) => _FlightOption(t, t.basePrice + delta))
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  void _book(_FlightOption o) {
    showActionSheet(
      context,
      title: '${o.tpl.airline} · 왕복',
      subtitle:
          '$_originCode → $_destCode  ${_dayLabel(_days[_selectedDay].date)}',
      priceLabel: '왕복 1인 기준',
      priceValue: '₩${_won.format(o.price)}',
      buttonLabel: '예약하기',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${o.tpl.airline} 왕복 예약을 진행합니다.')),
        );
      },
    );
  }

  String _dayLabel(DateTime d) => '${d.month}월 ${d.day}일';
  String _chipDate(DateTime d) => '${d.month}.${d.day}';

  @override
  Widget build(BuildContext context) {
    final options = _optionsForSelectedDay();
    final cheapestPrice = options.first.price;
    final best = _days[_bestDay];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        title: const Text('검색 결과', style: AppText.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // 목적지 사진 (실제 사진 에셋이 없어 도시명 기반 플레이스홀더 사진 사용)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: SizedBox(
              height: 120,
              child: NetworkPhoto.seeded(_destCity,
                  fallbackIcon: Icons.flight_takeoff),
            ),
          ),
          const SizedBox(height: 16),
          // 경로 요약
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _airportLabel(_originCity, _originCode),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.swap_horiz, color: AppColors.subtleText),
              ),
              _airportLabel(_destCity, _destCode),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${_dayLabel(_days.first.date)} · 성인 1명 · 일반석',
              style: AppText.caption,
            ),
          ),
          const SizedBox(height: 16),

          // AI 최저가 배너
          InfoBadge(
            icon: Icons.auto_awesome,
            title:
                'AI 추천: ${_dayLabel(best.date)} 출발이 가장 저렴해요 (₩${_won.format(best.minPrice)}~)',
          ),
          const SizedBox(height: 16),

          // 날짜별 최저가 셀렉터
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _DayChip(
                label: _chipDate(_days[i].date),
                price: '₩${_won.format(_days[i].minPrice)}',
                selected: i == _selectedDay,
                isBest: i == _bestDay,
                onTap: () => setState(() => _selectedDay = i),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 항공편 목록 (가격 오름차순, 최저가에 스마트 초이스)
          for (var i = 0; i < options.length; i++) ...[
            _FlightCard(
              option: options[i],
              originCode: _originCode,
              destCode: _destCode,
              won: _won,
              isBest: options[i].price == cheapestPrice,
              onSelect: () => _book(options[i]),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _airportLabel(String city, String code) {
    return Column(
      children: [
        Text(code,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink)),
        Text(city, style: AppText.caption),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final String price;
  final bool selected;
  final bool isBest;
  final VoidCallback onTap;
  const _DayChip({
    required this.label,
    required this.price,
    required this.selected,
    required this.isBest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: AppText.caption.copyWith(
                        color: selected ? Colors.white : AppColors.bodyText)),
                if (isBest) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.star,
                      size: 11,
                      color: selected ? Colors.white : AppColors.success),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(price,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.ink,
                )),
          ],
        ),
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final _FlightOption option;
  final String originCode;
  final String destCode;
  final NumberFormat won;
  final bool isBest;
  final VoidCallback onSelect;
  const _FlightCard({
    required this.option,
    required this.originCode,
    required this.destCode,
    required this.won,
    required this.isBest,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = option.tpl;
    return AppCard(
      borderColor: isBest ? AppColors.primary : AppColors.trackAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBest)
            const Align(
              alignment: Alignment.centerRight,
              child: AiRibbonBadge(label: '스마트 초이스'),
            ),
          if (isBest) const SizedBox(height: 8),
          // 가는 편
          _leg(t.airline, t.outDep, originCode, t.outArr, destCode, t.outDur,
              t.stops),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.track),
          const SizedBox(height: 10),
          // 오는 편
          _leg(t.airline, t.inDep, destCode, t.inArr, originCode, t.inDur,
              t.stops),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isBest)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text('최적가',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₩${won.format(option.price)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  Text('왕복 1인 기준', style: AppText.caption),
                ],
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 92,
                height: 44,
                child: isBest
                    ? ElevatedButton(
                        onPressed: onSelect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                        ),
                        child: const Text('선택'),
                      )
                    : OutlinedButton(
                        onPressed: onSelect,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                        ),
                        child: const Text('선택'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leg(String airline, String dep, String depCode, String arr,
      String arrCode, String dur, int stops) {
    return Row(
      children: [
        const Icon(Icons.flight, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dep,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(depCode, style: AppText.caption),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Text(dur, style: AppText.caption),
              const Divider(color: AppColors.border),
              Text(stops == 0 ? '직항' : '경유 $stops회',
                  style: AppText.caption.copyWith(
                      color: stops == 0
                          ? AppColors.success
                          : AppColors.subtleText)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(arr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(arrCode, style: AppText.caption),
          ],
        ),
      ],
    );
  }
}

class _DayFare {
  final DateTime date;
  final int delta;
  final int minPrice;
  const _DayFare(this.date, this.delta, this.minPrice);
}

class _FlightTpl {
  final String airline;
  final String outDep;
  final String outArr;
  final String outDur;
  final String inDep;
  final String inArr;
  final String inDur;
  final int stops;
  final int basePrice;
  const _FlightTpl(this.airline, this.outDep, this.outArr, this.outDur,
      this.inDep, this.inArr, this.inDur, this.stops, this.basePrice);
}

class _FlightOption {
  final _FlightTpl tpl;
  final int price;
  const _FlightOption(this.tpl, this.price);
}
