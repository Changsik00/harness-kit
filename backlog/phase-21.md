# phase-21: Turbo 모드 추가 — 실행 우선 + 사후 검증

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-21-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-21` |
| **상태** | In Progress |
| **시작일** | 2026-06-12 |
| **목표 종료일** | 2026-06-30 |
| **소유자** | dennis |
| **Base Branch** | `phase-21-turbo-mode` |

## 🎯 배경 및 목표

### 현재 상황

harness-kit 의 현행 Governed 모드는 `spec → plan → task → Plan Accept → Strict Loop → Ship` 의 전체 SDD ceremony 를 거친다. 안전성은 높지만 의도→실행 사이의 마찰이 크다. 특히 `check-plan-accept.sh` 가 Plan Accept 전 모든 코드 편집을 물리적으로 차단하고, 5개 산출물(spec/plan/task/walkthrough/pr_description)을 한국어로 작성해야 하는 ceremony 비용이 소규모 변경에도 동일하게 부과된다.

AI 에이전트의 수준이 높아지면서 "사전 승인 → 실행" 보다 "실행 → 사후 검증 → 필요시 revert" 패턴이 더 효율적인 국면이 됐다. oh-my-pi 같은 최신 에이전트들은 이 방향으로 설계되어 있으며, 사용자도 현행 harness-kit 이 추세에 맞지 않을 만큼 느리다고 인식한다.

기존 Governed 모드를 제거하거나 대체하는 것이 아니라, **Turbo 모드를 opt-in 추가**하는 방향으로 접근한다. 대형 아키텍처 변경에는 여전히 Governed 모드를 쓰고, 일상적 구현/수정에는 Turbo 모드를 선택할 수 있게 한다.

### 목표 (Goal)

`sdd mode turbo` 명령 하나로 Turbo 모드를 활성화할 수 있다. Turbo 모드에서는 Plan Accept 없이 코드 편집이 가능하고, 커밋 후 자동 검증(테스트 + scope + 포맷)이 실행된다. 검증 실패 시 자동 revert + 리포트. `sdd mode governed` 로 언제든 원래 모드로 복귀 가능.

### 성공 기준 (Success Criteria) — 정량 우선

1. `sdd mode turbo` 활성화 후 Plan Accept 없이 production 코드 편집 가능 (check-plan-accept 통과)
2. 커밋 후 `post-commit-verify.sh` 가 실행되어 테스트 실패 또는 scope 이탈 시 `git revert` 수행
3. `sdd mode governed` 복귀 후 기존 훅 게이트 (check-plan-accept, check-scope) 정상 차단 확인
4. 기존 Governed 모드 회귀 없음 — `tests/` 전체 통과

## 🧩 작업 단위 (SPEC + phase-FF)

> SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다. 자세한 spec/plan/task 는 `specs/spec-21-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-21-01` | mode-schema | P? | Merged | `specs/spec-21-01-mode-schema/` |
| `spec-21-02` | turbo-hooks | P? | Planning | `specs/spec-21-02-turbo-hooks/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-21-01 — 모드 스키마 및 CLI

- **요점**: `state.json` 에 `mode` 필드 추가, `sdd mode [turbo|governed|status]` 서브커맨드 구현
- **방향성**: `current.json` 에 `"mode": "governed"` (기본값) 추가. `sdd mode turbo` 가 값을 변경하고 확인 메시지 출력. 기존 `hook_state` 함수로 훅에서 mode 를 읽을 수 있게 함
- **참조**: `.harness-kit/hooks/_lib.sh` (`hook_state` 함수), `.harness-kit/bin/lib/state.sh`
- **연관 모듈**: `.harness-kit/bin/sdd`, `.harness-kit/bin/lib/state.sh`, `.claude/state/current.json`

### spec-21-02 — Turbo 훅 분기 및 PostCommit 검증

- **요점**: `check-plan-accept.sh` / `check-scope.sh` 에 Turbo 모드 분기 추가, `post-commit-verify.sh` 신규 생성
- **방향성**: 두 기존 훅이 `hook_state mode` 를 읽어 `turbo` 이면 즉시 exit 0. `post-commit-verify.sh` 는 `Stop` 훅으로 등록 — 커밋 후 테스트 실행, 실패 시 `git revert HEAD` + stderr 리포트
- **참조**: `.harness-kit/hooks/check-plan-accept.sh`, `.harness-kit/hooks/check-scope.sh`, `.harness-kit/hooks/_lib.sh`
- **연관 모듈**: `.harness-kit/hooks/`, `.claude/settings.json` (Stop hook 등록)

### spec-21-03 — Intent 블록 커맨드

- **요점**: Turbo 모드에서 간단한 의도 선언을 위한 `sdd intent` 커맨드 + `intent.yaml` 스키마 정의
- **방향성**: `sdd intent "목표 한 줄" --files "src/a.sh,src/b.sh" --test "bash tests/run.sh"` 로 `.claude/state/intent.yaml` 생성. post-commit-verify 가 이 파일의 `test` 커맨드를 실행. intent 없이도 Turbo 동작 가능 (test 없으면 포맷 검증만)
- **참조**: `spec-21-01` (state 경로), `spec-21-02` (post-commit-verify 연동)
- **연관 모듈**: `.harness-kit/bin/sdd`, `.claude/state/intent.yaml`

