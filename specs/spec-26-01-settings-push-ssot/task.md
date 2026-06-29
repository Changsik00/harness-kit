# Task List: spec-26-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> base 모드 — phase-26 브랜치 위에서 진행, push/PR 은 phase-ship 에서 일괄.
> auto 모드 — post-commit-verify auto-revert 회피 위해 commit 시점은 항상 green.

---

## Task 0: 선행 영향 점검 (read-only)

- [ ] `test-turbo-mode.sh` 등이 git push ask 토글 동작에 의존하는지 grep (의존 시 함께 갱신 필요 판단)

---

## Task 1: SSOT 테스트 + _settings_mode_patch 제거

### 1-1. 테스트 작성 (TDD)
- [ ] `tests/test-settings-ssot.sh` 신규: T1(fragment ask 무 git push)·T2(deny force 3변형)·T3(sdd 가 ask git push 미조작)
- [ ] 실행 → T3 Fail 확인 (현재 `_settings_mode_patch` 존재)

### 1-2. 구현
- [ ] `sources/bin/sdd`: `_settings_mode_patch()` + turbo/auto/governed 호출 3곳 제거
- [ ] `tests/test-settings-ssot.sh` 실행 → 전부 Pass
- [ ] `tests/test-turbo-mode.sh` 실행 → Pass (회귀 없음, Task 0 결과 반영)
- [ ] Commit: `refactor(spec-26-01): remove git-push ask 토글 (§5.7 push 자동 정합) + SSOT 테스트`

---

## Task 2: .claude/settings.json 명시 잔재 정리

- [ ] `permissions.allow` 의 stray `Bash(git push:*)` 제거 (`git:*` 로 redundant). `ask` 는 git push 없는 현 상태 유지
- [ ] `jq . .claude/settings.json` 로 유효 JSON 확인
- [ ] Commit: `chore(spec-26-01): .claude/settings.json git push 잔재 정리`

---

## Task 3: Ship (spec walkthrough)

### 🚦 Pre-Push Quality Gate
- [ ] `bash tests/run.sh` → 전체 PASS

### 📝 산출물
- [ ] `walkthrough.md` 작성 (결정·검증·발견)
- [ ] `pr_description.md` 작성 (phase-ship PR 본문에 반영될 spec 요약)
- [ ] phase-26 결정 기록에 W3 방향2 + §5.7 발견 반영
- [ ] Commit: `docs(spec-26-01): ship walkthrough + pr description`

> push / PR 은 phase-ship(`/hk-phase-ship`)에서 phase-26 → main 단일 PR 로 진행. 별도 spec PR 없음.
