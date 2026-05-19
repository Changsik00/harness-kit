# Task List: spec-x-sdd-bugfix

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — `sdd plan accept` 시 자동 갱신
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-x-sdd-bugfix`
- [ ] Commit: 없음

---

## Task 2: 스펙 산출물 등록

- [ ] spec.md / plan.md / task.md / walkthrough.md + backlog/queue.md staging
- [ ] Commit: `docs(spec-x-sdd-bugfix): add spec/plan/task`

---

## Task 3: Bug 1 — `specx_new()` Branch 중복 수정

### 3-1. `sources/bin/sdd` 수정
- [ ] `specx_new()` sed 패턴에 `{seq}-{slug}` 선행 치환 추가
- [ ] 수동 검증: `sdd specx new test-slug` → Branch = `spec-x-test-slug` 확인 후 디렉토리 삭제
- [ ] Commit: `fix(spec-x-sdd-bugfix): fix Branch field duplicate in sdd specx new`

### 3-2. `.harness-kit/bin/sdd` 동기화
- [ ] 동일 변경 적용
- [ ] Commit: `fix(spec-x-sdd-bugfix): sync .harness-kit/bin/sdd specx_new fix`

---

## Task 4: Bug 2 — 테스트 glob 불일치 수정

### 4-1. `tests/test-uninstall-cmd-list.sh` 수정
- [ ] Scenario 1 glob `hk-*.md` → `*.md`
- [ ] `bash tests/test-uninstall-cmd-list.sh` → ALL PASS
- [ ] Commit: `fix(spec-x-sdd-bugfix): fix hk-*.md glob in test-uninstall-cmd-list`

---

## Task 5: 회귀 테스트

- [ ] `bash tests/test-install-claude-import.sh` → ALL PASS
- [ ] `bash tests/test-marker-append-guard.sh` → ALL PASS
- [ ] `bash tests/test-marker-edge-cases.sh` → ALL PASS
- [ ] `bash .harness-kit/bin/sdd test passed`
- [ ] Commit: 없음

---

## Task 6: Ship

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-sdd-bugfix): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-sdd-bugfix`
- [ ] **PR 생성**: `gh pr create` 자동
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 (Pre-flight 제외) |
| **예상 commit 수** | 5 (Task 2 + 3-1 + 3-2 + 4-1 + Ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-19 |
