import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'travelers_screen.dart';

/// 단계 1: 예산 설정.
class BudgetScreen extends StatefulWidget {
  static const route = '/onboarding/budget';
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _controller = TextEditingController();
  final _formatter = NumberFormat.decimalPattern('ko');

  @override
  void initState() {
    super.initState();
    // 단일 진실 공급원(TripStore)에 이미 저장된 예산으로 초기화.
    final budget = context.read<TripStore>().totalBudget;
    if (budget > 0) _controller.text = _formatter.format(budget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digits) ?? 0;
    // 입력 즉시 현재 여행 예산에 저장 → 홈 카드에 바로 반영.
    context.read<TripStore>().setTotalBudget(value);
    final formatted = value == 0 ? '' : _formatter.format(value);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripStore>();

    return Scaffold(
      appBar: const BrandAppBar(showBack: true),
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: StepProgressBar(step: 1, label: '단계 1'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 배지
                  const PillBadge(
                    icon: Icons.savings_outlined,
                    label: '스마트 예산 설정',
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(height: 16),
                  const Text('이번 여행의\n총 예산은 얼마인가요?', style: AppText.h1),
                  const SizedBox(height: 12),
                  Text('예산에 맞춰 편안하게 즐길 수 있는 숙소, 식당, 활동을 추천해 드립니다.',
                      style: AppText.body),
                  const SizedBox(height: 24),
                  // 예산 입력 카드
                  AppCard(
                    color: AppColors.canvas,
                    borderColor: AppColors.track,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('총 예산 (원)',
                            style: AppText.label
                                .copyWith(color: AppColors.bodyText)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          onChanged: _onChanged,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textAlign: TextAlign.center,
                          style: AppText.money,
                          decoration: const InputDecoration(
                            prefixText: '₩ ',
                            prefixStyle: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bodyText,
                            ),
                            hintText: '0',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: trip.totalBudget
                              .clamp(0, TripStore.maxBudget)
                              .toDouble(),
                          max: TripStore.maxBudget.toDouble(),
                          divisions: 100,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.track,
                          onChanged: (v) {
                            final value = v.round();
                            context.read<TripStore>().setTotalBudget(value);
                            final f = _formatter.format(value);
                            _controller.value = TextEditingValue(
                              text: f,
                              selection:
                                  TextSelection.collapsed(offset: f.length),
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0원', style: AppText.caption),
                            Text('${_formatter.format(TripStore.maxBudget)}원+',
                                style: AppText.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const InfoBadge(
                    icon: Icons.verified_user_outlined,
                    title: '가성비 걱정 끝',
                    body: '입력하신 예산 범위 안에서만 추천하니 초과 걱정 없이 계획하세요.',
                  ),
                ],
              ),
            ),
          ),
          _bottomBar(context, trip),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context, TripStore trip) {
    return BottomActionBar(
      padding: const EdgeInsets.all(24),
      child: PrimaryButton(
        label: '다음',
        onPressed: trip.totalBudget > 0
            ? () => Navigator.of(context).pushNamed(TravelersScreen.route)
            : null,
      ),
    );
  }
}
