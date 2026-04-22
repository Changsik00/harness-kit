# Task List: spec-13-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-13.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-13-01-onboarding-doctor`
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: 테스트 작성 (TDD Red)

### 2-1. test-hk-doctor.sh 작성
- [x] `tests/test-hk-doctor.sh` 작성 — 4가지 시나리오:
  - `sdd doctor` 실행 시 체크리스트 출력 확인 (PASS/WARN/FAIL 문자열 포함)
  - `sources/commands/hk-doctor.md` 파일 존재 + description frontmatter 확인
  - `sdd doctor` 종료 코드 0 확인
  - `sdd help` 출력에 `doctor` 항목 포함 확인
- [x] 테스트 실행 → 4개 항목 FAIL 확인
- [x] Commit: `test(spec-13-01): add failing tests for sdd doctor command`

---

## Task 3: sdd doctor 서브커맨드 구현

### 3-1. sources/bin/sdd에 doctor 구현
- [x] `cmd_doctor()` 함수 추가 — 체크 항목: bash 버전, jq, git, gh(WARN), installed.json, constitution.md, hooks 실행권한, .claude/settings.json
- [x] `case` 분기에 `doctor)` 추가
- [x] `cmd_help()` 에 `doctor` 항목 추가
- [x] 테스트 실행 → PASS 확인
- [ ] Commit: `feat(spec-13-01): add sdd doctor subcommand`

---

## Task 4: hk-doctor 슬래시 커맨드 추가

### 4-1. sources/commands/hk-doctor.md 작성
- [x] `sources/commands/hk-doctor.md` 작성 — description frontmatter + `sdd doctor` 실행 지시
- [x] 테스트 실행 → 전체 PASS 확인
- [x] Commit: `feat(spec-13-01): add hk-doctor slash command`

---

## Task 5: Ship

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-13-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-13-01-onboarding-doctor`
- [ ] **PR 생성**: `/hk-pr-gh` 로 생성
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (+ Pre-flight + Ship) |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-22 |
