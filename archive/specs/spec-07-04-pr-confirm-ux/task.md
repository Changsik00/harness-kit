# Task List: spec-07-04

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec 디렉토리 생성: `specs/spec-07-04-pr-confirm-ux/`
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + hk-gh-pr.md PR 확인 블록 추가

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-07-04-pr-confirm-ux`

### 1-2. hk-gh-pr.md 수정
- [ ] `sources/commands/hk-gh-pr.md` — §4에 PR 확인 블록 + Y/n + `--no-confirm` 추가
- [ ] `.claude/commands/hk-gh-pr.md` — 동일 반영
- [ ] Commit: `refactor(spec-07-04): add pr confirm block to hk-gh-pr`

---

## Task 2: hk-handoff.md Push 확인 블록 표준화

- [ ] `sources/commands/hk-handoff.md` — §4 Push 확인 절차를 고정 블록으로 교체
- [ ] `.claude/commands/hk-handoff.md` — 동일 반영
- [ ] Commit: `refactor(spec-07-04): standardize push confirm block in hk-handoff`

---

## Task 3: hk-bb-pr.md 확인 블록 추가

- [ ] `sources/commands/hk-bb-pr.md` — 동일 확인 블록 형식 적용
- [ ] `.claude/commands/hk-bb-pr.md` — 동일 반영
- [ ] Commit: `refactor(spec-07-04): add pr confirm block to hk-bb-pr`

---

## Task 4: hk-spec-critique.md 긍정/거부 규칙 추가

- [ ] `sources/commands/hk-spec-critique.md` — 반영 항목 선택 프롬프트에 긍정/거부 규칙 명시
- [ ] `.claude/commands/hk-spec-critique.md` — 동일 반영
- [ ] Commit: `refactor(spec-07-04): add affirmative/reject rules to hk-spec-critique prompt`

---

## Task 5: Hand-off

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-07-04): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-07-04-pr-confirm-ux`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 확인 [Y/n]

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (+ Hand-off) |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
