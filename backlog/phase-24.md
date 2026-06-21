# phase-24: auto-mode

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-24-{seq}-auto-mode/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-24` |
| **상태** | In Progress |
| **시작일** | 2026-06-19 |
| **목표 종료일** | 2026-06-30 |
| **소유자** | dennis |
| **Base Branch** | 없음 (각 spec → main; phase-ship 시 누적 검토) |

## 🎯 배경 및 목표

### 현재 상황

`turbo` 는 *attended 빠른 모드* 다 — 사람이 붙어 있는 상태에서 ceremony 만 뺀다. 그래서 "sdd 를 걸어두고 다른 일에 집중" (unattended, phase 전체 자율) 이 안 된다: ① `AskUserQuestion` 이 사람을 기다리며 블로킹, ② 자율 실행 시 *언제 진행/정지* 할지 정책 부재, ③ MCP 경유 편집(Serena 쓰기)이 `Edit|Write` 훅 매처를 우회해 blast-radius 가드 밖에 있음.

ADR-009 가 이를 거버닝한다 — 거버넌스를 *agent 신뢰도에 반비례·blast-radius 에 비례* 해 적용하고, 예산을 사전 게이트 → 사후 검증으로 옮긴다. 본 phase 는 그 원칙의 구현체인 `auto` 모드를 만든다.

### 목표 (Goal)

phase 전체를 fire-and-forget 으로 수행하는 `auto` 모드 구현 — 논블로킹 결정(기본값+로그), 정지규칙(①②③) hard stop, 사후 검증(테스트·post-commit-verify·결정 로그)이 유일 안전망, 사람 검토는 `phase-ship` PR 1회.

### 성공 기준 (Success Criteria) — 정량 우선
1. `sdd mode auto` 존재 + `sdd status` 에 표시, governed/turbo/auto 3모드 전환 정상 (테스트).
2. auto 모드에서 결정 지점이 기본값+로그로 논블로킹 처리됨을 e2e 로 증명 (멈추지 않음).
3. 정지규칙 ②(비가역 행동) 1건 이상이 실제로 hard stop 되는 테스트 존재.
4. blast-radius scope 불변식이 *커밋 시점* 에서도 검사되어 MCP 편집 경로 우회를 차단 (경고 모드 시작).
5. 전체 테스트 PASS + auto 모드 e2e 신규 추가.

## 🧩 작업 단위 (SPEC + phase-FF)

> 본 절은 phase 의 *작업 지도* 입니다. phase 설계 시 각 작업을 크기에 맞게 미리 배치합니다 — 실질적/불확실 → **SPEC**(아래 표), 작고 가역적인 1–2 commit → **phase-FF**(맨 아래 목록, spec 산출물 없음, → ADR-004).
> SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다. 자세한 spec/task 는 `specs/spec-24-{seq}-auto-mode/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-24-01` | auto-mode-base | P? | Active | `specs/spec-24-01-auto-mode-base/` |
| `spec-24-02` | auto-scope-commit | P? | Active | `specs/spec-24-02-auto-scope-commit/` |
| `spec-24-03` | stop-rules | P? | Active | `specs/spec-24-03-stop-rules/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`
> sdd가 ship 시 자동으로 `Merged`로 갱신합니다. `In Progress`는 active spec에 자동 마킹됩니다.

### spec-24-01 — auto 모드 토대 (CLI + 상태)

- **요점**: `sdd mode auto` 추가, `state.mode='auto'`, `sdd status` 에 표시. governed/turbo/auto 3모드 전환.
- **방향성**: 기존 `cmd_mode` 확장 — turbo 로직(논블로킹 토대) 재사용, 잘못된 모드값 거부. agent.md 모드 표는 *린하게*(상세는 ADR-009 참조 — 단어예산).
- **참조**: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md` (Decision 표)
- **연관 모듈**: `sources/bin/sdd` (`cmd_mode`), `.harness-kit/bin/sdd`

### spec-24-02 — blast-radius 가드 커밋시점 정렬 (선행조건)

- **요점**: 편집시점 scope 불변식을 *커밋 시점* 에서도 검사 → MCP/Serena 편집 우회를 도구 무관하게 차단.
- **방향성**: `check-scope` 핵심 검사를 커밋 직전(Bash 매처) 으로 보강. hook 단계론대로 **경고 모드(exit 0 + stderr)** 로 시작.
- **참조**: ADR-009 Consequences (부정 — MCP 우회)
- **연관 모듈**: `sources/hooks/check-scope.sh`, commit-time hook

