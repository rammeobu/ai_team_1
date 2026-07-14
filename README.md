# Met U 🧳 — 예산 기반 AI 여행 플래너

> **누구를 위해**: "얼마 있는데 이 돈으로 어디를, 어떻게 다녀오지?"를 고민하는 예산 제약형 여행자
> **무엇을**: 총예산·인원·일정·스타일만 입력하면, AI 파이프라인이 **검색된 실데이터를 근거로** 예산을 카테고리별로 배분하고 여행 계획을 요약해 주는 서비스

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart SDK](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Provider-4B32C3)
![HTTP](https://img.shields.io/badge/HTTP-Dio-00B4AB)
![AI](https://img.shields.io/badge/AI-OpenRouter%20gpt--4o--mini-8A2BE2)

---

## 목차

1. [서비스 정의](#1-서비스-정의)
2. [핵심 파이프라인 설계](#2-핵심-파이프라인-설계-에이전트--rag)
3. [기술 스택 & 아키텍처](#3-기술-스택--아키텍처)
4. [설치 · 실행 방법](#4-설치--실행-방법)
5. [필요 라이브러리](#5-필요-라이브러리)
6. [시연 시나리오 (대표 · 엣지 케이스)](#6-시연-시나리오-대표--엣지-케이스)
7. [프로젝트 구조](#7-프로젝트-구조)
8. [팀원별 담당 파트](#8-팀원별-담당-파트)

---

## 1. 서비스 정의

### 문제
여행 계획의 병목은 "어디를 갈까"가 아니라 **"내 예산 안에서 어떻게 배분할까"** 다. 항공·숙소·식비·활동을 각각 따로 검색하다 보면 총합이 예산을 넘고, 어디서 줄여야 할지 판단이 어렵다.

### 대상 사용자
- 예산이 정해져 있는 **대학생·사회초년생·가족 여행자**
- 여러 예약 사이트를 오가며 비교하기 번거로운 사람
- "이 예산이면 이 여행이 현실적인가?"를 빠르게 확인하고 싶은 사람

### 제공 가치
| 사용자의 질문 | Met U의 답 |
|---|---|
| 이 예산으로 이 여행이 가능한가? | 고정비(항공+숙소) 실측 → **가능/부족 판별**과 대안 제시 |
| 어디에 얼마를 써야 하나? | 스타일 가중치 기반 **카테고리별 예산 배분** |
| 뭘 준비해야 하나? | 국내/해외 판별 → **서류·체크리스트 자동 구성** |

### 핵심 사용자 흐름
`로그인 → 온보딩 4단계(예산·인원·목적지/날짜·스타일) → AI 요약·예산배분 확인 → 홈 대시보드(진행 여행·항공·숙소·맛집·서류)`

---

## 2. 핵심 파이프라인 설계 (에이전트 / RAG)

> **설계 원칙**: LLM은 파이프라인의 **한 구성요소**일 뿐이며, 서비스 로직(판별·검색·계산·검증)이 전체를 통제한다. 단순 "입력→LLM 1회 호출→출력"이 아니라 **검색·판별·분기·멀티스텝·검증**이 연결된 구조.

```
[온보딩 입력: TripPlan]
        │
        ▼
 Stage 0  입력 정규화 & 결측/이상치 판별
        │   · 박/일 계산, 1인 1일 예산 산출, 필수값 검사
        ▼
 Stage 1  판별 (Classification / Routing)
        │   · 국내 vs 해외   · 예산 등급(알뜰/표준/여유)   · 스타일 가중치 프로파일
        ├──── 해외 ─────────► [서류/비자 브랜치] country_doc_rules 조회
        ├──── 예산부족 판별 ─► [대안 브랜치] 일정단축·근거리대안·스타일축소 제안
        ▼ (정상 경로)
 Stage 2  검색 / RAG (Retrieval — 근거 확보)
        │   · 항공 최저가 · 숙소 시세 · 맛집/활동 · 환율 · 국가별 서류(내장 지식베이스)
        ▼
 Stage 3  멀티스텝 예산 추론 (Multi-step, 툴 사용)
        │   A) 고정비(항공+숙소) 실측 계산
        │   B) 잔여예산 = 총예산 − 고정비
        │   C) 잔여를 스타일 가중치로 식비/활동/쇼핑/예비 배분
        │   D) LLM이 검색 데이터를 인용해 highlights·팁 생성
        ▼
 Stage 4  검증 & 자기수정 루프 (Validation)
        │   · Σamount = 총예산? Σpercent = 100? · 고정비 > 예산 → Stage 1 회귀
        │   · 실패 시 재프롬프트(최대 N회)
        ▼
[TripSummary 조립 → 화면 표시 → 확정 시 /trips 저장]
```

### 단계별 요약

| 단계 | 구분 | 하는 일 |
|---|---|---|
| Stage 0 | 정규화 | 결측·이상치 필터로 불필요한 LLM 호출 차단, 파생값(일수·1인예산) 계산 |
| Stage 1 | **판별** | 국내/해외·예산등급·스타일을 분류(규칙 + LLM 혼합)해 경로 결정 |
| Stage 2 | **검색/RAG** | 항공·숙소·환율·서류를 실제 조회해 컨텍스트 주입 → 환각 방지 |
| Stage 3 | **멀티스텝** | 고정비→잔여→배분→인사이트로 이어지는 순차·툴 사용 추론 |
| Stage 4 | 검증 | 예산 제약 강제, 위반 시 자기수정 또는 대안 브랜치로 회귀 |

### "단순 API 호출"과 다른 점
- **검색**: 실제 시세·환율·서류를 조회해 근거 있는 답 생성(RAG)
- **판별**: 상황을 분류해 처리 경로를 나눔
- **분기**: 국내/해외·예산 과부족별로 다른 흐름
- **멀티스텝**: 계산→재검색→재계산이 가능한 툴 사용 루프
- **검증**: 제약 위반을 잡고 스스로 교정

> 현재 코드의 진입점은 `TripService.previewPlan()` → `OpenRouterService.summarizePlan()`. `previewPlan()` 이 경계로 분리돼 있어, 그 뒤를 단일 호출에서 위 파이프라인으로 교체해도 화면 코드는 바뀌지 않는다.

---

## 3. 기술 스택 & 아키텍처

| 영역 | 사용 기술 |
|---|---|
| 프레임워크 | Flutter (Dart SDK `>=3.0.0 <4.0.0`) — Android · iOS · Web · Desktop |
| 상태관리 | [Provider](https://pub.dev/packages/provider) |
| HTTP 클라이언트 | [Dio](https://pub.dev/packages/dio) (인터셉터로 인증·에러 메시지 변환) |
| 로컬 저장 | `shared_preferences`(설정·예산), `flutter_secure_storage`(토큰·API 키) |
| 인증 | `flutter_web_auth_2` (OAuth2 브라우저 플로우, 콜백 `withact://`) |
| AI | [OpenRouter](https://openrouter.ai) — OpenAI Chat Completions 호환 (`gpt-4o-mini`) |

**아키텍처 계층**: `screens`(UI) → `providers`(상태) → `services`(도메인·네트워크·AI) → `models`(데이터). AI 파이프라인은 `services/` 계층에 위치해 화면과 분리.

---

## 4. 설치 · 실행 방법

### 사전 준비
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (Dart `>=3.0.0`)
- `flutter doctor` 로 환경 점검

### 실행
```bash
# 1) 저장소 클론
git clone -b frontend-app https://github.com/rammeobu/ai_team_1.git
cd ai_team_1

# 2) 의존성 설치
flutter pub get

# 3) 실행
flutter run              # 연결된 기기/에뮬레이터
flutter run -d chrome    # 웹 데모(발표 시연 권장)
```

### AI 기능 설정 (필수)
1. 앱 실행 후 **프로필 → API 연결 설정 → AI 연동(OpenRouter)** 로 이동
2. [openrouter.ai](https://openrouter.ai) 에서 발급한 API 키 입력 → 기기 보안 저장소에 저장
3. 온보딩 마지막 단계에서 AI 요약·예산배분 생성

> 백엔드 주소는 **프로필 → API 연결 설정**에서 변경 가능(기본값 `https://api.withact.xyz`).

---

## 5. 필요 라이브러리

`pubspec.yaml` 기준 주요 의존성:

```yaml
dependencies:
  provider: ^6.1.2              # 상태관리
  dio: ^5.4.0                   # HTTP 클라이언트
  shared_preferences: ^2.2.2    # 설정·예산 로컬 저장
  flutter_secure_storage: ^9.0.0# 토큰·API 키 보안 저장
  flutter_web_auth_2: ^5.0.0    # 소셜 로그인(OAuth2)
  file_picker: ^8.1.7           # 파일 선택
  url_launcher: ^6.3.0          # 외부 링크
  intl: ^0.19.0                 # 날짜·숫자 포맷
  cupertino_icons: ^1.0.6
```

설치는 `flutter pub get` 한 번으로 일괄 처리됩니다.

---

## 6. 시연 시나리오 (대표 · 엣지 케이스)

### 대표 케이스 — 서비스 의도대로 정상 작동

| # | 입력 | 기대 동작 |
|---|---|---|
| 1 | 국내 · 100만원 · 2인 · 2박3일 · "맛집" | 국내 판별→서류 스킵, 식비 비중↑ 배분, 현실적 요약 |
| 2 | 해외(일본) · 200만원 · 2인 · 3박4일 · "관광" | 해외 판별→여권/서류 체크리스트 자동 구성, 환율 반영 배분 |
| 3 | 국내 · 50만원 · 1인 · 1박2일 · "힐링" | 알뜰 등급 판별, 숙소·활동 저비용 위주 배분 |

### 엣지 케이스 — 판별이 애매하거나 입력이 지저분한 상황

| # | 입력 | 기대 동작 |
|---|---|---|
| E1 | 해외 · **30만원** · 4인 · 5박6일 | **예산 부족 판별** → 요약 대신 대안 3종(일정 단축·근거리 목적지·인원/스타일 조정) 제시 |
| E2 | 목적지 **공백** 또는 날짜 미정 | Stage 0에서 결측 감지 → LLM 호출 전 재입력 유도 |
| E3 | OpenRouter 키 미설정 / 네트워크 오류 | 안내 메시지 + 재시도 버튼, 한국어 오류 메시지로 변환 |

---

## 7. 프로젝트 구조

```
lib/
├─ main.dart                     # DI(Provider) + 라우팅 + 모바일 프레임 셸
├─ theme/app_theme.dart          # 디자인 색상 · 타이포
├─ models/models.dart            # AppUser, TripPlan, TripSummary, BudgetAllocation 등
├─ providers/                    # AuthProvider, OnboardingProvider, HomeProvider
├─ services/
│  ├─ api_service.dart           # Dio 래퍼(인증·에러 변환)
│  ├─ auth_service.dart          # 소셜 로그인
│  ├─ trip_service.dart          # 여행 계획 저장 / AI 프리뷰 경계 (파이프라인 진입점)
│  ├─ openrouter_service.dart    # AI 요약(OpenRouter) 호출
│  ├─ ai_config_store.dart       # OpenRouter 키 보안 저장
│  ├─ country_doc_rules.dart     # 국가별 서류 규칙(내장 지식베이스 = 로컬 RAG)
│  ├─ trip_store.dart            # 예산 단일 진실 공급원
│  └─ checklist_store.dart · chat_store.dart · community_store.dart
├─ screens/                      # 로그인·온보딩·홈·항공·숙소·맛집·서류·게시판 등
└─ widgets/common_widgets.dart   # 공통 UI
```

---

## 8. 팀원별 담당 파트

> 이름 칸만 팀원 실명으로 바꿔 사용하세요. 4인 기준 역할 분담입니다.

| 팀원 | 역할 | 담당 파트 | 주요 파일/영역 |
|---|---|---|---|
| 김기훈 | **AI/파이프라인 리드** | AI 파이프라인 설계·OpenRouter 연동, 프롬프트/검증 로직 | `services/openrouter_service.dart`, `services/trip_service.dart`, `services/ai_config_store.dart` |
| 강희재 | **온보딩/상태관리** | 온보딩 4단계 UI, 입력 검증, Provider 상태 흐름 | `screens/onboarding_*`, `providers/onboarding_provider.dart`, `models/models.dart` |
| 이수진 | **홈/여행 도구** | 홈 대시보드, 항공·숙소·맛집 검색·필터·정렬 | `screens/home_screen.dart`, `flight_/hotel_/restaurant_screen.dart`, `providers/home_provider.dart` |
| 김운성 | **인증/부가 기능 · 인프라** | 소셜 로그인, 서류 체크리스트, 커뮤니티/채팅, API 계층·배포 | `services/auth_service.dart`, `api_service.dart`, `checklist_store.dart`, `community_store.dart` |

**1팀전체**: 발표자료, 시연 시나리오(대표·엣지 케이스), 코드 리뷰, README 관리

---

<sub>Met U · 예산 기반 AI 여행 플래너 · <a href="https://github.com/rammeobu/ai_team_1/tree/frontend-app">rammeobu/ai_team_1 @ frontend-app</a></sub>
