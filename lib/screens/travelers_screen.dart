import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'destination_screen.dart';

/// 단계 2: 인원 선택.
class TravelersScreen extends StatelessWidget {
  static const route = '/onboarding/travelers';
  const TravelersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final count = onboarding.plan.travelers;

    return Scaffold(
      appBar: const BrandAppBar(showBack: true),
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepProgressBar(step: 2, label: '단계 2'),
                  const SizedBox(height: 24),
                  const Text('누구와 함께\n여행하시나요?', style: AppText.h1),
                  const SizedBox(height: 24),
                  // 인원 카운터 카드
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('여행 인원', style: AppText.h2),
                                const SizedBox(height: 4),
                                Text('총 $count명',
                                    style: AppText.body.copyWith(fontSize: 14)),
                              ],
                            ),
                            Row(
                              children: [
                                _CounterButton(
                                  icon: Icons.remove,
                                  enabled: count > 1,
                                  onTap: onboarding.decrementTravelers,
                                ),
                                SizedBox(
                                  width: 48,
                                  child: Text('$count',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      )),
                                ),
                                _CounterButton(
                                  icon: Icons.add,
                                  enabled: true,
                                  onTap: onboarding.incrementTravelers,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Icon(
                          count <= 1
                              ? Icons.person
                              : count == 2
                                  ? Icons.people
                                  : Icons.groups,
                          size: 44,
                          color: const Color(0xFFE0B79C),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.trackAlt,
                      border:
                          Border.all(color: AppColors.border.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡',
                            style:
                                AppText.h3.copyWith(color: AppColors.success)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '인원 수에 따라 1인당 최적 예산과 숙소 타입을 AI가 다시 계산해요.',
                            style: AppText.body.copyWith(color: AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _bottomBar(context),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return BottomActionBar(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
                child: Text('이전',
                    style: AppText.label.copyWith(color: AppColors.primary)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              label: '다음',
              trailingIcon: null,
              onPressed: () =>
                  Navigator.of(context).pushNamed(DestinationScreen.route),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.border : AppColors.track,
          ),
        ),
        child: Icon(icon,
            size: 18, color: enabled ? AppColors.primary : AppColors.border),
      ),
    );
  }
}
