# Task List: spec-9-006

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (phase-9.md SPEC 표 갱신)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + 테스트 작성 (TDD Red)

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-9-006-gitignore-config`

### 1-2. 테스트 작성 (TDD Red)
- [ ] `tests/test-gitignore-config.sh` 작성 (7 checks)
- [ ] 테스트 실행 → FAIL 확인
- [ ] Commit: `test(spec-9-006): add failing tests for gitignore config option`

---

## Task 2: install.sh — gitignore 옵션 구현 (TDD Green)

### 2-1. install.sh 수정
- [ ] Section 1: `--gitignore` / `--no-gitignore` 플래그 파싱, `HK_GITIGNORE=-1` 초기값
- [ ] Section 5 이후: gitignore UX 질문 (ASSUME_YES=1이면 기본값 Y 자동 적용)
- [ ] Section 16: 조건부 `.gitignore` 처리 (Y → `.harness-kit/`, N → `!.harness-kit/`)
- [ ] Section 17: `harness.config.json`에 `"gitignore"` 필드 포함
- [ ] Usage 주석 업데이트

### 2-2. 테스트 실행 → PASS 확인
- [ ] `bash tests/test-gitignore-config.sh` → ALL PASS
- [ ] Commit: `feat(spec-9-006): add gitignore config option to install.sh`

---

## Task 3: update.sh — gitignore 설정 보존

### 3-1. update.sh 수정
- [ ] uninstall 전 `harness.config.json`에서 `gitignore` 필드 읽기
- [ ] install 호출 시 `--gitignore` / `--no-gitignore` 플래그 전달

### 3-2. 테스트 실행 → PASS 확인
- [ ] `bash tests/test-gitignore-config.sh` (E, F 시나리오) → PASS
- [ ] `bash tests/run-all.sh` → ALL PASS
- [ ] Commit: `feat(spec-9-006): preserve gitignore config through update.sh`

---

## Task 4: Ship

- [ ] `bash tests/run-all.sh` → ALL PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-9-006): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-9-006-gitignore-config`
- [ ] **PR 생성** (사용자 승인 후)
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 (테스트, install.sh, update.sh) + 1 (archive) |
| **현재 단계** | Execution |
| **마지막 업데이트** | 2026-04-15 |
