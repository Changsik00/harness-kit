# Task List: spec-12-01

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-12.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-12-01-staged-lint`
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: 테스트 작성 (TDD Red)

- [ ] `tests/test-staged-lint.sh` 작성
  - Check 1: staged 파일 없음 → silent skip (exit 0)
  - Check 2: 타입 미감지 → skip
  - Check 3: Node.js 타입 + eslint 없음 → 경고 후 exit 0
  - Check 4: Shell 타입 + shellcheck 있음 → shellcheck 실행
  - Check 5: Shell 타입 + shellcheck 없음 → 경고 후 exit 0
- [ ] 테스트 실행 → FAIL 확인
- [ ] Commit: `test(spec-12-01): add failing tests for check-staged-lint hook`

---

## Task 3: 구현 (TDD Green)

- [ ] `sources/hooks/check-staged-lint.sh` 작성
  - `_lib.sh` source
  - staged 파일 추출
  - 프로젝트 타입 감지
  - linter 실행 (경고 모드)
- [ ] 테스트 실행 → PASS 확인
- [ ] Commit: `feat(spec-12-01): add check-staged-lint hook`

---

## Task 4: install.sh 연동

- [ ] `install.sh` hooks 배포 목록에 `check-staged-lint.sh` 추가
- [ ] `tests/test-install-layout.sh` 또는 관련 테스트 확인
- [ ] 전체 테스트 실행 → PASS
- [ ] Commit: `feat(spec-12-01): wire check-staged-lint into install.sh`

---

## Task 5: Ship

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-12-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-12-01-staged-lint`
- [ ] **PR 생성** (사용자 승인 후)
- [ ] **사용자 알림**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-20 |