### spec-24-03 — 정지규칙 엔진 + 결정 로그

- **요점**: 정지규칙 ①②③ 판정 + 결정·근거를 walkthrough 에 자동 누적하는 결정 로그.
- **방향성**: auto 모드에서 비가역 행동 감지(②), 반복 테스트 실패 카운터(③, N회). 결정 로그 포맷 정의(이슈·기본값·근거).
- **참조**: ADR-009 auto 규약 3·4
- **연관 모듈**: `sources/hooks/`, `sources/bin/sdd`, walkthrough 템플릿

### spec-24-04 — 논블로킹 결정 (기본값+로그)

- **요점**: auto 모드에서 결정 지점(통상 `AskUserQuestion`) → 기본값 채택 + 로그, 사람 미대기.
- **방향성**: agent.md §8.4 에 auto 행동 규칙 추가(린하게). auto 모드에서 `ask-mode` 가 자동으로 text+기본값.
- **참조**: ADR-009 auto 규약 2
- **연관 모듈**: `sources/governance/agent.md` §8.4, `sources/bin/sdd` (config)

### spec-24-05 — phase-ship 체크포인트 강화

- **요점**: 누적 결정 로그를 `phase-ship` PR 에 일괄 노출 + spec 전환 시 테스트 게이트.
- **방향성**: `hk-phase-ship` 가 phase 결정 로그 수집·표시. spec 사이 테스트 PASS 강제.
- **참조**: ADR-009 auto 규약 4
- **연관 모듈**: `sources/commands/hk-phase-ship.md`, `sources/bin/sdd`

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 직접 커밋(phase-FF, → ADR-004). 착수 시 §11.3 재검증으로 크기 재확인, 커질 경우 SPEC 승격.

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| README auto 모드 | proposed → 정식 설명으로 갱신 (phase 종료 후) | 1 |
| 거버넌스 단어수 | auto 규칙 추가로 7786w 초과 위험 시 rule-prune | 1 |

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 체크포인트 입도 | spec 단위 정지 / phase 전체 fire-and-forget / hybrid | phase 전체 fire-and-forget | 오너 결정(2026-06-19) — "걸어두고 딴 일" 목적, phase-ship 1회 검토 |
| 결정 지점 처리 | 기본값+로그 / 큐 보류 / 방향만 정지 | 기본값+로그 | 흐름 끊김 최소, 논블로킹 (ADR-009) |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: auto 모드 unattended 실행
- **Given**: `sdd mode auto` + 다중 spec phase
- **When**: 결정 필요 지점에 도달
- **Then**: 기본값 채택 + 결정 로그 기록, *멈추지 않고* 다음 진행
- **연관 SPEC**: spec-24-01, spec-24-04

### 시나리오 2: 정지규칙 hard stop
- **Given**: auto 모드 실행 중
- **When**: 비가역 행동(force push / 대량 삭제 등) 시도
- **Then**: 멈추고 사람 대기 (정지규칙 ②)
- **연관 SPEC**: spec-24-02, spec-24-03

### 통합 테스트 실행
```bash
# 본 phase 의 e2e (auto 모드)
bash tests/test-e2e-lifecycle.sh
bash tests/test-e2e-auto-mode.sh   # 24-04/24-05 에서 추가 예정
```

## 🔗 의존성

- **선행 phase**: 없음
- **외부 시스템**: 없음 (bash 3.2 + git + gh)
- **연관 ADR**:
  - `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md` (거버닝)
  - `docs/decisions/ADR-002-planning-economy.md`, `docs/decisions/ADR-008-extension-preferential-use.md`

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| 거버넌스 단어수 한계 (7786/8000) | auto 규칙 추가 시 초과 | 상세는 ADR-009 참조, agent.md 엔 표+포인터만. 초과 시 rule-prune (phase-FF) |
| 닭-달걀 (auto 모드 부재) | phase-24 자체는 auto 로 못 함 | turbo 로 구현, auto 첫 도그푸딩은 phase-25+ |
| 정지규칙 오탐/누락 | ② 판정 좁으면 사고·넓으면 자율성 저하 | 경계를 테스트로 고정, 경고 모드 1주 후 차단 승격 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (각 spec → main)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
