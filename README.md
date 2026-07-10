# Met U (Flutter)

예산 기반 여행 추천 앱. 제공된 디자인(로그인 + 온보딩 4단계 + 홈 대시보드)을 Flutter로 구현하고, REST API 백엔드에 연동할 수 있도록 서비스 계층을 분리했습니다.

## 화면 구성

| 라우트 | 화면 | 설명 |
|---|---|---|
| `/login` | 로그인 | 구글·애플·카카오 소셜 로그인 |
| `/onboarding/budget` | 단계 1 | 총 예산 입력(숫자 포맷 + 슬라이더) |
| `/onboarding/travelers` | 단계 2 | 인원 카운터 |
| `/onboarding/destination` | 단계 3 | 출발지/목적지 + 날짜 범위 선택 |
| `/onboarding/style` | 단계 4 | 여행 스타일 다중 선택 → 계획 생성 |
| `/onboarding/summary` | AI 요약 | 입력값을 AI가 정리한 요약 확인 후 확정 |
| `/home` | 홈 | 진행 중 여행·AI 팁·추천 여행지 |
| `/flight` | 항공권 | 날짜별 최저가 비교·예약 흐름 |
| `/hotel` | 숙소 | 필터·정렬·예약 흐름 |
| `/restaurants` | 맛집 | 예산 맞춤 맛집 추천·일정 저장 |
| `/documents` | 서류 | 여행 서류·준비물 체크리스트 |
| `/community` | 게시판 | 동행 구하기·여행지 추천·리뷰 (좋아요·댓글·사진, 정렬 필터, 내 글 수정·삭제) |
| `/chat` | 톡 | 1:1 DM·그룹채팅 목록 |
| `/budget` | 예산 관리 | 카테고리별 지출 추가·수정·삭제 |

## 추가로 있으면 좋은 프롬프트 정보

실제 서비스 수준으로 더 다듬으려면 아래 내용을 알려주면 좋습니다.

- 대상 사용자: 혼행, 커플, 가족, 대학생, 직장인 중 어디에 맞출지
- 여행 범위: 국내만, 해외만, 국내+해외 모두
- 실제 로그인 방식: 카카오, 구글, 애플 중 출시 우선순위
- 결제/예약을 앱 안에서 끝낼지, 외부 예약 사이트로 보낼지
- 백엔드와 AI 추천 API가 이미 있는지, 데모 데이터로 먼저 갈지
- 꼭 필요한 색상, 로고, 말투, 금지하고 싶은 디자인 스타일

## 아키텍처

```
lib/
  main.dart               # DI(Provider) + 라우팅
  theme/app_theme.dart    # 디자인 색상·타이포
  models/models.dart      # AppUser, TripPlan, ActiveTrip 등
  services/
    api_service.dart      # Dio 래퍼 (baseUrl / 토큰)
    auth_service.dart     # 소셜 로그인 API
    trip_service.dart     # 여행 계획 저장 / 홈 데이터
    openrouter_service.dart # AI 요약(OpenRouter) 직접 호출
    ai_config_store.dart  # OpenRouter API 키 저장(보안 저장소)
    onboarding_session_store.dart # 온보딩 임시 저장 세션 토큰(보안 저장소)
  providers/              # AuthProvider, OnboardingProvider, HomeProvider
  screens/                # 앱 화면
  widgets/common_widgets.dart  # 앱바·프로그레스바·버튼·카드
```

- 상태관리: **Provider**
- HTTP: **Dio**

## 백엔드 연동 방법

1. `lib/main.dart` 의 `baseUrl` 을 실제 서버 주소로 변경합니다(또는 앱 실행 후
   프로필 > API 연결 설정에서 입력).
2. `AuthService`/`TripService` 는 이미 실제 API를 호출하도록 구현되어 있습니다.
   서버가 아래 계약과 다르면 각 서비스의 경로/파싱 부분만 맞춰 조정하세요.

서버 계약(예시):

```
POST /auth/social      { provider, token }            -> { accessToken, user }
POST /onboarding/draft (TripPlan JSON)                 -> { sessionToken }
POST /trips            (TripPlan JSON + sessionToken)  -> { tripId }
GET  /trips/active                                     -> { trip }
GET  /recommendations                                  -> { items: [...] }
```

`/onboarding/draft`는 스타일 선택 완료 직후 입력값을 서버에 임시 저장하고
세션 토큰을 발급받는 용도입니다(웹의 httpOnly 쿠키에 대응하는 모바일 방식 —
`OnboardingSessionStore`가 기기 보안 저장소에 토큰을 보관하고, 최종 `/trips`
호출 시 함께 전달합니다).

토큰은 로그인 성공 시 `ApiService.setToken` 으로 저장되어 이후 모든 요청
헤더(`Authorization: Bearer ...`)에 자동 첨부됩니다.

## AI 요약 (OpenRouter)

`/onboarding/summary` 화면(예산·인원·일정·스타일 입력 직후)은 **백엔드가 아니라
클라이언트에서 [OpenRouter](https://openrouter.ai)를 직접 호출**해 AI 요약을
만듭니다(`lib/services/openrouter_service.dart`, 모델: `openai/gpt-4o-mini`).

- 키는 앱 안 **프로필 > API 연결 설정 > AI 연동(OpenRouter)** 에서 입력하고,
  기기 보안 저장소(Keychain/Keystore)에 저장됩니다(`ai_config_store.dart`).
- 키가 없으면 이 화면은 안내 메시지 + 재시도 버튼을 보여줍니다.
- ⚠️ **보안 주의**: 클라이언트 앱에 저장된 키는 리버스 엔지니어링으로 추출될 수
  있습니다. 프로덕션에서는 이 호출을 자체 백엔드 프록시(`POST /trips/preview`
  같은 엔드포인트)로 옮기는 것을 권장합니다 — `TripService.previewPlan()`
  하나만 바꾸면 되도록 이미 분리되어 있습니다.

## 실행

```bash
flutter pub get
flutter run
```

## 참고

- 소셜 로그인(`AuthService.signInWithOAuth`)은 백엔드의 OAuth2 엔드포인트로
  브라우저를 열고, `withact://...?token=...` 콜백으로 돌아온 토큰을 보안
  저장소에 저장합니다. Android/iOS 스킴 등록은 `AndroidManifest.xml` /
  `Info.plist` 를 참고하세요.
- 이미지/배경은 디자인의 플레이스홀더를 아이콘·그라디언트로 대체했습니다.
  실제 에셋을 `assets/` 에 추가하고 `pubspec.yaml` 에 등록해 교체하세요.