### spec-21-04 — 거버넌스 문서 및 슬래시 커맨드

- **요점**: `constitution.md` 에 Turbo 모드 조항 추가, `/hk-mode` 슬래시 커맨드 생성
- **방향성**: constitution §2 Work Modes 에 Mode D (Turbo) 조항. `/hk-mode` 는 `sdd mode` 를 wrapping 하여 대화형으로 모드 전환. `agent.md` §3.1 Work Type Behavior Table 에 Turbo 행 추가
- **참조**: `.harness-kit/agent/constitution.md` §2, `.harness-kit/agent/agent.md` §3.1
- **연관 모듈**: `.harness-kit/agent/constitution.md`, `.harness-kit/agent/agent.md`, `.claude/commands/hk-mode.md`, `sources/governance/`, `sources/commands/`

### spec-21-05 — 통합 테스트

- **요점**: Turbo 모드 end-to-end 플로우 + 회귀 검증 테스트 스크립트
- **방향성**: `tests/test-turbo-mode.sh` 작성 — 모드 전환, 훅 분기, post-commit-verify, auto-revert 시나리오 커버. 기존 `tests/` 전체 실행으로 Governed 회귀 없음 확인
- **참조**: `spec-21-01` ~ `spec-21-04` 전체
- **연관 모듈**: `tests/test-turbo-mode.sh`

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 phase base 브랜치에 직접 커밋(phase-FF).

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| `sdd status` turbo 상태 표시 | status 출력에 현재 모드 한 줄 추가 | 1 |
| hk-doctor turbo 체크 | doctor 진단에 post-commit-verify 훅 등록 여부 확인 | 1 |

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 기존 Governed 모드 대체 vs 추가 | 대체 / 추가 | 추가 | 기존 사용자 영향 없음, 점진적 마이그레이션 가능 |
| Turbo 모드 기본값 여부 | 기본 on / opt-in | opt-in (governed 유지) | 안전 우선, 사용자가 명시적으로 선택 |
| post-commit-verify 훅 위치 | PreToolUse / Stop | Stop | 커밋 완료 후 실행이 맞음 — Stop 이 세션 종료·대기 신호 |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: Turbo 모드 happy path
- **Given**: `sdd mode turbo` 활성화, Plan Accept 없음
- **When**: production 코드 파일 편집 → 커밋
- **Then**: check-plan-accept 통과, post-commit-verify PASS, PR 생성 가능
- **연관 SPEC**: spec-21-01, spec-21-02

### 시나리오 2: Turbo 모드 auto-revert
- **Given**: `sdd mode turbo`, `sdd intent "fix X" --test "bash tests/run.sh"`
- **When**: 코드 편집 → 커밋 → 테스트 실패
- **Then**: `git revert HEAD` 자동 실행, 실패 원인 stderr 출력
- **연관 SPEC**: spec-21-02, spec-21-03

### 시나리오 3: 모드 전환 후 Governed 복귀
- **Given**: Turbo 모드 활성 중
- **When**: `sdd mode governed` 실행 → Plan Accept 없이 코드 편집 시도
- **Then**: check-plan-accept 가 차단 (exit 2)
- **연관 SPEC**: spec-21-01, spec-21-02

### 시나리오 4: 기존 Governed 회귀 없음
- **Given**: 기본 governed 모드 (mode 필드 없거나 "governed")
- **When**: `bash tests/run.sh` 전체 실행
- **Then**: 기존 테스트 전부 PASS
- **연관 SPEC**: spec-21-05

### 통합 테스트 실행
```bash
bash tests/test-turbo-mode.sh
bash tests/run.sh
```

## 🔗 의존성

- **선행 phase**: phase-20 (director mode) — 완료
- **외부 시스템**: 없음
- **연관 ADR**: 신규 ADR-007 (Turbo 모드 결정) 작성 예정 (spec-21-04)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| Stop 훅이 커밋 외 상황에서도 트리거 | post-commit-verify 오작동 | 훅 내부에서 `git log -1` 로 실제 커밋 여부 확인 후 실행 |
| auto-revert 가 의도치 않은 커밋을 되돌림 | 작업 손실 | revert 전 `git stash` + 사용자 리포트 — 복구 경로 보장 |
| Governed 훅 분기 누락 | 기존 거버넌스 우회 | 기존 훅에 mode 분기 추가 후 기존 테스트 전체 재실행 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 `phase-21-turbo-mode` 브랜치에 merge
- [ ] 통합 테스트 전 시나리오 PASS (`tests/test-turbo-mode.sh`)
- [ ] 기존 `tests/run.sh` 전체 PASS (회귀 없음)
- [ ] `sdd status` 에 현재 모드 표시
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
