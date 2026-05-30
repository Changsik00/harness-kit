# Task List: spec-x-harness-footguns

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new harness-footguns`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 0: 브랜치 생성

- [ ] `git checkout -b spec-x-harness-footguns` (main 에서)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 1: 시크릿 가드 env 보간·placeholder 오탐 제거

### 1-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-check-secrets-dual-mode.sh` 에 케이스 추가:
  - `export POSTGRES_PASSWORD=${DB_PASSWORD:-default}` staged → 통과(exit 0) 기대
  - `password: changeme` staged → 통과 기대
  - `password=Xy9hardcodedSecret` staged → 차단(exit≠0) 유지 기대
- [ ] 실행 → 신규 케이스 Fail 확인
- [ ] Commit: `test(spec-x-harness-footguns): add secret-guard false-positive cases`

### 1-2. 구현 (TDD Green)
- [ ] `sources/hooks/check-secrets.sh:58` 일반 시크릿 검사에 shell 변수 보간·placeholder 2차 필터 추가 + 주석 갱신
- [ ] `.harness-kit/hooks/check-secrets.sh` 동기화 (설치본도 갱신)
- [ ] 실행 → 전체 PASS 확인
- [ ] Commit: `fix(spec-x-harness-footguns): skip env interpolation and placeholders in secret guard`

---

## Task 2: update 미커밋 산물 커밋 안내

### 2-1. 구현 + 검증
- [ ] `update.sh` 종료부에 install 영역(`.harness-kit/`·`.claude/`) 미커밋 감지 시 커밋 안내 블록 출력 추가
- [ ] `sources/commands/hk-update.md` 에 업데이트 후 커밋 단계 추가
- [ ] `bash tests/test-update.sh` → 회귀 PASS 확인 (안내 추가가 기존 검증을 깨지 않음)
- [ ] Commit: `fix(spec-x-harness-footguns): guide committing harness-kit update artifacts`

> 참고: update.sh 전체 흐름 테스트(test-update.sh)는 회귀 확인용. 안내 출력은 수동 검증 시나리오로 보완.

---

## Task 3: spec/specx new 시 install drift 경고

### 3-1. 테스트 작성 (TDD Red)
- [ ] spec-new 관련 테스트(`tests/test-sdd-spec-new-seq.sh` 확장 또는 신규 `tests/test-sdd-spec-new-drift-warn.sh`):
  - 미커밋 `.harness-kit/` 파일이 있을 때 `specx new` → stderr 에 경고 + exit 0 + 정상 생성
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-x-harness-footguns): expect install-drift warn on spec new`

### 3-2. 구현 (TDD Green)
- [ ] `sources/bin/sdd` 에 `_warn_install_drift` 헬퍼 추가, `spec_new()`/`specx_new()` 진입부에서 호출 (비차단 warn)
- [ ] 실행 → PASS 확인
- [ ] Commit: `fix(spec-x-harness-footguns): warn on uncommitted install drift before branching`

---

## Task 4: phase activate --base 마찰 해소

### 4-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-sdd-phase-activate.sh` 에 케이스 추가:
  - `phase activate <id> --base=phase-NN-slug` → phase.md `Base Branch` 메타가 해당 값으로 갱신됨
  - `cur_phase==id` 인 상태에서 `--base` 재활성화 → active spec 보존(리셋 안 됨)
- [ ] 실행 → Fail 확인
- [ ] Commit: `test(spec-x-harness-footguns): expect base meta autofill and spec preservation`

### 4-2. 구현 (TDD Green)
- [ ] `sources/bin/sdd` `phase_activate()`: `--base=<branch>` 파싱 + phase.md 메타 자동 갱신 + 같은 phase 재활성화 시 spec 보존 + help 텍스트 보강
- [ ] `bash tests/test-sdd-phase-activate.sh` 및 `bash tests/test-sdd-base-branch.sh` → 전체 PASS
- [ ] Commit: `fix(spec-x-harness-footguns): autofill base meta and preserve active spec on phase activate --base`

---

## Task 5: Ship (필수)

- [ ] 코드 품질 점검: 변경 스크립트 `bash -n` 문법 확인
- [ ] 관련 테스트 전체 실행 → 모두 PASS (`check-secrets`, `phase-activate`, `base-branch`, `update`, spec-new drift)
- [ ] **walkthrough.md 작성** (결정·발견·검증 증거)
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-harness-footguns): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-harness-footguns`
- [ ] **PR 생성**: `/hk-pr-gh` (또는 gh pr create)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (브랜치 포함 6) |
| **예상 commit 수** | 7 (test/impl 분리 + ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-30 |
