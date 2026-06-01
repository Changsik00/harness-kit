# Implementation Plan: spec-x-harness-footguns

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-harness-footguns` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main` (spec-x 는 항상 main 에서 브랜치)
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **시크릿 가드 완화 범위**: env 보간 + placeholder 토큰을 예외 처리한다. 이론적으로 `password=changeme` 같은 *실제로 약한 시크릿*도 통과시키지만, 그건 시크릿이 아니라 placeholder 이므로 의도된 trade-off. 진짜 하드코딩 값(`password=Xy9!secret`)은 계속 차단.
> - [ ] **`phase activate --base` 시맨틱 확장**: 같은 phase 재활성화(`cur_phase==id`) 시 active spec 을 보존하도록 동작을 바꾼다. 기존엔 항상 spec 리셋이었으므로 미세한 행동 변경.

> [!WARNING]
> - [ ] 키트 원본(`sources/`, `update.sh`) 수정 — 이미 설치된 프로젝트는 `update.sh` 로만 전파됨 (자동 갱신 아님).

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **시크릿 가드 (②)** | regex 매칭 후 값 부분이 `$`/placeholder 면 `grep -v` 로 2차 필터 | 단일 regex 부정형보다 bash 3.2 / BSD grep 에서 안전하고 가독성 높음 |
| **update 가드 (①)** | 자동 커밋 대신 종료 시 커밋 안내 출력 | dirty repo 자동 커밋은 위험 — 안내까지만 (Out of Scope) |
| **branch 경고 (①)** | `spec new`/`specx new` 에 비차단 warn 추가 | 오염이 실제로 발생하는 지점 차단; 단 Hook 단계론에 따라 warn 모드 |
| **base 마찰 (③)** | 기존 `phase activate --base` 수정 (신규 서브커맨드 X) | spec-x 범위 유지 — feature 추가 회피 |

### 📑 ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음

## 📂 Proposed Changes

### ② 시크릿 가드 오탐 (Task 1)

#### [MODIFY] `sources/hooks/check-secrets.sh`
- `:58` 일반 시크릿 검사를 다단계 파이프로 변경: 후보 라인 grep → 값이 shell 변수 보간(`[=:]\s*["']?\$[{(]` 또는 `\$[A-Za-z_]`)이면 제외 → placeholder 토큰(`changeme|placeholder|example|your[_-]|xxx+|dummy|<[^>]+>|\.\.\.`)이면 제외 → 남은 라인 있으면 violation.
- 주석(9~13행)의 패턴 설명에 예외 규칙 한 줄 추가.

### ① update 미커밋 산물 (Task 2)

#### [MODIFY] `update.sh`
- 완료 메시지(`:191` 부근) 직전/직후에 `git -C "$HARNESS_ROOT" status --porcelain` 결과를 `.harness-kit/`·`.claude/` 로 필터, 비어있지 않으면 경고 블록 + 정확한 `git add .harness-kit .claude && git commit -m "chore: apply harness-kit update"` 안내 출력.
- 비-git 디렉토리/HARNESS_ROOT 미설정 시 안전 탈출.

#### [MODIFY] `sources/commands/hk-update.md`
- 업데이트 실행 섹션(`:73-105`)에 "업데이트 후 산물을 별도 커밋하라" 단계 추가.

### ① branch 오염 경고 (Task 3)

#### [MODIFY] `sources/bin/sdd`
- `spec_new()` 와 `specx_new()` 진입부에 미커밋 install drift 감지 헬퍼 호출 추가 → 감지 시 stderr 로 `⚠ 미커밋 install 변경 감지 — 브랜치 생성 전 커밋 권장` warn (비차단, exit 유지).
- 공통 로직은 작은 헬퍼(`_warn_install_drift`)로 분리.

### ③ phase activate --base 마찰 (Task 4)

#### [MODIFY] `sources/bin/sdd`
- `phase_activate()`:
  - `--base=<branch>` 형태 인자 파싱 추가 (기존 `--base` 도 유지).
  - base 브랜치 결정 우선순위: `--base=<branch>` 인자 > phase.md 메타. 둘 다 없으면 더 명확한 메시지로 die (`--base=<branch> 로 지정하거나 phase.md 메타를 채우세요`).
  - base 브랜치 확정 시 phase.md `Base Branch` 메타를 sed 로 자동 갱신 (phase_new 패턴 미러).
  - `cur_phase == id` 인 경우(같은 phase 재활성화): `state_set spec/planAccepted` 리셋을 건너뛰고 `die_if_active_spec` 도 건너뜀 → baseBranch + phase.md 만 갱신.
- help 텍스트(`:38-41`)에 `--base=<branch>` 표기 보강.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

각 테스트는 독립 실행 (`bash tests/test-*.sh`, exit 0 = PASS). 중앙 러너 없음 — 변경 관련 테스트를 개별 실행.

```bash
bash tests/test-check-secrets-dual-mode.sh   # ② 오탐 케이스 추가
bash tests/test-sdd-phase-activate.sh        # ③ base 메타/spec 보존
bash tests/test-sdd-base-branch.sh           # ③ base branch 회귀
bash tests/test-update.sh                    # ① update 가드 회귀
bash tests/test-sdd-spec-new-seq.sh          # ③(Task3) spec new 회귀
```

- **Task 1**: `test-check-secrets-dual-mode.sh` 에 케이스 추가 — `${POSTGRES_PASSWORD:-x}`·`password: changeme` staged → **통과**(차단 안 됨), `password=Xy9hardcoded` staged → **차단** 유지.
- **Task 3**: 신규 또는 기존 spec-new 테스트에 "미커밋 `.harness-kit/` 파일 있을 때 경고 출력 + exit 0" 케이스.
- **Task 4**: `test-sdd-phase-activate.sh` 에 케이스 추가 — `--base=<branch>` 시 phase.md 메타 갱신 확인 / 같은 phase 재활성화 시 active spec 보존 확인.

### 수동 검증 시나리오

1. dirty `.harness-kit/` 상태에서 `bash update.sh` (또는 해당 코드 경로) → 커밋 안내 출력 확인.
2. 미커밋 install 변경 상태에서 `sdd specx new foo` → warn 출력 + 정상 생성 확인.

## 🔁 Rollback Plan

- 모든 변경이 키트 원본 파일 수정이며 가역적. 문제 시 해당 커밋 revert.
- 시크릿 가드 완화가 과하면 placeholder allowlist 만 좁히는 후속 패치로 조정.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
