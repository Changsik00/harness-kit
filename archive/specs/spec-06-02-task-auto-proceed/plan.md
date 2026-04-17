# Implementation Plan: spec-06-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-06-02-task-auto-proceed`
- 시작 지점: `main`
- PR Target: `main`

## 🎯 핵심 전략

거버넌스 문서 4개 파일의 Strict Loop 관련 텍스트만 변경. 코드 변경 없음.

### 변경 내용

**agent.md §6.1 — 7번 단계 변경**:
- Before: "Stop & Report: Report completion of the task and WAIT for the user's signal to proceed. Batching tasks without reporting is a CRITICAL VIOLATION."
- After: "Auto-proceed or Stop: If no issues, automatically proceed to the next task. If any issue occurs (test failure, unexpected error, scope deviation), immediately STOP and report to the user. Hand-off task always requires explicit user confirmation before push/PR."

**align.md — Strict Loop 설명 변경**:
- Before: "한 task 완료 시마다 task.md 업데이트 + 사용자에게 보고 + 대기"
- After: "한 task 완료 시마다 task.md 업데이트. 이슈 없으면 자동 진행, 이슈 시 멈추고 보고. Hand-off 전에는 반드시 사용자 확인"

## 📂 Proposed Changes

#### [MODIFY] `sources/governance/agent.md`
- §6.1 7번 단계 텍스트 변경

#### [MODIFY] `sources/governance/align.md`
- Strict Loop 설명 변경

#### [MODIFY] `agent/agent.md`
- 도그푸딩 동일 반영

#### [MODIFY] `agent/align.md`
- 도그푸딩 동일 반영

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
