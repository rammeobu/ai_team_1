# Met U 🧳

> **예산 기반 여행 추천 앱** — 총예산·인원·일정·스타일을 입력하면 AI가 여행 계획을 요약하고 카테고리별 예산 배분을 추천합니다.

Flutter로 구현한 크로스플랫폼(Android · iOS · Web · Desktop) 앱으로, 로그인 → 온보딩 4단계 → AI 요약 → 홈 대시보드로 이어지는 흐름을 갖추고 있으며, REST API 백엔드와 연동할 수 있도록 서비스 계층이 분리되어 있습니다.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart SDK](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Provider-4B32C3)
![HTTP](https://img.shields.io/badge/HTTP-Dio-00B4AB)

---

## 목차

- [주요 기능](#주요-기능)
- [화면 구성](#화면-구성)
- [기술 스택](#기술-스택)
- [프로젝트 구조](#프로젝트-구조)
- [시작하기](#시작하기)
- [백엔드 연동](#백엔드-연동)
- [AI 요약 (OpenRouter)](#ai-요약-openrouter)
- [보안 주의](#보안-주의)
- [데이터 모델](#데이터-모델)
- [로드맵 / 더 다듬을 점](#로드맵--더-다듬을-점)

---

## 주요 기능

- **소셜 로그인** — 구글 · 애플 · 카카오 OAuth2 로그인 (`flutter_web_auth_2`, 콜백 스킴 `withact://`)
- **온보딩 4단계** — 예산 입력 → 인원 → 출발지/목적지·날짜 → 여행 스타일 선택
- **AI 여행 요약** — 입력값을 OpenRouter(`gpt-4o-mini`)가 정리해 제목·한줄요약·인사이트·카테고리별 예산 배분을 생성
- **홈 대시보드** — 진행 중 여행 카드, AI 팁, 예산 맞춤 추천 여행지
- **여행 도구** — 항공권 최저가 비교, 숙소 검색·필터·정렬, 예산 맞춤 맛집 추천, 서류·준비물 체크리스트
- **커뮤니티** — 동행 구하기·리뷰 게시판(좋아요·댓글·사진, 정렬 필터, 내 글 수정·삭제)
- **채팅** — 1:1 DM · 그룹채팅 목록
- **예산 관리** — 카테고리별 지출 추가·수정·삭제 (예산의 단일 진실 공급원 `TripStore`)
- **모바일 프레임 미리보기** — 넓은 화면(웹/데스크톱)에서는 iPhone 크기 프레임으로 렌더링

---

## 화면 구성

| 라우트 | 화면 | 설명 |
|---|---|---|
| `/login` | 로그인 | 구글·애플·카카오 소셜 로그인 |
| `/onboarding/budget` | 단계 1 | 총 예산 입력(숫자 포맷 + 슬라이더) |
| `/onboarding/travelers` | 단계 2 | 인원 카운터 |
| `/onboarding/destination` | 단계 3 | 출발지/목적지 + 날짜 범위 선택 |
| `/onboarding/style` | 단계 4 | 여행 스타일 다중 선택 → 계획 생성 |
| `/onboarding/summary` | AI 요약 | 입력값을 AI가 정리한 요약 확인 후 확정 |
| `/home` | 홈 | 진행 중 여행 · AI 팁 · 추천 여행지 |
| `/flight` | 항공권 | 날짜별 최저가 비교 · 예약 흐름 |
| `/hotel` | 숙소 | 필터 · 정렬 · 예약 흐름 |
| `/restaurants` | 맛집 | 예산 맞춤 맛집 추천 · 일정 저장 |
| `/documents` | 서류 | 여행 서류 · 준비물 체크리스트 |
| `/community` | 게시판 | 동행 구하기 · 여행지 추천 · 리뷰 |
| `/chat` | 톡 | 1:1 DM · 그룹채팅 목록 |
| `/budget` | 예산 관리 | 카테고리별 지출 추가 · 수정 · 삭제 |

---

## 기술 스택

| 영역 | 사용 기술 |
|---|---|
| 프레임워크 | Flutter (Dart SDK `>=3.0.0 <4.0.0`) |
| 상태관리 | [Provider](https://pub.dev/packages/provider) |
| HTTP 클라이언트 | [Dio](https://pub.dev/packages/dio) |
| 로컬 저장 | `shared_preferences` (설정·예산), `flutter_secure_storage` (토큰·API 키) |
| 인증 | `flutter_web_auth_2` (OAuth2 브라우저 플로우) |
| 파일/링크 | `file_picker`, `url_launcher` |
| 포맷/국제화 | `intl` |
| AI | [OpenRouter](https://openrouter.ai) — OpenAI Chat Completions 호환 API |

---

## 프로젝트 구조

```
lib/
├─ main.dart                     # DI(Provider) 구성 + 라우팅 + 모바일 프레임 셸
├─ theme/app_theme.dart          # 디자인 색상 · 타이포
├─ models/models.dart            # AppUser, TripPlan, TripSummary, ActiveTrip 등
├─ providers/                    # AuthProvider, OnboardingProvider, HomeProvider
├─ services/
│  ├─ api_service.dart           # Dio 래퍼 (baseUrl · 토큰 · API 키 · 에러 메시지 변환)
│  ├─ auth_service.dart          # 소셜 로그인 API
│  ├─ trip_service.dart          # 여행 계획 저장 / 홈 데이터 / AI 프리뷰 경계
│  ├─ openrouter_service.dart    # AI 요약(OpenRouter) 직접 호출
│  ├─ ai_config_store.dart       # OpenRouter API 키 저장(보안 저장소)
│  ├─ api_config_store.dart      # 백엔드 Base URL · API 키 저장
│  ├─ onboarding_session_store.dart # 온보딩 임시 세션 토큰(보안 저장소)
│  ├─ token_storage.dart         # 로그인 토큰 저장
│  ├─ trip_store.dart            # 예산의 단일 진실 공급원
│  ├─ checklist_store.dart       # 서류/체크리스트
│  ├─ chat_store.dart            # 채팅 데모 저장소(세션 메모리)
│  ├─ community_store.dart       # 게시판 데모 저장소(세션 메모리)
│  └─ country_doc_rules.dart     # 국가별 서류 규칙
├─ screens/                      # 앱 화면 (로그인·온보딩·홈·항공·숙소·맛집·게시판 등)
└─ widgets/common_widgets.dart   # 앱바 · 프로그레스바 · 버튼 · 카드
```

지원 플랫폼 폴더: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`

---

## 시작하기

### 사전 준비
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (Dart `>=3.0.0`)
- `flutter doctor` 로 환경 확인

### 실행

```bash
# 1. 의존성 설치
flutter pub get

# 2. 실행 (연결된 기기/에뮬레이터/브라우저)
flutter run

# 웹으로 바로 실행하려면
flutter run -d chrome
```

첫 실행 후 **프로필 → API 연결 설정**에서 백엔드 주소와 OpenRouter 키를 입력하세요. (아래 참고)

---

## 백엔드 연동

1. `lib/main.dart` 의 `baseUrl`(`https://api.withact.xyz`)을 실제 서버 주소로 변경하거나, 앱 실행 후 **프로필 > API 연결 설정**에서 입력합니다.
2. `AuthService` / `TripService` 는 이미 실제 API를 호출하도록 구현되어 있으므로, 서버 규격이 다르면 각 서비스의 경로/파싱 부분만 조정하면 됩니다.

### 서버 계약 (예시)

```
POST /auth/social      { provider, token }            -> { accessToken, user }
POST /onboarding/draft (TripPlan JSON)                 -> { sessionToken }
POST /trips            (TripPlan JSON + sessionToken)  -> { tripId }
GET  /trips/active                                     -> { trip }
GET  /recommendations                                  -> { items: [...] }
```

- `POST /onboarding/draft` 는 스타일 선택 완료 직후 입력값을 서버에 임시 저장하고 세션 토큰을 발급받는 용도입니다. (웹의 httpOnly 쿠키에 대응하는 모바일 방식 — `OnboardingSessionStore` 가 기기 보안 저장소에 토큰을 보관하고 최종 `/trips` 호출 시 함께 전달)
- 로그인 성공 시 토큰이 `ApiService.setToken` 으로 저장되어 이후 모든 요청 헤더(`Authorization: Bearer ...`)에 자동 첨부됩니다.
- 백엔드 API 키가 있으면 `X-API-Key` 헤더로 전송됩니다. (서버 규격에 맞게 헤더 이름 조정)

> `ApiService` 는 Dio 인터셉터로 타임아웃·네트워크·권한(401/403)·서버(5xx) 오류를 사용자에게 보여줄 한국어 메시지로 변환하고, 서버가 응답 본문에 담아 보낸 에러 메시지가 있으면 그걸 우선 표시합니다.

---

## AI 요약 (OpenRouter)

`/onboarding/summary` 화면은 **백엔드가 아니라 클라이언트에서 [OpenRouter](https://openrouter.ai)를 직접 호출**해 AI 요약을 만듭니다. (`lib/services/openrouter_service.dart`, 모델 `openai/gpt-4o-mini`)

- 예산·인원·출발지·목적지·날짜·스타일을 프롬프트로 보내고, 다음 JSON 스키마로 응답을 받습니다:
  - `title` — AI가 만든 여행 제목
  - `overview` — 한 줄 요약
  - `highlights` — 예산/일정 관점의 인사이트 3~5개
  - `budgetBreakdown` — 카테고리별 추천 예산 배분(합계 = 총예산, percent 합계 = 100)
- 키는 앱 안 **프로필 > API 연결 설정 > AI 연동(OpenRouter)** 에서 입력하고, 기기 보안 저장소(Keychain / Keystore)에 저장됩니다. (`ai_config_store.dart`)
- 키가 없으면 이 화면은 안내 메시지 + 재시도 버튼을 보여줍니다.

---

## 데이터 모델

`lib/models/models.dart` 의 주요 모델:

| 모델 | 역할 |
|---|---|
| `AppUser` | 로그인 사용자(id · name · email · photoUrl) |
| `TripPlan` | 온보딩 4단계 동안 채워지는 여행 계획(예산 · 인원 · 출발/목적지 · 날짜 · 스타일) |
| `TripStyle` | 여행 스타일 enum — 힐링 · 관광 · 맛집 · 쇼핑 · 액티비티 |
| `TripSummary` | AI가 정리한 요약(제목 · 개요 · 인사이트 · 예산 배분) |
| `BudgetAllocation` | 카테고리별 예산 배분(금액 · 비율) |
| `ActiveTrip` | 홈 대시보드의 진행 중 여행 카드 |
| `RecommendedTheme` | 예산별 AI 추천 여행지 카드 |

> 예산 값은 모델이 아니라 `TripStore` 를 단일 진실 공급원으로 삼아 설정 화면과 홈 카드가 함께 구독합니다.

---

## 로드맵 / 더 다듬을 점

실제 서비스 수준으로 발전시키려면 아래 항목을 정하면 좋습니다.

- **대상 사용자** — 혼행 · 커플 · 가족 · 대학생 · 직장인 중 우선순위
- **여행 범위** — 국내만 / 해외만 / 국내+해외
- **로그인 우선순위** — 카카오 · 구글 · 애플 중 출시 순서
- **예약 플로우** — 앱 내 결제/예약 vs 외부 예약 사이트 연결
- **데이터 소스** — 실제 백엔드·추천 API 사용 여부(현재 채팅/게시판은 세션 메모리 데모)
- **디자인 가이드** — 색상 · 로고 · 말투 · 금지 스타일
- **AI 호출 백엔드 이전** — 보안 강화를 위한 프록시 전환
- **에셋 교체** — 현재 플레이스홀더(아이콘·그라디언트)를 실제 이미지로 (`assets/` 추가 후 `pubspec.yaml` 등록)

---

<sub>Met U · Flutter 예산 여행 추천 앱 · <a href="https://github.com/rammeobu/ai_team_1">rammeobu/ai_team_1</a></sub>
