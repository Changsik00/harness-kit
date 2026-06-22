# Task List: spec-x-doctor-template-sync

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

---

## Task 0: Pre-flight

- [ ] Plan Accept
- [ ] `git checkout -b spec-x-doctor-template-sync`
- [ ] **spec/task 계획 산출물 커밋** (첫 task 전 — PR 포함 보장)

---

## Task 1: 회귀 테스트 작성 (TDD Red)

### 1-1. test-doctor-templates.sh
- [ ] `tests/test-doctor-templates.sh` — `doctor.sh` 필수 템플릿 목록 == `sources/templates/*.md` 검증:
  - plan.md 가 목록에 **없어야** 함 (유령 제거)
  - phase-ship.md 가 목록에 **있어야** 함 (누락 보강)
  - 목록 집합 == 실제 템플릿 집합 (양방향)
- [ ] 실행 → Fail 확인 (현재 doctor.sh 가 plan.md 포함·phase-ship.md 누락)
- [ ] Commit: `test(spec-x-doctor-template-sync): doctor 템플릿 목록 정합 검증 (Red)`

---

## Task 2: doctor.sh 목록 동기화 (TDD Green)

### 2-1. doctor.sh
- [ ] `doctor.sh` `[3/7]` 템플릿 목록에서 `plan.md` 제거 + `phase-ship.md` 추가
- [ ] `tests/test-doctor-templates.sh` → Pass
- [ ] `bash doctor.sh` → FAIL 0 (plan.md 오탐 사라짐)
- [ ] 전체 회귀 PASS
- [ ] Commit: `fix(spec-x-doctor-template-sync): doctor.sh 템플릿 목록 동기화 (plan.md 오탐 제거, #204)`

---

## Task 3: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] **전체 테스트 실행** (`bash tests/run.sh`) → 모두 PASS
- [ ] 수동: `bash doctor.sh` plan.md FAIL 없음 확인

### 📝 산출물 작성
- [ ] **walkthrough.md 작성** (양방향 drift 발견 · 재발 방지 테스트)
- [ ] **pr_description.md 작성** (`Closes #204`)
- [ ] Commit: `docs(spec-x-doctor-template-sync): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-x-doctor-template-sync`
- [ ] PR 생성 (base=main, `Closes #204`)
- [ ] `sdd specx done doctor-template-sync` (머지 후)
