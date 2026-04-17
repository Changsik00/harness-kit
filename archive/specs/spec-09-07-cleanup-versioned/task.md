# Task List: spec-09-07

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-09.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: cleanup.sh 신설 + 테스트

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-09-07-cleanup-versioned` (from `phase-09-install-conflict-defense`)
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [x] 테스트 케이스 작성: `tests/test-cleanup.sh`
  - 범위 내 migration 실행 → 파일 삭제 확인
  - 범위 외 migration skip
  - 동일 버전(빈 범위) 정상 종료
  - 존재하지 않는 파일 skip
- [x] 테스트 실행 → Fail 확인
- [x] Commit: `test(spec-09-07): add cleanup.sh test cases`

### 1-3. 구현 (TDD Green)
- [x] `cleanup.sh` 작성
  - `--from`/`--to`/`--yes`/TARGET 인자 파싱
  - semver 비교 함수 (macOS 호환, sort -V 미사용)
  - migration 파일 순회 + source + 함수 호출
  - 파일 삭제 + 결과 출력
- [x] 테스트 실행 → Pass 확인 (8/8)
- [x] Commit: `feat(spec-09-07): add cleanup.sh versioned migration runner`

---

## Task 2: update.sh 연동

### 2-1. update.sh 수정
- [x] state 복원 후 cleanup.sh 호출 코드 추가
- [x] 기존 테스트 실행 → Pass 확인 (test-update 7/7, test-cleanup 8/8)
- [x] Commit: `feat(spec-09-07): wire cleanup.sh into update.sh`

---

## Task 3: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS (`bash tests/run-all.sh`)
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-07): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-07-cleanup-versioned`
- [ ] **PR 생성**: 사용자 승인 후
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 (test + impl + update.sh + archive) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-15 |
