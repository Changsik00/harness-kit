# Task List: spec-28-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 브랜치 + 실패 테스트 (TDD Red)

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-28-02-source-sync-drift`

### 1-2. 테스트 작성
- [ ] `tests/test-source-sync-drift.sh` 작성 (임시 fixture)
  - 케이스 1: 원본과 사본이 다른 파일이 있으면 doctor 가 경고하고 파일명을 보여준다
  - 케이스 2: 모두 일치하면 침묵(`원본↔사본 일치`)
  - 케이스 3: 사본에 없는 원본 파일도 drift 로 센다
  - 케이스 4: 사본에만 있는 파일은 무시한다
  - 케이스 5: `sources/` 가 없는 다운스트림 fixture 는 침묵하고 doctor 가 비정상 종료하지 않는다
  - 케이스 6: `sdd status` 진단에 한 줄이 나온다
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-28-02): add failing test for source-copy drift check`

---

## Task 2: 헬퍼 구현 + doctor/status 통합 (TDD Green)

- [ ] `_source_sync_report` 구현
- [ ] `cmd_doctor` 연결 + `_status_diagnose` 연결
- [ ] 케이스 1~6 Pass, `tests/test-wiki-freshness.sh` 회귀 없음
- [ ] Commit: `feat(spec-28-02): add source-copy drift check to doctor and status`

---

## Task 3: 도그푸딩 사본 동기화

- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [ ] 본 저장소 `sdd doctor` → drift 0 확인, 변조 후 감지 확인(복구)
- [ ] Commit: `chore(spec-28-02): sync dogfood copy of sdd`

---

## Task 4: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** (`bash tests/run.sh`) → PASS / FAIL 0

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-28-02): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-28-02-source-sync-drift`
- [ ] PR 생성 (base: `phase-28-docs-freshness`)
