import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'budget_management_screen.dart';
import 'my_trips_screen.dart';
import 'api_settings_screen.dart';

/// 프로필 (Profile).
/// 홈 하단 네비게이션의 "프로필" 탭에서 진입합니다.
class ProfileScreen extends StatelessWidget {
  static const route = '/profile';
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃', style: AppText.h3),
        content: const Text('정말 로그아웃하시겠어요?', style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.route,
          (_) => false,
        );
      }
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature 기능은 앱 설정 화면으로 연결될 예정이에요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final trip = context.watch<TripStore>();
    final name = user?.name ?? 'ㅇㅇ';
    final email = user?.email ?? 'user@example.com';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const BrandAppBar(showBack: true),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // 프로필 헤더
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name.characters.first : '?',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$name님', style: AppText.h3),
                      const SizedBox(height: 4),
                      Text(email, style: AppText.caption),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showComingSoon(context, '프로필 수정'),
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.subtleText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 간단 통계
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.card_travel,
                  value: trip.hasTrip ? '1' : '0',
                  label: '진행 중 여행',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.savings_outlined,
                  value: '${trip.progressPercent}%',
                  label: '예산 사용률',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 메뉴
          const Text('계정', style: AppText.h3),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SettingsMenuItem(
                  icon: Icons.card_travel,
                  label: '내 여행',
                  onTap: () =>
                      Navigator.of(context).pushNamed(MyTripsScreen.route),
                ),
                SettingsMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: '예산 관리',
                  onTap: () => Navigator.of(context)
                      .pushNamed(BudgetManagementScreen.route),
                ),
                SettingsMenuItem(
                  icon: Icons.notifications_none,
                  label: '알림 설정',
                  onTap: () => _showComingSoon(context, '알림 설정'),
                ),
                SettingsMenuItem(
                  icon: Icons.language,
                  label: '언어 · 통화',
                  trailingText: '한국어 · KRW',
                  onTap: () => _showComingSoon(context, '언어 · 통화'),
                ),
                SettingsMenuItem(
                  icon: Icons.vpn_key_outlined,
                  label: 'API 연결 설정',
                  onTap: () => Navigator.of(context)
                      .pushNamed(ApiSettingsScreen.route),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('지원', style: AppText.h3),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SettingsMenuItem(
                  icon: Icons.help_outline,
                  label: '도움말 · 문의',
                  onTap: () => _showComingSoon(context, '도움말 · 문의'),
                ),
                SettingsMenuItem(
                  icon: Icons.description_outlined,
                  label: '이용약관 · 개인정보',
                  onTap: () => _showComingSoon(context, '이용약관 · 개인정보'),
                ),
                SettingsMenuItem(
                  icon: Icons.logout,
                  label: '로그아웃',
                  danger: true,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Met U · v1.0.0',
                style: AppText.caption.copyWith(color: AppColors.subtleText)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              )),
          const SizedBox(height: 2),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}
