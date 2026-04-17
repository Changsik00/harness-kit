# Task List: spec-10-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-10.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: Done → Merged 전환 테스트 및 구현

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-10-01-archive-status-fix`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [x] `tests/test-sdd-archive-completion.sh`에 Done 상태 spec archive 시나리오 추가
- [x] 테스트 실행 → Fail 확인
- [x] Commit: `test(spec-10-01): add failing test for Done → Merged transition`

### 1-3. 구현 (TDD Green)
- [x] `sources/bin/sdd` `cmd_archive()` awk 패턴에 `| Done |` 매칭 추가 + 상태 전이 주석
- [x] `.harness-kit/bin/sdd` 동일 변경 적용
- [x] 테스트 실행 → Pass 확인 (7/7 PASS)
- [x] Commit: `fix(spec-10-01): add Done status matching to archive awk pattern`

---

## Task 2: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 (`bash tests/run-all.sh`) → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-10-01): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-10-01-archive-status-fix`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 2 |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
