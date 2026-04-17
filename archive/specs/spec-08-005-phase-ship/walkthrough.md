# Walkthrough: spec-08-005

## 📋 실제 구현된 변경사항

- [x] `sources/commands/hk-phase-ship.md` — 5단계 Phase Ship 슬래시 커맨드 신규 작성
  - Step 1: Pre-check (모든 Spec Merged 확인)
  - Step 2: Success Criteria Verification (항목별 PASS/FAIL + 증거)
  - Step 3: Integration Test Execution (시나리오별 실행 + 결과)
  - Step 4: Go/No-Go Report (사용자 승인 대기 — 자동 진행 금지)
  - Step 5: Phase PR Creation + sdd phase done
- [x] `sources/templates/phase-ship.md` — Phase PR 전용 본문 템플릿 신규 작성
  - Overview / Scope / Spec Summary / Success Criteria / Integration Tests / Architecture Decisions / Known Issues / Follow-up / Stats
- [x] `sources/governance/constitution.md` — §3.1 Phase에 Phase Ship Rule 추가 (영문)
- [x] `sources/governance/agent.md` — §3.1 Work Type Table Phase 행 + §6.3 Phase done 행 갱신 (영문)
- [x] `agent/constitution.md` + `agent/agent.md` + `agent/templates/phase-ship.md` 동기화

## 🧪 검증 결과

### 수동 검증

1. **Action**: `hk-phase-ship.md` 5단계 절차 리뷰
   - **Result**: Pre-check → Criteria → Tests → Go/No-Go → PR 순서 논리적으로 완전

2. **Action**: `phase-ship.md` 템플릿 vs 업계 Release Readiness Review 패턴 대조
   - **Result**: Scope/Criteria/Tests/Decisions/Issues/Follow-up 구조가 Google RRR, Stripe Launch Checklist 패턴과 일치

3. **Action**: constitution.md + agent.md 한국어 잔존 확인
   - **Result**: 0건 (영문 전용 확인)

4. **Action**: 도그푸딩 검증 예정
   - **Result**: 이 spec merge 후 `/hk-phase-ship`을 phase-08 자체에 적용 예정

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Claude Opus 4.6) + Dennis |
| **작성 기간** | 2026-04-11 |
| **최종 commit** | `bdb3ba4` |
