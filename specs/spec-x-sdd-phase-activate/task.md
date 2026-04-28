# Task List: spec-x-sdd-phase-activate

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-sdd-phase-activate`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: TDD Red — phase activate / new 가드 테스트 작성

### 2-1. 테스트 작성
- [x] `tests/test-sdd-phase-activate.sh` 신규 작성 — 9 시나리오 (PASS=5 / FAIL=8 baseline)
- [x] 테스트 실행 → Fail 확인 (8 fail)
- [x] Commit: `test(spec-x-sdd-phase-activate): add failing tests for phase activate and new guard`

---

## Task 3: TDD Green — sdd CLI 구현

### 3-1. 헬퍼 함수 추가
- [x] `sources/bin/sdd` 에 `queue_phase_is_done()` 추가
- [-] `queue_remove_from_queued()` — queue.md "대기 Phase" 섹션은 자동 마커가 아니라 자유 메모 영역이라 불필요 (계획 단순화)

### 3-2. phase_activate 함수 + 라우팅
- [x] `sources/bin/sdd` 에 `phase_activate()` 구현
- [x] `cmd_phase` 라우팅에 `activate)` 추가

### 3-3. phase_new 가드 + --force
- [x] `sources/bin/sdd` `phase_new()` 에 사전 정의 phase 가드 추가
- [x] `--force` 플래그 파싱 추가

### 3-4. 도움말 갱신
- [x] `cmd_help` 에 `phase activate`, `phase new --force` 항목 추가

### 3-5. 검증
- [x] `bash tests/test-sdd-phase-activate.sh` → 13/13 PASS
- [x] `bash tests/test-sdd-base-branch.sh` → 4/4 PASS (회귀)
- [x] Commit: `fix(spec-x-sdd-phase-activate): add phase activate command and phase new guard`

---

## Task 4: 도그푸딩 동기화

### 4-1. 설치본 sdd 동기화
- [x] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [x] 실행 권한 부여

### 4-2. 검증
- [x] `bash .harness-kit/bin/sdd version` 정상 출력
- [x] Commit: `chore(spec-x-sdd-phase-activate): sync installed sdd from sources`

---

## Task 5: 버전 bump 0.6.2

### 5-1. VERSION + tests
- [x] `VERSION` → `0.6.2`
- [x] `tests/test-version-bump.sh` `TARGET="0.6.2"` 로 갱신

### 5-2. installed.json
- [x] `.harness-kit/installed.json` `kitVersion: "0.6.2"`

### 5-3. 검증
- [x] `bash tests/test-version-bump.sh` → VERSION/installed PASS, CHANGELOG/README FAIL (다음 task에서 해결)
- [x] Commit: `chore(spec-x-sdd-phase-activate): bump version to 0.6.2`

---

## Task 6: CHANGELOG + README

### 6-1. 문서 갱신
- [x] `CHANGELOG.md` `## [0.6.2] — 2026-04-28` 항목 추가
- [x] `README.md` 버전 배지 0.6.1 → 0.6.2

### 6-2. 검증
- [x] `bash tests/test-version-bump.sh` → 6/6 PASS + 전체 스위트 FAIL=0
- [x] Commit: `docs(spec-x-sdd-phase-activate): document 0.6.2 changes`

---

## Task 7: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 스위트 실행 → 모두 PASS
- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-sdd-phase-activate): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-sdd-phase-activate`
- [ ] **PR 생성**: `gh pr create`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고
- [ ] 완료 후: spec-x done 처리 (`sdd specx done sdd-phase-activate`)

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 |
| **예상 commit 수** | 6 (Task 1은 브랜치 생성만, 커밋 없음) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-28 |
