# spec-21-04: 거버넌스 문서 및 슬래시 커맨드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-21-04` |
| **Phase** | `phase-21` |
| **Branch** | `spec-21-04-governance-update` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-06-13 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

spec-21-01~03 에서 Turbo 모드 기반 인프라가 완성됐다 (`sdd mode`, `sdd intent`, turbo 훅 분기, post-commit-verify). 그러나 `constitution.md` 와 `agent.md` 에는 Turbo 모드가 Work Mode 로 등재되지 않아, Claude 가 새 세션에서 Turbo 모드를 인식하지 못한다. 슬래시 커맨드 `/hk-turbo` 도 없어 사용자가 대화 중 모드 전환을 간편하게 요청할 수 없다.

### 문제점

- Claude 의 거버넌스 규약(`constitution.md`)에 Turbo 가 없으면 세션마다 "Turbo 모드란?" 을 다시 설명해야 한다
- Agent 행동 테이블(`agent.md §3.1`)에 Turbo 행이 없어 Turbo 세션에서 어떻게 행동해야 하는지 모호하다
- `/hk-turbo` 슬래시 커맨드 없이는 사용자가 명시적으로 `sdd mode turbo` 를 알고 있어야만 전환 가능하다

### 해결 방안 (요약)

`constitution.md §2` 에 Mode D (Turbo) 조항을 추가하고, `agent.md §3.1` 행동 테이블에 Turbo 행을 추가한다. `/hk-turbo` 슬래시 커맨드를 신규 작성하여 대화 중 모드 전환을 안내한다. 모든 변경은 `sources/governance/` 와 `sources/commands/` 에도 미러링한다.

## 🎯 요구사항

### Functional Requirements

1. `constitution.md §2` — Mode D (Turbo) 조항 추가 (영문)
2. `constitution.md §2.4` — Work Mode Decision Tree 에 Turbo 분기 추가
3. `agent.md §3.1` — Work Type Behavior Table 에 Turbo 행 추가 (영문)
4. `.claude/commands/hk-turbo.md` 신규 생성 — `sdd mode` / `sdd intent` 안내
5. `sources/governance/constitution.md` 동일 변경 미러링
6. `sources/governance/agent.md` 동일 변경 미러링
7. `sources/commands/hk-turbo.md` 동일 변경 미러링

### Non-Functional Requirements

1. constitution.md / agent.md 는 영문 전용 (기존 정책 유지)
2. 기존 Mode A/B/C 조항 변경 없음

## 🚫 Out of Scope

- ADR-007 작성 (Turbo 모드 설계 결정) — 별도 spec-x 또는 phase-FF
- intent.yaml 스키마 공식 문서화 — spec-21-03 walkthrough 로 충분
- `/hk-intent` 슬래시 커맨드 — 필요 시 다음 phase

## 📑 ADR 후보

- [ ] 없음

## 🔗 관련 문서

- 관련 spec: `specs/spec-21-01-mode-schema/`, `specs/spec-21-02-turbo-hooks/`, `specs/spec-21-03-intent-block/`
- 관련 phase: `backlog/phase-21.md`

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-governance-update.sh`)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-21-04-governance-update` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
