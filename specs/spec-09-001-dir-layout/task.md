# Task List: spec-09-001

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-09.md SPEC 표 sdd 자동 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-09-001-dir-layout` (main에서 시작)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 신규 레이아웃 검증 테스트 작성 (TDD Red)

### 2-1. test-install-layout.sh 작성
- [x] `tests/test-install-layout.sh` 작성: 임시 repo에 `install.sh --yes` 실행 → `.harness-kit/` 생성 확인, `agent/` 미생성 확인, `installed.json` 존재 확인, `!.harness-kit/` in .gitignore 확인
- [x] 테스트 실행 → Fail 확인 (현재 install.sh가 `agent/`를 생성하므로)
- [x] Commit: `test(spec-09-001): add failing test for new .harness-kit layout`

---

## Task 3: install.sh 경로 전면 교체 (TDD Green)

### 3-1. install.sh 설치 경로 변경
- [x] 디렉토리 생성: `agent/` → `.harness-kit/agent/`, `scripts/harness/bin/lib` → `.harness-kit/bin/lib`, `scripts/harness/hooks` → `.harness-kit/hooks`, `scripts/harness/lib` → `.harness-kit/lib`
- [x] 복사 경로: 거버넌스, 템플릿, bin, hooks 전부 `.harness-kit/` 하위로
- [x] `.harness-kit/installed.json` 생성 로직 (kitVersion, installedAt)
- [x] `.gitignore` 처리: `!.harness-kit/`, `.harness-backup-*/` 추가
- [x] 설치 계획 출력 텍스트 업데이트
- [x] `tests/test-install-layout.sh` 실행 → Pass 확인
- [x] Commit: `refactor(spec-09-001): change install target dirs to .harness-kit/`

---

## Task 4: settings.json fragment hook 경로 교체

### 4-1. fragment 수정
- [x] `sources/claude-fragments/settings.json.fragment`: hook 경로 `scripts/harness/hooks/` → `.harness-kit/hooks/`
- [x] `bash tests/test-hook-modes.sh` → Pass 확인
- [x] Commit: `refactor(spec-09-001): update settings fragment hook paths to .harness-kit/`

---

## Task 5: governance 문서 + slash commands 경로 참조 교체

### 5-1. sources/governance/ 수정
- [x] `sources/governance/agent.md`: `scripts/harness/bin/sdd` → `.harness-kit/bin/sdd`, `agent/` 참조 → `.harness-kit/agent/`
- [x] `sources/governance/align.md`: sdd 경로, agent/ 참조 교체
- [x] `sources/governance/constitution.md`: `agent/templates/` → `.harness-kit/agent/templates/`

### 5-2. sources/commands/ 수정
- [x] `sources/commands/hk-align.md`: `@agent/` → `@.harness-kit/agent/`
- [x] `sources/commands/hk-cleanup.md`: diff 경로, ls 경로 전체 교체
- [x] `sources/commands/hk-phase-ship.md`: `agent/templates/` → `.harness-kit/agent/templates/`

### 5-3. 테스트
- [x] `bash tests/test-governance-dedup.sh` → Check 2는 Task 8(dogfooding 마이그레이션) 전까지 의도적으로 Fail (나머지 6/8 Pass)
- [x] Commit: `refactor(spec-09-001): update all agent/ and scripts/harness/ path refs to .harness-kit/`

---

## Task 6: update.sh — v0.3→v0.4 migration 로직 추가

### 6-1. migration 로직 구현
- [x] old-layout 감지: `agent/` 존재 + `.harness-kit/` 부재 → v0.3으로 판단
- [x] migration 플로우: 안내 출력 → 사용자 확인 → `.harness-backup-{TS}/` 백업 → `mv agent/ .harness-kit/agent/` → `scripts/harness/` 하위 파일을 `.harness-kit/`으로 이동 → `settings.json` hook 경로 jq 패치 → `.gitignore` 업데이트 → `installed.json` 작성
- [x] `--yes` 플래그 시 확인 없이 진행
- [x] Commit: `feat(spec-09-001): add v0.3→v0.4 layout migration to update.sh`

---

## Task 7: uninstall.sh + doctor.sh 경로 교체

### 7-1. uninstall.sh 수정
- [x] `rm -rf "$TARGET/agent"` → `rm -rf "$TARGET/.harness-kit"`
- [x] `rm -rf "$TARGET/scripts/harness"` → 제거 (`.harness-kit/`으로 통합됨)
- [x] 백업 대상 경로 업데이트

### 7-2. doctor.sh 수정
- [x] `agent/`, `scripts/harness/` 경로 체크 → `.harness-kit/agent/`, `.harness-kit/bin/` 체크

### 7-3. 테스트
- [x] 주요 테스트 Pass 확인 (Check 2는 Task 8 전까지 의도적 Fail)
- [x] Commit: `refactor(spec-09-001): update uninstall.sh and doctor.sh paths to .harness-kit/`

---

## Task 8: 이 프로젝트 dogfooding 자체 마이그레이션

> ⚠️ 이 Task 실행 후 sdd 경로가 `bash .harness-kit/bin/sdd`로 변경됨.

### 8-1. 파일 이동
- [x] `mv agent/ .harness-kit/agent/`
- [x] `mkdir -p .harness-kit/bin/lib .harness-kit/hooks .harness-kit/lib` 후 `mv scripts/harness/bin/ .harness-kit/bin/`, `mv scripts/harness/hooks/ .harness-kit/hooks/`
- [x] `rmdir scripts/harness scripts/ 2>/dev/null || true` (비어있으면 제거)

### 8-2. 참조 업데이트
- [x] `CLAUDE.md`: `agent/constitution.md`, `agent/agent.md`, `scripts/harness/bin/sdd` 참조 교체
- [x] `.claude/settings.json`: hook 경로 `scripts/harness/hooks/` → `.harness-kit/hooks/`
- [x] `.gitignore`: `.harness-uninstall-backup-*/` 추가
- [x] `tests/test-hook-modes.sh`: Check 5/7 경로 `.harness-kit/` 로 업데이트

### 8-3. VERSION 갱신
- [x] `VERSION`: 이미 `0.4.0`
- [x] `.harness-kit/installed.json` 생성 (kitVersion: "0.4.0", installedAt: 오늘)
- [x] `.claude/state/current.json` kitVersion → `0.4.0`

### 8-4. 검증
- [x] `bash .harness-kit/bin/sdd status` → phase-09 active 정상 출력
- [x] 모든 테스트 Pass (governance-dedup 8/8, hook-modes 12/12, install-layout 7/7, two-tier 7/7)
- [x] Commit: `chore(spec-09-001): migrate harness-kit dogfooding to .harness-kit/ layout, bump v0.4.0`

---

## Task 9: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 실행 → 모두 PASS (34/34 checks)
- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-09-001): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-001-dir-layout`
- [ ] **PR 생성**: (사용자 승인 후), target: `phase-09-install-conflict-defense`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 (+ Ship) |
| **예상 commit 수** | 7 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-14 |
