# Task List: spec-30-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 컴포넌트 페이지 템플릿 + 계약 테스트 골격

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-30-01-wiki-three-layer-schema`

### 1-2. 테스트 작성 (TDD Red)
- [x] `tests/test-wiki-schema-v2.sh` 작성 — Case 1 (템플릿 존재·필수 섹션 6개·frontmatter 필드·원본/사본 동일) 먼저, Case 2~7 은 이후 task 에서 추가
- [x] 테스트 실행 → Fail 확인
- [x] Commit: `test(spec-30-01): add failing test for wiki component template`

### 1-3. 구현 (TDD Green)
- [x] `sources/templates/wiki-component.md` 작성 + `.harness-kit/agent/templates/` 사본
- [x] 테스트 실행 → Pass 확인
- [x] Commit: `feat(spec-30-01): add wiki component page template`

---

## Task 2: schema.md 개정 (3층·갱신·충돌·verify 마커·크기 상한)

### 2-1. 테스트 (Red)
- [x] Case 2 (schema 문구 존재 / append-only 문구 부재), Case 4 (시범 페이지 섹션·크기 상한), Case 5 (hooks.md verify 마커) 추가 → Fail
- [x] Commit: `test(spec-30-01): add failing test for schema v2 contract`

### 2-2. 구현 (Green)
- [x] `docs/wiki/schema.md` 재작성 (Ingest/Query/Lint 절 포함)
- [x] `docs/wiki/components/hooks.md` hook 표 위 `verify` 마커 부착 (direction.md 는 기계 검증 표가 없으면 생략)
- [x] 테스트 Pass → Commit: `docs(spec-30-01): rewrite wiki schema as 3-layer with in-place update`

---

## Task 3: `/hk-wiki-ingest` 개정 + fragment 조회 순서

### 3-1. 테스트 (Red)
- [x] Case 3 (ingest 문구·원본/사본 동일), Case 7 (fragment 조회 순서) 추가 → Fail
- [x] `tests/test-wiki-ingest.sh`·`test-wiki-structure.sh` 가 기존 문구에 의존하는지 확인하고 필요 시 함께 갱신
- [x] Commit: `test(spec-30-01): add failing test for ingest contract`

### 3-2. 구현 (Green)
- [x] `sources/commands/hk-wiki-ingest.md` 재작성 → `.claude/commands/` 사본 `cp`
- [x] `sources/claude-fragments/CLAUDE.fragment.md` 수정 → `.harness-kit/CLAUDE.fragment.md` 사본 `cp`
- [x] 테스트 Pass (`test-source-sync-drift` 포함) → Commit: `feat(spec-30-01): revise wiki ingest to component-based in-place update`

---

## Task 4: 기존 페이지 격하·안내 정합

### 4-1. 테스트 (Red)
- [ ] Case 6 (decisions/patterns 격하 배너, 줄 수 불감소) 추가 → Fail
- [ ] Commit: `test(spec-30-01): add failing test for legacy log banner`

### 4-2. 구현 (Green)
- [ ] `decisions.md`·`patterns.md` 상단 배너, `index.md` 3층 안내 행 (`updated`/`log.md` 는 건드리지 않음 — 인제스트 이벤트가 아님)
- [ ] 테스트 Pass + `bash tests/run.sh` 전체 → Commit: `docs(spec-30-01): demote decisions and patterns to source logs`

---

## Task 5: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** → 모두 PASS
- [ ] `sdd doctor` 에서 wikilink·ADR·원본↔사본 경고 없음 확인

### 📝 산출물 작성

- [ ] **walkthrough.md 작성** (수동 검증 시나리오 1 결과 또는 이월 명시, ADR 후보 처리 포함)
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-30-01): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-30-01-wiki-three-layer-schema`
- [ ] PR 생성 (`gh pr create --base phase-30-wiki-as-knowledge`)
