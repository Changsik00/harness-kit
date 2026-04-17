# Task List: spec-10-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase.md SPEC 표 자동 갱신 완료)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + 테스트 작성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-10-02-status-cross-check` (base: `phase-10-status-reliability`)
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [x] 테스트 파일 생성: `tests/test-sdd-status-cross-check.sh`
  - 시나리오 1: 브랜치 패턴 → work mode 추론 (`spec-N-seq-*` → SDD-P, `phase-N-*` → phase base, `spec-x-*` → SDD-x, `main` → 대기)
  - 시나리오 2: phase.md Done + git 머지됨 → `⚠` 경고 + 행동 제안 출력
  - 시나리오 3: state.json `spec=null` + `phase=active` → 안내 메시지
  - 시나리오 4: `planAccepted=true` + plan.md 없음 → 경고
- [x] 테스트 실행 → Fail 확인 (PASS=1, FAIL=6)
- [x] Commit: `test(spec-10-02): add failing tests for status self-diagnosis`

---

## Task 2: 브랜치 패턴 해석 구현

### 2-1. `_infer_work_mode` 함수 구현
- [x] `sources/bin/sdd`에 `_infer_work_mode()` 함수 추가
  - 브랜치명 regex 매칭 → work mode 문자열 반환
- [x] `cmd_status()`의 Branch 출력 라인에 work mode 표시 추가
- [x] 테스트 실행 → 시나리오 1 Pass 확인 (4/4 PASS)
- [x] Commit: `feat(spec-10-02): add branch pattern work mode inference`

---

## Task 3: phase.md ↔ git 교차 검증 + state.json 정합성

### 3-1. `_status_diagnose` 함수 구현
- [x] `sources/bin/sdd`에 `_status_diagnose()` 함수 추가
  - phase.md non-Merged spec 추출 → git log 대조 → 불일치 경고 + 행동 제안
  - state.json 정합성 검사 (spec=null+phase, planAccepted+no plan)
- [x] `cmd_status()`에서 기본 출력 후 `_status_diagnose` 호출
- [x] `--brief`, `--json` 에서는 호출 생략 (early return으로 진단 도달 안 함)
- [x] 테스트 실행 → 전체 7/7 PASS
- [x] Commit: `feat(spec-10-02): add status cross-check diagnostics`

---

## Task 4: 도그푸딩 동기화

### 4-1. .harness-kit/bin/sdd 동기화
- [x] `sources/bin/sdd` → `.harness-kit/bin/sdd` 복사
- [x] `sdd status` 실행으로 동작 확인 — work mode `(SDD-P (phase-10))` 표시 정상
- [x] 전체 회귀 테스트 15개 파일 전부 PASS
- [x] Commit: `chore(spec-10-02): sync sdd to .harness-kit`

---

## Task 5: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 실행 → 15개 파일 전부 PASS
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-10-02): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-10-02-status-cross-check`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 6 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
