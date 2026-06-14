# Task List: spec-21-03

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
- [ ] `git checkout -b spec-21-03-intent-block` from `phase-21-turbo-mode`

### 1-2. 테스트 작성 (TDD Red)
- [ ] `tests/test-intent-block.sh` 작성 (9 케이스)
  - T01: `sdd intent "목표"` → intent.yaml goal 기록
  - T02: `sdd intent "목표" --test "true"` → goal + test 기록
  - T03: `sdd intent "목표" --files "a,b"` → goal + files 기록
  - T04: `sdd intent show` → 내용 출력
  - T05: `sdd intent show` (없음) → 안내 메시지
  - T06: `sdd intent clear` → intent.yaml 삭제
  - T07: `sdd status` → Active Intent 행 포함
  - T08: post-commit-verify — turbo + intent.test PASS → exit 0
  - T09: post-commit-verify — turbo + intent.test FAIL → revert
- [ ] 테스트 실행 → Fail 확인 (RED)
- [ ] Commit: `test(spec-21-03): add failing tests for intent block command`

---

## Task 2: sdd intent 커맨드 구현

### 2-1. 구현
- [ ] `.harness-kit/bin/sdd` — `cmd_intent()` / `_intent_write()` / `_intent_show()` / `_intent_clear()` 추가
- [ ] `.harness-kit/bin/sdd` — `main()` dispatch 에 `intent)` 추가
- [ ] `.harness-kit/bin/sdd` — `cmd_help()` 에 intent 도움말 추가
- [ ] `.harness-kit/bin/sdd` — `cmd_status()` Active Intent 행 추가
- [ ] `sources/bin/sdd` — 동일 변경 미러링
- [ ] 테스트 실행 → T01~T07 PASS 확인
- [ ] Commit: `feat(spec-21-03): add sdd intent command`

---

## Task 3: post-commit-verify intent 연동

### 3-1. 구현
- [ ] `.harness-kit/hooks/post-commit-verify.sh` — intent.yaml test 필드 우선 실행 로직 추가
- [ ] `sources/hooks/post-commit-verify.sh` — 동일 변경 미러링
- [ ] 테스트 실행 → T08~T09 PASS, 전체 9개 PASS 확인
- [ ] 회귀 확인: `bash tests/test-turbo-hooks.sh` → 8/8 PASS (precheck fallback 보존)
- [ ] Commit: `feat(spec-21-03): integrate intent.test with post-commit-verify`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] `bash tests/test-intent-block.sh` → 9/9 PASS
- [ ] `bash tests/test-turbo-hooks.sh` → 8/8 PASS
- [ ] `bash tests/test-mode-schema.sh` → 7/7 PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-21-03): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-21-03-intent-block`
- [ ] **PR 생성**: `gh pr create --base phase-21-turbo-mode`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 (test + feat×2 + docs) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-06-13 |
