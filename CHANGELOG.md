# CHANGELOG

harness-kit의 주요 변경 사항을 버전별로 정리합니다.
형식: [Semantic Versioning](https://semver.org/)

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
