import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// 상단 앱바 - 뒤로가기 + Met U 로고.
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  const BrandAppBar({super.key, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      leadingWidth: showBack ? 44 : 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.primaryDark),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          BrandLogoMark(),
          SizedBox(width: 8),
          Text('Met U', style: AppText.logo),
        ],
      ),
    );
  }
}

/// 그라디언트 로고 아이콘. 앱바(28px)와 홈 화면(24px) 등 크기만 다르게 재사용.
class BrandLogoMark extends StatelessWidget {
  final double size;
  const BrandLogoMark({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(size * 8 / 28),
      ),
      child: Icon(Icons.flight_takeoff, size: size * 16 / 28, color: Colors.white),
    );
  }
}

/// 온보딩 단계 진행 바.
class StepProgressBar extends StatelessWidget {
  final int step; // 1-based
  final int total;
  final String? label;

  const StepProgressBar({
    super.key,
    required this.step,
    this.total = 4,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (step / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AppText.label),
              Text('$step / $total',
                  style: AppText.label.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.trackAlt,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// 하단 고정 메인 버튼(다음 / 계속).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.trailingIcon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: AppText.label.copyWith(color: Colors.white)),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 16, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}

/// 카드 컨테이너(흰 배경 + 얕은 그림자).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: child,
    );
  }
}

/// 안심 / AI 인사이트 배지.
class InfoBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String? body;

  const InfoBadge({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.iconColor = AppColors.success,
    this.background = AppColors.canvasBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppText.label.copyWith(color: AppColors.ink)),
                if (body != null) ...[
                  const SizedBox(height: 4),
                  Text(body!,
                      style:
                          AppText.body.copyWith(fontSize: 14, height: 20 / 14)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 화면 하단 고정 액션 영역(상단 보더 + 세이프에어리어).
/// 온보딩 4단계 화면들이 각자 손으로 그리던 컨테이너를 통일합니다.
class BottomActionBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const BottomActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.trackAlt)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// 아이콘 + 라벨 알약 배지. 예산/목적지 화면 등에서 반복되던 패턴.
class PillBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double iconSize;
  final TextStyle? textStyle;

  const PillBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.primary,
    this.iconSize = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: textStyle ?? AppText.label.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// 작은 태그 칩(맛집/숙소/커뮤니티 카드의 #태그·편의시설 표기).
class TagChip extends StatelessWidget {
  final String label;
  const TagChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppText.caption),
    );
  }
}

/// "AI 추천" 계열 리본 배지(항공권 스마트 초이스, 호텔 AI 추천 등).
class AiRibbonBadge extends StatelessWidget {
  final String label;
  const AiRibbonBadge({super.key, this.label = 'AI 추천'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 빈 목록 안내 텍스트(검색 결과 없음 등).
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          message,
          style: AppText.body.copyWith(color: AppColors.subtleText),
        ),
      ),
    );
  }
}

/// 예약/신청류 바텀시트(제목 + 부제 + 선택적 가격 행 + 확인 버튼).
/// 항공권/숙소/맛집 화면이 각자 그리던 showModalBottomSheet 를 통일합니다.
Future<void> showActionSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? priceLabel,
  String? priceValue,
  required String buttonLabel,
  IconData buttonIcon = Icons.check,
  required VoidCallback onConfirm,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h3),
          const SizedBox(height: 4),
          Text(subtitle, style: AppText.body.copyWith(fontSize: 14)),
          if (priceLabel != null && priceValue != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(priceLabel, style: AppText.body),
                Text(priceValue,
                    style: AppText.h3.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: buttonLabel,
            trailingIcon: buttonIcon,
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
          ),
        ],
      ),
    ),
  );
}

/// 카테고리(색 점 + 이름 + 지출) 한 줄.
///
/// [onEdit] 또는 [onDelete]가 있으면 수정 가능한 형태(예산 관리 화면)로,
/// 없으면 [totalBudget] 대비 진행률 바가 있는 읽기 전용 형태(예산 상세 화면)로 렌더링합니다.
class CategoryRow extends StatelessWidget {
  final String name;
  final int spent;
  final Color color;
  final int percent;
  final NumberFormat won;
  final int? totalBudget;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryRow({
    super.key,
    required this.name,
    required this.spent,
    required this.color,
    required this.percent,
    required this.won,
    this.totalBudget,
    this.onEdit,
    this.onDelete,
  });

  Widget _dot() => Container(
        width: 12,
        height: 12,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      );

  @override
  Widget build(BuildContext context) {
    if (onEdit != null || onDelete != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            _dot(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  style: AppText.body
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text('${won.format(spent)}원',
                            style: AppText.body.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit_outlined,
                            size: 14, color: AppColors.subtleText),
                      ],
                    ),
                    Text('$percent%',
                        style: AppText.caption.copyWith(color: color)),
                  ],
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close,
                    size: 18, color: AppColors.subtleText),
                visualDensity: VisualDensity.compact,
                tooltip: '삭제',
              ),
          ],
        ),
      );
    }

    final total = totalBudget ?? 0;
    final ratio = total == 0 ? 0.0 : (spent / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _dot(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  style: AppText.body
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            Text('${won.format(spent)}원  ', style: AppText.caption),
            Text('$percent%',
                style: AppText.caption
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: AppColors.trackAlt,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

/// 아이콘 + 라벨 + 트레일링(텍스트/화살표) 목록 행. 설정류 화면(프로필 등)에서 재사용.
class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final bool danger;
  final VoidCallback onTap;
  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: danger ? AppColors.danger : AppColors.bodyText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: AppText.body.copyWith(
                      fontSize: 15, color: color, fontWeight: FontWeight.w500)),
            ),
            if (trailingText != null)
              Text(trailingText!, style: AppText.caption),
            if (!danger)
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.subtleText),
          ],
        ),
      ),
    );
  }
}

/// 네트워크 이미지를 안전하게 표시. 로딩 중엔 스피너, 실패(오프라인 등)하면
/// 아이콘 플레이스홀더로 대체합니다. 실제 사진 에셋이 없는 화면(숙소/맛집/항공권)에서
/// [seed] 기반 플레이스홀더 사진(picsum.photos)을 채워 넣을 때 사용합니다 —
/// 실제 서비스에서는 [url]을 진짜 사진 URL로 교체하세요.
class NetworkPhoto extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;
  const NetworkPhoto({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.image_outlined,
  });

  /// picsum.photos의 seed 기반 랜덤(그러나 같은 seed면 항상 동일한) 사진 URL.
  factory NetworkPhoto.seeded(
    String seed, {
    Key? key,
    int width = 400,
    int height = 300,
    IconData fallbackIcon = Icons.image_outlined,
  }) {
    final safeSeed = Uri.encodeComponent(seed);
    return NetworkPhoto(
      key: key,
      url: 'https://picsum.photos/seed/$safeSeed/$width/$height',
      fallbackIcon: fallbackIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: AppColors.trackAlt,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: AppColors.trackAlt,
        child: Center(
          child: Icon(fallbackIcon, color: AppColors.subtleText, size: 28),
        ),
      ),
    );
  }
}
