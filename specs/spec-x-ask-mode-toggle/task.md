# Task List: spec-x-ask-mode-toggle

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new ask-mode-toggle`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-ask-mode-toggle` (main 에서 분기)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: SDD 산출물 commit

> spec.md / plan.md / task.md 는 Plan Accept 전 working tree 에 작성되어 있음.
> 브랜치 생성 후 첫 commit 으로 묶음.

### 2-1. SDD 산출물 commit
- [x] `git add specs/spec-x-ask-mode-toggle/spec.md specs/spec-x-ask-mode-toggle/plan.md specs/spec-x-ask-mode-toggle/task.md`
- [x] Commit: `docs(spec-x-ask-mode-toggle): add spec/plan/task`

---

## Task 3: `sdd config ux-mode toggle` 액션 추가 (TDD)

### 3-1. 실패 테스트 작성 (TDD Red)
- [x] `tests/test-sdd-config.sh` 에 T5/T6 추가 (toggle 시나리오 + error 메시지)
- [x] `bash tests/test-sdd-config.sh` 실행 → T5/T6 FAIL 확인
- [x] Commit: `test(spec-x-ask-mode-toggle): add failing test for ux-mode toggle action`

### 3-2. CLI 구현 (TDD Green)
- [x] `sources/bin/sdd` 의 `_config_ux_mode` 에 `toggle` 분기 추가
- [x] `sources/bin/sdd` 의 도움말 (line ~54) `[interactive|text]` → `[interactive|text|toggle]`
- [x] `.harness-kit/bin/sdd` 동기화 (도그푸딩)
- [x] `bash tests/test-sdd-config.sh` 실행 → 전체 PASS 확인 (7/7)
- [x] Commit: `feat(spec-x-ask-mode-toggle): add toggle action to sdd config ux-mode`

---

## Task 4: `/hk-ask-mode` 슬래시 커맨드 추가

### 4-1. sources/commands 추가
- [x] `sources/commands/hk-ask-mode.md` 작성 (description + 단일 bash 호출)
- [x] `.claude/commands/hk-ask-mode.md` 동일 복사 (도그푸딩)
- [x] `.harness-kit/installed.json` 의 `installedCommands` 배열에 `"hk-ask-mode"` 추가 (알파벳 순서)
- [x] Commit: `feat(spec-x-ask-mode-toggle): add /hk-ask-mode slash command`

---

## Task 5: 거버넌스 문서 동기화

### 5-1. agent.md §8.4 갱신
- [x] `sources/governance/agent.md` §8.4 의 변경 방법 안내 갱신
- [x] `.harness-kit/agent/agent.md` 동일 갱신 (sources↔installed 정합성)
- [-] `bash tests/test-governance-dedup.sh` PASS 확인 — Pre-existing FAIL (단어 수 초과 6415→6418w, main 부터 초과 상태). 본 spec 원인 아님 → Icebox 등록.
- [x] Commit: `docs(spec-x-ask-mode-toggle): document toggle action and /hk-ask-mode in agent.md §8.4`

---

## Task 6: 부수 발견 — Icebox 등록

### 6-1. 부수 발견 3 건 Icebox 등록
- [x] `backlog/queue.md` Icebox 섹션에 3 건 추가:
  - `sdd specx new` 의 spec.md Branch 필드 slug 중복 버그
  - `tests/test-uninstall-cmd-list.sh` Scenario 1 pre-existing FAIL (glob 패턴 불일치)
  - 거버넌스 단어 수 한계 초과 (6418w > 6000w)
- [x] Commit: `chore(spec-x-ask-mode-toggle): record findings in icebox (...)`

---

## Task 7: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차 수행.

- [x] 전체 회귀 테스트 실행
  - [x] `bash tests/test-sdd-config.sh` — 7 PASS
  - [-] `bash tests/test-install-manifest-sync.sh` — PASS (영향 없음 확인)
  - [-] `bash tests/test-uninstall-cmd-list.sh` — Scenario 1 pre-existing FAIL (Icebox 등록)
  - [-] `bash tests/test-governance-dedup.sh` — 단어 수 한계 pre-existing FAIL (Icebox 등록)
- [x] `bash .harness-kit/bin/sdd test passed` (테스트 통과 기록)
- [x] **walkthrough.md 작성** (예상 못한 발견 + 결정 이유 + Icebox 기록)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Ship Commit**: `docs(spec-x-ask-mode-toggle): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-x-ask-mode-toggle`
- [x] **PR 생성**: https://github.com/Changsik00/harness-kit/pull/132
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight 별도) |
| **예상 commit 수** | 6 (Task 1 은 브랜치만, Task 2~6 = 5 commits, Task 7 ship = 1 commit) |
| **현재 단계** | Ship 완료 (PR #132 머지 대기) |
| **마지막 업데이트** | 2026-05-17 |
