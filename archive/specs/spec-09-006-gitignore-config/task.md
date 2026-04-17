# Task List: spec-09-006

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-09.md SPEC 표 갱신)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + 테스트 작성 (TDD Red)

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-09-006-gitignore-config`

### 1-2. 테스트 작성 (TDD Red)
- [x] `tests/test-gitignore-config.sh` 작성 (11 checks)
- [x] 테스트 실행 → FAIL 확인
- [x] Commit: `test(spec-09-006): add failing tests for gitignore config option`

---

## Task 2: install.sh + update.sh 구현 (TDD Green)

### 2-1. install.sh + update.sh 수정
- [x] Section 1: `--gitignore` / `--no-gitignore` 플래그 파싱, `HK_GITIGNORE=-1` 초기값
- [x] Section 5b: gitignore UX 질문 (ASSUME_YES=1이면 기본값 Y 자동 적용)
- [x] Section 16: 조건부 `.gitignore` 처리 (Y → `.harness-kit/`, N → `!.harness-kit/`)
- [x] Section 17: `harness.config.json`에 `"gitignore"` 필드 포함
- [x] update.sh: `gitignore` 필드 읽어 `--gitignore`/`--no-gitignore` 전달
- [x] `test-install-layout.sh` Check 7 업데이트

### 2-2. 테스트 실행 → PASS 확인
- [x] `bash tests/test-gitignore-config.sh` → 11/11 ALL PASS
- [x] Commit: `feat(spec-09-006): add gitignore config option to install.sh and update.sh`

---

## Task 4: Ship

- [x] `bash tests/test-gitignore-config.sh` → 11/11 ALL PASS
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-006): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-006-gitignore-config`
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
