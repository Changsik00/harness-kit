# Task List: spec-24-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: 브랜치 생성

- [ ] `git checkout -b spec-24-03-stop-rules` (커밋 없음 — setup)

---

## Task 1: ②비가역 행동 감지 훅 (TDD)

### 1-1. Red
- [ ] `tests/test-stop-rules.sh` — ②감지 케이스: force push / history rewrite / rm-rf·git clean / publish 경고, 정상 명령 무경고, 경계 FP 없음, block 모드 exit 2
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-24-03): add failing irreversible-action detection test`

### 1-2. Green
- [ ] `sources/hooks/check-irreversible.sh` 신규 (+ `.harness-kit/` 미러)
- [ ] `sources/claude-fragments/settings.json.fragment` + `.claude/settings.json` 등록
- [ ] 실행 → ②케이스 Pass
- [ ] Commit: `feat(spec-24-03): add irreversible-action stop-rule hook (warn mode)`

---

## Task 2: ③반복 테스트 실패 카운터 (TDD)

### 2-1. Red
- [ ] `tests/test-stop-rules.sh` 확장 — ③: 실패 누적 · N회 hard-stop · 통과 리셋
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-24-03): add failing repeat-failure counter test`

### 2-2. Green
- [ ] `sources/hooks/post-commit-verify.sh` — `state.autoFailCount` 카운터 + N회 hard-stop (+ 미러)
- [ ] 실행 → ③케이스 Pass, `test-turbo-hooks` 회귀 없음
- [ ] Commit: `feat(spec-24-03): hard-stop after N repeated auto verify failures`

---

## Task 3: 결정 로그 `sdd decision` (TDD)

### 3-1. Red
- [ ] `tests/test-decision-log.sh` — add 행 append / 헤더 멱등 / list / active spec 부재 graceful
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-24-03): add failing decision-log test`

### 3-2. Green
- [ ] `sources/bin/sdd` — `decision add/list` 서브커맨드 (+ `.harness-kit/` 미러)
- [ ] 실행 → Pass
- [ ] Commit: `feat(spec-24-03): add sdd decision log (add/list)`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] 전체 테스트 실행 → 모두 PASS

### 📝 산출물 작성
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-24-03): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-24-03-stop-rules`
- [ ] PR 생성 (`/hk-pr-gh`)
