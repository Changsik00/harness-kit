# Task List: spec-09-003

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-09.md SPEC 표 spec-09-003 Active 추가)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-09-003-conflict-detection` (phase-09-install-conflict-defense에서 시작)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: TDD Red — 경로 config 테스트 작성

### 2-1. test-path-config.sh 작성
- [x] `tests/test-path-config.sh` 작성:
  - `--yes` 실행 → config 미생성, `backlog/` 생성 확인
  - prefix `hk-` 지정(`--prefix hk-`) → `harness.config.json` 생성, `hk-backlog/`, `hk-specs/` 생성 확인
  - config 있는 상태에서 `sdd status` → 오류 없이 실행 확인
- [x] 테스트 실행 → Fail 확인
- [x] Commit: `test(spec-09-003): add failing test for path config system`

---

## Task 3: common.sh 경로 수정 + config 읽기

### 3-1. sources/bin/lib/common.sh 수정
- [x] `sdd_find_root`: `.harness-kit/installed.json` 감지 조건 추가
- [x] `SDD_AGENT` → `.harness-kit/agent/`, `SDD_TEMPLATES` → `.harness-kit/agent/templates/`
- [x] `harness.config.json` 읽기: `SDD_BACKLOG`/`SDD_SPECS` override (jq 없으면 grep 폴백)
- [x] `sources/bin/` → `.harness-kit/bin/` 동기화
- [x] Commit: `refactor(spec-09-003): fix common.sh agent paths and add config reading`

---

## Task 4: install.sh — prefix UX + config 생성

### 4-1. install.sh 수정
- [x] `--prefix` 플래그 파싱 추가 (비대화식 환경용)
- [x] 설치 계획 출력 후 prefix 프롬프트 추가 (`--yes` 시 스킵)
- [x] prefix 있으면 `harness.config.json` 생성, `{prefix}backlog/`/`{prefix}specs/` 사용
- [x] backlog/specs 디렉토리 생성 및 초기 파일 생성 시 config 경로 반영
- [x] `tests/test-path-config.sh` → Pass 확인 (9/9)
- [x] Commit: `feat(spec-09-003): add prefix UX and harness.config.json to install.sh`

---

## Task 5: doctor.sh — config 반영

### 5-1. doctor.sh 수정
- [x] Section 5(State): `harness.config.json` 존재 + 설정 경로 출력
- [x] Section 2(디렉토리 구조): config 경로로 backlog/specs 체크
- [x] Commit: `refactor(spec-09-003): doctor.sh reflects harness.config.json paths`

---

## Task 6: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-09-003): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-003-conflict-detection`
- [ ] **PR 생성**: (사용자 승인 후), target: `phase-09-install-conflict-defense`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (+ Ship) |
| **예상 commit 수** | 5 |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-04-14 |
