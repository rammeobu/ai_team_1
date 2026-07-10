import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/onboarding_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'style_screen.dart';

/// 단계 3: 장소 및 일정.
class DestinationScreen extends StatefulWidget {
  static const route = '/onboarding/destination';
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  static const _recentOriginKey = 'recent_origins';
  static const _recentDestinationKey = 'recent_destinations';
  static const _places = [
    _Place('서울', '대한민국', 'ICN', '인천국제공항', ['seoul', 'icn', '인천공항']),
    _Place('김포', '대한민국', 'GMP', '김포국제공항', ['gimpo', 'gmp']),
    _Place('부산', '대한민국', 'PUS', '김해국제공항', ['busan', 'pus', '김해']),
    _Place('제주', '대한민국', 'CJU', '제주국제공항', ['jeju', 'cju']),
    _Place('오사카', '일본', 'KIX', '간사이국제공항', ['osaka', 'kix', '간사이']),
    _Place('도쿄', '일본', 'NRT', '나리타국제공항', ['tokyo', 'nrt', 'hnd']),
    _Place('후쿠오카', '일본', 'FUK', '후쿠오카공항', ['fukuoka', 'fuk']),
    _Place('다낭', '베트남', 'DAD', '다낭국제공항', ['danang', 'dad']),
    _Place('방콕', '태국', 'BKK', '수완나품공항', ['bangkok', 'bkk']),
    _Place('타이베이', '대만', 'TPE', '타오위안국제공항', ['taipei', 'tpe']),
    _Place('세부', '필리핀', 'CEB', '막탄 세부국제공항', ['cebu', 'ceb']),
    _Place('싱가포르', '싱가포르', 'SIN', '창이공항', ['singapore', 'sin']),
  ];
  late final TextEditingController _originCtrl;
  late final TextEditingController _destCtrl;
  late final FocusNode _originFocus;
  late final FocusNode _destFocus;
  final _dateFmt = DateFormat('yyyy.MM.dd');
  List<String> _recentOrigins = [];
  List<String> _recentDestinations = [];

  @override
  void initState() {
    super.initState();
    final plan = context.read<OnboardingProvider>().plan;
    _originCtrl = TextEditingController(text: plan.origin);
    _destCtrl = TextEditingController(text: plan.destination);
    _originFocus = FocusNode();
    _destFocus = FocusNode();
    _loadRecentPlaces();
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _originFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  void _loadRecentPlaces() {
    final prefs = context.read<SharedPreferences>();
    setState(() {
      _recentOrigins = prefs.getStringList(_recentOriginKey) ?? [];
      _recentDestinations = prefs.getStringList(_recentDestinationKey) ?? [];
    });
  }

  Future<void> _saveRecentPlaces() async {
    final prefs = context.read<SharedPreferences>();
    final origin = _originCtrl.text.trim();
    final destination = _destCtrl.text.trim();
    if (origin.isNotEmpty) {
      _recentOrigins = _mergeRecent(_recentOrigins, origin);
      await prefs.setStringList(_recentOriginKey, _recentOrigins);
    }
    if (destination.isNotEmpty) {
      _recentDestinations = _mergeRecent(_recentDestinations, destination);
      await prefs.setStringList(_recentDestinationKey, _recentDestinations);
    }
  }

  List<String> _mergeRecent(List<String> source, String value) {
    return [value, ...source.where((item) => item != value)].take(5).toList();
  }

  List<_Place> _placeOptions(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return _places.take(6).toList();
    return _places.where((place) => place.matches(trimmed)).take(6).toList();
  }

  _Place? _matchPlace(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    for (final place in _places) {
      if (place.matches(trimmed) ||
          place.city.toLowerCase() == trimmed ||
          place.code.toLowerCase() == trimmed) {
        return place;
      }
    }
    return null;
  }

  bool _samePlace(String a, String b) {
    final left = _matchPlace(a);
    final right = _matchPlace(b);
    if (left != null && right != null) return left.code == right.code;
    return a.trim().isNotEmpty &&
        b.trim().isNotEmpty &&
        a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  void _setOrigin(String value) {
    _originCtrl.text = value;
    context.read<OnboardingProvider>().setOrigin(value);
  }

  void _setDestination(String value) {
    _destCtrl.text = value;
    context.read<OnboardingProvider>().setDestination(value);
  }

  void _swapPlaces() {
    final origin = _originCtrl.text;
    final destination = _destCtrl.text;
    _setOrigin(destination);
    _setDestination(origin);
  }

  void _useCurrentLocation() {
    _setOrigin('서울 (ICN)');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('현재 위치 근처 출발지를 서울(ICN)로 설정했어요.')),
    );
  }

