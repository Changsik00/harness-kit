# Task List: spec-26-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> base 모드 — phase-26 브랜치 위에서 진행, push/PR 은 phase-ship 에서 일괄.
> auto 모드 — post-commit-verify auto-revert 회피 위해 commit 시점은 항상 green.

---

## Task 0: 선행 영향 점검 (read-only)

- [x] `test-turbo-mode.sh` 등이 git push ask 토글 동작에 의존하는지 grep
  - 결과: test-install-settings-hook T5·test-e2e-auto-mode ① 은 "ask 에 push 없음"을 단언 → 방향2 와 정합(깨지지 않음). governed 가 push 를 ask 에 *추가*함을 단언하는 테스트는 없음 → 제거 안전.

---

## Task 1: SSOT 테스트 + _settings_mode_patch 제거

### 1-1. 테스트 작성 (TDD)
- [x] `tests/test-settings-ssot.sh` 신규: T1·T2·T3
- [x] 실행 → T3 Fail 확인 (RED)

### 1-2. 구현
- [x] `sources/bin/sdd`: `_settings_mode_patch()` + 호출 3곳 제거
- [x] `tests/test-settings-ssot.sh` → 3/3 Pass
- [x] `tests/test-turbo-mode.sh`(5/5) · `test-e2e-auto-mode.sh`(8/8) Pass (회귀 없음)
- [x] Commit `8cb3332`: `refactor(spec-26-01): git-push ask 토글 제거 (§5.7 정합) + SSOT 테스트`

---

## Task 2: .claude/settings.json 명시 잔재 정리

- [x] `permissions.allow` 의 stray `Bash(git push:*)` 제거. `ask` 는 git push 없는 현 상태 유지
- [x] `jq` 로 유효 JSON + git push 부재 확인
- [x] Commit `f999bb8`: `chore(spec-26-01): .claude/settings.json git push 잔재 정리`

---

## Task 2.5: 도그푸딩 설치본 동기화 (emergent)

> Pre-push 회귀에서 test-hook-modes 등 3건이 sources↔.harness-kit 불일치로 FAIL → 설치본 전파 필요.

- [x] `cp sources/bin/sdd .harness-kit/bin/sdd` + `check-irreversible.sh` 동기화
- [x] 3건 재실행 PASS
- [x] Commit `337362d`: `chore(spec-26-01): 도그푸딩 설치본 동기화`

---

## Task 3: Ship (spec walkthrough)

### 🚦 Pre-Push Quality Gate
- [x] `bash tests/run.sh` → 전체 PASS

### 📝 산출물
- [x] `walkthrough.md` 작성
- [x] `pr_description.md` 작성
- [x] phase-26 결정 기록에 W3 방향2 + §5.7 발견 반영 (commit `7732d3d`)
- [x] Commit: `docs(spec-26-01): ship walkthrough + pr description`

> push / PR 은 phase-ship(`/hk-phase-ship`)에서 phase-26 → main 단일 PR 로 진행. 별도 spec PR 없음.
