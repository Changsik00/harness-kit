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
- [ ] `git checkout -b spec-9-002-claude-md-import` (phase-9-install-conflict-defense에서 시작)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: TDD Red — 설치 @import 검증 테스트 작성

### 2-1. test-install-claude-import.sh 작성
- [ ] `tests/test-install-claude-import.sh` 작성:
  - 임시 repo에 `install.sh --yes` 실행
  - `.harness-kit/CLAUDE.fragment.md` 존재 확인
  - `CLAUDE.md`에 `@.harness-kit/CLAUDE.fragment.md` 줄 존재 확인
  - `CLAUDE.md` 내 `에이전트 운영 규약` 직접 삽입 미존재 확인
  - fragment 내 `핵심 규칙 요약` 존재 확인
  - 멱등성: `install.sh --yes` 재실행 후 `@import` 줄 중복 없음 확인
- [ ] 테스트 실행 → Fail 확인 (현재 install.sh가 블록 전체를 삽입하므로)
- [ ] Commit: `test(spec-9-002): add failing test for CLAUDE.md @import install`

---

## Task 3: TDD Green — sources fragment 파일명 변경 + install.sh 수정

### 3-1. fragment 파일명 변경
- [ ] `sources/claude-fragments/CLAUDE.md.fragment` → `sources/claude-fragments/CLAUDE.fragment.md` (rename)
- [ ] fragment 내용: `.harness-kit/agent/` 경로 참조 확인/수정

### 3-2. install.sh Section 15 수정
- [ ] `.harness-kit/CLAUDE.fragment.md` 복사 로직 추가
- [ ] CLAUDE.md 삽입을 3줄 @import로 교체 (기존 블록 교체 또는 append)
- [ ] `tests/test-install-claude-import.sh` 실행 → Pass 확인
- [ ] `tests/test-two-tier-loading.sh` 실행 → Pass 확인 (FRAGMENT 변수 경로 업데이트 포함)
- [ ] Commit: `feat(spec-9-002): switch CLAUDE.md install to 3-line @import`

---

## Task 4: update.sh — fragment 교체 + 마이그레이션 로직

### 4-1. update.sh 수정
- [ ] CLAUDE.md 본문 수정 로직 제거 (fragment만 교체하도록)
- [ ] `.harness-kit/CLAUDE.fragment.md` 교체 로직 추가
- [ ] 마이그레이션 감지: HARNESS-KIT 블록이 `@import` 없이 내용을 포함하면 → 3줄 @import로 전환
- [ ] 마이그레이션 시 CLAUDE.md 백업 (`.harness-backup-{TS}/`)
- [ ] Commit: `feat(spec-9-002): update.sh replaces only CLAUDE.fragment.md, adds migration`

---

## Task 5: 도그푸딩 — 이 프로젝트 CLAUDE.md @import 전환

### 5-1. 이 프로젝트 CLAUDE.md 업데이트
- [ ] `.harness-kit/CLAUDE.fragment.md` 생성 (sources/claude-fragments/CLAUDE.fragment.md 복사)
- [ ] `CLAUDE.md` HARNESS-KIT 블록을 3줄 @import로 교체
- [ ] `tests/test-two-tier-loading.sh` → Pass 확인
- [ ] Commit: `chore(spec-9-002): migrate this repo CLAUDE.md to @import format`

---

## Task 6: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
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
