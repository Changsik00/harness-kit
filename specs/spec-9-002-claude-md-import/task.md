# Task List: spec-9-002

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-9.md SPEC 표 spec-9-002 Active 추가)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-9-002-claude-md-import` (phase-9-install-conflict-defense에서 시작)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: TDD Red — 설치 @import 검증 테스트 작성

### 2-1. test-install-claude-import.sh 작성
- [x] `tests/test-install-claude-import.sh` 작성 (6개 검증 항목)
- [x] 테스트 실행 → Fail 확인 (5/6 FAIL)
- [x] Commit: `test(spec-9-002): add failing test for CLAUDE.md @import install`

---

## Task 3: TDD Green — sources fragment 파일명 변경 + install.sh 수정

### 3-1. fragment 파일명 변경
- [x] `sources/claude-fragments/CLAUDE.md.fragment` → `sources/claude-fragments/CLAUDE.fragment.md` (rename)
- [x] fragment 내용: `.harness-kit/agent/` 경로 참조 수정, HARNESS-KIT 마커 제거

### 3-2. install.sh Section 15 수정
- [x] `.harness-kit/CLAUDE.fragment.md` 복사 로직 추가
- [x] CLAUDE.md 삽입을 3줄 @import로 교체 (기존 블록 교체 또는 append)
- [x] `tests/test-install-claude-import.sh` → 6/6 PASS
- [x] `tests/test-two-tier-loading.sh` → 7/7 PASS
- [x] Commit: `feat(spec-9-002): switch CLAUDE.md install to 3-line @import`

---

## Task 4: update.sh — fragment 교체 + 마이그레이션 로직

### 4-1. update.sh 수정
- [x] CLAUDE.md 마이그레이션은 install.sh 재실행으로 처리 (구 방식 블록 → @import 자동 교체)
- [x] 일반 업데이트 시 CLAUDE.md 백업 추가 (`.harness-backup-{TS}/`)
- [x] old-layout v0.3 마이그레이션 백업에도 CLAUDE.md 추가
- [x] Commit: `feat(spec-9-002): update.sh backs up CLAUDE.md before install; fragment-only update via install.sh`

---

## Task 5: 도그푸딩 — 이 프로젝트 CLAUDE.md @import 전환

### 5-1. 이 프로젝트 CLAUDE.md 업데이트
- [x] `.harness-kit/CLAUDE.fragment.md` 생성
- [x] `CLAUDE.md` HARNESS-KIT 블록을 3줄 @import로 교체
- [x] `tests/test-two-tier-loading.sh` → 7/7 PASS
- [x] Commit: `chore(spec-9-002): migrate this repo CLAUDE.md to @import format`

---

## Task 6: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 실행 → 40/40 PASS
- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-9-002): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-9-002-claude-md-import`
- [ ] **PR 생성**: (사용자 승인 후), target: `phase-9-install-conflict-defense`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (+ Ship) |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-14 |
