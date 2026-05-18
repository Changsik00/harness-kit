# Task List: spec-x-kit-update-notify

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — spec-x specx 섹션은 `sdd plan accept` 시 자동 갱신
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-kit-update-notify` (main 기준)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 스펙 산출물 등록

### 2-1. 초기 docs commit
- [x] spec.md / plan.md / task.md / walkthrough.md (템플릿) + backlog/queue.md staging
- [x] Commit: `docs(spec-x-kit-update-notify): add spec/plan/task` (41355a5)

---

## Task 3: `sdd status --brief` 버전 suffix 추가

### 3-1. `sources/bin/sdd` 수정
- [x] `cmd_status()` brief 분기에 cache.json 읽기 + `→UPDATE:X.Y.Z` suffix 로직 추가
- [x] 검증: `cache.json`에 더 높은 버전 임시 기록 후 `sdd status --brief` → suffix 확인
- [x] 검증: `cache.json` 없는 상태 → 기존 포맷 그대로 확인
- [x] Commit: `fix(spec-x-kit-update-notify): add →UPDATE suffix to sdd status --brief` (f9a7a05)

### 3-2. `.harness-kit/bin/sdd` 동기화
- [x] 동일 변경 적용 (dogfooding 동기화)
- [x] Commit: `fix(spec-x-kit-update-notify): sync .harness-kit/bin/sdd brief update suffix` (eac021b)

---

## Task 4: `/hk-update` step 5 실행 로직 변경

### 4-1. `sources/commands/hk-update.md` 수정
- [x] step 5: 승인 시 Bash 직접 실행 로직 + 거절 시 `!` prefix 수동 안내로 교체
- [x] Commit: `fix(spec-x-kit-update-notify): hk-update executes on user approval` (c29bafa)

### 4-2. `.claude/commands/hk-update.md` 동기화
- [x] 동일 변경 적용 (dogfooding 동기화)
- [x] Commit: `fix(spec-x-kit-update-notify): sync .claude/commands/hk-update.md` (86034d2)

---

## Task 5: SessionStart IMPORTANT 에코 갱신

### 5-1. `.claude/settings.json` 수정
- [x] SessionStart 세 번째 훅 echo 메시지에 `→UPDATE:` 감지 지시 추가
- [x] Commit: `fix(spec-x-kit-update-notify): add →UPDATE detection to SessionStart hook` (a21e44a)

---

## Task 6: 회귀 테스트

### 6-1. 핵심 테스트 실행
- [x] `bash tests/test-install-claude-import.sh` → ✅ ALL PASS (6/6)
- [x] `bash tests/test-marker-append-guard.sh` → ✅ ALL 5 CHECKS PASSED
- [x] `bash tests/test-marker-edge-cases.sh` → ✅ ALL 8 CHECKS PASSED
- [x] `bash .harness-kit/bin/sdd test passed` → 2026-05-18T07:59:18Z
- [x] Commit: 없음 (테스트 실행만)

---

## Task 7: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-kit-update-notify): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-kit-update-notify`
- [ ] **PR 생성**: `gh pr create` 자동
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight 제외) |
| **예상 commit 수** | 6 (Task 2/3-1/3-2/4-1/4-2/5 + Ship; Task 1/6 무 commit) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-18 |
