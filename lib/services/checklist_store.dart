import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 체크리스트 섹션(탭).
enum ChecklistSection { documents, packing, booking }

extension ChecklistSectionLabel on ChecklistSection {
  String get label {
    switch (this) {
      case ChecklistSection.documents:
        return '필수 서류';
      case ChecklistSection.packing:
        return '준비물';
      case ChecklistSection.booking:
        return '예약 확인';
    }
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String subtitle;
  final ChecklistSection section;
  final bool checked;
  final bool removable; // 사용자 추가 항목만 자유 삭제(기본 항목도 삭제 허용)
  final String? attachment; // 첨부 파일명(있으면 첨부됨)
  final String? link; // 공식 신청/안내 URL (있으면 '바로가기' 노출)

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.section,
    this.checked = false,
    this.removable = false,
    this.attachment,
    this.link,
  });

  ChecklistItem copyWith(
          {bool? checked, String? attachment, bool clearAttachment = false}) =>
      ChecklistItem(
        id: id,
        title: title,
        subtitle: subtitle,
        section: section,
        checked: checked ?? this.checked,
        removable: removable,
        attachment: clearAttachment ? null : (attachment ?? this.attachment),
        link: link,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'section': section.index,
        'checked': checked,
        'removable': removable,
        'attachment': attachment,
        'link': link,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String? ?? '',
        section: ChecklistSection.values[(j['section'] ?? 0) as int],
        checked: j['checked'] as bool? ?? false,
        removable: j['removable'] as bool? ?? false,
        attachment: j['attachment'] as String?,
        link: j['link'] as String?,
      );
}

/// 여행 서류/체크리스트의 단일 진실 공급원. shared_preferences 영구 저장.
class ChecklistStore extends ChangeNotifier {
  static const _kItems = 'checklist_items_json';
  static const _kPassport = 'checklist_passport_expiry';

  final SharedPreferences _prefs;
  List<ChecklistItem> _items = [];
  DateTime? _passportExpiry;
  int _seq = 0; // 고유 ID 생성용 시퀀스

  ChecklistStore(this._prefs) {
    _restore();
  }

  List<ChecklistItem> get items => List.unmodifiable(_items);
  DateTime? get passportExpiry => _passportExpiry;

  List<ChecklistItem> section(ChecklistSection s) =>
      _items.where((i) => i.section == s).toList();

  int get total => _items.length;
  int get done => _items.where((i) => i.checked).length;
  double get progress => total == 0 ? 0.0 : done / total;

  int doneOf(ChecklistSection s) =>
      _items.where((i) => i.section == s && i.checked).length;
  int totalOf(ChecklistSection s) =>
      _items.where((i) => i.section == s).length;

  Future<void> toggle(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(checked: !_items[idx].checked);
    await _persist();
    notifyListeners();
  }

  Future<void> add(ChecklistSection s, String title, String subtitle,
      {String? link}) async {
    final t = title.trim();
    if (t.isEmpty) return;
    _items.add(ChecklistItem(
      id: 'u${DateTime.now().microsecondsSinceEpoch}_${_seq++}',
      title: t,
      subtitle: subtitle.trim(),
      section: s,
      removable: true,
      link: link,
    ));
    await _persist();
    notifyListeners();
  }

  /// 여러 항목을 한 번에 추가(예: 국가별 필수 서류 일괄 담기). 저장은 한 번만 수행.
  Future<void> addAll(
    ChecklistSection s,
    Iterable<({String title, String subtitle, String? link})> items,
  ) async {
    for (final item in items) {
      final t = item.title.trim();
      if (t.isEmpty) continue;
      _items.add(ChecklistItem(
        id: 'u${DateTime.now().microsecondsSinceEpoch}_${_seq++}',
        title: t,
        subtitle: item.subtitle.trim(),
        section: s,
        removable: true,
        link: item.link,
      ));
    }
    await _persist();
    notifyListeners();
  }

  /// 이미 존재하는(제목 기준) 항목인지.
  bool hasTitle(ChecklistSection s, String title) =>
      _items.any((i) => i.section == s && i.title == title);

  Future<void> remove(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> setAttachment(String id, String? fileName) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx]
        .copyWith(attachment: fileName, clearAttachment: fileName == null);
    await _persist();
    notifyListeners();
  }

  Future<void> setPassportExpiry(DateTime? d) async {
    _passportExpiry = d;
    if (d == null) {
      await _prefs.remove(_kPassport);
    } else {
      await _prefs.setString(_kPassport, d.toIso8601String());
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setString(
        _kItems, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void _restore() {
    final p = _prefs.getString(_kPassport);
    _passportExpiry = p == null ? null : DateTime.tryParse(p);

    final raw = _prefs.getString(_kItems);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _items = list
            .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      } catch (_) {}
    }
    _items = _defaults();
  }

  static List<ChecklistItem> _defaults() => const [
        // 필수 서류
        ChecklistItem(
            id: 'passport',
            title: '여권',
            subtitle: '만료일이 6개월 이상 남았는지 확인',
            section: ChecklistSection.documents),
        ChecklistItem(
            id: 'visa',
            title: '비자 / ETA',
            subtitle: '목적지 입국 요건 확인',
            section: ChecklistSection.documents),
        ChecklistItem(
            id: 'insurance',
            title: '여행자 보험',
            subtitle: '가입 및 증서 보관',
            section: ChecklistSection.documents),
        // 준비물
        ChecklistItem(
            id: 'adapter',
            title: '충전기 · 멀티 어댑터',
            subtitle: '국가별 콘센트 규격 확인',
            section: ChecklistSection.packing),
        ChecklistItem(
            id: 'meds',
            title: '상비약',
            subtitle: '두통약·소화제·밴드',
            section: ChecklistSection.packing),
        ChecklistItem(
            id: 'cash',
            title: '현금 · 카드',
            subtitle: '환전 및 해외결제 카드',
            section: ChecklistSection.packing),
        ChecklistItem(
            id: 'sim',
            title: '유심 · 로밍',
            subtitle: '데이터 요금제 준비',
            section: ChecklistSection.packing),
        // 예약 확인
        ChecklistItem(
            id: 'eticket',
            title: '항공권 (e-티켓)',
            subtitle: '출발·귀국편 예약 확인',
            section: ChecklistSection.booking),
        ChecklistItem(
            id: 'hotel',
            title: '숙소 바우처',
            subtitle: '체크인 정보 저장',
            section: ChecklistSection.booking),
      ];
}
