# Task List: spec-x-phase-16-define

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-phase-16-define`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: phase-16-reliability-layer.md 작성

### 2-1. phase 정의 파일 신규 작성
- [x] `.harness-kit/agent/templates/phase.md` 형식을 따라 `backlog/phase-16-reliability-layer.md` 신규 작성
  - 메타: `phase-16` / Planning / Base Branch 없음
  - 배경 / 목표 / 성공 기준 4 개 (정량)
  - SPEC 표(마커 사이) + 4 개 spec 상세(요점/방향성/참조/연관 모듈)
  - 통합 테스트 시나리오 헤더 3 개 (세부 비움)
  - 의존성 / 위험 요소
- [x] 수동 점검:
  - `grep -c "spec-16-" backlog/phase-16-reliability-layer.md` = 21 (≥ 4)
- [x] Commit: `docs(spec-x-phase-16-define): draft phase-16 reliability layer in backlog`

---

## Task 3: queue.md 대기 Phase 섹션 등록

### 3-1. queue.md "📋 대기 Phase" 한 줄 추가
- [x] `backlog/queue.md` 의 "📋 대기 Phase" 섹션 `없음` 줄을 phase-16 한 줄로 교체
- [x] sdd 자동 갱신 마커(active/specx/done) 는 *건드리지 않음*
- [x] 수동 점검: `bash .harness-kit/bin/sdd status` → active phase 여전히 "없음"
- [x] Commit: `chore(spec-x-phase-16-define): list phase-16 in queue waiting section`

---

## Task 4: Ship (필수)

> 모든 작업 task 완료 후 ship 절차.

- [x] `git diff main` 범위가 plan 한정인지 확인 (backlog/phase-16-* + queue.md + spec-x 산출물 5)
- [x] **walkthrough.md 작성** (결정 기록 / 사용자 협의 / 발견 사항 위주)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Ship Commit**: `docs(spec-x-phase-16-define): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-x-phase-16-define`
- [x] **PR 생성**: `gh pr create` (Plan Accept 후 자동 진행, 사용자 확인 생략)
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 (Task 2, 3, 4 ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-15 |
