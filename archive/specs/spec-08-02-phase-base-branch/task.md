# Task List: spec-08-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`specs/spec-08-02-phase-base-branch/`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (`backlog/phase-08.md` spec 표 — In Progress 마킹)
- [ ] 사용자 Plan Accept

---

## Task 1: sdd 단위 테스트 작성 (TDD Red)

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-08-02-phase-base-branch phase-08-work-model`
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성
- [ ] `tests/test-sdd-base-branch.sh` 신규 작성 (4종 케이스)
  - Check 1: `sdd phase new slug --base` → state.json baseBranch = "phase-N-slug"
  - Check 2: `sdd phase new slug` (no flag) → baseBranch = null
  - Check 3: `sdd status --json` → baseBranch 키 포함
  - Check 4: `sdd phase done` → baseBranch = null
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-08-02): add failing tests for sdd phase base branch support`

---

## Task 2: sdd 구현 — phase_new --base 플래그 + state.json baseBranch

### 2-1. 구현 (TDD Green)
- [ ] `scripts/harness/bin/sdd` — `phase_new()` 에 `--base` 플래그 파싱 추가
- [ ] `phase_new()` — `baseBranch` 값 계산 + `state_set baseBranch` 호출
- [ ] `phase_new()` — `phase.md` 메타 `Base Branch` 필드에 브랜치명 기재
- [ ] `phase_done()` — `state_set baseBranch "null"` 추가
- [ ] `cmd_status()` — `--json` 출력에 `baseBranch` 키 추가
- [ ] 테스트 실행 → 4/4 Pass 확인
- [ ] Commit: `feat(spec-08-02): add --base flag to sdd phase new and baseBranch to status json`

### 2-2. sources/ 동기화
- [ ] `sources/bin/sdd` — `scripts/harness/bin/sdd` 와 동일 변경 반영
- [ ] Commit: `chore(spec-08-02): sync sources/bin/sdd with harness implementation`

---

## Task 3: hk-ship.md Step 4 — phase base branch 감지 명세 추가

### 3-1. hk-ship.md 수정
- [ ] `sources/commands/hk-ship.md` Step 4 수정:
  - `sdd status --json | jq -r '.baseBranch'` 로 baseBranch 읽기
  - baseBranch != null 이면: `git ls-remote --exit-code origin {baseBranch}` 확인
  - 없으면: `git checkout -b {baseBranch} main && git push -u origin {baseBranch} && git checkout -`
  - 확인 블록 타깃을 baseBranch 로 표시
  - PR 생성 시 `--base {baseBranch}` 적용
- [ ] Commit: `feat(spec-08-02): add phase base branch jit creation spec to hk-ship step 4`

---

## Task 4: Hand-off (필수)

- [ ] 전체 테스트 실행 (`bash tests/test-sdd-base-branch.sh`) → 4/4 PASS
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-08-02): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-08-02-phase-base-branch`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 요청 (PR 타깃: `phase-08-work-model`)

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
