# Task List: spec-11-003

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

## Task 1: sdd archive 명령 구현

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-11-003-dir-archive`

### 1-2. cmd_archive 구현 + dispatch + help
- [x] `sources/bin/sdd`: 기존 deprecated `cmd_archive`(= ship 위임) 제거, 새 `cmd_archive` 구현
- [x] dispatch의 `archive)` 케이스: deprecated 경고 제거, 새 `cmd_archive` 호출
- [x] help 텍스트: `archive` 항목 갱신
- [x] `.harness-kit/bin/sdd`: 동기화
- [x] Commit: `feat(spec-11-003): implement sdd archive for directory archival`

---

## Task 2: status 진단 + align 제안

### 2-1. sdd status 진단
- [x] `sources/bin/sdd`: `_diagnose` 함수에 `specs/` 디렉토리 수 검사 추가 (20개+ 시 아카이브 제안) — Task 1에서 함께 구현
- [x] `.harness-kit/bin/sdd`: 동기화

### 2-2. align.md 갱신
- [x] `sources/governance/align.md`: 아카이브 제안 §4 추가
- [x] `.harness-kit/agent/align.md`: 동기화

- [x] Commit: `feat(spec-11-003): add archive suggestion to status diagnostics and align`

---

## Task 3: 테스트

### 3-1. 테스트 작성 및 실행
- [x] `tests/test-sdd-dir-archive.sh` 신규 작성 (6개 체크, 10 assertions)
- [x] 테스트 실행 → 10/10 PASS
- [x] 기존 테스트 실행 → 7/7 PASS (Check 7 deprecated 제거, 새 archive로 교체)
- [x] Commit: `test(spec-11-003): add directory archive tests`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-11-003): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-11-003-dir-archive`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: push 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (구현 2 + 테스트 1 + Ship 1) |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
