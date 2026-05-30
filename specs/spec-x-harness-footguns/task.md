# Task List: spec-x-harness-footguns

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new harness-footguns`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 0: 브랜치 생성

- [x] `git checkout -b spec-x-harness-footguns` (main 에서)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 1: 시크릿 가드 env 보간·placeholder 오탐 제거

### 1-1. 테스트 작성 (TDD Red)
- [x] `tests/test-check-secrets-dual-mode.sh` 에 Test 12/13/14 추가 (env 보간·placeholder 통과 / 하드코딩 차단 유지)
- [x] 실행 → 신규 케이스 Fail 확인
- [x] Commit: `test(spec-x-harness-footguns): add secret-guard false-positive cases`

### 1-2. 구현 (TDD Green)
- [x] `sources/hooks/check-secrets.sh` 일반 시크릿 검사에 변수 보간·placeholder 2차 필터 추가
- [x] `.harness-kit/hooks/check-secrets.sh` 동기화
- [x] 실행 → 전체 PASS (14/14) 확인
- [x] Commit: `fix(spec-x-harness-footguns): skip env interpolation and placeholders in secret guard`

---

## Task 2: update 미커밋 산물 커밋 안내

- [x] `update.sh` 종료부에 install 영역 미커밋 감지 시 커밋 안내 블록 추가
- [x] `sources/commands/hk-update.md` + `.claude/commands/hk-update.md` 에 커밋 단계 추가
- [x] `bash tests/test-update.sh` → 회귀 PASS (11/11)
- [x] Commit: `fix(spec-x-harness-footguns): guide committing harness-kit update artifacts`

---

## Task 3: spec/specx new 시 install drift 경고

### 3-1. 테스트 작성 (TDD Red)
- [x] 신규 `tests/test-sdd-spec-new-drift-warn.sh` 작성
- [x] 실행 → Fail 확인
- [x] Commit: `test(spec-x-harness-footguns): expect install-drift warn on spec new`

### 3-2. 구현 (TDD Green)
- [x] `sources/bin/sdd` 에 `_warn_install_drift` 헬퍼 추가, `spec_new()`/`specx_new()` 에서 호출
- [x] `.harness-kit/bin/sdd` 동기화, 실행 → PASS (4/4)
- [x] Commit: `fix(spec-x-harness-footguns): warn on uncommitted install drift before branching`

---

## Task 4: phase activate --base 마찰 해소

### 4-1. 테스트 작성 (TDD Red)
- [x] `tests/test-sdd-phase-activate.sh` 에 Check 10/11 추가 (메타 자동기입 / spec 보존)
- [x] 실행 → Fail 확인
- [x] Commit: `test(spec-x-harness-footguns): expect base meta autofill and spec preservation`

### 4-2. 구현 (TDD Green)
- [x] `sources/bin/sdd` `phase_activate()`: `--base=<branch>` 파싱 + `_set_phase_base_meta` 자동 갱신 + 같은 phase 재활성화 시 spec 보존 + help 보강
- [x] `.harness-kit/bin/sdd` 동기화, `phase-activate`(17/17)·`base-branch`(4/4) PASS
- [x] Commit: `fix(spec-x-harness-footguns): autofill base meta and preserve active spec on phase activate --base`

---

## Task 5: Ship (필수)

- [ ] 코드 품질 점검: 변경 스크립트 `bash -n` 문법 확인
- [ ] 관련 테스트 전체 실행 → 모두 PASS
- [ ] **walkthrough.md 작성** (결정·발견·검증 증거)
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-harness-footguns): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-harness-footguns`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (브랜치 포함 6) |
| **예상 commit 수** | 7 (test/impl 분리 + ship) |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-05-30 |
