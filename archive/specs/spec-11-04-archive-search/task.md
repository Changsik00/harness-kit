# Task List: spec-11-04

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-11.md SPEC 표 — sdd 자동 갱신 완료)
- [ ] 사용자 Plan Accept

---

## Task 1: sdd 탐색 함수에 archive fallback 추가

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-11-04-archive-search`

### 1-2. spec_list, phase_list, phase_show, spec_show 수정
- [x] `sources/bin/sdd`: `spec_list` — `archive/specs/` glob 추가, `(archived)` 표시
- [x] `sources/bin/sdd`: `phase_list` — `archive/backlog/` 탐색 + spec count에 archive 포함
- [x] `sources/bin/sdd`: `phase_show` — `archive/backlog/`, `archive/specs/` fallback
- [x] `sources/bin/sdd`: `spec_show` — `archive/specs/` fallback
- [x] `sources/bin/sdd`: `status --verbose` — archive spec 수 표시
- [x] `sources/bin/sdd`: `_status_diagnose` — archive 항목 수 진단 추가
- [x] `.harness-kit/bin/sdd`: 동기화
- [x] Commit: `feat(spec-11-04): add archive fallback to spec/phase search commands`

---

## Task 2: 테스트

### 2-1. 테스트 작성 및 실행
- [x] `tests/test-sdd-archive-search.sh` 신규 작성 (4개 체크, 11 assertions)
- [x] 테스트 실행 → 11/11 PASS
- [x] 기존 테스트 실행 → 17/17 PASS (회귀 없음)
- [x] `C_YEL` → `C_YLW` 버그 수정 (`.harness-kit/bin/sdd`)
- [x] Commit: `test(spec-11-04): add archive search integration tests`

---

## Task 3: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-11-04): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-11-04-archive-search`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: push 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (구현 1 + 테스트 1 + Ship 1) |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
