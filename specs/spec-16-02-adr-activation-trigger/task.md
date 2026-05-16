# Task List: spec-16-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (해당 phase 의 phase.md SPEC 표 갱신) — `sdd spec new` 가 처리
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + 기획 산출물 commit

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-16-02-adr-activation-trigger`
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 기획 산출물 commit (planning artifacts)
- [ ] `git add backlog/phase-16.md backlog/queue.md specs/spec-16-02-adr-activation-trigger/`
- [ ] Commit: `chore(spec-16-02): add planning artifacts (spec/plan/task)`

---

## Task 2: ADR 템플릿 신설

### 2-1. sources 템플릿 작성
- [ ] `sources/templates/adr.md` 신규 작성 — frontmatter (`name` / `description` / `metadata.type`) + 본문 5 섹션 (Context / Decision / Consequences / Alternatives / Status)
- [ ] Commit: `feat(spec-16-02): add adr template under sources`

### 2-2. install 미러 동기화
- [ ] `.harness-kit/agent/templates/adr.md` 를 sources 와 동일하게 생성 (`cp sources/templates/adr.md .harness-kit/agent/templates/adr.md`)
- [ ] `diff sources/templates/adr.md .harness-kit/agent/templates/adr.md` → 차이 없음 확인
- [ ] Commit: `feat(spec-16-02): sync adr template to install mirror`

---

## Task 3: spec/plan/walkthrough 템플릿에 트리거 박기

### 3-1. spec.md 보강
- [ ] `sources/templates/spec.md` 의 "🚫 Out of Scope" 다음에 "📑 ADR 후보" 섹션 추가 (plan.md 의 Proposed Changes 참고)
- [ ] `.harness-kit/agent/templates/spec.md` 동기화
- [ ] `diff` 로 두 파일 동일성 확인
- [ ] Commit: `feat(spec-16-02): add ADR candidate trigger to spec template`

### 3-2. plan.md 보강
- [ ] `sources/templates/plan.md` 의 "### 주요 결정" 표 직후 "📑 ADR 후보" 섹션 추가
- [ ] `.harness-kit/agent/templates/plan.md` 동기화
- [ ] `diff` 로 동일성 확인
- [ ] Commit: `feat(spec-16-02): add ADR candidate trigger to plan template`

### 3-3. walkthrough.md 보강
- [ ] `sources/templates/walkthrough.md` 의 "📌 결정 기록" 표 직후 "ADR 승격 가이드" + 체크박스 추가
- [ ] `.harness-kit/agent/templates/walkthrough.md` 동기화
- [ ] `diff` 로 동일성 확인
- [ ] Commit: `feat(spec-16-02): add ADR promotion guide to walkthrough template`

---

## Task 4: `/hk-spec-critique` 보강

### 4-1. critique sub-agent prompt 에 ADR 후보 섹션 추가
- [ ] `sources/commands/hk-spec-critique.md` 의 sub-agent 출력 형식에 "## 4. ADR 후보 추출" 섹션 추가 (plan.md 참고)
- [ ] `.claude/commands/hk-spec-critique.md` 동기화
- [ ] `diff` 로 동일성 확인
- [ ] Commit: `feat(spec-16-02): extend hk-spec-critique with ADR candidate section`

---

## Task 5: 거버넌스 (constitution) 갱신

### 5-1. §6.3 ADR 정의 보강 + §6.4 어휘 규칙 갱신
- [ ] `sources/governance/constitution.md` §6.3 ADR 항목에 *템플릿 경로* + *type 의무* 한 줄 추가
- [ ] §6.4 Rules 첫 항목을 "RCA and ADR; both adopt the closure" 로 갱신
- [ ] `.harness-kit/agent/constitution.md` 동기화
- [ ] `diff` 로 동일성 확인
- [ ] Commit: `docs(spec-16-02): formalize ADR slot in constitution §6.3/§6.4`

---

## Task 6: 첫 ADR — ADR-001-knowledge-types

### 6-1. docs/decisions/ 디렉토리 + ADR-001 작성
- [ ] `docs/decisions/` 디렉토리가 없으면 생성
- [ ] `docs/decisions/ADR-001-knowledge-types.md` 작성 — frontmatter `type: decision` + 본문 5 섹션 (spec-16-01 의 Knowledge Type Vocabulary 도입을 long-lived decision 으로 기록)
- [ ] `grep "^  type: decision$" docs/decisions/ADR-001-knowledge-types.md` 결과 hit
- [ ] Commit: `docs(spec-16-02): adopt first ADR — knowledge-types vocabulary`

---

## Task 7: 검증 (Verification)

### 7-1. 단위 검증 (plan.md §검증 계획 전 항목)
- [ ] 트리거 헤더 grep — spec/plan/walkthrough 템플릿 3 군데 hit
- [ ] install 미러 diff — adr/spec/plan/walkthrough/hk-spec-critique/constitution 모두 sources ↔ install 동일
- [ ] ADR-001 frontmatter type 정규 어휘
- [ ] type closure — `grep -rh "^  type:" docs/rca docs/decisions | sort -u` 가 정규 어휘 집합 (failure-pattern / decision) 만
- [ ] critique prompt 에 "ADR 후보 추출" 문구 hit
- [ ] Commit: 없음 (검증만)

---

## Task 8: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 코드 품질 점검 — bash 키트라 lint/type check 별도 없음. shellcheck 만 한 번 (변경 사항 없으면 생략 가능)
- [ ] Task 7 검증 항목 전수 재확인
- [ ] **walkthrough.md 작성** — 결정 기록 표 + ADR 승격 체크 (본 spec 자체에 ADR 가치 결정 있었는지 적기) + 검증 로그
- [ ] **pr_description.md 작성** — 변경 파일 목록 + 사용자 영향 + Out-of-Scope 명시
- [ ] **Ship Commit**: `docs(spec-16-02): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-16-02-adr-activation-trigger`
- [ ] **PR 생성**: `gh pr create` (사용자 승인 없이 자동 진행 — Plan Accept 후 메모리 룰)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 (Pre-flight 별도) |
| **예상 commit 수** | 8 (브랜치 생성 0 + 템플릿 동기화 2 + 트리거 3 + critique 1 + 거버넌스 1 + ADR-001 1 + Ship 1 — 총 9 commit 이내) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-16 |
