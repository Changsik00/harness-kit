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
- [ ] `tests/test-uninstall-cmd-list.sh` 신규 — 4 시나리오:
  1. F1 — fresh install: installed.json.installedCommands 존재 + ≥ 12 항목
  2. F2 — install + 사용자 foo.md → uninstall: hk-* 제거 + foo.md 보존
  3. F3 — legacy installed.json (installedCommands 키 제거) → uninstall fallback 정상
  4. F5 — update 흐름: 최종 hk-* 정확히 명단대로

### 2-2. 실행 → Fail 확인
- [ ] `bash tests/test-uninstall-cmd-list.sh` → 시나리오 1, 3 부분 fail (installedCommands 키 미구현 / fallback 미구현 가능)
- [ ] Commit: `test(spec-15-03): add failing tests for uninstall command list`

---

## Task 3: TDD Green — install.sh + uninstall.sh

### 3-1. install.sh — installedCommands 기록
- [ ] `install.sh:447-459` 부근 `installed.json` 작성 블록 수정 (plan.md §Proposed Changes 참고)
- [ ] `sources/commands/*.md` 글롭 → basename 배열 → JSON 텍스트 조립

### 3-2. uninstall.sh — installedCommands 우선 + fallback
- [ ] `uninstall.sh:91-97` 의 stale `KIT_COMMANDS=...` 제거
- [ ] jq + installed.json 우선 / fallback 으로 hk-* glob

### 3-3. 검증
- [ ] `bash tests/test-uninstall-cmd-list.sh` → 모두 PASS
- [ ] `bash tests/test-version-bump.sh` → 전체 스위트 FAIL=0
- [ ] `bash tests/test-update.sh` → update 흐름 회귀 0
- [ ] `bash tests/test-install-layout.sh` → install 레이아웃 회귀 0
- [ ] Commit: `fix(spec-15-03): record installedCommands and fix uninstall stale list`

---

## Task 4: Ship

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
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
