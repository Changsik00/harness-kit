# Task List: spec-27-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-27-03-archive-residue-detect` (base: `phase-27-docs-integrity`)

---

## Task 2: 테스트 작성 (TDD Red)

### 2-1. 실패하는 테스트 작성
- [x] `tests/test-status-backlog-residue.sh` 작성 — fixture 로 다음을 검증:
  - `queue.md` done 구간에 완료 phase 를 추가 + 대응 `backlog/phase-NN.md` 존재 → `sdd status` 🔍 진단에 잔존 안내 등장
  - fixture 제거 후에는 해당 안내 사라짐(다른 실 데이터 잔존은 남을 수 있음 — fixture ID 로만 검증)
- [x] 테스트 실행 → Fail 확인 (진단 로직 미구현)
- [x] Commit: `test(spec-27-03): add failing test for status backlog residue diagnosis`

---

## Task 3: 구현 (TDD Green)

### 3-1. `_status_diagnose()` 확장
- [x] `sources/bin/sdd` 의 `_status_diagnose()` 에 `_backlog_completed_residue`(spec-27-02 공유 헬퍼) 호출 + 진단 라인 추가
- [x] `.harness-kit/bin/sdd` 에 동일 변경 미러
- [x] 테스트 실행 → Pass 확인 (`bash tests/test-status-backlog-residue.sh` 2/2, `bash tests/run.sh` 81/81)
- [x] Commit: `feat(spec-27-03): surface backlog phase residue in sdd status diagnosis`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** → 모두 PASS (`bash tests/run.sh`)

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-27-03): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-27-03-archive-residue-detect`
- [ ] PR 생성 (`gh pr create` 또는 `/hk-pr-gh`, base: `phase-27-docs-integrity`)
