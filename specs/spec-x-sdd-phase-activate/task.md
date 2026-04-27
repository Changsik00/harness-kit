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
- [ ] `tests/test-sdd-phase-activate.sh` 신규 작성 — 시나리오:
  1. `phase activate phase-03` 정상 → state/queue 갱신, phase.md 본문 미변경
  2. 파일 없음 → die
  3. 이미 done 인 phase → die
  4. 다른 active phase 존재 → die
  5. `--base` + 메타 채워진 경우 → 메타값 사용
  6. `--base` + 메타 빈 경우 → `phase-NN-<slug>` 생성
  7. `phase new` 사전 정의 phase 존재 시 die + 안내 메시지에 `phase activate` 포함
  8. `phase new --force` 우회 → 정상 생성
  9. 사전 정의 없을 때 `phase new` 정상 동작
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-x-sdd-phase-activate): add failing tests for phase activate and new guard`

---

## Task 3: TDD Green — sdd CLI 구현

### 3-1. 헬퍼 함수 추가
- [ ] `sources/bin/sdd` 에 `queue_phase_is_done()`, `queue_remove_from_queued()` 추가

### 3-2. phase_activate 함수 + 라우팅
- [ ] `sources/bin/sdd` 에 `phase_activate()` 구현
- [ ] `cmd_phase` 라우팅에 `activate)` 추가

### 3-3. phase_new 가드 + --force
- [ ] `sources/bin/sdd` `phase_new()` 에 사전 정의 phase 가드 추가
- [ ] `--force` 플래그 파싱 추가

### 3-4. 도움말 갱신
- [ ] `cmd_help` 에 `phase activate`, `phase new --force` 항목 추가

### 3-5. 검증
- [ ] `bash tests/test-sdd-phase-activate.sh` → Pass 확인
- [ ] Commit: `fix(spec-x-sdd-phase-activate): add phase activate command and phase new guard`

---

## Task 4: 도그푸딩 동기화

### 4-1. 설치본 sdd 동기화
- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [ ] 실행 권한 확인 (`chmod +x .harness-kit/bin/sdd` 필요 시)

### 4-2. 검증
- [ ] `bash .harness-kit/bin/sdd version` 정상 출력
- [ ] Commit: `chore(spec-x-sdd-phase-activate): sync installed sdd from sources`

---

## Task 5: 버전 bump 0.6.2

### 5-1. VERSION + tests
- [ ] `VERSION` → `0.6.2`
- [ ] `tests/test-version-bump.sh` `TARGET="0.6.2"` 로 갱신

### 5-2. installed.json
- [ ] `.harness-kit/installed.json` `kitVersion: "0.6.2"`

### 5-3. 검증
- [ ] `bash tests/test-version-bump.sh` → 일부 PASS, CHANGELOG/README 미반영 FAIL 예상 (다음 task에서 해결)
- [ ] Commit: `chore(spec-x-sdd-phase-activate): bump version to 0.6.2`

---

## Task 6: CHANGELOG + README

### 6-1. 문서 갱신
- [ ] `CHANGELOG.md` `## [0.6.2] — 2026-04-28` 항목 추가 (Added: phase activate / Fixed: phase new 가드)
- [ ] `README.md` 0.6.1 참조 → 0.6.2 (필요한 경우 phase activate 안내 한 줄 추가)

### 6-2. 검증
- [ ] `bash tests/test-version-bump.sh` → 전체 PASS
- [ ] Commit: `docs(spec-x-sdd-phase-activate): document 0.6.2 changes`

---

## Task 7: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 스위트 실행 → 모두 PASS (`bash tests/test-version-bump.sh`)
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-sdd-phase-activate): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-sdd-phase-activate`
- [ ] **PR 생성**: `gh pr create` 또는 `/hk-pr-gh`
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
