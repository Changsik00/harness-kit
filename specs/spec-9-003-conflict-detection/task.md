# Task List: spec-9-003

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-9.md SPEC 표 spec-9-003 Active 추가)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-9-003-conflict-detection` (phase-9-install-conflict-defense에서 시작)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: TDD Red — 충돌 감지 테스트 작성

### 2-1. test-conflict-detection.sh 작성
- [ ] `tests/test-conflict-detection.sh` 작성:
  - 신규 빈 repo → install 정상, config 미생성 확인
  - `backlog/` 기존 내용 있는 repo → `--yes` 실행 → `harness.config.json` 생성, `hk-backlog/` 존재 확인
  - `specs/` 기존 내용 있는 repo → `--yes` 실행 → `harness.config.json` 생성, `hk-specs/` 존재 확인
  - config 있는 상태에서 `sdd status` → 오류 없이 실행 확인
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-9-003): add failing test for conflict detection and config system`

---

## Task 3: common.sh 경로 수정 + config 읽기

### 3-1. sources/bin/lib/common.sh 수정
- [ ] `sdd_find_root`: `.harness-kit/installed.json` 감지 조건 추가
- [ ] `SDD_AGENT` → `.harness-kit/agent/`, `SDD_TEMPLATES` → `.harness-kit/agent/templates/`
- [ ] `harness.config.json` 읽기: `SDD_BACKLOG`/`SDD_SPECS` override
- [ ] `.harness-kit/agent/` + `.harness-kit/bin/` 동기화
- [ ] Commit: `refactor(spec-9-003): fix common.sh paths and add harness.config.json support`

---

## Task 4: install.sh — 충돌 감지 + config 생성

### 4-1. install.sh 수정
- [ ] 충돌 감지 함수 `_check_dir_conflict()` 추가
- [ ] install 초반에 충돌 스캔 실행
- [ ] 충돌 시: 내역 출력 → 제안 경로 → 사용자 확인 (또는 `--yes`로 자동 채택)
- [ ] `harness.config.json` 생성 로직 추가
- [ ] backlog/specs 디렉토리 생성 시 config 경로 반영
- [ ] `tests/test-conflict-detection.sh` → Pass 확인
- [ ] Commit: `feat(spec-9-003): add conflict detection and harness.config.json to install.sh`

---

## Task 5: doctor.sh — config 반영

### 5-1. doctor.sh 수정
- [ ] `harness.config.json` 존재 시 설정 경로 출력
- [ ] Section 2 디렉토리 체크: config 경로 반영
- [ ] Commit: `refactor(spec-9-003): doctor.sh reflects harness.config.json paths`

---

## Task 6: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-9-003): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-9-003-conflict-detection`
- [ ] **PR 생성**: (사용자 승인 후), target: `phase-9-install-conflict-defense`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (+ Ship) |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-14 |
