# Task List: spec-20-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (phase-20.md 상태 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 기획 산출물 커밋 (planning artifacts)

> spec/plan/task 3개를 브랜치에 커밋한다. 이미 브랜치에 있으므로 브랜치 전환 확인만.

### 1-1. 브랜치 확인
- [x] 현재 브랜치가 `spec-20-02-director-protocol` 인지 확인 (`git branch --show-current`)
- [x] Commit: 없음 (확인만)

### 1-2. 기획 산출물 커밋
- [x] `specs/spec-20-02-director-protocol/spec.md`, `plan.md`, `task.md` 스테이징
- [x] Commit: `docs(spec-20-02): add spec plan task for director protocol`

---

## Task 2: test-director-protocol.sh 작성 (TDD Red)

> 핵심 용어 grep + 미러 parity + 단어 예산 검증 테스트를 먼저 작성. §6.8 미존재 상태에서 실패 확인.

### 2-1. 테스트 파일 작성
- [x] `tests/test-director-protocol.sh` 신규 작성
  - Check 1: `6.8 Director Mode Protocol` 섹션 존재 확인 (`grep` on `sources/governance/agent.md`)
  - Check 2: 핵심 불변식 용어 존재 확인 (`intent handshake`, `distilled contract`, `re-ingestion` 또는 `full transcript`, `Plan Accept`)
  - Check 3: sources ↔ 미러 parity (`diff -q sources/governance/agent.md .harness-kit/agent/agent.md`)
  - Check 4: 단어 예산 (constitution+agent.md 합계 8000w 이하)
- [x] `bash tests/test-director-protocol.sh` → Check 1/2 Fail 확인 (§6.8 미존재), Check 3/4 Pass 예상
- [x] Commit: `test(spec-20-02): add director protocol verification test`

---

## Task 3: agent.md §6.8 절 추가 + 미러 동기화 (TDD Green)

> `sources/governance/agent.md` 에 §6.8 Director Mode Protocol 추가 후 미러 동기화. 단어 예산 300w 이하 확인 후 커밋.

### 3-1. §6.8 절 작성
- [x] `sources/governance/agent.md` §6.7 다음에 §6.8 절 추가 (영어, 300w 이하)
- [x] `wc -w sources/governance/agent.md sources/governance/constitution.md` → 합계 8000w 이하 확인
- [x] `.harness-kit/agent/agent.md` 미러 동기화 (`cp sources/governance/agent.md .harness-kit/agent/agent.md`)
- [x] `bash tests/test-director-protocol.sh` → 전체 PASS
- [x] `bash tests/test-governance-dedup.sh` → 전체 PASS (특히 Check 2/3)
- [x] `bash tests/test-director-mode.sh` → 기존 테스트 회귀 없음 확인
- [x] Commit: `feat(spec-20-02): add director mode protocol section to agent.md`

---

## Task 4: ADR-006 업데이트 (proposed → accepted)

> 검증 불변식을 ADR-006 에 흡수하고 상태를 accepted 로 갱신한다.

### 4-1. ADR-006 갱신
- [x] `docs/decisions/ADR-006-director-mode.md` 수정:
  - `status: proposed` → `status: accepted`
  - Consequences 에 검증 불변식 항목 추가
  - "적용: agent.md §6.8 (spec-20-02)" 기록
- [x] Commit: `docs(spec-20-02): accept adr-006 with verification invariant`

---

## Task 5: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

### 🚦 Pre-Push Quality Gate (push 전 필수)

- [ ] **전체 테스트 실행**: `bash tests/test-director-protocol.sh` → PASS
- [ ] **전체 테스트 실행**: `bash tests/test-governance-dedup.sh` → PASS
- [ ] **전체 테스트 실행**: `bash tests/test-director-mode.sh` → PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성** (발견 사항·결정·증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-20-02): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-20-02-director-protocol`
- [ ] **PR 생성**: `gh pr create` 또는 `/hk-pr-gh` (base: `phase-20-director-mode`)
- [ ] **사용자 알림**: 현재 브랜치명 `spec-20-02-director-protocol` + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (Pre-flight 포함 시 4 작업 task) |
| **예상 commit 수** | 4 (docs planning / test / feat / docs adr) + 1 ship |
| **현재 단계** | T1-T4 완료 (Ship 대기) |
| **마지막 업데이트** | 2026-06-04 |
