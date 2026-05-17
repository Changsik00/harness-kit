# spec-16-04: Reliability Layer 포지셔닝

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-16-04` |
| **Phase** | `phase-16` |
| **Branch** | `spec-16-04-reliability-positioning` |
| **상태** | Planning |
| **타입** | Docs |
| **Integration Test Required** | no |
| **작성일** | 2026-05-16 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- README 부제: `Claude Code를 위한 SDD(Spec-Driven Development) 거버넌스 부트스트랩 툴킷` — *기능 설명* 중심, *정체* 불명.
- `version.json`: `{"version": "0.9.1"}` — description 필드 없음.
- `sources/governance/constitution.md`: `# Project Constitution` + invariant laws 정의로 직진 — *왜 이런 거버넌스인지* (= 무엇을 위한 키트인지) 명시 없음.
- `grep -l "reliability layer" README.md version.json .harness-kit/agent/constitution.md` → **0 hit** (어디에도 없음).

### 문제점

- 외부 진단(velog `80-problem-in-agentic-coding`) 과 추가 제안서가 일관되게 지적한 키트의 *진짜 정체* — **"AI 코딩 프레임워크가 아니라 AI-assisted engineering 의 reliability 계층"** — 가 키트 어디에도 박혀있지 않음.
- 신규 사용자는 README 첫 부제만 보고 "또 하나의 SDD 도구" 로 분류 가능. 키트의 *얇은 보강 / 신뢰성 강제* 정체성이 전달 안 됨.
- spec-16-01 / 02 / 03 의 누적 (RCA / ADR / Stale 탐지) 이 *왜 reliability 계층인지* 의 증거가 됐지만, 그 결과를 *말로* 묶어주는 한 줄 슬로건이 부재.

### 해결 방안 (요약)

영문 한 줄 슬로건 — `Not an AI coding framework. A reliability layer for AI-assisted engineering.` — 을 3 곳에 박는다. README 는 한영 병기 (영문 slogan italic + 기존 한국어 부제 유지), version.json 은 description 필드 신설, constitution.md 는 invariant laws 정의 *직전* identity 한 줄 추가. install 미러 동기화.

## 🎯 요구사항

### Functional Requirements

1. **README.md**: `# harness-kit` 직후, 기존 한국어 부제 (blockquote) 직전에 영문 slogan 1 줄 추가 (italic, blank line 으로 분리).
2. **version.json**: top-level `"description"` 필드 신설. 값은 슬로건 그대로.
3. **sources/governance/constitution.md**: `# Project Constitution` 직후 (현재 "The Constitution defines..." 문장 *직전*) identity 한 줄 추가 — 본 키트의 정체를 명시하는 영문 1 문장.
4. **install 미러**: `.harness-kit/agent/constitution.md` 도 동일하게 갱신.
5. **검증 grep**: `grep -l "reliability layer" README.md version.json .harness-kit/agent/constitution.md` 가 3 곳 모두 hit (phase 통합 테스트 시나리오 3).

### Non-Functional Requirements

1. **거버넌스 영문 톤 유지** — constitution.md 의 한 줄 추가는 영문 (메모리 룰: feedback_governance_english 4 파일 영어 전용).
2. **한국어 본문 보존** — README 본문 / 기존 섹션 구조 변경 없음. 슬로건만 *위에 얹는다*.
3. **slogan 정확성** — 영문 typo 없음, period 포함, italic 강조 일관.
4. **회귀 없음** — 본 spec 외 다른 산출물 (다른 governance / templates / tests) 영향 없음.

## 🚫 Out of Scope

- **README install 경로 신설** (`curl ... | bash` 등) — Icebox 의 *접근성 개선 Phase* 에서 별도 처리. 본 spec 은 슬로건 / 정체성 *노출* 만.
- **README 본문 톤 전면 개편** — 기존 한국어 본문은 그대로. 부제 / 정체성 표기 한정.
- **거버넌스 한국어 번역** — 영문 톤 유지.
- **로고 / 배지 / 디자인 변경** — 본 spec 의 *언어적 노출* 범위 밖.
- **다른 산출물 (CHANGELOG / install.sh 헤더 등) 의 슬로건 일치** — 본 spec 의 3 곳 외 확산은 별 spec.
- **version.json schema 확장** (예: `name`, `homepage`) — `description` 1 필드만 추가.

## ✅ Definition of Done

- [ ] README.md 부제 위에 영문 slogan italic 1 줄 추가
- [ ] version.json 에 `description` 필드 추가 (값 = 슬로건)
- [ ] sources/governance/constitution.md identity 한 줄 추가
- [ ] `.harness-kit/agent/constitution.md` 동기화 (`diff` 차이 없음)
- [ ] `grep -l "reliability layer" README.md version.json .harness-kit/agent/constitution.md` → 3 줄 출력 (phase 시나리오 3 PASS)
- [ ] 회귀: 다른 governance 파일 / templates / tests 영향 없음
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] `spec-16-04-reliability-positioning` 브랜치 push 완료 + PR 생성 (target: `phase-16-reliability-layer`)
