# Task List: spec-21-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-21.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 및 테스트 작성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-21-01-mode-schema`
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [ ] `tests/test-mode-schema.sh` 작성 — 5개 시나리오
- [ ] 테스트 실행 → Fail 확인 (cmd_mode 미구현)
- [ ] Commit: `test(spec-21-01): add failing tests for sdd mode subcommand`

---

## Task 2: sdd mode 서브커맨드 구현

### 2-1. `.harness-kit/bin/sdd` 변경
- [ ] `cmd_mode()` 함수 추가 (turbo / governed / status)
- [ ] `main()` dispatch 에 `mode)` 케이스 추가
- [ ] `cmd_status()` 에 `Active Mode` 행 추가

### 2-2. `sources/bin/sdd` 미러링
- [ ] 동일 변경 적용

### 2-3. 테스트 실행 → Pass 확인
- [ ] `bash tests/test-mode-schema.sh` PASS
- [ ] Commit: `feat(spec-21-01): add sdd mode subcommand and status display`

---

## Task 3: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** `bash tests/run.sh` → 모두 PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-21-01): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-21-01-mode-schema`
- [ ] **PR 생성**: `phase-21-turbo-mode` 를 base 로 PR 생성
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-06-12 |
