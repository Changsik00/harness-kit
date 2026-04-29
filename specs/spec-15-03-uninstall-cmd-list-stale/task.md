# Task List: spec-15-03

> One Task = One Commit. 매 commit 직후 본 파일 체크박스 갱신.

## Pre-flight

- [x] Spec ID 확정 + 디렉토리 생성 (`sdd spec new uninstall-cmd-list-stale`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] phase-15.md spec 표 자동 갱신 (sdd 처리)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + phase-15.md spec 명세 swap

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-15-03-uninstall-cmd-list-stale` (phase-15-upgrade-safety 에서 분기)

### 1-2. phase-15.md §spec 명세 swap
- [x] §spec-15-03 (uninstall-cmd-list-stale) ↔ §spec-15-04 (historical-regression-tests) swap
- [x] §위험 섹션 — "spec-15-04 으로 즉시 픽스" → "spec-15-03 으로 즉시 픽스"
- [ ] Commit: `chore(spec-15-03): swap spec specs in phase-15 to match execution order`

---

## Task 2: TDD Red — 단위 테스트 작성

### 2-1. 테스트 작성
- [x] `tests/test-uninstall-cmd-list.sh` 신규 — 4 시나리오 × 9 checks

### 2-2. 실행 → Fail 확인
- [x] `bash tests/test-uninstall-cmd-list.sh` → Red 4 fail (installedCommands 키 부재 / hk-* 잔재 / fallback 미동작)
- [x] Commit: `test(spec-15-03): add failing tests for uninstall command list`

---

## Task 3: TDD Green — install.sh + uninstall.sh

### 3-1. install.sh — installedCommands 기록
- [x] `install.sh:447-466` `installed.json` 작성 블록에 `installedCommands` 추가
- [x] `sources/commands/*.md` 글롭 → basename → JSON 텍스트 조립 (jq 의존 회피)

### 3-2. uninstall.sh — installedCommands 우선 + fallback
- [x] `uninstall.sh:91-104` 의 stale `KIT_COMMANDS=...` 제거
- [x] 백업 디렉토리의 `installed.json` 에서 명단 읽음 (.harness-kit/ 는 이미 제거됨)
- [x] jq 없거나 키 부재 시 `hk-*.md` glob fallback

### 3-3. 검증
- [x] `bash tests/test-uninstall-cmd-list.sh` → 9/9 PASS
- [x] `bash tests/test-version-bump.sh` → 전체 스위트 FAIL=0 (test-update / test-install-layout 포함)
- [x] Commit: `fix(spec-15-03): record installedCommands and fix uninstall stale list`

---

## Task 4: Ship

- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-15-03): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-15-03-uninstall-cmd-list-stale`
- [ ] **PR 생성**: `gh pr create --base phase-15-upgrade-safety`

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 4 (Task 1 의 swap 도 commit, Task 2 / 3 / Ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-28 |
