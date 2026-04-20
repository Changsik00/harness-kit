# Implementation Plan: spec-x-tool-comparison

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-tool-comparison`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 비교 대상 툴 범위 확인 — 아래 선정 툴 외 추가/제외 원하는 것 있으면 말씀

## 🎯 핵심 전략

### 비교 대상 툴 (선정 기준: AI 기반 개발 워크플로 또는 pre-commit/CI 자동화)

| 카테고리 | 툴 |
|---|---|
| Pre-commit hook 관리 | Husky, Lefthook, pre-commit (Python) |
| Staged 파일 lint | lint-staged |
| 커밋 메시지 검증 | commitlint |
| AI 코딩 어시스턴트 규칙 | Cursor Rules, GitHub Copilot Instructions, Cline Rules |
| AI 워크플로 자동화 | Aider, Devon (프로세스 관리 측면) |

### 비교 기준 (Feature Matrix 축)

1. **설치 자동화** — 프로젝트에 자동 셋업 여부
2. **프로젝트 타입 감지** — 언어/프레임워크 자동 인식
3. **Pre-commit 자동화** — lint, test, 포맷 자동 실행
4. **커밋 컨벤션 강제** — 메시지 포맷 검증
5. **AI 컨텍스트 제공** — LLM에게 프로젝트 규칙 전달
6. **SDD 워크플로** — Spec → Plan → Task → PR 흐름 강제
7. **거버넌스 문서화** — constitution, ADR, walkthrough 등
8. **상태 추적** — 현재 어떤 작업 중인지 추적

## 📂 Proposed Changes

### [NEW] `specs/spec-x-tool-comparison/report.md`
리서치 결과물. 비교 매트릭스 + Gap 분석 + 다음 Phase 후보 3개 이상.

## 🧪 검증 계획

### 수동 검증 시나리오
1. report.md에 비교 매트릭스가 존재 — 기대: 7개 이상 툴 × 8개 이상 기준 포함
2. Gap 섹션에 harness-kit이 못 하는 영역 명시 — 기대: 3개 이상
3. 다음 Phase 후보가 우선순위와 함께 제시 — 기대: 3개 이상

## 🔁 Rollback Plan

- 리서치 산출물만 생성하므로 롤백 불필요. 브랜치 삭제로 충분.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
