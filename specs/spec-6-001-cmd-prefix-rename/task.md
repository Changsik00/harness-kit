# Task List: spec-6-001

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 커맨드 파일명 변경

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-6-001-cmd-prefix-rename`

### 1-2. sources/commands/ 파일명 변경
- [x] 9개 파일 모두 `hk-` prefix 추가
- [x] Commit: `refactor(spec-6-001): rename slash commands with hk- prefix`

### 1-3. .claude/commands/ 도그푸딩 반영
- [x] 기존 파일 삭제 + `hk-` prefix 파일로 교체
- [x] Commit: `chore(spec-6-001): update dogfooding commands with hk- prefix`

---

## Task 2: 거버넌스 참조 갱신

### 2-1. sources/governance/ 참조 갱신
- [x] `align.md`, `constitution.md`, `agent.md` 내 커맨드 참조 변경
- [x] Commit: `docs(spec-6-001): update governance command references to hk- prefix`

### 2-2. agent/ 도그푸딩 참조 갱신
- [x] `align.md`, `constitution.md`, `agent.md` 내 커맨드 참조 변경
- [x] Commit: `docs(spec-6-001): update dogfooding governance references to hk- prefix`

### 2-3. fragments, install.sh, CLAUDE.md 참조 갱신
- [x] `sources/claude-fragments/CLAUDE.md.fragment` 내 참조 변경
- [x] `install.sh` 내 참조 변경
- [x] `CLAUDE.md` 내 참조 변경
- [x] Commit: `docs(spec-6-001): update remaining command references to hk- prefix`

### 2-4. 검증
- [x] `sources/commands/` 에 `hk-` 없는 파일 없는지 확인
- [x] 구 이름 참조가 남아있지 않은지 grep 확인

---

## Task 3: Hand-off

- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] **Archive Commit**: `docs(spec-6-001): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-6-001-cmd-prefix-rename`
- [x] **사용자 알림**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
