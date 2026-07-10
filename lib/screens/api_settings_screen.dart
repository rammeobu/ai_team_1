import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/ai_config_store.dart';
import '../services/api_config_store.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// 백엔드 API 연결 설정 (Base URL · API 키).
/// 프로필 > "API 연결 설정" 에서 진입합니다.
class ApiSettingsScreen extends StatefulWidget {
  static const route = '/settings/api';
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  late final TextEditingController _urlCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _aiKeyCtrl;
  bool _obscure = true;
  bool _aiObscure = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final cfg = context.read<ApiConfigStore>();
    final aiCfg = context.read<AiConfigStore>();
    _urlCtrl = TextEditingController(text: cfg.baseUrl);
    _keyCtrl = TextEditingController(text: cfg.apiKey);
    _aiKeyCtrl = TextEditingController(text: aiCfg.apiKey);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    _aiKeyCtrl.dispose();
    super.dispose();
  }

  /// http(s):// 로 시작하고 호스트가 있는 최소한의 URL 형식인지 확인.
  bool _isValidBaseUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _save() async {
    if (!_isValidBaseUrl(_urlCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Base URL 형식이 올바르지 않아요. (예: https://api.example.com)')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context
          .read<ApiConfigStore>()
          .save(baseUrl: _urlCtrl.text, apiKey: _keyCtrl.text);
      await context.read<AiConfigStore>().save(_aiKeyCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API 설정을 저장했어요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장에 실패했어요: ${describeError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<ApiConfigStore>();
    final aiCfg = context.watch<AiConfigStore>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const BrandAppBar(showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const Text('API 연결 설정', style: AppText.h1),
          const SizedBox(height: 4),
          Text('백엔드 서버 주소와 API 키를 입력하세요. 저장하면 모든 요청에 자동 적용됩니다.',
              style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 20),

          // 연결 상태 배지
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (cfg.isConfigured ? AppColors.success : AppColors.subtleText)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Row(
              children: [
                Icon(
                  cfg.isConfigured ? Icons.check_circle : Icons.info_outline,
                  size: 18,
                  color: cfg.isConfigured
                      ? AppColors.success
                      : AppColors.subtleText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cfg.isConfigured
                        ? 'API 키가 설정되어 있어요.'
                        : 'API 키가 아직 설정되지 않았어요 (데모 모드).',
                    style: AppText.caption.copyWith(
                      color: cfg.isConfigured
                          ? AppColors.success
                          : AppColors.subtleText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Base URL', style: AppText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlCtrl,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'https://api.myserver.com',
                    prefixIcon: Icon(Icons.link, size: 18),
                  ),
                ),
                const SizedBox(height: 20),
                Text('API 키', style: AppText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _keyCtrl,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: 'sk_live_... 또는 발급받은 키',
                    prefixIcon: const Icon(Icons.vpn_key_outlined, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                          size: 18),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('키는 이 기기에만 저장되며, 요청 헤더(X-API-Key)로 전송됩니다.',
                    style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('AI 연동 (OpenRouter)', style: AppText.h3),
          const SizedBox(height: 4),
          Text('온보딩 "AI 요약" 화면에서 사용할 OpenRouter API 키를 입력하세요.',
              style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OpenRouter API 키', style: AppText.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _aiKeyCtrl,
                  obscureText: _aiObscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: 'sk-or-v1-...',
                    prefixIcon:
                        const Icon(Icons.auto_awesome, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _aiObscure ? Icons.visibility : Icons.visibility_off,
                          size: 18),
                      onPressed: () =>
                          setState(() => _aiObscure = !_aiObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '이 키는 기기 보안 저장소에 저장되고 OpenRouter로 직접 전송됩니다. '
                  '유출 시 과금 위험이 있으니 OpenRouter 대시보드에서 사용량 한도를 걸어두세요.',
                  style: AppText.caption,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse('https://openrouter.ai/keys'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('openrouter.ai/keys 에서 키 발급'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          PrimaryButton(
            label: '저장',
            trailingIcon: Icons.check,
            loading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: 12),
          if (cfg.isConfigured)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await context.read<ApiConfigStore>().clear();
                  _keyCtrl.clear();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('API 키 삭제'),
              ),
            ),
          if (aiCfg.isConfigured)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await context.read<AiConfigStore>().clear();
                  _aiKeyCtrl.clear();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('OpenRouter 키 삭제'),
              ),
            ),
        ],
      ),
    );
  }
}
