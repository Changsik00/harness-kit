# Implementation Plan: spec-x-remove-stack-adapter

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-remove-stack-adapter`
- 시작 지점: `phase-8-work-model`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `hk-ship.md`에서 lint/test 명령을 환경변수 대신 "에이전트가 프로젝트 설정을 확인 후 실행" 안내로 변경
> - [ ] `agent.md` §6.7 Stack Awareness 섹션 삭제

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **stacks/** | 디렉토리 전체 삭제 | 소비자 없음, 오버엔지니어링 |
| **install.sh** | `--stack` 옵션 + `detect_stack()` + 복사 로직 제거 | 감지할 필요 없음 |
| **hk-ship.md** | 환경변수 → 에이전트 직접 판단 안내 | 에이전트가 package.json 등을 읽고 판단하는 게 더 정확 |
| **도그푸딩 동기화** | sources/ 수정 후 agent/ 동기화 | sources가 원본, agent/는 설치 결과 |

## 📂 Proposed Changes

### [DELETE] `stacks/generic.sh`, `stacks/nodejs.sh`

stack adapter 파일 및 `stacks/` 디렉토리 전체 삭제.

### [DELETE] `scripts/harness/lib/stack.sh`

설치된 결과물. 더 이상 생성하지 않으므로 삭제.

### [MODIFY] `install.sh`

- `--stack=` 옵션 파싱 제거
- `FORCE_STACK` 변수 제거
- `detect_stack()` 함수 제거
- stacks/ 디렉토리 존재 체크 제거
- stack adapter 복사 섹션 제거
- 설치 계획 출력에서 "스택" 줄 제거

### [MODIFY] `update.sh`

- stack 복원 로직 제거 (SAVED_STACK 관련)

### [MODIFY] `doctor.sh`

- [5/6] State / Stack 섹션에서 stack 검증 항목 제거 (State 검증은 유지)
- `scripts/harness/lib/stack.sh` 존재 체크 제거

### [MODIFY] `scripts/harness/bin/sdd`

- `stack` 변수 선언/조회/출력 제거

### [MODIFY] `.claude/state/current.json`

- `"stack"` 필드 제거

### [MODIFY] `sources/commands/hk-ship.md` + `.claude/commands/hk-ship.md`

- `source ./scripts/harness/lib/stack.sh` 제거
- `$HARNESS_LINT_CMD`, `$HARNESS_TEST_CMD`, `$HARNESS_TEST_INTEGRATION_CMD` → 에이전트에게 프로젝트의 package.json / Makefile 등을 확인하여 적절한 명령 실행 지시

### [MODIFY] `sources/governance/agent.md` + `agent/agent.md` (영문)

- §6.7 Stack Awareness 섹션 삭제

### [MODIFY] `sources/templates/plan.md` + `agent/templates/plan.md`

- "스택별 명령은 stack adapter 또는 CLAUDE.md 참고" → 일반 안내로 변경

### [MODIFY] 문서

- `CLAUDE.md`: `stacks/` 디렉토리 설명 줄 삭제, No Over-engineering 항목 수정
- `README.md`: `lib/stack.sh` 참조 삭제
- `docs/REFERENCE.md`: `--stack` 옵션, stack 환경변수 섹션, 스택 어댑터 섹션 삭제
- `docs/USAGE.md`: `--stack` 옵션 설명 삭제

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오

1. `install.sh --help` 실행 → `--stack` 옵션이 없어야 함
2. `doctor.sh` 실행 → stack 관련 체크 없어야 함
3. `sdd status` 실행 → `stack=` 출력 없어야 함
4. grep으로 `HARNESS_STACK`, `HARNESS_TEST_CMD`, `HARNESS_LINT_CMD` 등이 프로젝트에 남아있지 않은지 확인

## 🔁 Rollback Plan

- 모든 변경이 문서/스크립트 수정 + 파일 삭제이므로 `git revert`로 원복 가능

## 📦 Deliverables 체크

- [x] spec.md 작성
- [x] plan.md 작성 (이 파일)
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
