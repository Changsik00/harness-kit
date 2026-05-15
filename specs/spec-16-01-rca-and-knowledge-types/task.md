# Task List: spec-16-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] phase-16.md SPEC 표 갱신 (sdd 자동)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [x] `git checkout -b spec-16-01-rca-and-knowledge-types`
- [x] Commit: 없음

---

## Task 2: Knowledge Type Vocabulary 어휘 정의

### 2-1. constitution.md §6.4 신설
- [x] `sources/governance/constitution.md` §6 안에 새 sub-section §6.4 추가 (영문, 5 type 표 + 3 룰)
- [x] §6.1~6.3 번호 보존 확인 (기존 §6.4 Branch Naming → §6.5 로 이동, agent.md §6.4 참조도 §6.5 로 갱신)
- [x] Commit: `feat(spec-16-01): add knowledge type vocabulary to constitution §6.4`

---

## Task 3: RCA 템플릿

### 3-1. sources/templates/rca.md 신규
- [x] 5 섹션 (Symptom / Reproduction / Root Cause / Invariant Violated / Prevention) + frontmatter (id / type=failure-pattern / date / severity / status)
- [x] 한국어 본문 가이드, 1~3 줄 분량 코멘트
- [x] Commit: `feat(spec-16-01): add rca template with 5-section schema`

---

## Task 4: hk-rca 슬래시 커맨드

### 4-1. sources/commands/hk-rca.md 신규
- [ ] 자동 id 부여 알고리즘 가이드 (docs/rca/ 스캔 → max+1)
- [ ] AskUserQuestion 으로 슬러그/severity 입력
- [ ] templates/rca.md 복사 + frontmatter 자동 채움
- [ ] *최근 발견 사항 제안* 단계 — walkthrough 의 발견 사항을 5 섹션 초안으로 제시
- [ ] Commit: `feat(spec-16-01): add /hk-rca slash command`

---

## Task 5: install.sh 매트릭스 확장 + 도그푸딩 mirror

### 5-1. install.sh 복사 매트릭스 확장
- [ ] sources/templates/rca.md → .harness-kit/agent/templates/rca.md
- [ ] sources/commands/hk-rca.md → .claude/commands/hk-rca.md
- [ ] dry-run 검증: `bash install.sh --dry-run .` → 신규 2 라인 노출
- [ ] Commit: `feat(spec-16-01): wire rca template and command into install matrix`

### 5-2. 본 키트 자기 install (도그푸딩 mirror)
- [ ] `bash install.sh .` 실행
- [ ] `.harness-kit/agent/templates/rca.md`, `.claude/commands/hk-rca.md`, `.harness-kit/agent/constitution.md` 동기화 확인
- [ ] `installedCommands` 에 `hk-rca` 포함 확인 (installed.json)
- [ ] Commit: `chore(spec-16-01): self-install for dogfooding mirror`

---

## Task 6: 첫 사용자 RCA-001 작성

### 6-1. docs/rca/ 디렉토리 + RCA-001
- [ ] `docs/rca/.gitkeep` 신규
- [ ] `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` 신규 — frontmatter (id=RCA-001 / type=failure-pattern / severity=medium / status=active) + 5 섹션 모두 한국어로 채움
- [ ] 수동 점검: `grep -rh "^type:" docs/rca` 결과 = `type: failure-pattern`
- [ ] 수동 점검: `grep -c "^## " docs/rca/RCA-001-*.md` ≥ 5
- [ ] Commit: `docs(spec-16-01): write RCA-001 sdd ship spec add missing pattern`

---

## Task 7: Ship

> 모든 작업 task 완료 후 ship 절차.

- [ ] `git diff main` 범위가 plan 한정인지 확인
- [ ] **walkthrough.md 작성** (결정 기록 / 사용자 협의 / 발견 사항 위주)
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-16-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-16-01-rca-and-knowledge-types`
- [ ] **PR 생성**: `gh pr create` (자동 진행)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 |
| **예상 commit 수** | 6 (Task 2/3/4/5-1/5-2/6) + 1 ship |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-15 |
