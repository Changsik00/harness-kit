# Implementation Plan: spec-10-005

## 📋 Branch Strategy

- 신규 브랜치: `spec-10-005-artifact-timing-fix`
- 시작 지점: `phase-10-status-reliability`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `sdd spec new`에서 walkthrough/pr_description 미생성 — 기존 워크플로우에서 Ship task 시 수동 생성 필요 (에이전트가 `/hk-ship`에서 작성)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **spec new** | walkthrough/pr_description 생성 제외 | Artifacts 단계 오판 방지. Ship 시점에만 존재해야 의미 있음 |
| **walkthrough 템플릿** | 결정 기록 + 사용자 협의 섹션 추가 | 검증 결과만이 아닌 작업 중 컨텍스트 보존 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd` — `spec_new()` (라인 667)

```text
# 변경 전
for f in spec plan task walkthrough pr_description; do

# 변경 후
for f in spec plan task; do
```

### 템플릿

#### [MODIFY] `sources/templates/walkthrough.md`

`📌 결정 기록`과 `💬 사용자 협의` 섹션 추가. `🔍 발견 사항`에서 Optional 제거.

### 동기화

#### [MODIFY] `.harness-kit/bin/sdd` + `.harness-kit/agent/templates/walkthrough.md`

sources 변경 사항 도그푸딩 동기화.

### 테스트

#### [MODIFY] `tests/test-sdd-spec-completeness.sh`

기존 시나리오 영향 확인 — spec new 후 walkthrough/pr_description이 없으므로 fixture에서 수동 생성하는 부분 조정 필요할 수 있음.

## 🧪 검증 계획 (Verification Plan)

### 전체 회귀 테스트
```bash
for t in tests/test-*.sh; do bash "$t"; done
```

### 수동 검증
1. `sdd spec new test-slug` → spec 디렉토리에 walkthrough.md, pr_description.md 없는지 확인
2. `sdd status` → Artifacts에서 walkthrough `✗`, pr_description `✗` 표시 확인

## 🔁 Rollback Plan

- `sources/bin/sdd`와 템플릿 변경만 revert.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
