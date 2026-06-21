# Task List: spec-24-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: 브랜치 생성

- [ ] `git checkout -b spec-24-03-stop-rules` (커밋 없음 — setup)

---

## Task 1: ②비가역 행동 감지 훅 (TDD)

### 1-1. Red
- [x] `tests/test-stop-rules.sh` — ②감지 케이스: force push / history rewrite / rm-rf·git clean / publish 경고, 정상 명령 무경고, 경계 FP 없음, block 모드 exit 2
- [x] 실행 → Fail 확인 (10 FAIL, rc=127 hook 부재)
- [x] Commit: `test(spec-24-03): add failing irreversible-action detection test` (c8501ba)

### 1-2. Green
- [x] `sources/hooks/check-irreversible.sh` 신규 (+ `.harness-kit/` 미러)
- [x] `sources/claude-fragments/settings.json.fragment` + `.claude/settings.json` 등록
- [x] 실행 → ②케이스 10/10 Pass, install-settings 회귀 7/7
- [x] Commit: `feat(spec-24-03): add irreversible-action stop-rule hook (warn mode)` (a633828)

---

## Task 2: ③반복 테스트 실패 카운터 (TDD)

### 2-1. Red
- [x] `tests/test-stop-rules.sh` 확장 — ③: 실패 누적 · N회 hard-stop · 통과 리셋
- [x] 실행 → Fail 확인 (③ 3 FAIL)
- [x] Commit: `test(spec-24-03): add failing repeat-failure counter test` (e9a1c2d)

### 2-2. Green
- [x] `sources/hooks/post-commit-verify.sh` — `state.autoFailCount` 카운터 + N회 hard-stop (+ 미러)
- [x] 실행 → ③케이스 13/13 Pass, turbo-hooks 8/8 · mode-auto 6/6 회귀 없음
- [x] Commit: `feat(spec-24-03): hard-stop after N repeated auto verify failures` (8c89822)

---

## Task 3: 결정 로그 `sdd decision` (TDD)

### 3-1. Red
- [x] `tests/test-decision-log.sh` — add 행 append / 헤더 멱등 / list / active spec 부재 graceful
- [x] 실행 → Fail 확인 (D1-D3 FAIL)
- [x] Commit: `test(spec-24-03): add failing decision-log test` (bb6ed24)

### 3-2. Green
- [x] `sources/bin/sdd` — `decision add/list` 서브커맨드 (+ `.harness-kit/` 미러)
- [x] 실행 → 4/4 Pass
- [x] Commit: `feat(spec-24-03): add sdd decision log (add/list)` (861a536)

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] 전체 테스트 실행 → 70/70 PASS

### 📝 산출물 작성
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] Commit: `docs(spec-24-03): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-24-03-stop-rules`
- [ ] PR 생성 (`/hk-pr-gh`)
