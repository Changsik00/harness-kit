# CHANGELOG

harness-kit의 주요 변경 사항을 버전별로 정리합니다.
형식: [Semantic Versioning](https://semver.org/)

---

## [0.8.0] — 2026-05-10

### Added
- `sdd archive` 가 완료된 spec-x 디렉토리도 정리 — `queue.md` done 섹션 등록 기준 (#102)
- `agent.md §6.3.2` Post-Merge Protocol for Phase 신설 — base/non-base mode 분기 + Phase living decision log (#105)
- `agent.md §6.7` Workflow Patterns 신설 — model transparency, parallel-by-default, background, sub-agent dispatch threshold, archive timing, version+CHANGELOG paired update (THIS)
- `phase.md` 템플릿 `📌 결정 기록 (Review)` 섹션 — Phase 레벨 living decision log (#105)
- `tests/test-sdd-dir-archive.sh` Check 7~9 — spec-x archive / dry-run / drift 보호 (#102, #103)
- `tests/test-git-precommit-hook.sh` Test 12~13 — no-active-spec bypass / legacy state 호환 (#104)

### Fixed
- `sdd archive` 의 `git add -A` 가 무관한 워킹트리 변경을 흡수 — `git mv` 가 이미 stage 했으므로 add 라인 제거 (#103)
- pre-commit / check-plan-accept hook 이 활성 SPEC 없을 때도 production commit 차단 — `state.spec == null` 시 통과 추가, FF 모드 정상화 (#104)
- `install.sh` self-host 모드에서 `# harness-kit` 헤더 잡음 추가 — self-host guard 뒤로 이동 + 한도 헤더 skip (FF 85d2462)
- `/hk-phase-ship` 의 `sdd phase done` 호출 시점 — PR 생성 → 사용자 phase 머지 신호 후로 이동 (base mode), Phase PR review 중 컨텍스트 손실 방지 (#105)

### Changed
- `constitution §3.1` Phase Exit Condition — `(base mode) Phase PR merge` 추가, state 리셋 boundary 명시 (#105)
- `constitution §5.6` Opinion Divergence — 결정 기록 대상에 `walkthrough.md` 추가 + PR review 분기 명시 (FF f48cc4c)
- `constitution §6.3` ADR 위치 — escalation 트리거 한 줄 (architectural / cross-Spec / long-lived) (#105)
- `agent.md §6.3 bullet 7` Living artifacts during review — scope 별 분기 (walkthrough/plan.md/ADR) (FF f48cc4c, #105)
- 거버넌스 word 한도 5000 → 6000 — generic-useful workflow 패턴 거버넌스화 헤드룸 확보 (THIS)

---

## [0.7.0] — 2026-05-09

### Added
- `sdd status` drift 섹션 kit 버전 자동 감지 — `curl` 로 GitHub `version.json` 조회, 새 버전 있으면 알림 표시 (#100)
- 24시간 캐시 — `installed.json` 에 `lastVersionCheck` + `latestKnownVersion` 기록 (#100)
- `installed.json` 에 `kitOrigin` 필드 추가 (install 시 kit 저장소 URL 기록) (#100)
- `/hk-update` 슬래시 커맨드 — 버전 확인 후 `update.sh` 실행 안내 (#100)
- git pre-commit hook Plan Accept 안전망 — `planAccepted=false` 상태에서 커밋 차단 (#96)
- `get.sh` curl 한 줄 원격 인스톨러 + `--uninstall` 플래그 (#95)
- `sdd status` drift 감지 섹션 — 원격 behind/ahead, 워킹트리, 정합성, install 부산물 (#93)

### Fixed
- pre-commit hook 재설치 시 `chmod +x` 누락 버그 — 기존 hook 파일 경로에서도 실행 권한 항상 적용 (#99)
- push/PR 확인 UX 단일화 — `constitution §5.7` 신설, push 자동화·PR `[Y/n]` 형식 고정 (#98)

### Changed
- `sdd` / `doctor.sh` 경로 출력 상대 경로화 — Warp 터미널 클릭 가능 링크 (#97)
- `doctor.sh` hook 권한 섹션 표 포맷 개선 (#97)
- `agent.md §8` 출력 형식 규칙 추가 — 경로·이모지·표 형식 정의 (#97)

---

## [0.6.3] — 2026-05-09

### Fixed
- **`install.sh` self-host gitignore 중복 추가** — `.harness-kit/`이 git 추적 중(self-host 모드)일 때 `.gitignore`에 `.harness-kit/` 항목을 추가하지 않도록 가드 추가 (→ spec-x-install-fragment-fixes)
- **`settings.json.fragment` permissions ask 목록에 `git push` 잔존** — 불필요한 `git push` 권한 요청 제거 (→ spec-x-install-fragment-fixes)

### Tests
- `tests/test-gitignore-config.sh` — self-host 모드 gitignore 가드 시나리오
- `tests/test-install-settings-hook.sh` — settings.json ask 목록 검증

---

## [0.6.2] — 2026-04-28

### Added
- **`sdd phase activate <phase-NN> [--base]`** — 사용자가 `backlog/`에 미리 작성해둔 phase 파일을 활성화하는 명령. 본문은 일체 변경하지 않고 state.json + queue.md 의 active 마커만 갱신. `--base` 옵션은 phase.md 메타 표의 `Base Branch` 필드(`phase-NN-<slug>` 형식)를 읽어 baseBranch 로 설정 — 채워져 있지 않으면 die. 사전 정의 phase 가 여럿이거나 active phase 가 다른 ID 인 경우 거부 (→ spec-x-sdd-phase-activate)

### Fixed
- **`sdd phase new` 사일런트 잘못된 생성** — 사용자가 `backlog/phase-03.md ~ phase-07.md` 처럼 phase 를 미리 정의해 둔 상태에서 `sdd phase new <slug>` 실행 시, sdd가 사전 정의 파일을 인지하지 못하고 max+1 번호로 새 phase 를 만들어 버리던 문제. 이제 done 도 active 도 아닌 phase 파일이 존재하면 die + `sdd phase activate <id>` 안내. `--force` 플래그로 우회 가능

### Tests
- `tests/test-sdd-phase-activate.sh` — phase activate 정상/실패 시나리오 + phase new 가드 + `--force` 우회 + 회귀 (총 13 checks)

---

## [0.6.1] — 2026-04-27

### Fixed
- **`update.sh` 의 state 손실 버그** — 기존엔 4개 필드(`phase`, `spec`, `planAccepted`, `lastTestPass`)만 백업/복원하여 `branch`, `baseBranch` 가 update 후 영구 소실되던 문제. 이제 6개 필드를 `jq * merge` 로 일괄 보존 (→ spec-x-update-preserve-state)
- **`install.sh` 의 state 템플릿** — 신규 설치 시 `baseBranch: null` 필드 명시 추가. `sdd phase new --base` 모드 사용 시 update 후에도 일관된 스키마 유지

### Tests
- `tests/test-update.sh` — `branch`/`baseBranch` 보존, `planAccepted`/`lastTestPass` 보존, `kitVersion` 동기화(state.json == installed.json == VERSION), 신규 install 직후 `baseBranch` 필드 존재 검증 추가 (총 11 checks)

---

## [0.6.0] — 2026-04-23

### Added
- **`sdd doctor`** — 설치 환경 진단 체크리스트 (bash 4.0+, jq, git, gh 설치 여부 / `.harness-kit/installed.json` / `constitution.md` 접근 / hook 실행 권한). 종합 PASS/FAIL 판정 출력 (→ phase-13, spec-13-01)
- **`sdd pr-watch <pr-number>`** — PR merge 자동 감지 (30초 폴링, 60분 타임아웃). merge 감지 시 post-merge 절차 자동 출력. gh CLI 미설치 환경에서는 graceful skip (→ phase-13, spec-13-02)
- **`sdd run-test <cmd...>`** — 테스트 결과 자동 기록 wrapper. exit 0 시 `sdd test passed` 자동 호출로 수동 기록 불필요 (→ phase-13, spec-13-03)
- **`/hk-doctor` 슬래시 커맨드** — 설치 환경 점검을 Claude Code 안에서 한 단어로 실행

---

## [0.5.0] — 2026-04-16

### Changed
- **`sdd archive` → `sdd ship` 리네이밍** — 실제 동작에 맞는 이름으로 변경. 기존 `sdd archive` 호출은 deprecation 경고 후 동작 (→ phase-11에서 디렉토리 아카이브로 교체)
- **식별자 2자리 패딩** — `phase-01`, `spec-01-01` 형식. 파일 시스템 정렬 보장
- **zsh 호환 코드 제거** — bash 4.0+ 전용. `_self()` ZSH 분기, `install.sh --shell=zsh`, `test-zsh-compat.sh` 삭제

### Added
- **`sdd archive [--keep=N] [--dry-run]`** — 완료된 phase의 spec/backlog를 `archive/` 디렉토리로 이동
- **아카이브 검색 통합** — `sdd spec list`, `sdd phase list/show` 등에서 `archive/` fallback + `(archived)` 표시
- **`/hk-archive` 슬래시 커맨드** — dry-run 미리보기 → 확인 → 실행 대화형 UX
- **`sdd status` 아카이브 진단** — specs/ 20개+ 시 아카이브 제안, archive 항목 수 표시
- **walkthrough 실시간 갱신** — `sdd spec new` 시 walkthrough.md 생성, Strict Loop step 7 추가

### Removed
- `test-zsh-compat.sh`
- `docs/REFERENCE.md` (README.md에 통합)
- `install.sh --shell` 옵션 및 `do_fix_shebang()`

---

## [0.4.0] — 2026-04-11

### Added
- **5개의 PreToolUse 훅 신규 추가**
  - `check-commit-msg` — 커밋 메시지 형식 검증 (`type(spec-NN-NN): 설명` 패턴)
  - `check-diff-size` — 비정상적으로 큰 diff 감지 (기본 임계값: 500줄, `HARNESS_DIFF_LIMIT` 으로 조정)
  - `check-scope` — 스펙 범위 이탈 감지
  - `check-secrets` — 시크릿/자격증명 노출 방지 (API 키, 토큰 패턴 스캔)
  - `check-task-checkbox` — task.md 체크박스 업데이트 검증 (One Task = One Commit 강제)
- **`update.sh` 버전 인식 마이그레이션 시스템** — 설치 버전 비교 후 마이그레이션 자동 실행
- **`CHANGELOG.md`** — 버전 히스토리 관리 파일 신설
- 모델 분배 전략 문서화 (`agent.md` — Opus=판단/기획, Sonnet=구현, Opus sub-agent=리뷰/분석)
- `update.sh` — `--shell=` 옵션 패스스루 지원

### Removed
- `/hk-spec-review` 슬래시 커맨드 — `/hk-code-review` 로 통합됨

### Changed
- Task 자동 진행 규칙 변경 (spec-6-002)
- README 전면 재작성 (현재 디렉토리 구조 반영)

### Migration (0.3.x → 0.4.0)
`update.sh` 실행 시 자동으로:
- `.claude/commands/hk-spec-review.md` 제거 (폐기된 커맨드)
- 구 명칭 커맨드 제거 — `hk-` prefix 이전 파일명 (`align.md`, `spec-new.md`, `plan-accept.md` 등)
- `.harness-backup-*` 임시 디렉토리 정리 안내 (git history 로 대체됨)
- 신규 훅 모드 설정 안내 출력

---

## [0.3.0] — 2026-04-10

### Added
- **슬래시 커맨드 `hk-` prefix 일괄 적용** (spec-6-001) — 충돌 방지 및 네임스페이스 정리
- `/hk-code-review` — 독립 서브에이전트 코드 리뷰 커맨드 (Opus 모델)
- `/hk-bb-pr` — Bitbucket Cloud PR 지원 (토큰 기반 인증)
- `zsh` 네이티브 스크립트 모드 (`--shell=zsh` 옵션, macOS 기본 zsh 사용 가능)
- Phase 4 도그푸딩 — harness-kit 자기 자신에 install 적용

### Changed
- 훅 모드 분리 (`warn` / `block` / `off`) 및 전환 UX
- 거버넌스 문서 중복 제거 및 실효성 정리 (spec-2-001)
- CLAUDE.md 2단계 로딩 전략 도입 (user/project 분리, spec-2-002)

### Removed
- `.harness-backup-*` 자동 생성 중단 — git history 가 보호 수단으로 충분
- 하드코딩 백업 참조 코드 제거

---

## [0.2.0] — 2026-04 (Phase 2)

### Added
- 훅 경고/차단 모드 분리 (`HARNESS_HOOK_MODE`, `HARNESS_HOOK_MODE_{NAME}`)
- CLAUDE.md 2단계 로딩 전략 — 거버넌스 중복 방지
- 권한 프롬프트 마찰 해소 (spec-1-001) — Claude Code 권한 사전 등록

---

## [0.1.0] — 2026-04 (Phase 1)

### Added
- 최초 릴리스
- `install.sh` / `uninstall.sh` / `doctor.sh` 기본 구조
- Claude Code 전용 SDD 거버넌스 부트스트랩
- Pre-commit 훅 3종 — `check-branch`, `check-plan-accept`, `check-test-passed`
- `sdd` CLI 메타 명령 (status, phase, spec, plan, task, archive 등)
- NestJS / Generic 스택 어댑터
- 슬래시 커맨드 초기 세트 (align, spec-new, plan-accept, spec-status, handoff, gh-pr)
