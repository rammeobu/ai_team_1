import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'budget_detail_screen.dart';
import 'budget_screen.dart';

/// 예산 관리 (Budget).
/// 총예산을 원형 차트 + 큰 숫자로 보여주고, 카테고리별 지출은 숫자 입력으로 수정합니다.
/// 카테고리는 자유롭게 추가/삭제할 수 있습니다.
class BudgetManagementScreen extends StatelessWidget {
  static const route = '/budget';
  const BudgetManagementScreen({super.key});

  static final ButtonStyle _dialogPrimaryStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  );

  Future<void> _editSpent(BuildContext context, String name) async {
    final store = context.read<TripStore>();
    final controller =
        TextEditingController(text: store.categorySpent(name).toString());
    final fmt = NumberFormat.decimalPattern('ko');

    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$name 지출 입력', style: AppText.h3),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '₩ ',
            hintText: '지출 금액',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            style: _dialogPrimaryStyle,
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(controller.text) ?? 0),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (value != null) {
      await store.setCategorySpent(name, value);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name 지출을 ${fmt.format(value)}원으로 저장했어요.')),
        );
      }
    }
  }

  Future<void> _addCategory(BuildContext context) async {
    final store = context.read<TripStore>();
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('카테고리 추가', style: AppText.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: '카테고리 이름'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '초기 지출 (선택)',
                prefixText: '₩ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            style: _dialogPrimaryStyle,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      await store.addCategory(
        nameCtrl.text,
        spent: int.tryParse(amountCtrl.text) ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripStore>();
    final won = NumberFormat.decimalPattern('ko');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const BrandAppBar(showBack: true),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const Text('예산 관리', style: AppText.h1),
          const SizedBox(height: 4),
          Text(trip.hasTrip ? '${trip.title} · ${trip.dateRange}' : '진행 중인 여행',
              style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 24),

          // 총예산 요약: 왼쪽 원형 차트 + 오른쪽 총예산
          _OverviewCard(trip: trip, won: won),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('카테고리별 지출', style: AppText.h3),
              TextButton.icon(
                onPressed: () => _addCategory(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('추가'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < trip.categories.length; i++) ...[
                  CategoryRow(
                    name: trip.categories[i].name,
                    spent: trip.categories[i].spent,
                    color: AppColors.categoryColor(i),
                    percent: trip.percentOfTotal(trip.categories[i].spent),
                    won: won,
                    onEdit: () => _editSpent(context, trip.categories[i].name),
                    onDelete: () => trip.removeCategory(trip.categories[i].name),
                  ),
                  if (i != trip.categories.length - 1)
                    const Divider(height: 1, color: AppColors.track),
                ],
                if (trip.categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('카테고리를 추가해 지출을 관리하세요.', style: AppText.caption),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(BudgetScreen.route),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('총예산 수정'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(BudgetDetailScreen.route),
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('상세 내역'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final TripStore trip;
  final NumberFormat won;
  const _OverviewCard({required this.trip, required this.won});

  @override
  Widget build(BuildContext context) {
    final over = trip.usedBudget > trip.totalBudget;
    // 원형 차트 세그먼트: 카테고리 지출 + 잔여(회색).
    final values = <double>[];
    final colors = <Color>[];
    for (var i = 0; i < trip.categories.length; i++) {
      final s = trip.categories[i].spent;
      if (s > 0) {
        values.add(s.toDouble());
        colors.add(AppColors.categoryColor(i));
      }
    }
    final remain = trip.totalBudget - trip.usedBudget;
    if (remain > 0) {
      values.add(remain.toDouble());
      colors.add(AppColors.trackAlt);
    }

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽: 원형(도넛) 차트
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutPainter(values: values, colors: colors),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${trip.progressPercent}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        )),
                    Text('사용', style: AppText.caption),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // 오른쪽: 총예산
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('총 예산', style: AppText.body.copyWith(fontSize: 13)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('₩ ${won.format(trip.totalBudget)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.ink,
                      )),
                ),
                const SizedBox(height: 10),
                _kv('사용', '${won.format(trip.usedBudget)}원',
                    over ? AppColors.danger : AppColors.ink),
                const SizedBox(height: 2),
                _kv('잔여', '${won.format(trip.remaining)}원', AppColors.success),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: AppText.caption),
        Text(v,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 18.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final total = values.fold(0.0, (a, b) => a + b);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.trackAlt;
    canvas.drawCircle(center, radius, bg);

    if (total <= 0) return;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}
