# Implementation Plan: spec-21-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-21-02-turbo-hooks`
- 시작 지점: `phase-21-turbo-mode` (spec-21-01 머지된 base branch)
- PR 대상: `phase-21-turbo-mode`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `post-commit-verify.sh` 의 auto-revert 범위: 10분 이내 커밋만 대상 — 오래된 커밋 보호

> [!WARNING]
> - [ ] Stop 훅 추가로 인해 Claude 가 멈출 때마다 `post-commit-verify.sh` 실행됨. precheck 미설정 시 no-op 이므로 기존 사용자 영향 없음

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **훅 분기 위치** | `hook_resolve_mode` 직후에 mode 체크 추가 | 기존 코드 구조 최소 변경 |
| **post-commit 트리거** | Stop 훅 | PreToolUse/PostToolUse 없이 세션 내 가장 자연스러운 "완료" 시점 |
| **auto-revert 가드** | 최근 10분 이내 커밋만 대상 | 오래된 커밋 혹은 다른 사람 커밋 실수 revert 방지 |
| **precheck 소스** | `installed.json` `.precheck[]` 배열 | 기존 `sdd config precheck` 인프라 재활용 |

### 📑 ADR 후보

- [ ] 없음

## 📂 Proposed Changes

### [기존 훅 분기]

#### [MODIFY] `.harness-kit/hooks/check-plan-accept.sh`
`hook_resolve_mode` 직후에 turbo 분기 추가:
```bash
[ "$(hook_state mode)" = "turbo" ] && exit 0
```

#### [MODIFY] `.harness-kit/hooks/check-scope.sh`
동일 패턴으로 turbo 분기 추가.

#### [MODIFY] `sources/hooks/check-plan-accept.sh`
동일 변경 미러링.

#### [MODIFY] `sources/hooks/check-scope.sh`
동일 변경 미러링.

### [신규 Stop 훅]

#### [NEW] `.harness-kit/hooks/post-commit-verify.sh`
Stop 이벤트에서 실행. mode=turbo + precheck 설정 + 최근 10분 이내 커밋 시에만 검증 수행.
실패 시 `git revert HEAD --no-edit` + stderr 리포트.

#### [NEW] `sources/hooks/post-commit-verify.sh`
동일 내용 미러링.

### [설정 등록]

#### [MODIFY] `.claude/settings.json`
Stop 훅 배열에 `post-commit-verify.sh` 엔트리 추가.

#### [MODIFY] `sources/claude-fragments/settings.json.fragment`
동일 변경 미러링.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-turbo-hooks.sh
```

8개 케이스:
- T01: check-plan-accept — turbo 시 통과
- T02: check-plan-accept — governed + plan 미승인 시 차단(warn)
- T03: check-scope — turbo 시 통과
- T04: check-scope — governed + plan 승인 + scope 이탈 시 차단(warn)
- T05: post-commit-verify — governed 시 no-op
- T06: post-commit-verify — turbo + precheck 없음 시 no-op
- T07: post-commit-verify — turbo + precheck PASS 시 exit 0
- T08: post-commit-verify — turbo + precheck FAIL 시 revert 후 exit 0

### 수동 검증 시나리오
1. `sdd mode turbo` → production 파일 편집 → check-plan-accept 통과 확인
2. `sdd mode governed` → production 파일 편집 → check-plan-accept 차단 확인

## 🔁 Rollback Plan

- `sdd mode governed` 로 즉시 복귀 → 기존 훅 게이트 복원
- `post-commit-verify.sh` 삭제로 Stop 훅 비활성화 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
