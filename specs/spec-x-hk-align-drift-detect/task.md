# Task List: spec-x-hk-align-drift-detect

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-hk-align-drift-detect`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: drift 감지 테스트 추가 (TDD Red)

### 2-1. 테스트 fixture 준비 + 5 시나리오 테스트 작성
- [ ] 신규: `tests/test-sdd-drift.sh`
  - T1: 깨끗한 상태 → "🔄 동기화 상태: 깔끔"
  - T2: behind=1 시뮬레이션 → "원격: behind 1 / ahead 0"
  - T3: specs/ 미커밋 → "워킹트리: ... spec drift"
  - T4: queue active phase 의 모든 spec Merged → "phase done 미실행 의심"
  - T5: `--no-drift` → 동기화 섹션 미출력
- [ ] `bash tests/test-sdd-drift.sh` 실행 → 5/5 Fail (구현 전이라 정상)
- [ ] Commit: `test(spec-x-hk-align-drift-detect): add failing tests for sdd status drift section`

---

## Task 3: drift 감지 구현 — 4 카테고리 함수 (TDD Green)

### 3-1. `sources/bin/sdd` 에 drift_check 및 4 서브 함수 추가
- [ ] `drift_remote()` — git fetch + behind/ahead
- [ ] `drift_worktree()` — git status --porcelain 분류
- [ ] `drift_consistency()` — queue.md vs phase-N.md 정합성
- [ ] `drift_install()` — sources vs .harness-kit untracked diff
- [ ] `drift_check()` — 4 함수 호출 + 깔끔/상세 분기
- [ ] `cmd_status()` 에 `--no-drift` 옵션 추가 + drift_check 호출
- [ ] cmd_help 의 status 항목에 `--no-drift` 설명 추가
- [ ] `bash tests/test-sdd-drift.sh` 실행 → 5/5 Pass
- [ ] 회귀 테스트:
  - `bash tests/test-sdd-spec-new-seq.sh` Pass
  - `bash tests/test-fixture-lib.sh` Pass
  - `bash tests/test-install-manifest-sync.sh` Pass
- [ ] Commit: `feat(spec-x-hk-align-drift-detect): add drift section to sdd status`

---

## Task 4: hk-align 슬래시 커맨드 + 거버넌스 동기화

### 4-1. `sources/commands/hk-align.md` 의 §5 (상태 요약 보고) 출력 형식에 동기화 섹션 추가
- [ ] §2 (컨텍스트 점검) 에 "drift 감지가 자동 포함됨" 한 줄 명시
- [ ] §5 출력 예시에 `🔄 동기화 상태` 섹션 추가

### 4-2. `sources/governance/align.md` 동기 갱신
- [ ] §2 갱신 (drift 자동 포함)
- [ ] §5 출력 예시 갱신

### 4-3. Commit
- [ ] Commit: `docs(spec-x-hk-align-drift-detect): document drift section in hk-align and align governance`

---

## Task 5: 도그푸딩 — 설치본 동기화

### 5-1. `.harness-kit/bin/sdd` 와 `.claude/commands/hk-align.md` 갱신
- [ ] `install.sh` 또는 직접 복사로 sources → .harness-kit / .claude 반영
- [ ] 본 프로젝트에서 `bash .harness-kit/bin/sdd status` 실행 → drift 섹션 출력 확인
- [ ] 출력 결과를 walkthrough 에 캡처
- [ ] Commit: `chore(spec-x-hk-align-drift-detect): sync installed kit to sources`

---

## Task 6: Ship (walkthrough + pr_description)

- [ ] 전체 테스트 재실행 → 모두 PASS
- [ ] **walkthrough.md 작성**: 결정 기록 + 4 카테고리 구현 + 도그푸딩 결과 캡처 + 발견 사항
- [ ] **pr_description.md 작성**: 본 spec 의 의도 (multi-device drift 자동 감지) + Before/After 출력 비교
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
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-30 |
