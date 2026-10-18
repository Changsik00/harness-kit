# Task List: spec-28-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 브랜치 + 실패 테스트 (TDD Red)

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-28-01-wiki-freshness-check`

### 1-2. 테스트 작성
- [x] `tests/test-wiki-freshness.sh` 작성 (임시 git 저장소 fixture)
  - 케이스 1: 미반영 ADR 이 있으면 doctor 가 경고하고 ADR id 를 보여준다
  - 케이스 2: 모든 ADR 이 반영됐고 인제스트 이후 archive 가 5개 미만이면 침묵한다
  - 케이스 3: 인제스트 이후 archive 된 walkthrough 가 5개 이상이면 경고한다
  - 케이스 4: 인제스트 당일에 archive 된 spec 은 세지 않는다
  - 케이스 5: wiki / archive / decisions 가 없으면 침묵하고 doctor 가 비정상 종료하지 않는다
  - 케이스 6: `sdd status` 진단에 낡음 한 줄이 나온다
- [x] 테스트 실행 → Fail 확인
- [x] Commit: `test(spec-28-01): add failing test for wiki freshness check`

---

## Task 2: 헬퍼 구현 + doctor 통합 (TDD Green)

- [x] `sources/bin/sdd` 에 `_wiki_freshness_report` 구현
- [x] `_check_wiki_layer` 에 W-4 로 연결
- [x] 케이스 1~5 Pass 확인, `tests/test-doctor-wiki.sh` 회귀 없음
- [x] Commit: `feat(spec-28-01): add wiki freshness check to doctor`

---

## Task 3: status 진단 통합

- [x] `_status_diagnose` 에 한 줄 연결
- [x] 케이스 6 Pass 확인, `tests/test-status-backlog-residue.sh` 회귀 없음
- [x] Commit: `feat(spec-28-01): surface wiki freshness in sdd status`

---

## Task 4: 도그푸딩 사본 동기화

- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [ ] sync 불일치를 보는 테스트 PASS 확인
- [ ] 본 저장소에서 `sdd doctor` 실행 → wiki 최신 판정 확인
- [ ] Commit: `chore(spec-28-01): sync dogfood copy of sdd`

---

## Task 5: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** (`bash tests/run.sh`) → 신규 회귀 0 (기존 pre-existing FAIL 은 구분해 기록)

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-28-01): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-28-01-wiki-freshness-check`
- [ ] PR 생성 (base: `phase-28-docs-freshness`)
