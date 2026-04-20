# spec-x-tool-comparison: 유사 툴 비교 리서치 및 harness-kit 개선 방향 도출

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-tool-comparison` |
| **Phase** | 없음 (Solo Spec) |
| **Branch** | `spec-x-tool-comparison` |
| **상태** | Planning |
| **타입** | Research |
| **Integration Test Required** | no |
| **작성일** | 2026-04-20 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
harness-kit은 Claude Code 전용 SDD 거버넌스 툴킷으로 phase-11까지 완성된 상태. 설치, 언인스톨, 업데이트, hook, sdd 메타 명령 등 핵심 기능이 갖춰져 있음.

### 문제점
다음 Phase를 결정해야 하는 시점에서 "harness-kit이 타 툴 대비 어떤 영역을 커버하지 못하는가"가 명확하지 않음. 중복 투자 또는 이미 잘 된 영역 재구현 위험이 있음.

### 해결 방안 (요약)
Husky, lint-staged, Lefthook, pre-commit, commitlint, GitHub Actions, Copilot Workspace 등 유사 툴과 harness-kit을 기능 매트릭스로 비교. harness-kit이 커버하지 못하는 빈 곳과 고유하게 잘 하는 부분을 분리하여 다음 Phase 후보를 도출.

## 🎯 요구사항

### Functional Requirements
1. 비교 대상 툴 선정 및 각 툴의 핵심 기능 정리
2. harness-kit과 기능 매트릭스 비교표 작성
3. harness-kit이 커버 못 하는 영역(Gap) 식별
4. harness-kit만의 고유 강점 정리
5. 다음 Phase 후보 3개 이상 도출 (우선순위 포함)

### Non-Functional Requirements
1. 리서치 결과는 `report.md`로 산출 (spec.md 대신)
2. 각 Gap에 대해 "구현 난이도 × 사용자 가치" 매트릭스 포함

## 🚫 Out of Scope

- 실제 구현 (리서치 및 방향 도출만)
- 모든 CI/CD 툴 전수 조사 (선별된 대표 툴만)

## ✅ Definition of Done

- [ ] `report.md` 작성 완료 (비교 매트릭스 + Gap 분석 + 다음 Phase 후보)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-tool-comparison` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
