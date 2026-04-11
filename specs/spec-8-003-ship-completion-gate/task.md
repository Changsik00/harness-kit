# Task List: spec-8-003

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`specs/spec-8-003-ship-completion-gate/`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (`backlog/phase-8.md` spec 표 — In Progress 마킹)
- [ ] 사용자 Plan Accept

---

## Task 1: 단위 테스트 작성 (TDD Red)

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-8-003-ship-completion-gate phase-8-work-model`
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성
- [ ] `tests/test-sdd-archive-completion.sh` 신규 작성 (4종 케이스)
  - Check 1: `sdd archive` 후 phase.md spec 상태 `In Progress` → `Merged` 갱신
  - Check 2: 잔여 Backlog/In Progress 없으면 phase done 유도 메시지 출력
  - Check 3: 잔여 Backlog 있으면 유도 메시지 없음
  - Check 4: `sdd specx done <slug>` → queue.md specx→done 이동
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-8-003): add failing tests for archive completion gate`

---

## Task 2: sdd archive — phase.md 자동 갱신 + phase done 유도

### 2-1. 구현 (TDD Green)
- [ ] `scripts/harness/bin/sdd` — `cmd_archive()` 에 phase.md Merged 갱신 로직 추가
- [ ] `scripts/harness/bin/sdd` — `_check_phase_all_merged()` 헬퍼 함수 추가
- [ ] 테스트 Check 1, 2, 3 → Pass 확인
- [ ] Commit: `feat(spec-8-003): auto-update phase.md to merged and prompt phase done after archive`

### 2-2. sdd specx done 명령 추가
- [ ] `scripts/harness/bin/sdd` — `cmd_specx()` + `specx_done()` 추가
- [ ] `sdd` 진입점에 `specx) cmd_specx "$@" ;;` 등록
- [ ] 테스트 Check 4 → Pass 확인
- [ ] Commit: `feat(spec-8-003): add sdd specx done command for queue completion`

### 2-3. sources/ 동기화
- [ ] `sources/bin/sdd` — 위와 동일 변경 반영
- [ ] Commit: `chore(spec-8-003): sync sources/bin/sdd with harness implementation`

---

## Task 3: hk-ship.md Step 6 — spec-x queue 갱신 명세 추가

### 3-1. hk-ship.md 수정
- [ ] `sources/commands/hk-ship.md` Step 6에 spec-x 완료 시 `sdd specx done {slug}` 호출 명세 추가
- [ ] Commit: `feat(spec-8-003): add spec-x queue completion step to hk-ship step 6`

---

## Task 4: Hand-off (필수)

- [ ] 전체 테스트 실행 (`bash tests/test-sdd-archive-completion.sh`) → 4/4 PASS
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-8-003): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-8-003-ship-completion-gate`
- [ ] **PR 생성**: 타깃 `phase-8-work-model`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 6 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
