# Task List: spec-16-04

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 — `sdd spec new` 가 처리 (수동 dedupe 필요 — Task 1-2)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-16-04-reliability-positioning` (from `phase-16-reliability-layer`)
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. 기획 산출물 + phase-16.md dedupe
- [ ] `phase-16.md` 의 중복된 spec-16-04 행 수동 정리 (sdd spec new marker append 버그 회피)
- [ ] `git add backlog/phase-16.md backlog/queue.md specs/spec-16-04-reliability-positioning/`
- [ ] Commit: `chore(spec-16-04): add planning artifacts (spec/plan/task) + dedupe phase-16 marker`

---

## Task 2: README 슬로건 추가

### 2-1. README.md italic slogan 추가
- [ ] `# harness-kit` 직후 빈 줄 → `*Not an AI coding framework. A reliability layer for AI-assisted engineering.*` → 빈 줄 → 기존 한국어 blockquote
- [ ] `grep "reliability layer" README.md` → hit 확인
- [ ] `grep "SDD(Spec-Driven Development) 거버넌스" README.md` → hit 확인 (한국어 부제 보존)
- [ ] Commit: `docs(spec-16-04): add english slogan to README header`

---

## Task 3: version.json description 필드 추가

### 3-1. version.json 갱신
- [ ] `{"version": "0.9.1"}` → 두 필드 (`version` + `description`) — slogan 값
- [ ] `jq . version.json` → 에러 없이 두 필드 출력
- [ ] `jq -r '.description' version.json` → 슬로건 그대로
- [ ] `jq -r '.version' version.json` → "0.9.1" (기존 값 보존)
- [ ] Commit: `docs(spec-16-04): add description field to version.json`

---

## Task 4: constitution.md identity 문장 추가

### 4-1. sources/governance/constitution.md prefix
- [ ] `# Project Constitution` 직후 빈 줄 → `harness-kit is a reliability layer for AI-assisted engineering. The Constitution below defines the invariant laws that make this layer enforceable.` → 빈 줄 → 기존 첫 문장
- [ ] `grep "harness-kit is a reliability layer" sources/governance/constitution.md` → hit 확인
- [ ] `grep "Constitution defines the invariant laws" sources/governance/constitution.md` → hit 확인 (기존 문장 보존)
- [ ] Commit: `docs(spec-16-04): add identity statement to constitution`

---

## Task 5: install 미러 동기화

### 5-1. .harness-kit/agent/constitution.md
- [ ] `cp sources/governance/constitution.md .harness-kit/agent/constitution.md`
- [ ] `diff sources/governance/constitution.md .harness-kit/agent/constitution.md` → 빈 출력
- [ ] Commit: `docs(spec-16-04): sync constitution to install mirror`

---

## Task 6: 통합 검증 (phase 시나리오 3)

### 6-1. grep 검증 + 회귀 점검
- [ ] `grep -l "reliability layer" README.md version.json .harness-kit/agent/constitution.md` → 3 줄 출력 확인 (시나리오 3 PASS)
- [ ] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS (회귀 없음 — 본 spec 이 sdd 동작에 영향 X)
- [ ] `bash .harness-kit/bin/sdd status` → 정상 출력, drift 섹션 stale ADR 없음
- [ ] Commit: 없음 (검증만)

---

## Task 7: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 코드 품질 점검 — bash 키트, pre-commit shellcheck 통과
- [ ] Task 2~6 검증 항목 전수 재확인
- [ ] **walkthrough.md 작성** — 결정 기록 + 검증 로그
- [ ] **pr_description.md 작성** — 변경 파일 + PR target=phase-16-reliability-layer 명시 + phase 통합 완성 안내
- [ ] **Ship Commit**: `docs(spec-16-04): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-16-04-reliability-positioning`
- [ ] **PR 생성**: `gh pr create --base phase-16-reliability-layer`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고 + *다음 단계 = `/hk-phase-ship`* 안내

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight 별도) |
| **예상 commit 수** | 6 (planning + readme + version + constitution + sync + ship) — Task 6 은 commit 없음 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-16 |
