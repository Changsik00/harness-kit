# Task List: spec-x-align-mode-salience

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> doc 변경이라 TDD red/green 없음 — 변경 후 정합 회귀로 검증.

---

## Task 0: Pre-flight
- [x] Plan Accept 확인

## Task 1: 브랜치 생성
- [x] `git checkout -b spec-x-align-mode-salience` (main 에서 분기)

---

## Task 2: align.md 모드 부각 + intent 잔재 정리

- [x] `sources/governance/align.md` 편집: Active Mode 라인 + §5.1 모드 부각 + §5.2 intent 잔재 점검
- [x] `.harness-kit/agent/align.md` 미러링 (도그푸딩 sync)
- [x] `diff -q` → IDENTICAL 확인
- [x] Commit: `docs(spec-x-align-mode-salience): surface active mode and stale-intent cleanup in align`

---

## Task 3: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] `bash tests/test-install-manifest-sync.sh` PASS (6/6)
- [x] `bash tests/run.sh --fast` → 56 PASS / 5 FAIL(기존 5건만, 신규 회귀 0)

### 📝 산출물 작성
- [x] walkthrough.md 작성
- [x] pr_description.md 작성
- [x] Commit: `docs(spec-x-align-mode-salience): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] `git push -u origin spec-x-align-mode-salience`
- [x] PR 생성 → main
- [ ] 머지 후 `sdd specx done align-mode-salience`
