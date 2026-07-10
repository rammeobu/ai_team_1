# AI Bootcamp — AI 여행 플래너 (Backend)

사용자가 여행 장소·날짜·인원·예산·스타일을 입력하면, AI가 이를 참조해 여행 일정과
필수 준비물(항공권/호텔/서류 등)을 추천·관리해 주는 여행 플래너 서비스의 백엔드입니다.
카카오/구글 소셜 로그인과 게스트(비로그인) 이용을 모두 지원하며, Flutter 앱과 웹 양쪽에서 사용합니다.

---

## 1. 시스템 환경 및 개발 툴 / 언어

| 구분 | 내용 |
|------|------|
| 언어 | Java 21 |
| 프레임워크 | Spring Boot 4.1.0 (Spring Web MVC, Spring Data JPA, Spring Security) |
| 빌드 도구 | Gradle |
| 인증/인가 | Spring Security OAuth2 Client (Kakao / Google), JWT (jjwt 0.12.6) |
| DB | PostgreSQL (Supabase 호스팅) · 개발 시 H2 / MariaDB 드라이버 병행 |
| ORM | JPA / Hibernate (`ddl-auto: update`) |
| API 문서 | springdoc-openapi (Swagger UI, `/swagger-ui.html`) |
| 유틸 | Lombok |
| 형상 관리 | Git / GitHub (`rammeobu/ai_team_1`) |
| IDE | IntelliJ IDEA |
| 배포 도메인 | `https://api.withact.xyz` |
| 클라이언트 | Flutter 앱 (커스텀 스킴 `withact://` 콜백) / 웹(테스트) |

---

## 2. 팀원 역할

> 아래 표의 담당 파트는 채워 주세요. (Git 기여자: `_.Cloudhigh`, `이수진`, `sujin711`)

| 이름 | 역할 | 담당 파트 |
|------|------|-----------|
| _.Cloudhigh | (예: 팀장 / 인증·인프라) | 소셜 로그인, JWT, 프로젝트 세팅 <!-- 수정 필요 --> |
| 이수진 | (예: 백엔드) | 인원(People) API 등 <!-- 수정 필요 --> |
| sujin711 | (예: 백엔드) | <!-- 채워주세요 --> |

---

## 3. 스케줄표

> 실제 일정에 맞게 수정해 주세요. (개발 기간: 2026-07-07 ~ 2026-07-09)

| 기간 | 작업 내용 | 담당 |
|------|-----------|------|
| Day 1 (07-07) | 프로젝트 세팅, 엔티티/DB 설계 | <!-- 채워주세요 --> |
| Day 2 (07-08) | 소셜 로그인, 도메인별 CRUD API 구현 | <!-- 채워주세요 --> |
| Day 3 (07-09) | API 통합/병합, 앱·웹 인증 분리 | <!-- 채워주세요 --> |
| 예정 | AI 여행 일정·준비물 추천 기능 | <!-- 채워주세요 --> |

---

## 4. 주요 기능

### 인증
- 카카오 / 구글 **소셜 로그인** (Spring Security OAuth2 Client)
- 로그인 성공 시 **JWT 발급**
  - **앱**: `withact://login?token=...` 커스텀 스킴으로 리다이렉트
  - **웹(테스트)**: `kakao-web` registration 사용 시 토큰을 JSON으로 응답
- **게스트(비로그인) 이용** 지원 — `guestId` 기반으로 데이터 저장·조회

### 여행 계획 도메인 (도메인별 REST API + Swagger 문서화)
| 도메인 | 경로 | 설명 |
|--------|------|------|
| 여행 장소/날짜 | `/api/travel-info` | 여행 지역, 시작일·종료일 관리 |
| 여행 인원 | `/api/people` | 여행 인원 수 관리 |
| 예산 | `/api/budgets` | 총 예산 관리 |
| 여행 스타일 | `/api/travel-style` | 사용자가 선택한 여행 스타일 관리 |
| 여행 일정 | `/api/travel-plan` | AI가 생성한 여행 일정 저장·조회 |
| 필수 준비물 | `/api/required-items` | 항공권/호텔/서류/추가 아이콘별 준비물·진행 상태 관리 |
| 대시보드 | `/api/dashboard` | 홈 화면 여행 요약 정보 |
| 유저 | `/api/v1` | 유저 조회/수정/삭제 |

- 각 도메인은 **로그인 사용자(userId) / 게스트(guestId) / 예산(budgetId) / 여행일정(travelplanId)** 기준 조회를 지원
- 필수 준비물은 아이콘 종류(FLIGHT/HOTEL/DOCUMENT/EXTRA)와
  상태(NOT_STARTED/SEARCHED/SELECTED/COMPLETED)별 관리

### AI 추천 (예정)
- 저장된 여행 정보(장소·날짜·인원·예산·스타일)를 AI가 참조하여
  **여행 일정 및 준비물을 실시간 추천** — Function calling 방식으로 내부 API를 조회해 최신 데이터 기반 추천

---

## 5. 시연

> 시연 자료(스크린샷 / GIF / 영상 링크)를 추가해 주세요.

- API 문서(Swagger): `https://api.withact.xyz/swagger-ui.html`
- 로그인 플로우 시연: <!-- 스크린샷/GIF 첨부 -->
- 여행 계획 → 추천 시연: <!-- 스크린샷/GIF 첨부 -->

---

## 6. 장단점 및 향후 개선 방안

### 장점
- 여행의 각 요소(장소·인원·예산·스타일·일정·준비물)를 **도메인별로 분리**해 확장성이 높음
- 로그인/게스트 이용을 모두 지원해 진입 장벽이 낮음
- Swagger로 전 API가 문서화되어 프론트(앱·웹) 협업이 용이
- 앱/웹 클라이언트에 따라 인증 리다이렉트 방식을 분기 처리

### 단점 / 개선 방안
- **인증 실패 핸들링 부재**: OAuth2 `failureHandler`가 없어 로그인 실패 시 기본 로그인 페이지로 노출됨 → 실패 시에도 클라이언트가 처리 가능한 응답으로 개선 필요
- **엔티티 직접 노출**: 컨트롤러가 엔티티를 그대로 반환 → 요청/응답 DTO 분리 권장
- **도메인 간 관계가 FK가 아닌 단순 ID 필드**로 연결됨 → 무결성 보장을 위한 연관관계 매핑 검토
- **CORS 전체 허용(`*`)** 및 `ddl-auto: update` 등 개발용 설정 → 운영 환경 분리 필요
- **AI 추천 기능 미완성** → 내부 API 기반 실시간 추천(Function calling) 구현 예정
- 코드 컨벤션(클래스 네이밍 등) 통일 및 테스트 코드 보강

---

## 실행 방법

```bash
# 환경 변수(.env) 설정 필요:
# DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
# KAKAO_CLIENT_ID, KAKAO_CLIENT_SECRET
# GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET
# JWT_SECRET

./gradlew bootRun
```

- API 문서: `http://localhost:8080/swagger-ui.html`
