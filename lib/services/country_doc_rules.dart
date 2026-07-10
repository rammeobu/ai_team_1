/// 목적지 국가별 입국/서류 규칙 (대한민국 여권 기준).
///
/// 실제 서비스에서는 이 데이터를 여행서류 API(Sherpa, IATA Timatic 등)나
/// 백엔드로 교체하면 됩니다. 지금은 로컬 규칙 맵으로 매칭합니다.
/// 각 서류에는 공식 신청/안내 URL을 연결해 바로 처리할 수 있게 했습니다.

/// 개별 서류 항목.
class DocItem {
  final String title;
  final bool required; // 필수(true) / 권장(false)
  final String? url; // 공식 신청·안내 링크
  final String? actionLabel; // 버튼 라벨 (예: '신청', '등록')

  const DocItem(this.title,
      {this.required = true, this.url, this.actionLabel});
}

class CountryDocRule {
  final String country; // '미국'
  final String flag; // 이모지 국기
  final String visaType; // 'ESTA (전자여행허가)'
  final int stayDays; // 무비자/허가 체류 일수
  final List<DocItem> docs;
  final String note;

  const CountryDocRule({
    required this.country,
    required this.flag,
    required this.visaType,
    required this.stayDays,
    required this.docs,
    required this.note,
  });
}

class CountryDocRules {
  static const _passportUrl = 'https://www.passport.go.kr';
  static const _insuranceUrl = 'https://www.google.com/search?q=여행자보험+비교';

  /// 국가명 → 규칙.
  static const Map<String, CountryDocRule> byCountry = {
    '미국': CountryDocRule(
      country: '미국',
      flag: '🇺🇸',
      visaType: 'ESTA (전자여행허가 · 무비자 VWP)',
      stayDays: 90,
      docs: [
        DocItem('전자여권 (체류기간 + 6개월 이상 권장)',
            url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('ESTA 승인 (출발 최소 72시간 전)',
            url: 'https://esta.cbp.dhs.gov', actionLabel: 'ESTA 신청'),
        DocItem('왕복 또는 제3국행 항공권'),
        DocItem('숙소 주소 · 여행 일정표'),
        DocItem('영문 재정 증빙', required: false),
        DocItem('여행자 보험', required: false, url: _insuranceUrl, actionLabel: '가입'),
      ],
      note: '무비자(VWP) 입국은 ESTA 승인이 필수예요. 관광·상용 90일 이내만 가능하고, ESTA는 보통 2년간 유효합니다.',
    ),
    '일본': CountryDocRule(
      country: '일본',
      flag: '🇯🇵',
      visaType: '무비자',
      stayDays: 90,
      docs: [
        DocItem('여권', url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('Visit Japan Web (입국 심사 QR)',
            url: 'https://www.vjw.digital.go.jp', actionLabel: '등록'),
        DocItem('왕복 항공권'),
        DocItem('여행자 보험', required: false, url: _insuranceUrl, actionLabel: '가입'),
      ],
      note: '입국 심사·세관 QR을 Visit Japan Web에서 미리 등록하면 빠릅니다.',
    ),
    '베트남': CountryDocRule(
      country: '베트남',
      flag: '🇻🇳',
      visaType: '무비자 (초과 시 e-Visa)',
      stayDays: 45,
      docs: [
        DocItem('여권 (6개월 이상)', url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('왕복 항공권'),
        DocItem('e-Visa (45일 초과 체류 시)',
            required: false,
            url: 'https://evisa.gov.vn',
            actionLabel: 'e-Visa 신청'),
        DocItem('여행자 보험', required: false, url: _insuranceUrl, actionLabel: '가입'),
      ],
      note: '45일 이내는 무비자, 그 이상 머물면 전자비자(e-Visa)를 발급받아야 해요.',
    ),
    '태국': CountryDocRule(
      country: '태국',
      flag: '🇹🇭',
      visaType: '무비자',
      stayDays: 90,
      docs: [
        DocItem('여권 (6개월 이상)', url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('왕복 항공권'),
        DocItem('입국카드 (TDAC)',
            url: 'https://tdac.immigration.go.th', actionLabel: '작성'),
        DocItem('여행자 보험', required: false, url: _insuranceUrl, actionLabel: '가입'),
      ],
      note: '관광 목적 무비자 체류가 가능합니다.',
    ),
    '대만': CountryDocRule(
      country: '대만',
      flag: '🇹🇼',
      visaType: '무비자',
      stayDays: 90,
      docs: [
        DocItem('여권 (6개월 이상)', url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('왕복 항공권'),
        DocItem('입국신고서 (온라인)',
            url: 'https://oa.immigration.gov.tw', actionLabel: '작성'),
      ],
      note: '온라인 입국신고서를 미리 작성하면 편리합니다.',
    ),
    '필리핀': CountryDocRule(
      country: '필리핀',
      flag: '🇵🇭',
      visaType: '무비자',
      stayDays: 30,
      docs: [
        DocItem('여권 (6개월 이상)', url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('왕복 항공권'),
        DocItem('eTravel 등록 (입국 QR)',
            url: 'https://etravel.gov.ph', actionLabel: '등록'),
      ],
      note: '입국 전 eTravel 등록이 필요합니다.',
    ),
    '영국': CountryDocRule(
      country: '영국',
      flag: '🇬🇧',
      visaType: '무비자 (ETA)',
      stayDays: 180,
      docs: [
        DocItem('여권', url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('ETA (전자여행허가)',
            url: 'https://www.gov.uk/apply-eta', actionLabel: 'ETA 신청'),
        DocItem('귀국 항공권 · 숙소 증빙'),
      ],
      note: '전자여행허가(ETA) 사전 신청이 필요합니다.',
    ),
    '호주': CountryDocRule(
      country: '호주',
      flag: '🇦🇺',
      visaType: 'ETA (전자비자)',
      stayDays: 90,
      docs: [
        DocItem('여권', url: _passportUrl, actionLabel: '여권 안내'),
        DocItem('ETA (전자비자 · 앱 신청)',
            url:
                'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/electronic-travel-authority-601',
            actionLabel: 'ETA 안내'),
        DocItem('귀국 항공권'),
      ],
      note: '무비자가 아니라 ETA(전자비자)를 반드시 발급받아야 입국할 수 있어요.',
    ),
  };

  /// 도시명 → 국가명.
  static const Map<String, String> _cityToCountry = {
    '오사카': '일본', '도쿄': '일본', '후쿠오카': '일본', '삿포로': '일본', '오키나와': '일본',
    '뉴욕': '미국', '로스앤젤레스': '미국', 'la': '미국', '엘에이': '미국',
    '라스베이거스': '미국', '샌프란시스코': '미국', '시애틀': '미국', '시카고': '미국',
    '하와이': '미국', '호놀룰루': '미국', '괌': '미국', '사이판': '미국', '워싱턴': '미국',
    '다낭': '베트남', '하노이': '베트남', '호치민': '베트남',
    '방콕': '태국', '치앙마이': '태국', '푸켓': '태국',
    '타이베이': '대만', '가오슝': '대만',
    '세부': '필리핀', '마닐라': '필리핀', '보라카이': '필리핀',
    '런던': '영국', '시드니': '호주', '멜버른': '호주',
  };

  static CountryDocRule? ruleForCity(String city) {
    final key = city.trim().toLowerCase();
    final country = _cityToCountry[key] ?? _cityToCountry[city.trim()];
    if (country == null) return null;
    return byCountry[country];
  }

  static CountryDocRule? ruleForCountry(String country) => byCountry[country];

  static List<String> get countryNames => byCountry.keys.toList();
}
