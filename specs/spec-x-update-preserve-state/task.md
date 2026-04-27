# Task List: spec-x-update-preserve-state

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new update-preserve-state`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — Pass: spec-x 는 phase.md/queue.md 갱신 불필요 (constitution §5.1)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. main 으로부터 spec-x 브랜치 분기
- [x] `git checkout -b spec-x-update-preserve-state` (main 에서 분기)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 테스트 확장 (TDD Red)

### 2-1. tests/test-update.sh 에 보존 검증 케이스 추가
- [x] 시나리오 A 에 `branch`, `baseBranch`, `kitVersion 동기화` 검증 추가
- [x] 신규 시나리오 C 추가: install.sh 가 baseBranch 필드 포함 state.json 작성
- [x] `bash tests/test-update.sh` 실행 → 신규 케이스 FAIL 확인 (Red, 2/11 fail)
- [x] Commit: `test(spec-x-update-preserve-state): add state preservation regression tests`

---

## Task 3: install.sh 의 state 템플릿에 baseBranch 추가 (TDD Green 1/2)

### 3-1. install.sh 수정
- [x] `install.sh` 의 state.json 템플릿에 `"baseBranch": null,` 추가
- [x] 검증: `tests/test-update.sh` 시나리오 C PASS
- [x] Commit: `fix(spec-x-update-preserve-state): add baseBranch field to install state template`

---

## Task 4: update.sh 의 state 보존 로직 확장 (TDD Green 2/2)

### 4-1. update.sh 수정
- [x] state 보존 로직을 jq 객체 머지 패턴으로 교체
- [x] 보존 키: `phase`, `spec`, `branch`, `baseBranch`, `planAccepted`, `lastTestPass`
- [x] `bash tests/test-update.sh` 실행 → 모두 PASS 확인 (Green, 11/11)
- [x] Commit: `fix(spec-x-update-preserve-state): preserve all state fields across update`

---

## Task 5: 버전 bump

### 5-1. VERSION + CHANGELOG.md + README + test-version-bump
- [x] `VERSION` 0.6.0 → 0.6.1
- [x] `CHANGELOG.md` 상단에 `[0.6.1] — 2026-04-27` 항목 추가
- [x] `README.md` 버전 배지 0.6.1
- [x] `tests/test-version-bump.sh` TARGET 0.6.1 (버전 앵커 sweep)
- [-] `tests/test-version-bump.sh` PASS — Pass: sdd version / installed.json 잔재는 Task 6 도그푸딩 후 해결
- [x] Commit: `chore(spec-x-update-preserve-state): bump version to 0.6.1`

---

## Task 6: 본 프로젝트 도그푸딩

### 6-1. update.sh 를 자기 자신에 적용
- [x] `bash update.sh --yes .` 실행 → `0.6.0 → 0.6.1`, doctor PASS=40 WARN=1 FAIL=0
- [x] `state.json` 검증: `kitVersion=0.6.1`, `baseBranch` 필드 존재, `spec/planAccepted/lastTestPass` 보존 ✓
- [x] `sdd status` 헤더가 `harness-kit 0.6.1` ✓
- [x] 도그푸딩으로 발견된 부수 이슈 3건 Icebox 에 기록 (gitignore self-host 충돌 / phase-ship.md 템플릿 누락 / settings.json ask 자동 추가)
- [x] Commit: `chore(spec-x-update-preserve-state): dogfood update on self`

---

## Task 7: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 sweep: Total fails = 0
- [x] **walkthrough.md 작성** (결정/협의/검증/발견 항목 포함)
- [x] **pr_description.md 작성** (템플릿 준수, 한국어)
- [ ] **Ship Commit**: `docs(spec-x-update-preserve-state): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-update-preserve-state`
- [ ] **PR 생성**: `gh pr create` (`/hk-pr-gh` 또는 직접). PR base = main
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight + Task1~6 + Ship) |
| **예상 commit 수** | 5 (Task 2~5 + Ship). Task 1 은 브랜치만, Task 6 은 변경 시에만 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-27 |
