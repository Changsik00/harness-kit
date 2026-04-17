# Task List: spec-09-004

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-09.md SPEC 표 spec-09-004 Active 추가)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-09-004-root-config` (phase-09-install-conflict-defense에서 시작)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: TDD Red — 테스트 업데이트

### 2-1. test-path-config.sh 수정
- [x] Check A: "harness.config.json 생성 (rootDir 포함)"으로 변경
- [x] Check A 추가: rootDir 값이 fixture 경로와 일치하는지 확인
- [x] Check B 추가: rootDir 값이 fixture B 경로와 일치하는지 확인
- [x] 테스트 실행 → Fail 확인
- [x] Commit: `test(spec-09-004): update test-path-config for rootDir`

---

## Task 3: install.sh — rootDir 항상 기록

### 3-1. install.sh 수정
- [x] prefix 없는 경우에도 `harness.config.json` 생성 (`rootDir` only)
- [x] prefix 있는 경우 `rootDir` + `backlogDir` + `specsDir` 포함
- [x] `tests/test-path-config.sh` → Pass 확인 (10/10)
- [x] Commit: `feat(spec-09-004): always write rootDir to harness.config.json`

---

## Task 4: common.sh — rootDir 우선 읽기

### 4-1. sources/bin/lib/common.sh 수정
- [x] `sdd_find_root`: rootDir 우선 읽기 로직 추가 (최대 10단계 탐색)
- [x] jq 없을 때 grep 폴백 포함
- [x] `.harness-kit/bin/lib/common.sh` 동기화
- [x] 전체 테스트 → Pass 확인
- [x] Commit: `refactor(spec-09-004): sdd_find_root reads rootDir from config`

---

## Task 5: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-004): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-004-root-config`
- [ ] **PR 생성**: target: `phase-09-install-conflict-defense`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (+ Ship) |
| **예상 commit 수** | 4 |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-04-14 |
