# Task List: spec-27-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-27-02-docs-integrity-check` (base: `phase-27-docs-integrity`)

---

## Task 2: 테스트 작성 (TDD Red)

### 2-1. 실패하는 테스트 작성
- [x] `tests/test-doctor-docs-integrity.sh` 작성 — fixture 로 다음을 검증:
  - ADR 두 개가 같은 `id:` 를 가지면 `sdd doctor` 출력에 FAIL(❌) + 중복 id 명시
  - ADR 파일이 `---` 로 시작하지 않으면 FAIL(❌)
  - `docs/decisions/README.md` 를 인위적으로 stale 하게 만들면 WARN(⚠️) — adr-index drift
  - `backlog/queue.md` done 구간에 있는 phase 의 `backlog/phase-NN.md` 가 존재하면 WARN(⚠️) — 잔존
  - 위반 없는 정상 상태에서는 ADR FAIL 없음 + "docs 무결성" 섹션 존재
- [x] 테스트 실행 → Fail 확인 (검사 로직 미구현 — "docs 무결성" 섹션 자체가 없음)
- [x] Commit: `test(spec-27-02): add failing test for doctor docs-integrity checks`

---

## Task 3: 구현 (TDD Green)

### 3-1. `cmd_doctor()` 확장
- [ ] `sources/bin/sdd` 의 `cmd_doctor()` 에 "docs 무결성" 섹션 추가:
  - `_check_adr_id_uniqueness` (fail-level)
  - `_check_adr_frontmatter` (fail-level)
  - `_check_adr_index_drift` — `( cmd_adr_index --check )` 서브셸 호출 (warn-level)
  - `_backlog_completed_residue` 헬퍼 + doctor wrapper (warn-level)
- [ ] `.harness-kit/bin/sdd` 에 동일 변경 미러
- [ ] 테스트 실행 → Pass 확인 (`bash tests/test-doctor-docs-integrity.sh`)
- [ ] Commit: `feat(spec-27-02): add docs integrity checks to sdd doctor`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** → 모두 PASS (`bash tests/run.sh`)

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-27-02): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-27-02-docs-integrity-check`
- [ ] PR 생성 (`gh pr create` 또는 `/hk-pr-gh`, base: `phase-27-docs-integrity`)
