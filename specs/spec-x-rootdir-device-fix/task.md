# Task List: spec-x-rootdir-device-fix

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — spec-x 는 phase.md 불필요
- [x] 사용자 Plan Accept

---

## Task 1: `sdd_find_root()` rootDir 의존 제거 (TDD)

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-rootdir-device-fix`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [x] 테스트 케이스 작성: `tests/test-sdd-root-detection.sh`
- [x] 테스트 실행 → Fail 확인 (A-2: `harness-kit ?` 출력)
- [x] Commit: `test(spec-x-rootdir-device-fix): add failing test for filesystem-anchored root detection`

### 1-3. 구현 (TDD Green)
- [x] 수정: `sources/bin/lib/common.sh` — `sdd_find_root()` 파일시스템 앵커링으로 교체
- [x] 수정: `.harness-kit/bin/lib/common.sh` — 도그푸딩 반영
- [x] 테스트 실행 → Pass 확인: ALL PASS (4/4)
- [x] Commit: `fix(spec-x-rootdir-device-fix): replace rootDir-based root detection with filesystem anchoring`

---

## Task 2: `install.sh` rootDir 기록 제거 + 테스트 수정

### 2-1. `install.sh` 수정
- [x] `install.sh`: `harness.config.json` 출력에서 `rootDir` 필드 제거 (2개 printf)
- [x] 수정: `tests/test-path-config.sh` — `rootDir` 부재 검증으로 변경
- [x] 테스트 실행: ALL PASS (10/10)
- [x] Commit: `fix(spec-x-rootdir-device-fix): remove rootDir from harness.config.json output`

---

## Task 3: check-branch.sh 주석 섹션 번호 오류 수정 (번들)

### 3-1. 주석 수정
- [x] 수정: `sources/hooks/check-branch.sh` `§9.1` → `§10.1`
- [x] 수정: `.harness-kit/hooks/check-branch.sh` 도그푸딩 반영
- [x] `.harness-kit/bin/sdd` spec-18-01 이후 누락 sync
- [x] 테스트: ALL PASS (12/12)
- [x] Commit: `fix(spec-x-rootdir-device-fix): correct constitution section reference in check-branch.sh`

---

## Task 4: Ship (필수)

- [x] 전체 테스트 실행 → PASS (4/4, 10/10, 12/12)
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-rootdir-device-fix): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-rootdir-device-fix`
- [ ] **PR 생성**: `/hk-pr-gh` 실행
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (Task 1~3 + Ship) |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-19 |
