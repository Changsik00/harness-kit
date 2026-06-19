# Task List: spec-24-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: auto 모드 테스트 (TDD Red)

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-24-01-auto-mode-base` (완료)

### 1-2. 테스트 작성 (Red)
- [ ] `tests/test-mode-auto.sh` 작성: `sdd mode auto` 전환, `state.mode=auto`, status 표시, 잘못된 모드 거부, `check-plan-accept.sh` 가 auto 에서 비차단(exit 0)
- [ ] 실행 → Fail 확인 (auto 미구현)
- [ ] Commit: `test(spec-24-01): add failing test for auto mode`

---

## Task 2: auto 모드 구현 (TDD Green)

### 2-1. sdd + 훅 구현
- [ ] `sources/bin/sdd`: `cmd_mode` 에 `auto)` case, `_settings_mode_patch` auto 분기, `cmd_status` 모드 표시, help 1줄
- [ ] `sources/hooks/check-plan-accept.sh`: turbo 비차단 게이트 → `turbo|auto` (+ 다른 turbo-게이트 훅 grep 확인 후 동일 적용)
- [ ] `sources/` → `.harness-kit/` 미러링 (cp, byte-identical)
- [ ] 테스트 실행 → Pass 확인
- [ ] Commit: `feat(spec-24-01): add auto mode (CLI + status + hook 인식)`

---

## Task 3: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [ ] **전체 테스트 실행** → 모두 PASS

### 📝 산출물 작성
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-24-01): ship walkthrough and pr description`

### 🚀 Push & PR
- [ ] `git push -u origin spec-24-01-auto-mode-base`
- [ ] PR 생성 (`gh pr create`)
