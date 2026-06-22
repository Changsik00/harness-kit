# phase-24: auto-mode

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-24-{seq}-auto-mode/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-24` |
| **상태** | Done |
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
| `spec-24-01` | auto-mode-base | P? | Merged | `specs/spec-24-01-auto-mode-base/` |
| `spec-24-02` | auto-scope-commit | P? | Merged | `specs/spec-24-02-auto-scope-commit/` |
| `spec-24-03` | stop-rules | P? | Merged | `specs/spec-24-03-stop-rules/` |
| `spec-24-04` | nonblocking-decision | P? | Merged | `specs/spec-24-04-nonblocking-decision/` |
| `spec-24-05` | phase-ship-checkpoint | P? | Merged | `specs/spec-24-05-phase-ship-checkpoint/` |
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

## 📊 검증 결과 (2026-06-22 phase-ship)

### 성공 기준
> ⚠️ 2026-06-22 phase-review 정정: 초기 ✅ 3건(#2·#3·#5)을 *단위 테스트 합산*으로 ✅ 처리했으나, 기준 문언("e2e 로 증명", "hard stop", "신규 e2e")에 비추면 **부분 충족**이다. 정직하게 ⚠️ 로 낮춘다. 후속 → phase-25.

| # | 기준 | 결과 | 증거 |
|---|---|:---:|---|
| 1 | `sdd mode auto` + status + 3모드 전환 | ✅ | `test-mode-auto` 6/6, `cmd_mode` auto case |
| 2 | auto 결정 기본값+로그 논블로킹 | ⚠️ 부분 | 단위(`test-ask-mode-auto` 5/5)·effective ux-mode resolver 검증됨. 그러나 **"멈추지 않음"을 unattended e2e 로 증명한 적 없음**(decision log 0건). 논블로킹이 산문 규약(§8.4)에만 의존하고 기계적 백스톱이 없음 → phase-25 spec-25-01 |
| 3 | 정지규칙 ②(비가역) hard stop | ⚠️ 부분 | block 모드 exit 2 경로 테스트(`test-stop-rules` T10)는 있으나 **운영 기본값은 경고(exit 0)** — 실제 hard stop 미작동. 차단 승격 → phase-25 spec-25-04 |
| 4 | scope 커밋시점 검사(MCP 무관, 경고) | ✅ | `check-scope.sh` dual-mode + `test-scope-commit` |
| 5 | 전체 PASS + 신규 e2e/테스트 | ⚠️ 부분 | 단위 72/72 PASS는 사실. 단 성공기준이 명시한 `test-e2e-auto-mode.sh` **미작성**(통합 e2e 미달) → phase-25 spec-25-03 |

### 통합 시나리오
- 시나리오 1(auto unattended 결정): ⚠️ **미실행** — auto 로 한 번도 안 돌려 "멈추지 않음"이 미증명(decision log 0건). 산문 규약만 존재.
- 시나리오 2(정지규칙 hard stop): ⚠️ **부분** — 차단 경로 테스트는 있으나 운영 기본값이 경고(exit 0)라 실제 정지 미작동.

### 자율 결정 로그 rollup
- `sdd decision list --phase` → `(결정 로그 없음)`. phase-24 는 attended(turbo)로 구축돼 auto 결정 0건 — rollup 실효는 phase-25+ auto 도그푸딩에서.

### 회귀
- 전체 스위트 72/72 PASS (synced main 기준). 병렬 세션(24-03/04)과 충돌 없이 통합.

### 📎 phase-review 핵심 발견 (2026-06-22)
- phase-24 는 auto 의 **배관(모드 전환·resolver·정지규칙 엔진·결정 로그·phase-ship rollup)** 을 완성했다. 단 auto 가 *실제로 안전하게 자율*하려면 필요한 두 기둥이 미구현이다:
  - **논블로킹의 기계적 백스톱** — `AskUserQuestion` 차단을 24-04 가 "agent 행동이라 hook 으로 못 막는다"로 닫았으나, 이는 절반만 맞다. `PreToolUse` matcher 는 도구명 임의 매칭이라 호출을 가로채 리다이렉트할 수 있다(전제 정정 → ADR-009 Addendum, GitHub #181). → phase-25 spec-25-01.
  - **사후 테스트의 신뢰** — ADR-009 가 "안전이 사후 테스트 품질에 전적으로 의존"이라 못 박았으나 그 품질 보강(GitHub #212 칸0 revert/over-mock)은 0건. unattended 라 가짜 green 의 폭발 반경이 커짐. → phase-25 spec-25-02.
- 결론: phase-24 ship 은 **"배관 완성"** 으로 정직하게 닫고, auto 도그푸딩은 phase-25(auto 신뢰성) 이후로 미룬다.
