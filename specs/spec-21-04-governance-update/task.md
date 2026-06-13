# Task List: spec-21-04

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (phase-21.md SPEC 표 상태 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: TDD Red — 테스트 작성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-21-04-governance-update` from `phase-21-turbo-mode`

### 1-2. 테스트 작성 (TDD Red)
- [ ] `tests/test-governance-update.sh` 작성 (6 케이스)
  - T01: constitution.md 에 "Mode D" 포함
  - T02: constitution.md 에 "sdd mode turbo" 포함
  - T03: agent.md 에 "Turbo" 행 포함
  - T04: .claude/commands/hk-turbo.md 존재
  - T05: sources/governance/constitution.md 에 Mode D 포함
  - T06: sources/commands/hk-turbo.md 존재
- [ ] 테스트 실행 → Fail 확인 (RED)
- [ ] Commit: `test(spec-21-04): add failing tests for governance update`

---

## Task 2: 거버넌스 문서 업데이트

### 2-1. 구현
- [ ] `.harness-kit/agent/constitution.md` — §2.5 Mode D + §2.4 Step 0 추가
- [ ] `.harness-kit/agent/agent.md` — §3.1 Turbo 행 추가
- [ ] `sources/governance/constitution.md` — 동일 변경 미러링
- [ ] `sources/governance/agent.md` — 동일 변경 미러링
- [ ] 테스트 실행 → T01~T03/T05 PASS 확인
- [ ] Commit: `docs(spec-21-04): add turbo mode to constitution and agent behavior table`

---

## Task 3: /hk-turbo 슬래시 커맨드

### 3-1. 구현
- [ ] `.claude/commands/hk-turbo.md` 신규 작성
- [ ] `sources/commands/hk-turbo.md` 동일 내용 미러링
- [ ] 테스트 실행 → T04/T06 PASS, 전체 6개 PASS 확인
- [ ] Commit: `feat(spec-21-04): add /hk-turbo slash command`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] `bash tests/test-governance-update.sh` → 6/6 PASS
- [ ] 회귀: `bash tests/test-turbo-hooks.sh` → 8/8 PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-21-04): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-21-04-governance-update`
- [ ] **PR 생성**: `gh pr create --base phase-21-turbo-mode`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 (test + docs + feat + docs-ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-06-13 |
