# Task List: spec-x-install-fragment-fixes

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-install-fragment-fixes`
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: settings.json.fragment — git push ask 제거 (버그 B)

### 2-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-install-settings-hook.sh` 에 신규 설치 후 ask 섹션에 git push 없음을 검증하는 시나리오 추가
- [ ] 테스트 실행 → Fail 확인 (`bash tests/test-install-settings-hook.sh`)
- [ ] Commit: `test(spec-x-install-fragment-fixes): add test for git push absent in ask section`

### 2-2. 구현 (TDD Green)
- [ ] `sources/claude-fragments/settings.json.fragment` ask 섹션에서 `"Bash(git push)"` / `"Bash(git push:*)"` 2줄 제거
- [ ] 테스트 실행 → Pass 확인 (`bash tests/test-install-settings-hook.sh`)
- [ ] Commit: `fix(spec-x-install-fragment-fixes): remove git push from permissions ask list`

---

## Task 3: install.sh — self-host gitignore guard (버그 A)

### 3-1. 테스트 작성 (TDD Red)
- [ ] `tests/test-gitignore-config.sh` 에 Scenario H 추가 — git-tracked `.harness-kit/` 존재 시 `.gitignore`에 추가되지 않음
- [ ] 테스트 실행 → Fail 확인 (`bash tests/test-gitignore-config.sh`)
- [ ] Commit: `test(spec-x-install-fragment-fixes): add self-host gitignore guard scenario`

### 3-2. 구현 (TDD Green)
- [ ] `install.sh` 섹션 16에 self-host guard 삽입 (`_hk_self_host` 플래그 방식)
- [ ] 테스트 실행 → Pass 확인 (`bash tests/test-gitignore-config.sh`)
- [ ] Commit: `fix(spec-x-install-fragment-fixes): skip gitignore when .harness-kit is git-tracked`

---

## Task 4: Ship

- [ ] 전체 테스트 실행 → 모두 PASS (`bash tests/test-gitignore-config.sh && bash tests/test-install-settings-hook.sh`)
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-install-fragment-fixes): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-install-fragment-fixes`
- [ ] **PR 생성**: `gh pr create` 또는 `/hk-pr-gh` 로 생성
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (브랜치 포함) |
| **예상 commit 수** | 5 (test×2 + fix×2 + ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-06 |
