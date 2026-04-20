# Task List: spec-x-tool-comparison

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 및 리서치 수행

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-tool-comparison`

### 1-2. 툴별 기능 조사 및 report.md 초안 작성
- [x] 비교 대상 툴 7개 기능 웹 서치
- [x] Feature Matrix 표 작성
- [x] harness-kit Gap 분석 작성
- [x] harness-kit 고유 강점 정리
- [x] 다음 Phase 후보 우선순위 도출
- [x] Commit: `docs(spec-x-tool-comparison): add tool comparison report`

---

## Task 2: Ship

- [ ] 전체 테스트 실행 → 모두 PASS (`for t in tests/test-*.sh; do bash "$t"; done`)
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-tool-comparison): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-tool-comparison`
- [ ] **PR 생성** (사용자 승인 후)
- [ ] **사용자 알림**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 2 |
| **예상 commit 수** | 2 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-20 |
