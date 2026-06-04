# Task List: spec-20-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (`backlog/phase-20.md` SPEC 표 `spec-20-03` 상태 → In Progress)
- [ ] 사용자 Plan Accept

---

## Task 1: 기획 산출물 커밋

> 브랜치는 이미 `spec-20-03-ceremony-split` (phase-20 base 모드 작업 중). 브랜치 생성 단계 불필요.

### 1-1. spec/plan/task 파일 스테이징 및 커밋
- [x] `git add specs/spec-20-03-ceremony-split/spec.md specs/spec-20-03-ceremony-split/plan.md specs/spec-20-03-ceremony-split/task.md`
- [x] `git add backlog/phase-20.md` (SPEC 표 상태 업데이트)
- [x] Commit: `docs(spec-20-03): add spec plan task for ceremony split`

---

## Task 2: 테스트 확장 (TDD Red)

### 2-1. test-director-protocol.sh Check 5 추가
- [x] `tests/test-director-protocol.sh` 열기 — 기존 Check 4 이후에 Check 5 블록 삽입
- [x] Check 5 항목:
  - `grep -q "Director Mode delegation"` — §6.1 위임 단락 존재
  - `grep -qi "artifact files\|planning artifacts"` — 산출물 커밋 의무
  - `grep -q "§6.1 Director Mode delegation\|→ §6.1"` — §6.8 참조 줄
- [x] 테스트 실행 → 3개 항목 FAIL 확인 (Red) — 실제 2개 FAIL (planning artifacts는 §6.6에 이미 존재)
- [x] Commit: `test(spec-20-03): extend test for ceremony split delegation`

---

## Task 3: §6.1 위임 단락 + §6.8 참조 줄 추가 (TDD Green)

### 3-1. sources/governance/agent.md 수정
- [x] §6.1 말미(7번 항목 뒤)에 "Director Mode delegation" 단락 추가
  - 포함 내용: 위임 조건, 브리핑 범위, 불변식 3가지 (게이트·산출물·검증)
  - 실제 단어 수: 88w (≤110w ✓)
- [x] §6.8 에 `→ §6.1 Director Mode delegation` 참조 줄 1행 추가
- [x] `wc -w sources/governance/agent.md sources/governance/constitution.md` 실행 → 합계 7613w ≤8000 확인

### 3-2. .harness-kit/agent/agent.md 미러 동기화
- [x] `cp sources/governance/agent.md .harness-kit/agent/agent.md`
- [x] `diff sources/governance/agent.md .harness-kit/agent/agent.md` → 출력 없음 확인

### 3-3. 테스트 실행 → PASS 확인
- [x] `bash tests/test-director-protocol.sh` → 전체 PASS
  - Check 1: §6.8 섹션 존재 ✓
  - Check 2: 핵심 용어 (기존) ✓
  - Check 3: 미러 parity ✓
  - Check 4: 단어 예산 7613w ≤8000w ✓
  - Check 5 (신규): ceremony-split 용어 3개 ✓
- [x] Commit: `feat(spec-20-03): add sdd ceremony delegation to agent.md §6.1`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

### 🚦 Pre-Push Quality Gate (push 전 필수)

> **이 단계를 건너뛰면 push 금지.** 로컬에서 모두 통과(GREEN) 확인 후 push 한다.

- [ ] **전체 테스트 실행**: `bash tests/test-director-protocol.sh` → PASS
- [ ] **추가 거버넌스 테스트**: `bash tests/test-governance-dedup.sh` `bash tests/test-director-mode.sh` → PASS
- [ ] Integration Test Required = no — 통합 테스트 생략

### 📝 산출물 작성

- [ ] **walkthrough.md 작성** (결정·협의·검증·발견 기록)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-20-03): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-20-03-ceremony-split`
- [ ] **PR 생성**: `gh pr create` 또는 `/hk-pr-gh` (base: `phase-20-director-mode`)
- [ ] **사용자 알림**: push 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (T1 산출물 커밋, T2 테스트 Red, T3 구현 Green, T4 Ship) |
| **예상 commit 수** | 4 |
| **현재 단계** | T1-T3 완료 (T4 Ship 대기) |
| **마지막 업데이트** | 2026-06-04 |
