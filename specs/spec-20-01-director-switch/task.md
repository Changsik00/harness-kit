# Task List: spec-20-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (`backlog/phase-20.md` SPEC 표 상태 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 확인 및 테스트 스캐폴딩

### 1-1. 브랜치 확인

- [ ] `spec-20-01-director-switch` 브랜치에 있음을 확인 (이미 체크아웃 되어 있으므로 생성 불필요)
- [ ] Commit: 없음 (브랜치 확인만)

### 1-2. 테스트 스캐폴딩 (TDD Red)

- [x] `tests/test-director-mode.sh` 작성 — 10개 테스트 케이스 (명령 존재, frontmatter, 미러 parity, config on/off/toggle, status grep, doctor grep)
- [x] `bash tests/test-director-mode.sh` 실행 → 전체 FAIL 확인 (구현 전이므로 정상)
- [x] Commit: `test(spec-20-01): add failing tests for director-mode command and config`

---

## Task 2: hk-director 슬래시 커맨드

### 2-1. 커맨드 파일 생성 (TDD Green — 커맨드 존재 테스트 통과)

- [x] `sources/commands/hk-director.md` 작성 (frontmatter + 본문: sdd config director-mode 래핑)
- [x] `.claude/commands/hk-director.md` 작성 (동일 내용 — 미러)
- [x] `bash tests/test-director-mode.sh` 실행 → 커맨드 존재·frontmatter·미러 parity 케이스 PASS 확인
- [x] Commit: `feat(spec-20-01): add hk-director slash command (sources + mirror)`

---

## Task 3: sdd config director-mode 서브커맨드

### 3-1. `_config_director_mode` 함수 구현 (TDD Green — config 테스트 통과)

- [x] `sources/bin/sdd` 수정:
  - `cmd_config` 라우팅에 `director-mode` 케이스 추가
  - `_config_director_mode` 함수 구현 (on/off/toggle/조회, `uxMode` 패턴 대칭)
  - usage 문자열에 `config director-mode [on|off|toggle]` 행 추가
- [x] `bash tests/test-director-mode.sh` 실행 → config on/off/toggle 케이스 PASS 확인
- [x] Commit: `feat(spec-20-01): implement sdd config director-mode subcommand`

---

## Task 4: sdd status + doctor 노출

### 4-1. status / doctor 에 directorMode 노출 (TDD Green — 노출 테스트 통과)

- [ ] `sources/bin/sdd` 수정:
  - `cmd_status` — `directorMode=true` 일 때 `Director Mode: on` 행 출력 (installed.json 읽기)
  - `cmd_doctor` — "설정" 섹션에 `directorMode` 점검 추가 (on → pass, off → pass 정보성, WARN 아님)
- [ ] `bash tests/test-director-mode.sh` 실행 → status grep + doctor grep 케이스 PASS 확인
- [ ] 전체 테스트 통과 확인
- [ ] Commit: `feat(spec-20-01): expose directorMode in sdd status and doctor`

---

## Task 5: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

### 🚦 Pre-Push Quality Gate (push 전 필수)

> **이 단계를 건너뛰면 push 금지.** 로컬에서 모두 통과(GREEN) 확인 후 push 한다.

- [ ] **전체 테스트 실행**: `bash tests/test-director-mode.sh` → 전체 PASS
- [ ] **기존 테스트 회귀**: `bash tests/test-hk-doctor.sh` 등 기존 테스트 suite PASS (있는 경우)
- [ ] (Integration Test Required = no — 별도 통합 테스트 불필요)

### 📝 산출물 작성

- [ ] **walkthrough.md 작성** (구현 중 발견·결정·이슈 중심으로 — 구현 나열 금지)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-20-01): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-20-01-director-switch`
- [ ] **PR 생성**: `gh pr create` 또는 `/hk-pr-gh` (base: `phase-20-director-mode`)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 (Task 1~4 + Ship) |
| **예상 commit 수** | 5 (test scaffold, 커맨드, config, status/doctor, ship docs) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-06-03 |
