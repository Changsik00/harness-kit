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
- [ ] 시나리오 A 에 `branch`, `baseBranch`, `kitVersion 동기화` 검증 추가
- [ ] 신규 시나리오 C 추가: 6개 필드 모두 값 주입 → update → 모두 보존
- [ ] `bash tests/test-update.sh` 실행 → 신규 케이스 FAIL 확인 (Red)
- [ ] Commit: `test(spec-x-update-preserve-state): add state preservation regression tests`

---

## Task 3: install.sh 의 state 템플릿에 baseBranch 추가 (TDD Green 1/2)

### 3-1. install.sh 수정
- [ ] `install.sh` lines 481-491 의 state.json 템플릿에 `"baseBranch": null,` 추가
- [ ] 직접 검증: `bash install.sh --yes <tmpdir>` 후 `jq '.baseBranch' .claude/state/current.json` → `null` 출력
- [ ] Commit: `fix(spec-x-update-preserve-state): add baseBranch field to install state template`

---

## Task 4: update.sh 의 state 보존 로직 확장 (TDD Green 2/2)

### 4-1. update.sh 수정
- [ ] lines 113-145 를 plan.md 의 jq 객체 머지 패턴으로 교체
- [ ] 보존 키: `phase`, `spec`, `branch`, `baseBranch`, `planAccepted`, `lastTestPass`
- [ ] `bash tests/test-update.sh` 실행 → 모두 PASS 확인 (Green)
- [ ] Commit: `fix(spec-x-update-preserve-state): preserve all state fields across update`

---

## Task 5: 버전 bump

### 5-1. VERSION + CHANGELOG.md
- [ ] `VERSION` 0.6.0 → 0.6.1
- [ ] `CHANGELOG.md` 상단에 `[0.6.1] — 2026-04-27` 항목 추가 (Fixed 섹션)
- [ ] `bash tests/test-version-bump.sh` 실행 → PASS
- [ ] Commit: `chore(spec-x-update-preserve-state): bump version to 0.6.1`

---

## Task 6: 본 프로젝트 도그푸딩

### 6-1. update.sh 를 자기 자신에 적용
- [ ] `bash update.sh --yes .` 실행 (현재 작업 디렉토리)
- [ ] `cat .claude/state/current.json` → `kitVersion=0.6.1`, `baseBranch` 필드 존재 확인
- [ ] `bash .harness-kit/bin/sdd status` → 헤더가 `harness-kit 0.6.1` 출력 확인
- [ ] (예상) 자기 자신의 `.harness-kit/` 디렉토리가 갱신됨 — git status 에 변경사항이 있다면 커밋
- [ ] Commit: `chore(spec-x-update-preserve-state): dogfood update on self`
  - 단, .harness-kit/ 변경이 없으면 commit 생략 가능 (이 경우 task 는 `[-]` Pass 로 마킹)

---

## Task 7: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 sweep: `for t in tests/test-*.sh; do bash "$t" || echo "FAIL: $t"; done` → 모두 PASS
- [ ] **walkthrough.md 작성** (증거 로그) — 빈 파일이 이미 존재하므로 내용만 채움
- [ ] **pr_description.md 작성** (템플릿 준수, 한국어)
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
