# Task List: spec-x-fix-archive-test-expectation

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new fix-archive-test-expectation`)
- [x] spec.md 작성 (P1+P2+P3 범위 반영)
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (spec-x 는 phase.md 불필요, queue.md specx 섹션 자동 등록됨)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 분리 및 main 정상화

### 1-1. 브랜치 생성 (현재 HEAD 그대로) + main 리셋
- [ ] `git switch -c spec-x-fix-archive-test-expectation` — 현재 main HEAD (`f601417`) 그대로 브랜치 생성. 두 원 커밋 (`120d0f2`, `f601417`) 은 브랜치에 보존됨.
- [ ] `git branch -f main origin/main` — 로컬 main 포인터를 origin/main 으로 리셋 (destructive, Plan Accept 시 승인됨).
- [ ] 검증: `git log origin/main..HEAD --oneline` → 2 commits.
- [ ] 검증: `git log main..origin/main --oneline` → 출력 없음.
- [ ] Commit: 없음 (레퍼런스 조작만)

---

## Task 2: P1 — Check 4 기대값 복원

### 2-1. 테스트 수정
- [ ] `tests/test-sdd-dir-archive.sh` Check 4 블록의 기대값을 "spec-x 디렉토리는 아카이브되지 않음" 으로 되돌림.
- [ ] `bash tests/test-sdd-dir-archive.sh` → 10/10 PASS 확인.
- [ ] Commit: `fix(spec-x-fix-archive-test-expectation): restore check 4 expectation to match pr #65 design`

---

## Task 3: P2 — 활성 .md ID placeholder 소문자 통일

### 3-1. align.md × 2 + hk-plan-accept.md × 2 수정
- [ ] `.harness-kit/agent/align.md` Line 43-44 소문자화.
- [ ] `sources/governance/align.md` Line 43-44 소문자화.
- [ ] `.claude/commands/hk-plan-accept.md` Line 36 소문자화 + placeholder `{NN}` → `{seq}`.
- [ ] `sources/commands/hk-plan-accept.md` Line 36 동일 수정.
- [ ] Commit: `docs(spec-x-fix-archive-test-expectation): align active md placeholders with constitution §6.2 lowercase format`

---

## Task 4: P3 — `sdd specx done` 회귀 테스트 추가

### 4-1. 테스트 확장
- [ ] `tests/test-sdd-ship-completion.sh` 에 Check 6b (prefix 포함 호출) 추가.
- [ ] `tests/test-sdd-ship-completion.sh` 에 Check 6c (state 리셋) 추가.
- [ ] `bash tests/test-sdd-ship-completion.sh` → 새 체크 포함 전체 PASS 확인.
- [ ] Commit: `test(spec-x-fix-archive-test-expectation): add specx done regression tests for prefix normalization and state reset`

---

## Task 5: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 코드 품질 점검: N/A (bash 테스트/문서 수정만)
- [ ] 전체 테스트 실행 → 19/19 PASS
- [ ] **walkthrough.md 작성** (증거 로그: 감사 경로, 세 문제 각각 진단과 해결)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-fix-archive-test-expectation): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-fix-archive-test-expectation`
- [ ] **PR 생성**: `/hk-pr-gh` 또는 `gh pr create` (auto-ship, 추가 확인 없이)
- [ ] **사용자 알림**: 푸시 완료 (현재 브랜치명 명시) + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (Pre-flight 제외) |
| **예상 commit 수** | 4 (fix + docs + test + ship docs) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-21 |
