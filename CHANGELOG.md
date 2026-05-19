# CHANGELOG

harness-kit의 주요 변경 사항을 버전별로 정리합니다.
형식: [Semantic Versioning](https://semver.org/)

---

## [0.13.1] — 2026-05-19

> `sdd_find_root()` 파일시스템 앵커링 전환으로 다중 디바이스 환경의 rootDir 절대경로 크리티컬섹션 수정.

### Fixed
- `sdd_find_root()` — `harness.config.json`의 `rootDir` 절대경로 의존 제거, `.harness-kit/` 위치 기반 파일시스템 앵커링으로 교체. git 추적 상태에서 다른 디바이스/경로 환경의 사일런트 오작동 방지 (#143)
- `install.sh` — `harness.config.json` 출력에서 `rootDir` 필드 제거. 신규 설치 시 절대경로 미저장 (#143)
- `sources/hooks/check-branch.sh` — 주석의 constitution 섹션 번호 `§9.1` → `§10.1` 수정 (#143)

---

## [0.13.0] — 2026-05-19

> `sdd config precheck` CLI로 PR 사전 검증 명령 등록·관리. installed.json 기반 동적 task.md 동기화.

### Added
- `sdd config precheck list` — installed.json에 등록된 precheck 명령 목록 출력 (#141)
- `sdd config precheck add <command>` — precheck 명령 추가. 중복 시 warn + skip. 활성 spec task.md의 `<!-- sdd:precheck:start/end -->` 마커 자동 동기화 (#141)
- `sdd config precheck remove <index>` — 1-기반 인덱스로 precheck 제거. 마커 자동 동기화 (#141)

---

## [0.12.2] — 2026-05-19

> sdd specx new Branch 필드 중복 버그 + 테스트 glob 불일치 수정.

### Fixed
- `sdd specx new <slug>` 생성된 `spec.md` Branch 필드 중복 수정 — `spec-x-foo-foo` → `spec-x-foo` (#139)
- `tests/test-uninstall-cmd-list.sh` Scenario 1 glob `hk-*.md` → `*.md` (install.sh 동작과 일치) (#139)

---

## [0.12.1] — 2026-05-18

> kit 업데이트 알림 전달 버그 수정 + 에이전트 직접 실행 UX 개선. 디렉토리별 CLAUDE.md 도입.

### Added
- `sources/CLAUDE.md`, `specs/CLAUDE.md` — 디렉토리 특화 컨텍스트 (kit-origin / work-log 시점 분리) (#136)

### Fixed
- `sdd status --brief` 에 `→UPDATE:X.Y.Z` suffix 추가 — SessionStart compact 포맷에 업데이트 알림 포함되어 에이전트에 안정적으로 도달 (#137)
- `/hk-update` step 5: 사용자 승인 시 에이전트가 `bash <(curl...) --update` 직접 실행 (임시 동의 기반). 거절 시 `!` prefix 수동 안내 (#137)
- SessionStart IMPORTANT 에코에 `→UPDATE:` 패턴 감지 지시 추가 (#137)

### Changed
- `root CLAUDE.md` 슬림화 — 릴리스 전략 섹션을 `docs/release-strategy.md` 로 분리 (108→71줄) (#135)
- `agent.md §6.6` docs-only task dispatch 예외 명시 — 순수 마크다운 작업은 main thread 에서 처리 (FF)
- `README.md` — 누락된 커맨드 4개, sdd 서브커맨드 4개, 모델 분배 예외 노트 동기화 (FF)

---

## [0.12.0] — 2026-05-18

> UX 토글 + 아카이브 통합 검색. `uxMode` 가 한 번에 뒤집히고, archived spec/ADR/RCA 가 grep wrapper 로 닿는다.

### Added
- `sdd config ux-mode toggle` — 현재값 자동 반전 (interactive ↔ text) (#132)
- `/hk-ask-mode` 슬래시 커맨드 — uxMode 토글 단일 명령 (#132)
- `sdd search <keyword> [--scope=<s>] [--ignore-case]` — 마크다운 자산 통합 검색 wrapper. scope: `all`(기본) / `active` / `archive` / `decisions` / `rca` / `backlog`. 카테고리별 그룹 헤더 + `<rel path>:<line>:<text>` 출력 (#133)
- `tests/test-sdd-search.sh` — fixture 기반 8 시나리오 단위 테스트 (#133)

### Changed
- `agent.md §8.4` AskUserQuestion Tool Preference — 변경 방법 안내에 `toggle` 액션 + `/hk-ask-mode` 슬래시 명시 (#132)

### Fixed
- `sdd search` 단일 파일 scope 결과 경로 누락 — `grep -H` 추가로 always-prefix path (single-file 디렉토리 회귀 방지 테스트 포함) (#133)

---

## [0.11.0] — 2026-05-17

> Planning Economy (SDD ceremony 비용 인식 + phase 내 inter-spec 재검증) + state.json 단일평면 footgun 가드.

### Added
- `agent.md §11` Planning Economy & Inter-Spec Re-Validation — SDD ceremony 비용 인식 (6-8K 토큰), scope economy thresholds (FF / spec-x / spec), phase 내 매 spec 시작 시 재검증 4 질문 (#129)
- `sources/bin/sdd cmd_spec_new` pre-spec validation — phase 활성 + 직전 merged spec 존재 시 walkthrough carry-over + 잔여 spec + 재검증 질문 자동 출력 (attention prompt, not gate) (#129)
- `docs/decisions/ADR-002-planning-economy.md` — Planning Economy 거버넌스 결정 기록 (type: decision) (#129)
- `sources/bin/lib/state.sh die_if_active_spec` helper — 활성 spec(spec-x 또는 SDD-P) 존재 시 die 하고 컨텍스트별 해결 명령 안내 (#130)
- `tests/test-sdd-state-guard.sh` — `phase activate` / `phase new` / `spec new` 가드 + `--force` 우회 + 회귀 13 check (#130)

### Fixed
- `sources/bin/sdd phase_activate` / `phase_new` / `spec_new` — 활성 spec 컨텍스트 silent reset footgun 가드 추가. `--force` 플래그로 우회 가능 (`phase_new` 는 기존 플래그 의미 확장) (#130)

---

## [0.10.0] — 2026-05-17

> phase-17 — 운영 성숙도 (Operational Maturity). 외부 접근성 (`/hk` + curl) + 내부 신뢰성 (cache 분리 + integration test + governance/test 정합) 5 spec.

### Added
- `sources/commands/hk.md` — `/hk` 단일 진입점 슬래시 커맨드. `sdd status` 기반 8 상태 분기, 다음 행동 1 줄 안내 (#123)
- README onboarding (Step 1 의 `/hk` 진입점 안내, curl 인스톨러 명시) (#123)
- `tests/test-sdd-marker-idempotent.sh` — sdd CLI marker 멱등성 회귀 테스트 3/3 (#122)
- `tests/test-phase16-integration.sh` — phase-16 통합 시나리오 3 자동화. `phase-NN-integration.sh` 명명 규약 신설 (#124)
- `tests/test-phase17-integration.sh` — phase-17 통합 시나리오 4 (3 PASS / 1 skip) 자동화 (#126)
- README "슬래시 커맨드" 표에 `/hk`, `/hk-update` 행 추가 (review W3 해소) (release)
- `.harness-kit/cache.json` — `lastVersionCheck` / `latestKnownVersion` 캐시 필드 분리. `.gitignore` 추가 (#124)
- `doctor.sh` 확장 — `docs/rca/`, `docs/decisions/` optional dir + `rca.md` / `adr.md` 템플릿 점검 (#124)
- `sources/templates/adr.md` 의 stale 검사 경로 가이드 Note 블록 (#125)
- `CLAUDE.md` "릴리스 전략" 의 `Phase ship 시 CHANGELOG draft` 룰 (#125)

### Fixed
- `sources/bin/sdd` `cmd_spec_new` / `cmd_ship` / `queue_mark_done` marker 멱등성 — RCA-001 prevention 직접 구현 (#122)
- `sources/governance/constitution.md` §6.4 closure 표 "Used in" 열 표현 명확화 (`ADR only` / `RCA only` / `(shared)` 마크) (#125)
- `tests/test-drift-stale-adr.sh` Step 3 회귀 마커 self-contained 화 — `ADR-998-valid-paths-fixture` 사용 (#125)
- `install.sh` 가 신규 installed.json 에 cache 필드 작성하던 잔재 제거 (#126)
- `sources/commands/hk-update.md` 의 cache 갱신 destination 을 `.harness-kit/cache.json` 으로 정정 (#126)
- `.harness-kit/installed.json.installedCommands` 에 신규 `hk` 추가 (도그푸딩 매니페스트 정합) (#126)
- `backlog/queue.md` Icebox 의 spec-17-02 / spec-17-03 매핑 swap (#126)

### Changed
- phase-17 재정의: "정합성 fix (3 spec)" → "운영 성숙도 (4 spec + pre-ship sweep)" — 사용자 피드백 (phase 단위 피로감) 반영 (#123)

---

## [0.9.1] — 2026-05-13

### Added
- `sources/hooks/check-kit-version.sh` — SessionStart hook 에서 새 kit 버전 알림. 24h 캐시 공유, 어떤 실패도 silent skip, `HARNESS_HOOK_MODE_KIT_VERSION=off` 로 비활성 가능 (#112)
- `sources/claude-fragments/settings.json.fragment` SessionStart 배열에 `check-kit-version` hook entry 등록 (#112)

### Changed
- `sources/commands/hk-update.md` §5 안내를 **원격 curl 1차 + 로컬 fallback 2차** 형태로 전환 — 로컬 kit clone 없이 `bash <(curl ...) --update` 한 줄로 갱신 가능 (#111)
- `sources/bin/sdd` 의 kit 새 버전 알림 문구를 `/hk-update` 단일 진입점으로 단순화 (#111)
- `README.md` 키트 진입점 표에 원격 갱신 명령 행 추가 (#111)

---

## [0.9.0] — 2026-05-12

### Added
- `sdd config ux-mode [interactive|text]` 커맨드 — `installed.json` `uxMode` 필드 조회/변경 (#108)
- `agent.md §8.4` AskUserQuestion 툴 사용 가이드라인 — 주요 결정 포인트에서 SHOULD, `uxMode` 필드 연동 (#108)
- `installed.json` 기본값에 `"uxMode": "interactive"` 추가 — install.sh 신규 설치 시 포함 (#108)
- `agent.md §8.1` 파일 경로 리스팅 규칙 — 전체 상대경로 한 줄 출력, indented 포맷 금지 (#109)

### Fixed
- `sdd status` / `sdd version` kitVersion SSOT를 `installed.json`으로 수정 — `current.json`(gitignored) 의존 제거 (#107)
- `sdd spec show` 파일 목록 → 전체 상대경로 출력 — Claude Code에서 클릭-열기 가능 (#109)
- `hk-ship.md` Push 정보 블록 → Markdown 테이블 — 렌더링 일관성 (#109)

---

## [0.8.0] — 2026-05-10

### Added
- `sdd archive` 가 완료된 spec-x 디렉토리도 정리 — `queue.md` done 섹션 등록 기준 (#102)
- `agent.md §6.3.2` Post-Merge Protocol for Phase 신설 — base/non-base mode 분기 + Phase living decision log (#105)
- `agent.md §6.7` Workflow Patterns 신설 — model transparency, parallel-by-default, background (visibility 룰 포함: 침묵 금지, Monitor/peek 으로 진척 노출), sub-agent dispatch threshold, archive timing, version+CHANGELOG paired update (THIS)
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
