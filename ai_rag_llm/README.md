# MetU AI / RAG / LLM 모듈

[MetU (Next.js + FastAPI)](https://github.com/evan-kim-dev/MetU)에서 AI·RAG·LLM 관련 코드만 분리해 둔 폴더입니다.  
Flutter 앱(`ai_team_1`)과 웹/백엔드 파이프라인을 맞출 때 참고용으로 사용하세요.

## 구성

```
ai_rag_llm/
├── backend/app/
│   ├── services/
│   │   ├── openai_service.py   # OpenRouter/OpenAI 호출 래퍼
│   │   └── ai_plan.py          # 모드별 인사이트·플랜 LLM 서비스
│   ├── routers/
│   │   └── ai.py               # POST /ai/chat
│   └── core/
│       ├── config.py           # OPENROUTER_* / OPENAI_* 설정
│       └── constants.py
├── lib/
│   ├── ai/                     # 프론트 AI 호출·프롬프트·타입
│   ├── rag/                    # 여행 지식·월별 딜·예산 밴드 (RAG 지식)
│   └── deals/
└── app/api/                    # Next.js BFF 라우트 (인사이트·딜·플랜)
```

## 파이프라인 요약

1. **RAG 지식** (`lib/rag/*`) — 목적지·시즌·예산 밴드 등 로컬 지식 검색/조합
2. **프롬프트** (`lib/ai/prompts/*`) — 모드별 시스템/유저 프롬프트
3. **Next BFF** (`app/api/*-insight`, `enrich-plan`, …) — 프론트 → FastAPI 전달
4. **FastAPI** (`POST /ai/chat`) — `InsightService` + `OpenAIService`(OpenRouter)
5. **응답** — 성공 시 `source: "ai"`, 실패 시 프론트 폴백

## 환경 변수 (백엔드)

```env
OPENROUTER_API_KEY=sk-or-...
OPENROUTER_MODEL=
OPENROUTER_HTTP_REFERER=https:
OPENROUTER_APP_TITLE=

# 하위 호환 (없으면 OPENROUTER 사용)
OPENAI_API_KEY=
OPENAI_MODEL=
```

## 주요 모드 (`POST /ai/chat` `mode`)

`budget` · `party` · `deal` · `weather` · `factbomb` · `tips` · `style` · `schedule` · `plan` · `deals` · `summary` · `buddy`

## 주의

- 이 폴더는 **참고/이식용 스냅샷**입니다. Flutter `lib/`와 import 경로가 바로 호환되지는 않습니다.
- API 키·시크릿은 포함하지 않았습니다. 키는 앱/서버 환경 변수로만 주입하세요.
- 프로덕션에서는 클라이언트에 OpenRouter 키를 두지 말고, 이 백엔드 프록시를 통해 호출하는 구성을 권장합니다.
