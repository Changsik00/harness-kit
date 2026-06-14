# Implementation Plan: spec-21-05

## 📋 Branch Strategy

- 신규 브랜치: `spec-21-05-integration-test`
- 시작 지점: `phase-21-turbo-mode`
- PR 대상: `phase-21-turbo-mode`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 통합 테스트는 tmpdir를 사용하여 실제 `.claude/state/` 를 건드리지 않음
> - [ ] S2 (auto-revert) 시나리오는 실제 git revert 커밋을 생성 — tmpdir git repo에서 격리 실행

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **테스트 격리** | tmpdir 가짜 repo + 환경 변수 주입 | 실제 `.claude/state/` 오염 방지 |
| **S2 revert 검증** | tmpdir git repo에서 실제 커밋 후 hook 실행 | auto-revert는 git 상태 변화를 실제로 봐야 검증 가능 |
| **기존 테스트** | `tests/run.sh` 그대로 실행 | 수정 없이 회귀 검증 |

### 📑 ADR 후보

- [ ] 없음

## 📂 Proposed Changes

### [통합 테스트]

#### [NEW] `tests/test-turbo-mode.sh`
4개 통합 시나리오. 각 시나리오는 tmpdir를 생성하고 완료 후 삭제.

**S1 — happy path**
```
setup: tmpdir + .harness-kit/hooks/check-plan-accept.sh 심링크
action: mode=turbo 상태로 hook 호출
expect: exit 0 (violation 없음)
```

**S2 — auto-revert**
```
setup: tmpdir git repo, turbo mode, intent.yaml(test=false)
action: dummy 커밋 후 post-commit-verify 실행
expect: git log 에 revert 커밋 추가됨
```

**S3 — governed 복귀 차단**
```
setup: tmpdir, mode=governed, plan 미승인
action: check-plan-accept 호출
expect: exit 2 또는 violation 메시지
```

**S4 — 회귀 (governed 기본)**
```
setup: tmpdir, mode 필드 없음(governed 기본)
action: check-plan-accept 호출 (plan 미승인)
expect: violation 출력
```

#### `tests/run.sh` 확인
기존 스크립트 실행 가능 여부 확인 (수정 없음).

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (= 통합 테스트)
```bash
bash tests/test-turbo-mode.sh
```

### 회귀 테스트
```bash
bash tests/run.sh
```

### 수동 검증 시나리오
1. `bash tests/test-turbo-mode.sh` → 4/4 PASS
2. `bash tests/run.sh` → 전체 PASS

## 🔁 Rollback Plan

- 신규 테스트 파일만 추가 — 기존 코드 변경 없음
- git revert 로 완전 롤백 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
