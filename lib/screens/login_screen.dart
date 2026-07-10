import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'budget_screen.dart';

class LoginScreen extends StatelessWidget {
  static const route = '/login';
  const LoginScreen({super.key});

  /// 소셜 로그인(브라우저 → 백엔드 OAuth 인증 → 토큰 저장). 4개 버튼이 모두 이 경로를 씁니다.
  Future<void> _login(BuildContext context, SocialProvider provider) async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithOAuth(provider);
    _afterLogin(context, ok, auth);
  }

  void _afterLogin(BuildContext context, bool ok, AuthProvider auth) {
    if (ok && context.mounted) {
      Navigator.of(context).pushReplacementNamed(BudgetScreen.route);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: ${auth.error ?? ''}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // 브랜드 로고
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.flight_takeoff,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Met U', style: AppText.h2),
              const SizedBox(height: 8),
              Text('예산에 딱 맞는 여행, AI가 찾아드려요',
                  style: AppText.body, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              // 로그인 카드
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  boxShadow: AppShadow.card,
                ),
                child: Column(
                  children: [
                    // 주 CTA. 이메일/비밀번호 로그인 API가 아직 없어 구글 OAuth로 연결됩니다.
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () => _login(context, SocialProvider.google),
                        icon: const Icon(Icons.email_outlined,
                            size: 18, color: Colors.white),
                        label: Text('이메일로 시작하기',
                            style: AppText.label.copyWith(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _dividerRow(),
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: '구글 간편로그인',
                      icon: Icons.g_mobiledata,
                      iconColor: Colors.red,
                      background: Colors.white,
                      textColor: AppColors.bodyText,
                      border: AppColors.border,
                      onTap: loading
                          ? null
                          : () => _login(context, SocialProvider.google),
                    ),
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: 'Apple 계정으로 계속',
                      icon: Icons.apple,
                      iconColor: Colors.white,
                      background: AppColors.apple,
                      textColor: Colors.white,
                      onTap: loading
                          ? null
                          : () => _login(context, SocialProvider.apple),
                    ),
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: '카카오 간편로그인',
                      icon: Icons.chat_bubble,
                      iconColor: const Color(0xFF191919),
                      background: AppColors.kakao,
                      textColor: const Color(0xFF191919),
                      onTap: loading
                          ? null
                          : () => _login(context, SocialProvider.kakao),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('계속 진행하면 이용약관에 동의하게 됩니다',
                  style: AppText.caption, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dividerRow() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('또는 소셜 계정으로',
              style: AppText.label.copyWith(color: AppColors.subtleText)),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final Color textColor;
  final Color? border;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.textColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          side: BorderSide(color: border ?? background),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child:
                  Text(label, style: AppText.label.copyWith(color: textColor)),
            ),
          ],
        ),
      ),
    );
  }
}
