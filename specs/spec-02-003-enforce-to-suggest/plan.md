# Implementation Plan: spec-02-003

## 📋 Branch Strategy

- 신규 브랜치: `spec-02-003-enforce-to-suggest`
- 시작 지점: `main`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] check-branch.sh를 block 기본으로 전환하면 main에서 실수 commit 시 차단됨. 의도한 동작인지 확인.

## 🎯 핵심 전략 (Core Strategy)

### Per-hook 모드 우선순위

```
HARNESS_HOOK_MODE_BRANCH (per-hook) → HARNESS_HOOK_MODE (글로벌) → 기본값 (hook별 상이)
```

### Hook별 기본 모드

| Hook | 기본 모드 | 이유 |
|:---:|:---:|:---|
| check-branch | `block` | main 보호는 안전 관련, 실수 방지 필수 |
| check-plan-accept | `warn` | FF 모드 등에서 유연성 필요 |
| check-test-passed | `warn` | docs 커밋 등 면제 필요 |

## 📂 Proposed Changes

### [MODIFY] `sources/hooks/_lib.sh`
- `hook_resolve_mode` 함수 추가: hook 이름을 받아 per-hook 환경변수 → 글로벌 → 기본값 순으로 해석
- 기존 `hook_violation`은 변경 없음 (이미 mode 기반)

### [MODIFY] `sources/hooks/check-branch.sh`
- `hook_resolve_mode "BRANCH" "block"` 호출로 기본 모드를 block으로 설정

### [MODIFY] `sources/hooks/check-plan-accept.sh`
- `hook_resolve_mode "PLAN_ACCEPT" "warn"` 호출 (기존 동작 유지, 명시적)

### [MODIFY] `sources/hooks/check-test-passed.sh`
- `hook_resolve_mode "TEST_PASSED" "warn"` 호출 (기존 동작 유지, 명시적)

### [MODIFY] `sources/bin/sdd`
- `hooks` 서브커맨드 추가

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-hook-modes.sh
```

### 수동 검증
1. main 브랜치에서 `git commit` 시도 → exit 2 (block)
2. `HARNESS_HOOK_MODE_BRANCH=warn` 설정 후 → exit 0 (warn)
3. `sdd hooks` → 각 hook 모드 출력

## 🔁 Rollback Plan

- per-hook 환경변수 제거, _lib.sh 롤백으로 원상복구

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
