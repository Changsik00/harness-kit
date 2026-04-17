# Walkthrough: spec-08-04

## 📋 실제 구현된 변경사항

- [x] `sources/commands/hk-align.md` — Step 4 상태 보고에 NOW/NEXT 행 추가
- [x] `sources/governance/agent.md` — §3.1 Work Type Behavior Table 추가 (Phase/Spec/spec-x/FF/Icebox 행동 규칙)
- [x] `sources/governance/agent.md` — §6.3 Completion Checklists by Work Type 추가
- [x] `sources/governance/agent.md` — §6.3 "Hand-off" → "Ship" 용어 통일
- [x] `agent/agent.md` — 위와 동일 동기화
- [x] `agent/templates/task.md` + `sources/templates/task.md` — "Hand-off" → "Ship" 변경, PR 생성 절차 명시
- [x] `sources/governance/constitution.md` + `agent/constitution.md` — 전문 영문화 (한국어 0건)
- [x] `sources/governance/agent.md` + `agent/agent.md` — 전문 영문화 (한국어 0건)
- [x] `README.md` — 전면 최신화:
  - 작업 유형 모델 섹션 신규 추가
  - Phase base branch 설명 추가
  - sdd 명령 표 갱신 (phase new --base, phase done, specx done, queue 등)
  - 슬래시 커맨드 표 갱신 (hk-ship, hk-spec-critique 등 현재 실제 커맨드)
  - 워크플로 요약 갱신 (NOW/NEXT/Icebox, /hk-ship)
  - FAQ 추가 (Phase base branch)
  - constitution 참조 섹션 번호 갱신

## 🧪 검증 결과

### 수동 검증

1. **Action**: hk-align.md 변경 후 Step 4 포맷 확인
   - **Result**: NOW/NEXT 행이 포함된 상태 보고 포맷 확인

2. **Action**: agent.md §3.1 Work Type Behavior Table 확인
   - **Result**: 5개 작업 유형별 Entry/Execution/Completion 행동이 명확히 표로 정리됨

3. **Action**: agent.md §6.3 Completion Checklists 확인
   - **Result**: Spec/spec-x/FF/Phase done 각각의 완료 후 필수 행동이 표로 정리됨

4. **Action**: README.md sdd 명령 표 vs `sdd help` 출력 대조
   - **Result**: 모든 명령이 일치함

5. **Action**: README.md 슬래시 커맨드 표 vs `.claude/commands/` 파일 목록 대조
   - **Result**: 7개 커맨드 모두 일치 (hk-align, hk-ship, hk-plan-accept, hk-pr-gh, hk-pr-bb, hk-code-review, hk-spec-critique)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Claude Opus 4.6) + Dennis |
| **작성 기간** | 2026-04-11 |
| **최종 commit** | `507a0a6` |
