import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/checklist_store.dart';
import '../services/country_doc_rules.dart';
import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// 여행 서류 및 체크리스트.
/// 홈의 "서류" 빠른 버튼에서 진입합니다.
/// 탭(서류·준비물·예약) + 진행률, 목적지 맞춤 비자/D-day, 항목 추가·삭제, 파일 첨부.
class DocumentsChecklistScreen extends StatefulWidget {
  static const route = '/documents';
  const DocumentsChecklistScreen({super.key});

  @override
  State<DocumentsChecklistScreen> createState() =>
      _DocumentsChecklistScreenState();
}

class _DocumentsChecklistScreenState extends State<DocumentsChecklistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _dateFmt = DateFormat('yyyy.MM.dd');

  // 선택된 목적지 국가 (기본: 여행 목적지에서 매칭, 없으면 미국 데모).
  String? _country;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: ChecklistSection.values.length, vsync: this);
    _tab.addListener(() => setState(() {}));
    final dest =
        context.read<TripStore>().title.replaceAll(' 여행', '').trim();
    _country = CountryDocRules.ruleForCity(dest)?.country ?? '미국';
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _addItem(BuildContext context, ChecklistSection s) async {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${s.label} 항목 추가', style: AppText.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: '항목 이름'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subCtrl,
              decoration: const InputDecoration(labelText: '메모 (선택)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('추가'),
          ),
        ],
      ),
    );
    if (ok == true && titleCtrl.text.trim().isNotEmpty && context.mounted) {
      context.read<ChecklistStore>().add(s, titleCtrl.text, subCtrl.text);
    }
  }

  Future<void> _attach(BuildContext context, String id) async {
    final res = await FilePicker.platform.pickFiles(withData: false);
    if (res != null && res.files.isNotEmpty && context.mounted) {
      context.read<ChecklistStore>().setAttachment(id, res.files.first.name);
    }
  }

  Future<void> _pickPassportExpiry(BuildContext context) async {
    final store = context.read<ChecklistStore>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 15),
      initialDate: store.passportExpiry ?? DateTime(now.year + 5),
    );
    if (picked != null) store.setPassportExpiry(picked);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ChecklistStore>();
    final trip = context.watch<TripStore>();
    final dest = trip.title.replaceAll(' 여행', '').trim();
    final departure = trip.departureDate;
    final rule =
        _country == null ? null : CountryDocRules.ruleForCountry(_country!);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        title: const Text('여행 서류 · 체크리스트', style: AppText.h3),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtleText,
          indicatorColor: AppColors.primary,
          labelStyle: AppText.label,
          tabs: [
            for (final s in ChecklistSection.values)
              Tab(text: '${s.label} ${store.doneOf(s)}/${store.totalOf(s)}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _addItem(context, ChecklistSection.values[_tab.index]),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('항목 추가',
            style: AppText.label.copyWith(color: Colors.white)),
      ),
      body: Column(
        children: [
          // 상단 요약: 전체 진행률 + 목적지/D-day
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dest.isNotEmpty ? '$dest · ${trip.dateRange}' : '출발 준비',
                      style: AppText.body.copyWith(fontSize: 13),
                    ),
                    Text('${(store.progress * 100).round()}% 완료',
                        style: AppText.label.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                // 섹션별 원형 진행률 (탭하면 해당 탭으로 이동)
                Row(
                  children: [
                    _sectionRing(store, ChecklistSection.documents, 0,
                        AppColors.primary),
                    _sectionRing(store, ChecklistSection.packing, 1,
                        AppColors.success),
                    _sectionRing(store, ChecklistSection.booking, 2,
                        AppColors.accent),
                  ],
                ),
                const SizedBox(height: 12),
                // 목적지 국가 선택 (도시 자동 매칭, 변경 가능)
                Row(
                  children: [
                    const Icon(Icons.public,
                        size: 16, color: AppColors.subtleText),
                    const SizedBox(width: 6),
                    Text('목적지 국가', style: AppText.caption),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _country,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (final c in CountryDocRules.countryNames)
                          DropdownMenuItem(
                            value: c,
                            child: Text(
                                '${CountryDocRules.byCountry[c]!.flag} $c',
                                style: AppText.label),
                          ),
                      ],
                      onChanged: (v) => setState(() => _country = v),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 비자 유형 + D-day 정보 칩
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (rule != null)
                      _infoChip(Icons.approval_outlined,
                          '${rule.visaType} · ${rule.stayDays}일'),
                    if (departure != null)
                      _infoChip(Icons.flight_takeoff,
                          '출발 D-${departure.difference(DateTime.now()).inDays}'),
                    _passportChip(context, store, departure),
                  ],
                ),
              ],
            ),
          ),
          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                for (final s in ChecklistSection.values)
                  _sectionList(context, store, s, rule),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionList(BuildContext context, ChecklistStore store,
      ChecklistSection s, CountryDocRule? rule) {
    final items = store.section(s);
    // 서류 탭 맨 위에 "국가별 필수 서류" 매칭 카드.
    final showRule = s == ChecklistSection.documents && rule != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (showRule) ...[
          _countryRuleCard(context, store, rule),
          const SizedBox(height: 16),
        ],
        if (items.isEmpty) const EmptyState('항목이 없어요. + 버튼으로 추가하세요.'),
        for (var i = 0; i < items.length; i++) ...[
          _ChecklistTile(
            item: items[i],
            onToggle: () => store.toggle(items[i].id),
            onDelete: () => store.remove(items[i].id),
            onAttach: () => _attach(context, items[i].id),
            onRemoveAttach: () => store.setAttachment(items[i].id, null),
            onOpenLink: items[i].link == null
                ? null
                : () => _openUrl(context, items[i].link!),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  /// 목적지 국가에 필요한 서류 매칭 카드 + 체크리스트 담기.
  Widget _countryRuleCard(
      BuildContext context, ChecklistStore store, CountryDocRule rule) {
    final notYet = rule.docs
        .where((d) => !store.hasTitle(ChecklistSection.documents, d.title))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rule.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${rule.country} 입국 필수 서류',
                    style: AppText.h3.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${rule.visaType} · 체류 ${rule.stayDays}일',
              style: AppText.caption.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          for (final d in rule.docs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    d.required
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color:
                        d.required ? AppColors.primary : AppColors.subtleText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(d.title,
                        style: AppText.body.copyWith(fontSize: 14)),
                  ),
                  if (!d.required)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.trackAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('권장', style: AppText.caption),
                    ),
                  if (d.url != null)
                    TextButton(
                      onPressed: () => _openUrl(context, d.url!),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(d.actionLabel ?? '바로가기',
                          style: AppText.caption
                              .copyWith(color: AppColors.primary)),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 15, color: AppColors.subtleText),
                const SizedBox(width: 6),
                Expanded(child: Text(rule.note, style: AppText.caption)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: notYet.isEmpty
                  ? null
                  : () async {
                      await store.addAll(
                        ChecklistSection.documents,
                        notYet.map((d) => (
                              title: d.title,
                              subtitle:
                                  '${rule.country} 입국 요건${d.required ? '' : ' · 권장'}',
                              link: d.url,
                            )),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('${notYet.length}개 서류를 체크리스트에 담았어요.')));
                      }
                    },
              icon: const Icon(Icons.playlist_add, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              label: Text(notYet.isEmpty
                  ? '이미 모두 담았어요'
                  : '체크리스트에 담기 (${notYet.length})'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('링크를 열 수 없어요: $url')),
      );
    }
  }

  /// 섹션별 원형 진행률 링.
  Widget _sectionRing(
      ChecklistStore store, ChecklistSection s, int index, Color color) {
    final total = store.totalOf(s);
    final done = store.doneOf(s);
    final pct = total == 0 ? 0.0 : done / total;
    final complete = total > 0 && done == total;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: () => _tab.animateTo(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 6,
                        backgroundColor: AppColors.trackAlt,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    if (complete)
                      Icon(Icons.check, color: color, size: 22)
                    else
                      Text('$done/$total',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          )),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(s.label,
                  style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.caption.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _passportChip(
      BuildContext context, ChecklistStore store, DateTime? departure) {
    final exp = store.passportExpiry;
    // 여권 만료가 출발일 기준 6개월 미만이면 경고.
    bool warn = false;
    String label;
    if (exp == null) {
      label = '여권 만료일 입력';
    } else {
      final ref = departure ?? DateTime.now();
      final months = (exp.difference(ref).inDays) / 30;
      warn = months < 6;
      label = '여권 만료 ${_dateFmt.format(exp)}${warn ? ' · 6개월 미만!' : ''}';
    }
    final color = warn ? AppColors.danger : AppColors.bodyText;
    return InkWell(
      onTap: () => _pickPassportExpiry(context),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: warn
              ? AppColors.danger.withOpacity(0.08)
              : AppColors.canvas,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: warn ? AppColors.danger : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge_outlined, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: AppText.caption
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onAttach;
  final VoidCallback onRemoveAttach;
  final VoidCallback? onOpenLink;
  const _ChecklistTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onAttach,
    required this.onRemoveAttach,
    this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final checked = item.checked;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              // 체크박스 + 텍스트 전체가 탭 영역 (줄 아무 데나 눌러도 체크)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: Row(
                    children: [
                      Icon(
                        checked ? Icons.check_circle : Icons.circle_outlined,
                        color: checked ? AppColors.success : AppColors.border,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: AppText.body.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  decoration: checked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: checked
                                      ? AppColors.subtleText
                                      : AppColors.ink,
                                )),
                            if (item.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(item.subtitle, style: AppText.caption),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 바로가기(공식 신청 링크)
              if (onOpenLink != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '바로가기',
                  onPressed: onOpenLink,
                  icon: const Icon(Icons.open_in_new,
                      size: 18, color: AppColors.primary),
                ),
              // 첨부 버튼
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: '파일 첨부',
                onPressed: onAttach,
                icon: Icon(Icons.attach_file,
                    size: 18,
                    color: item.attachment != null
                        ? AppColors.primary
                        : AppColors.subtleText),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: '삭제',
                onPressed: onDelete,
                icon: const Icon(Icons.close,
                    size: 18, color: AppColors.subtleText),
              ),
            ],
          ),
          if (item.attachment != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.attachment!,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption
                            .copyWith(color: AppColors.primary)),
                  ),
                  GestureDetector(
                    onTap: onRemoveAttach,
                    child: const Icon(Icons.cancel,
                        size: 15, color: AppColors.subtleText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
