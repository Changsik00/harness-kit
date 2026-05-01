# Task List: spec-x-hk-align-drift-detect

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
- [x] `git checkout -b spec-x-hk-align-drift-detect`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: drift 감지 테스트 추가 (TDD Red)

### 2-1. 테스트 fixture 준비 + 5 시나리오 테스트 작성
- [x] 신규: `tests/test-sdd-drift.sh`
  - T1: 깨끗한 상태 → "🔄 동기화 상태: 깔끔"
  - T2: behind=1 시뮬레이션 → "원격: behind 1 / ahead 0"
  - T3: specs/ 미커밋 → "워킹트리: ... spec drift"
  - T4: queue active phase 의 모든 spec Merged → "phase done 미실행 의심"
  - T5: `--no-drift` → 동기화 섹션 미출력
- [x] `bash tests/test-sdd-drift.sh` → 4 Fail / 1 PASS (T5 가 false positive — drift 섹션 자체가 없어서 미출력. 구현 후 재검증 필요)
- [x] Commit: `test(spec-x-hk-align-drift-detect): add failing tests for sdd status drift section` (38ded62)

---

## Task 3: drift 감지 구현 — 4 카테고리 함수 (TDD Green)

### 3-1. `sources/bin/sdd` 에 drift_check 및 4 서브 함수 추가
- [x] `_drift_remote()` — git fetch + behind/ahead
- [x] `_drift_worktree()` — git status --porcelain 분류
- [x] `_drift_consistency()` — queue.md vs phase-N.md 정합성
- [x] `_drift_install()` — sources vs .harness-kit/.claude untracked diff
- [x] `_status_drift()` — 4 함수 호출 + 깔끔/상세 분기
- [x] `cmd_status()` 에 `--no-drift` 옵션 추가 + drift 호출 (--brief / --json 도 자동 no-drift)
- [x] cmd_help 의 status 항목에 `--no-drift` 설명 + 환경변수 `HARNESS_DRIFT_FETCH` 설명 추가
- [x] `bash tests/test-sdd-drift.sh` → 6/6 Pass (T1 fixture 보강 후)
- [x] 회귀 테스트:
  - `tests/test-sdd-spec-new-seq.sh` 5/5 Pass
  - `tests/test-fixture-lib.sh` 18/18 Pass
  - `tests/test-install-manifest-sync.sh` 6/6 Pass
- [x] Commit: `feat(spec-x-hk-align-drift-detect): add drift section to sdd status` (4cf6695)

---

## Task 4: hk-align 슬래시 커맨드 + 거버넌스 동기화

### 4-1. `sources/commands/hk-align.md` 의 §5 (상태 요약 보고) 출력 형식에 동기화 섹션 추가
- [x] §2 (컨텍스트 점검) 에 "drift 감지가 자동 포함됨" 한 줄 명시 + escape hatch 안내
- [x] §5 출력 예시에 `🔄 동기화 상태` 섹션 추가 + "자동 정리 금지" 명시

### 4-2. `sources/governance/align.md` 동기 갱신
- [x] §2 갱신 (drift 자동 포함)
- [x] §5 출력 예시 갱신 + "자동 정리 금지" 명시

### 4-3. Commit
- [x] Commit: `docs(spec-x-hk-align-drift-detect): document drift section in hk-align and align governance` (c677aca)

---

## Task 5: 도그푸딩 — 설치본 동기화

### 5-1. `.harness-kit/bin/sdd`, `.harness-kit/agent/align.md`, `.claude/commands/hk-align.md` 갱신
- [x] sources → 설치 위치 직접 복사 (3 파일)
- [x] 본 프로젝트에서 `bash .harness-kit/bin/sdd status` 실행 → drift 섹션 정상 출력 (워킹트리 6 변경 / install 부산물 1)
- [x] 출력 결과를 walkthrough 에 캡처 예정
- [x] Commit: `chore(spec-x-hk-align-drift-detect): sync installed kit to sources` (caacacc)

---

## Task 6: Ship (walkthrough + pr_description)

- [x] 전체 테스트 재실행 → 모두 PASS (drift 6/6, regression 5/5 + 18/18 + 6/6)
- [x] **walkthrough.md 작성**: 결정 기록 + 4 카테고리 구현 + 도그푸딩 결과 캡처 + 발견 사항
- [x] **pr_description.md 작성**: 본 spec 의 의도 (multi-device drift 자동 감지) + Key Review Points
- [ ] **Ship Commit**: `docs(spec-x-hk-align-drift-detect): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-hk-align-drift-detect`
- [ ] **PR 생성**: `gh pr create` 자동 진행 (auto-ship 메모리 §)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 5 (test red → feat green → docs → chore install → ship) |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-05-01 |
