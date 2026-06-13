# Task List: spec-21-06

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 브랜치 생성 및 테스트 업데이트

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-21-06-template-merge`

### 1-2. 테스트 먼저 업데이트 (TDD Red)
plan.md 제거·spec 구조 변경을 검증하는 테스트를 먼저 수정한다.
- [ ] `tests/test-install-layout.sh` — 템플릿 목록에서 `plan.md` 제거
- [ ] `tests/test-sdd-spec-completeness.sh` — Planning 판정 로직 변경 (plan.md fixture 제거)
- [ ] `tests/test-sdd-status-cross-check.sh` — Check 4 제거
- [ ] `tests/test-turbo-hooks.sh` + `tests/test-turbo-mode.sh` — plan.md fixture → spec.md
- [ ] `bash tests/run.sh` → 변경된 테스트 FAIL 확인 (Red)
- [ ] Commit: `test(spec-21-06): update tests for plan.md removal`

---

## Task 2: 템플릿 파일 개편

### 2-1. spec.md 통합 + plan.md 삭제
- [ ] `sources/templates/spec.md` — plan 핵심 섹션 병합 (사용자 검토 필요·핵심 전략·Proposed Changes·검증 계획)
- [ ] `sources/templates/plan.md` — 삭제
- [ ] `.harness-kit/agent/templates/spec.md` — 동일 적용
- [ ] `.harness-kit/agent/templates/plan.md` — 삭제
- [ ] Commit: `refactor(spec-21-06): merge spec+plan templates, delete plan.md`

### 2-2. task.md + walkthrough.md 트림
- [ ] `sources/templates/task.md` — Pre-flight 섹션·진행 요약 테이블 제거
- [ ] `sources/templates/walkthrough.md` — 관련 문서·메타 테이블·ADR 승격 가이드 prose 제거
- [ ] `.harness-kit/agent/templates/` — 동일 적용
- [ ] Commit: `refactor(spec-21-06): trim task and walkthrough templates`

---

## Task 3: sdd 바이너리 업데이트

- [ ] `spec_new()`: `for f in spec plan task` → `for f in spec task`; 안내 메시지 수정
- [ ] `sdd_status()`: `planAccepted=true + plan.md 없음` 경고 제거
- [ ] `spec_show()`: `has_plan` 체크·✓/✗ 표시 제거
- [ ] `.harness-kit/bin/sdd` — 동일 적용
- [ ] `bash tests/run.sh` → Green 확인
- [ ] Commit: `feat(spec-21-06): update sdd spec new and status for plan.md removal`

---

## Task 4: 거버넌스 문서 업데이트

- [ ] `sources/governance/constitution.md` — spec.md + plan.md 언급 → spec.md 단일 언급
- [ ] `sources/governance/agent.md` — 동일
- [ ] `.harness-kit/agent/constitution.md` + `.harness-kit/agent/agent.md` — 동일
- [ ] `bash tests/run.sh` → 전체 PASS (신규 FAIL 없음)
- [ ] Commit: `docs(spec-21-06): update governance refs from spec+plan to spec`

---

## Task 5: Ship

### 🚦 Pre-Push Quality Gate
- [ ] `bash tests/run.sh` → 전체 PASS (신규 FAIL 없음)

### 📝 산출물 작성
- [ ] walkthrough.md 작성
- [ ] pr_description.md 작성
- [ ] Commit: `docs(spec-21-06): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-21-06-template-merge`
- [ ] PR 생성 (`phase-21-turbo-mode` 기준)
