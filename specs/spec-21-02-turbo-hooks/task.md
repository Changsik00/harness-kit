# Task List: spec-21-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (phase-21.md SPEC 표 상태 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: TDD Red — 테스트 작성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-21-02-turbo-hooks` from `phase-21-turbo-mode`

### 1-2. 테스트 작성 (TDD Red)
- [ ] `tests/test-turbo-hooks.sh` 작성 (8 케이스)
  - T01: check-plan-accept — turbo 시 exit 0
  - T02: check-plan-accept — governed + plan 미승인 시 violation
  - T03: check-scope — turbo 시 exit 0
  - T04: check-scope — governed + plan 승인 + scope 이탈 시 violation
  - T05: post-commit-verify — governed 시 exit 0
  - T06: post-commit-verify — turbo + precheck 없음 시 exit 0
  - T07: post-commit-verify — turbo + precheck PASS 시 exit 0
  - T08: post-commit-verify — turbo + precheck FAIL 시 revert 후 exit 0
- [ ] 테스트 실행 → Fail 확인 (RED)
- [ ] Commit: `test(spec-21-02): add failing tests for turbo hook bypass and post-commit-verify`

---

## Task 2: 훅 분기 — check-plan-accept + check-scope

### 2-1. 구현
- [ ] `.harness-kit/hooks/check-plan-accept.sh` — `hook_resolve_mode` 직후 turbo 분기 추가
- [ ] `.harness-kit/hooks/check-scope.sh` — 동일 패턴 turbo 분기 추가
- [ ] `sources/hooks/check-plan-accept.sh` — 동일 변경 미러링
- [ ] `sources/hooks/check-scope.sh` — 동일 변경 미러링
- [ ] 테스트 실행 → T01~T04 PASS 확인
- [ ] Commit: `feat(spec-21-02): bypass plan-accept and scope hooks in turbo mode`

---

## Task 3: post-commit-verify.sh + 설정 등록

### 3-1. Stop 훅 구현
- [ ] `.harness-kit/hooks/post-commit-verify.sh` 신규 작성
  - Guard 1: mode != turbo → exit 0
  - Guard 2: precheck 미설정 → exit 0
  - Guard 3: 최근 커밋 > 10분 → exit 0
  - precheck 실행 → PASS 시 stderr 통과 메시지
  - precheck 실패 시 `git revert HEAD --no-edit` + stderr 리포트
- [ ] `sources/hooks/post-commit-verify.sh` — 동일 내용 미러링
- [ ] `.claude/settings.json` — Stop 훅 배열에 `post-commit-verify.sh` 추가
- [ ] `sources/claude-fragments/settings.json.fragment` — 동일 변경 미러링
- [ ] 테스트 실행 → T05~T08 PASS, 전체 8개 PASS 확인
- [ ] Commit: `feat(spec-21-02): add post-commit-verify stop hook for turbo mode`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행**: `bash tests/test-turbo-hooks.sh` → 8/8 PASS
- [ ] **기존 테스트 회귀 확인**: `bash tests/test-mode-schema.sh` → 7/7 PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-21-02): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-21-02-turbo-hooks`
- [ ] **PR 생성**: `gh pr create --base phase-21-turbo-mode`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 (test + feat×2 + docs) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-06-12 |
