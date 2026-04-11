# Task List: spec-7-002

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec 디렉토리 생성: `specs/spec-7-002-spec-critique-workflow/`
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + hk-spec-critique 커맨드 작성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-7-002-spec-critique-workflow`

### 1-2. 커맨드 파일 작성
- [ ] `sources/commands/hk-spec-critique.md` 신설
- [ ] Commit: `feat(spec-7-002): add hk-spec-critique slash command`

---

## Task 2: agent.md §4.5 critique 단계 추가

- [ ] `sources/governance/agent.md` — §4.5 추가
- [ ] `agent/agent.md` — 동일 반영
- [ ] Commit: `refactor(spec-7-002): add optional critique step to SDD workflow`

---

## Task 3: spec 템플릿 Critique 섹션 추가

- [ ] `sources/templates/spec.md` — `## 🔍 Critique 결과` 섹션 추가
- [ ] `agent/templates/spec.md` — 동일 반영
- [ ] Commit: `refactor(spec-7-002): add critique section to spec template`

---

## Task 4: Hand-off

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-7-002): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-7-002-spec-critique-workflow`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 확인 [Y/n]

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (+ Hand-off) |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
