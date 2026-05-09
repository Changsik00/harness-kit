# Task List: spec-x-wording-cleanup

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.
> docs-only 변경이므로 TDD 단계 없음.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — Solo Spec, phase.md 불필요
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-x-wording-cleanup`
- Commit: 없음 (브랜치 생성만)

---

## Task 2: PR 커맨드 + Handoff 워딩 정리

대상: `hk-gh-pr`, `hk-bb-pr`, `hk-handoff` (sources + .claude/commands 쌍)

- [ ] `hk-gh-pr`: 긍정/거부 예시 목록 → constitution §4.2 참조, `본 명령은` → `이 명령은`
- [ ] `hk-bb-pr`: 동일
- [ ] `hk-handoff`: §5-A awk 코드 블록 제거, §4 긍정/거부 → constitution 참조
- [ ] sources 와 .claude/commands 내용 일치 확인
- [ ] Commit: `docs(spec-x-wording-cleanup): simplify confirm rules and remove awk duplication`

---

## Task 3: Plan Accept Strict Loop 축약

대상: `hk-plan-accept` (sources + .claude/commands 쌍)

- [ ] §3 Strict Loop 8단계 → agent.md §6.1 참조 한 줄로 대체
- [ ] sources 와 .claude/commands 내용 일치 확인
- [ ] Commit: `docs(spec-x-wording-cleanup): replace strict loop steps with agent.md reference`

---

## Task 4: Code Review 서브에이전트 model 추가

대상: `hk-code-review` (sources + .claude/commands 쌍)

- [ ] `sub-agent 에게` → `서브에이전트에게`
- [ ] Agent tool 호출에 `model: "opus"` 추가
- [ ] sources 와 .claude/commands 내용 일치 확인
- [ ] Commit: `docs(spec-x-wording-cleanup): add opus model to code-review sub-agent`

---

## Task 5: Spec New 인자 누락 처리 추가

대상: `hk-spec-new` (sources + .claude/commands 쌍)

- [ ] §1 사전 점검에 `$1` 없을 때 처리 추가
- [ ] sources 와 .claude/commands 내용 일치 확인
- [ ] Commit: `docs(spec-x-wording-cleanup): add missing slug argument guard to hk-spec-new`

---

## Task 6: 언어 혼용 일괄 정리

대상: `hk-spec-critique`, `hk-spec-status`, `hk-align`, `hk-plan-accept` (sources + .claude/commands 쌍)

- [ ] `active spec` → `활성 spec`, `active phase` → `활성 phase`
- [ ] `Test Fail` / `Test Pass` → `테스트 실패` / `테스트 통과` (hk-plan-accept)
- [ ] sources 와 .claude/commands 내용 일치 확인
- [ ] Commit: `docs(spec-x-wording-cleanup): unify korean/english mixed expressions`

---

## Task 7: Constitution §4.2 제목 변경

대상: `sources/governance/constitution.md` + `agent/constitution.md`

- [ ] `### 4.2 Plan Rules` → `### 4.2 Plan Accept & Critique 인식`
- [ ] sources 와 agent 내용 일치 확인
- [ ] Commit: `docs(spec-x-wording-cleanup): clarify constitution section 4.2 title`

---

## Task 8: Hand-off

- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-x-wording-cleanup): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-wording-cleanup`
- [ ] **사용자 알림**: push 완료, `/hk-gh-pr` 로 PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (브랜치 + 6개 수정 + hand-off) |
| **예상 commit 수** | 7 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