  Future<void> _goNext() async {
    await _saveRecentPlaces();
    if (!mounted) return;
    Navigator.of(context).pushNamed(StyleScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final plan = onboarding.plan;
    final now = DateTime.now();
    final datesPicked = plan.startDate != null && plan.endDate != null;
    final hasSamePlace = _samePlace(plan.origin, plan.destination);
    final originPlace = _matchPlace(plan.origin);
    final destinationPlace = _matchPlace(plan.destination);
    final canContinue = onboarding.step3Valid && !hasSamePlace;

    return Scaffold(
      appBar: const BrandAppBar(showBack: true),
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: StepProgressBar(step: 3, label: '단계 3'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('어디로 언제 떠나시나요?', style: AppText.h1),
                  const SizedBox(height: 8),
                  Text('최적의 가성비 여행을 위해 세부 정보를 입력해주세요.',
                      style: AppText.body.copyWith(fontSize: 14)),
                  const SizedBox(height: 24),
                  // 출발지/목적지 카드
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardHeader(Icons.place_outlined, '출발지 및 목적지'),
                        const SizedBox(height: 16),
                        _placeInput(
                          label: '출발지',
                          controller: _originCtrl,
                          focusNode: _originFocus,
                          hint: '예: 서울 / Seoul (ICN)',
                          icon: Icons.flight_takeoff,
                          onChanged: onboarding.setOrigin,
                          onSelected: _setOrigin,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _PlaceMeta(
                                place: originPlace,
                                emptyText: '출발지를 입력하면 공항 코드가 표시돼요',
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: _swapPlaces,
                              icon: const Icon(Icons.swap_vert),
                              tooltip: '출발지와 목적지 바꾸기',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _placeInput(
                          label: '목적지',
                          controller: _destCtrl,
                          focusNode: _destFocus,
                          hint: '예: 오사카 / Osaka (KIX)',
                          icon: Icons.location_on_outlined,
                          onChanged: onboarding.setDestination,
                          onSelected: _setDestination,
                        ),
                        const SizedBox(height: 8),
                        _PlaceMeta(
                          place: destinationPlace,
                          emptyText: '목적지를 입력하면 가까운 공항을 추천해요',
                        ),
                        if (hasSamePlace) ...[
                          const SizedBox(height: 8),
                          Text('출발지와 목적지는 다르게 입력해주세요.',
                              style: AppText.caption
                                  .copyWith(color: AppColors.danger)),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _useCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const Text('현재 위치로 출발지 설정'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _chipSection(
                          title: '최근 선택',
                          values: [
                            ..._recentOrigins.map((item) => '출발 $item'),
                            ..._recentDestinations.map((item) => '도착 $item'),
                          ],
                          onTap: (value) {
                            if (value.startsWith('출발 ')) {
                              _setOrigin(value.replaceFirst('출발 ', ''));
                            } else {
                              _setDestination(value.replaceFirst('도착 ', ''));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 날짜 카드 (인라인 캘린더 - 저장 버튼 없음)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cardHeader(Icons.calendar_today_outlined, '여행 날짜'),
                        const SizedBox(height: 8),
                        Text(
                          datesPicked
                              ? '${_dateFmt.format(plan.startDate!)} - ${_dateFmt.format(plan.endDate!)}'
                              : '가는 날과 오는 날을 선택하세요',
                          style: AppText.body.copyWith(
                            fontSize: 14,
                            color: datesPicked
                                ? AppColors.primary
                                : AppColors.subtleText,
                            fontWeight:
                                datesPicked ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InlineRangeCalendar(
                          start: plan.startDate,
                          end: plan.endDate,
                          firstDate: DateTime(now.year, now.month, now.day),
                          lastDate: DateTime(now.year + 2),
                          onChanged: (s, e) => onboarding.setDateRange(s, e),
                        ),
                        if (datesPicked) ...[
                          const SizedBox(height: 12),
                          PillBadge(
                            icon: Icons.auto_awesome,
                            iconSize: 13,
                            label:
                                '${plan.endDate!.difference(plan.startDate!).inDays}박 ${plan.endDate!.difference(plan.startDate!).inDays + 1}일 · 항공권이 저렴한 기간이에요',
                            textStyle: AppText.caption
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 날짜를 선택하면 하단 진행 바가 자동으로 나타남
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => SizeTransition(
              sizeFactor: anim,
              axisAlignment: -1,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: datesPicked
                ? BottomActionBar(
                    key: const ValueKey('proceed-bar'),
                    padding: const EdgeInsets.all(16),
                    child: PrimaryButton(
                      label: '다음 단계로',
                      onPressed: onboarding.step3Valid
                          ? (canContinue ? _goNext : null)
                          : null,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppText.h3),
      ],
    );
  }

  Widget _placeInput({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSelected,
  }) {
    return RawAutocomplete<_Place>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: (option) => '${option.city} (${option.code})',
      optionsBuilder: (value) => _placeOptions(value.text),
      onSelected: (option) => onSelected('${option.city} (${option.code})'),
      fieldViewBuilder: (context, fieldController, fieldFocus, onSubmitted) {
        return TextField(
          controller: fieldController,
          focusNode: fieldFocus,
          onChanged: onChanged,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          enableSuggestions: true,
          autocorrect: false,
          style: AppText.body,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.subtleText),
          ),
        );
      },
      optionsViewBuilder: (context, onOptionSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 340),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.flight, color: AppColors.primary),
                    title: Text('${option.city} (${option.code})',
                        style: AppText.body.copyWith(fontSize: 14)),
                    subtitle: Text('${option.country} · ${option.airport}',
                        style: AppText.caption),
                    onTap: () => onOptionSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chipSection({
    required String title,
    required List<String> values,
    required ValueChanged<String> onTap,
  }) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              ActionChip(
                label: Text(value, style: AppText.caption),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                onPressed: () => onTap(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _PlaceMeta extends StatelessWidget {
  final _Place? place;
  final String emptyText;

  const _PlaceMeta({required this.place, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    final text = place == null
        ? emptyText
        : '${place!.code} · ${place!.airport} · ${place!.country}';
    return Row(
      children: [
        Icon(Icons.airplanemode_active,
            size: 14,
            color: place == null ? AppColors.subtleText : AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppText.caption.copyWith(
              color: place == null ? AppColors.subtleText : AppColors.primary,
              fontWeight: place == null ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Place {
  final String city;
  final String country;
  final String code;
  final String airport;
  final List<String> keywords;

  const _Place(
    this.city,
    this.country,
    this.code,
    this.airport,
    this.keywords,
  );

  bool matches(String query) {
    final q = query.toLowerCase();
    return city.toLowerCase().contains(q) ||
        country.toLowerCase().contains(q) ||
        code.toLowerCase().contains(q) ||
        airport.toLowerCase().contains(q) ||
        keywords.any((keyword) => keyword.toLowerCase().contains(q));
  }
}

/// 저장 버튼이 없는 인라인 기간 선택 캘린더.
/// 날짜를 탭하면 즉시 상위로 콜백되어 하단 진행 바가 자동으로 나타납니다.
class _InlineRangeCalendar extends StatefulWidget {
  final DateTime? start;
  final DateTime? end;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime? start, DateTime? end) onChanged;

  const _InlineRangeCalendar({
    required this.start,
    required this.end,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  State<_InlineRangeCalendar> createState() => _InlineRangeCalendarState();
}

class _InlineRangeCalendarState extends State<_InlineRangeCalendar> {
  late DateTime _visibleMonth;
  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    final base = widget.start ?? DateTime.now();
    _visibleMonth = DateTime(base.year, base.month);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _inRange(DateTime d) {
    if (widget.start == null || widget.end == null) return false;
    return d.isAfter(_dateOnly(widget.start!)) &&
        d.isBefore(_dateOnly(widget.end!));
  }

  void _handleTap(DateTime day) {
    final start = widget.start;
    final end = widget.end;
    if (start == null || end != null) {
      widget.onChanged(day, null);
    } else {
      if (day.isBefore(start)) {
        widget.onChanged(day, null);
      } else if (_sameDay(day, start)) {
        widget.onChanged(day, day);
      } else {
        widget.onChanged(start, day);
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = first.weekday % 7; // 일요일 시작 기준
    final title = DateFormat('yyyy년 M월').format(_visibleMonth);

    final canGoPrev = DateTime(_visibleMonth.year, _visibleMonth.month)
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
      final disabled = date.isBefore(_dateOnly(widget.firstDate)) ||
          date.isAfter(_dateOnly(widget.lastDate));
      final isStart = widget.start != null && _sameDay(date, widget.start!);
      final isEnd = widget.end != null && _sameDay(date, widget.end!);
      final selectedEdge = isStart || isEnd;
      final between = _inRange(date);

      cells.add(_DayCell(
        day: day,
        disabled: disabled,
        selectedEdge: selectedEdge,
        between: between,
        onTap: disabled ? null : () => _handleTap(date),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: canGoPrev ? () => _changeMonth(-1) : null,
                icon: const Icon(Icons.chevron_left, size: 20),
                color: AppColors.bodyText,
                splashRadius: 20,
              ),
              Text(title, style: AppText.body.copyWith(color: AppColors.ink)),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, size: 20),
                color: AppColors.bodyText,
                splashRadius: 20,
              ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      _weekdays[i],
                      style: AppText.caption.copyWith(
                        color: i == 0 ? AppColors.danger : AppColors.subtleText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool disabled;
  final bool selectedEdge;
  final bool between;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.disabled,
    required this.selectedEdge,
    required this.between,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (disabled) {
      textColor = AppColors.border;
    } else if (selectedEdge) {
      textColor = Colors.white;
    } else {
      textColor = AppColors.ink;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selectedEdge
              ? AppColors.primary
              : between
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
          shape: selectedEdge ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: between ? BorderRadius.circular(6) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: selectedEdge ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
