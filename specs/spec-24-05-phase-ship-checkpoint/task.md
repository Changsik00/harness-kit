# Task List: spec-24-05

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

---

## Task 1: phase rollup 테스트 (TDD Red)

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-24-05-phase-ship-checkpoint` (완료)

### 1-2. 테스트 작성 (Red)
- [x] `tests/test-decision-phase.sh`: fixture 에서 2개 spec walkthrough 에 `decision add`, `sdd decision list --phase` 가 양쪽 집계 + spec 라벨, 결정 없는 spec 스킵, 0건 graceful, 기존 `list` 불변
- [x] 실행 → Fail 확인
- [x] Commit: `test(spec-24-05): add failing test for phase decision rollup`

---

## Task 2: rollup 구현 (TDD Green)

### 2-1. sdd decision list --phase + 미러
- [x] `sources/bin/sdd`: `cmd_decision` list `--phase` → `_decision_list_phase` (active phase 전 spec walkthrough 집계, spec 라벨, graceful)
- [x] `sources/` → `.harness-kit/` 미러링
- [x] 테스트 실행 → Pass + 전체 회귀 (72/72)
- [x] Commit: `feat(spec-24-05): sdd decision list --phase (rollup)`

### 2-2. hk-phase-ship 연동
- [x] `sources/commands/hk-phase-ship.md`: go/no-go 에 결정 로그 rollup 노출 단계 + PR 본문 포함 지시
- [x] `.claude/commands/hk-phase-ship.md` 미러
- [x] Commit: `docs(spec-24-05): hk-phase-ship 에 결정 로그 rollup 단계`

---

## Task 3: Ship

### 🚦 Pre-Push Quality Gate
- [x] 전체 테스트 PASS (72/72)

### 📝 산출물
- [x] walkthrough.md / pr_description.md
- [x] Commit: `docs(spec-24-05): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] push + `gh pr create`
