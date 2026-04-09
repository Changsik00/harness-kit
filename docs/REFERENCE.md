# harness-kit 레퍼런스

> 모든 명령/슬래시/hook/파일/환경변수의 사전식 레퍼런스.
> 워크플로 가이드는 [USAGE.md](./USAGE.md) 를 보세요.

## 키트 진입점 (키트 디렉토리에서 실행)

| 명령 | 설명 |
|---|---|
| `install.sh [TARGET]` | 대상 프로젝트에 키트 설치 |
| `update.sh [TARGET]` | 기존 설치 갱신 (state 보존) |
| `uninstall.sh [TARGET]` | 제거 (산출물 보존, 안전 백업) |
| `doctor.sh [TARGET]` | 설치 상태 점검 |

### install.sh 옵션
| 옵션 | 의미 |
|---|---|
| `--dry-run` | 변경 없이 계획만 출력 |
| `--force` | 기존 파일 백업 없이 덮어쓰기 |
| `--no-hooks` | hooks 설치 생략 |
| `--stack=NAME` | 스택 자동 감지 무시하고 강제 지정 (`generic`, `nodejs`, `nestjs`) |
| `--yes` / `-y` | 확인 프롬프트 생략 |

### uninstall.sh 옵션
| 옵션 | 의미 |
|---|---|
| `--keep-state` | `.claude/state/` 보존 |
| `--yes` / `-y` | 확인 프롬프트 생략 |

---

## bin/sdd — 메타 명령 (대상 프로젝트에서 실행)

> 설치 후 위치: `<target>/scripts/harness/bin/sdd`

### 일반
| 명령 | 설명 |
|---|---|
| `sdd help` | 도움말 |
| `sdd version` | 키트 버전 |

### status
| 명령 | 설명 |
|---|---|
| `sdd status` | 사람용 색상 출력 (기본) |
| `sdd status --brief` | 한 줄 요약 (`SessionStart` hook 가 사용) |
| `sdd status --verbose` | 자세히 (git log, 변경 파일 포함) |
| `sdd status --json` | JSON 출력 (스크립트/툴 연동용) |

### phase
| 명령 | 설명 |
|---|---|
| `sdd phase new <slug>` | 새 `backlog/phase-{N}.md` 단일 파일 생성, queue.md 갱신, active 설정 |
| `sdd phase done [N]` | phase 를 완료 처리 (queue.md 의 done 으로 이동) |
| `sdd queue` | `backlog/queue.md` 출력 (대시보드) |
| `sdd phase list` | 모든 phase 와 spec 수, active 표시 |
| `sdd phase show [N]` | phase 상세 (N 생략 시 active) |

### spec
| 명령 | 설명 |
|---|---|
| `sdd spec new <slug>` | active phase 안에 새 SPEC 생성 (5종 템플릿 복사) |
| `sdd spec list [--phase=N]` | spec 목록 |
| `sdd spec show [spec-N-NNN-slug]` | spec 상세 (생략 시 active) |

### plan
| 명령 | 설명 |
|---|---|
| `sdd plan accept` | plan.md/task.md 검증 후 `planAccepted=true` |
| `sdd plan reset` | `planAccepted=false` (다음 spec 시작 전 호출) |

### task
| 명령 | 설명 |
|---|---|
| `sdd task done <num>` | task.md 의 N 번째 미완 항목을 `[x]` 로 마킹 |

### test
| 명령 | 설명 |
|---|---|
| `sdd test passed` | `lastTestPass = now` 기록 (commit 직전 호출) |

### archive
| 명령 | 설명 |
|---|---|
| `sdd archive --check` | walkthrough/pr_description 검증만 (변경 없음) |
| `sdd archive` | 검증 + git add + commit |

---

## 슬래시 커맨드 (Claude Code 안에서)

> 위치: `<target>/.claude/commands/*.md`

| 슬래시 | 설명 | 호출 시점 |
|---|---|---|
| `/align` | 세션 부트스트랩 (constitution 로드, 상태 보고, 단 하나의 질문) | 새 세션마다 |
| `/spec-new <slug>` | 새 SPEC 생성 + spec.md 작성 시작 | 새 작업 단위마다 |
| `/plan-accept` | plan.md 명시적 승인 → Strict Loop 시작 | plan/task 작성 완료 후 |
| `/spec-status` | 현재 진행 상태 자세히 + 다음 task 미리보기 | 언제든 |
| `/handoff` | 검증 + archive + push 안내 | 모든 task 완료 후 |

---

## Hook (Claude Code 가 자동 호출)

> 위치: `<target>/scripts/harness/hooks/*.sh`
> 등록: `<target>/.claude/settings.json` 의 `hooks` 키 (install.sh 가 자동 등록)

| Hook | Matcher | 검사 | 차단 시점 |
|---|---|---|---|
| `check-branch.sh` | `Bash` | `git commit` / `git push` 가 main 브랜치인지 | constitution §9.1 |
| `check-plan-accept.sh` | `Edit\|Write\|MultiEdit` | 안전 경로(agent/, *.md, ...) 외에서 `planAccepted=true` 인지 | constitution §4.3 |
| `check-test-passed.sh` | `Bash` | `git commit` 시 lastTestPass 가 N분 내인지 | constitution §8.1 |

### Hook 모드 (HARNESS_HOOK_MODE)
| 값 | 동작 |
|---|---|
| `warn` (기본) | 위반 시 stderr 메시지만 출력, exit 0 (통과) |
| `block` | 위반 시 stderr 메시지 + exit 2 (차단) |
| `off` | 즉시 통과 (검사 자체 비활성) |

설정:
```bash
export HARNESS_HOOK_MODE=block       # 영구
HARNESS_HOOK_MODE=off git commit ... # 일회성
```

### check-test-passed.sh 임계 조정
```bash
export HARNESS_TEST_WINDOW_MIN=60    # 기본 30
```

### 면제 규칙 (check-test-passed.sh)
- `docs(...)`, `chore(...)`, `style(...)` commit subject 는 검사 면제

---

## 디렉토리 구조 (설치 후 대상 프로젝트)

```
<target>/
├── agent/                              # 거버넌스 + 템플릿
│   ├── constitution.md
│   ├── agent.md
│   ├── align.md
│   └── templates/
│       ├── phase.md
│       ├── spec.md
│       ├── plan.md
│       ├── task.md
│       ├── walkthrough.md
│       └── pr_description.md
│
├── .claude/                            # Claude Code 설정 + state
│   ├── settings.json                   # hooks 등록 + 권한 화이트리스트
│   ├── commands/                       # 슬래시 커맨드 5종
│   └── state/                          # 런타임 (gitignore)
│       └── current.json                # phase/spec/branch/planAccepted/lastTestPass
│
├── scripts/harness/                    # 키트 런타임
│   ├── bin/
│   │   ├── sdd                         # 메타 명령
│   │   └── lib/{common,state}.sh
│   ├── hooks/
│   │   ├── _lib.sh
│   │   ├── check-branch.sh
│   │   ├── check-plan-accept.sh
│   │   └── check-test-passed.sh
│   └── lib/stack.sh                    # 스택 어댑터 (install 시 선택된 것)
│
├── backlog/                            # phase 정의 = 평면 파일 (git 추적)
│   ├── queue.md                        #   대시보드 (sdd 자동 갱신)
│   ├── phase-1.md                      #   phase 1: spec 표 + 통합 테스트 + ADR 참조
│   ├── phase-2.md
│   └── ...
│
├── specs/                              # 실제 SPEC 작업 = work log (평면, git 추적)
│   ├── spec-1-001-{slug}/
│   │   ├── spec.md                     #   phase-1.md 의 spec-1-001 항목을 *구체화*
│   │   ├── plan.md
│   │   ├── task.md
│   │   ├── walkthrough.md
│   │   └── pr_description.md
│   ├── spec-1-002-{slug}/
│   └── spec-2-001-{slug}/
│
├── docs/decisions/                     # ADR (phase-x.md / spec.md 가 link 참조)
│   └── ADR-{NNN}-{slug}.md
│
└── CLAUDE.md                           # 사용자 내용 + HARNESS-KIT 블록
```

---

## .claude/state/current.json 스키마

```json
{
  "kitVersion": "0.1.0",
  "stack": "nestjs",
  "phase": "phase-1",
  "spec": "spec-1-001-webhook-lock-fail-throw",
  "branch": null,
  "planAccepted": false,
  "lastTestPass": "2026-04-09T10:30:00Z",
  "installedAt": "2026-04-09T02:57:15Z"
}
```

| 키 | 의미 | 갱신 주체 |
|---|---|---|
| `kitVersion` | 설치된 키트 버전 | install/update |
| `stack` | 스택 어댑터 이름 | install |
| `phase` | active phase ID (없으면 `null`) | `sdd phase new` |
| `spec` | active spec ID (없으면 `null`) | `sdd spec new` |
| `branch` | 현재 작업 브랜치 (참고용) | (선택) |
| `planAccepted` | Plan Accept 상태 | `sdd plan accept/reset` |
| `lastTestPass` | 마지막 테스트 통과 ISO8601 (UTC) | `sdd test passed` |
| `installedAt` | 최초 설치 시각 | install |

---

## 환경변수

| 변수 | 기본값 | 설명 |
|---|---|---|
| `HARNESS_HOOK_MODE` | `warn` | hook 동작 모드 (`warn` / `block` / `off`) |
| `HARNESS_TEST_WINDOW_MIN` | `30` | check-test-passed.sh 의 lastTestPass 만료 (분) |
| `HARNESS_STACK_*` | (스택 어댑터가 export) | `_TEST_CMD`, `_LINT_CMD`, `_BUILD_CMD` 등 |

---

## 스택 어댑터

위치: `<kit>/stacks/*.sh` → 설치 시 `<target>/scripts/harness/lib/stack.sh` 로 복사

| 스택 | 감지 | 동작 |
|---|---|---|
| `nodejs` | `package.json` 존재 | 패키지 매니저 자동 감지 후 `<pm> test` / `<pm> run lint` / `<pm> run build` 등 |
| `generic` | 그 외 | placeholder (사용자가 직접 채워야 함) |

### nodejs 어댑터의 패키지 매니저 자동 감지

런타임에 매번 재감지합니다 (사용자가 마이그레이션하면 키트도 자동으로 따라옴).

| 우선순위 | 감지 방법 | 결과 |
|:---:|---|---|
| 1 | `package.json` 의 `"packageManager"` 필드 (corepack 표준) | 명시된 PM |
| 2 | `pnpm-lock.yaml` 존재 | `pnpm` |
| 3 | `yarn.lock` 존재 | `yarn` |
| 4 | `bun.lockb` 존재 | `bun` |
| 5 | `package-lock.json` 존재 | `npm` |
| 6 | (그 외) | `npm` (fallback) |

### nodejs 어댑터가 export 하는 변수

| 변수 | 값 예시 (pnpm) |
|---|---|
| `HARNESS_PKG_MANAGER` | `pnpm` |
| `HARNESS_BIN_RUNNER` | `pnpm exec` (npm 은 `npx`, bun 은 `bunx`, yarn 은 `yarn`) |
| `HARNESS_TEST_CMD` | `pnpm test` |
| `HARNESS_LINT_CMD` | `pnpm run lint` |
| `HARNESS_BUILD_CMD` | `pnpm run build` |
| `HARNESS_TYPECHECK_CMD` | `pnpm exec tsc --noEmit` |
| `HARNESS_TEST_INTEGRATION_CMD` | `pnpm run test:e2e` (있으면) 또는 `pnpm test` |
| `HARNESS_TEST_FILE_GLOB` | `*.{test,spec}.{js,ts,jsx,tsx,mjs,cjs}` |
| `HARNESS_INTEGRATION_TEST_FILE_GLOB` | `*.{e2e-spec,e2e}.{js,ts}` |

### 신규 스택 추가 시
1. `stacks/<name>.sh` 에 `HARNESS_*` 변수들 export
2. `install.sh` 의 `detect_stack()` 에 감지 로직 추가
3. install 시 `--stack=<name>` 로 강제 지정 가능

---

## 거버넌스 빠른 참조

| | |
|---|---|
| **One Spec = One PR** | constitution §4.1 |
| **Plan Accept 전 코드 편집 금지** | constitution §4.3 |
| **One Task = One Commit** | constitution §7 |
| **No Test, No Commit** | constitution §8.1 |
| **main 브랜치 직접 작업 금지** | constitution §9.1 |
| **commit subject 포맷** | `<type>(spec-{phaseN}-{seq}): <description>` (모두 소문자, constitution §9.2) |
| **branch 포맷** | `spec-{phaseN}-{seq}-{slug}` (브랜치 = spec 디렉토리, `feature/` prefix 없음) |
| **모든 산출물 한국어** | constitution §4.4 |

---

## 키트 디렉토리 구조 (개발자 시점)

```
harness-kit/
├── README.md, CLAUDE.md, VERSION, .gitignore
├── install.sh, update.sh, uninstall.sh, doctor.sh
│
├── sources/                  # 대상 프로젝트로 *복사될* 파일들
│   ├── governance/           # constitution, agent, align
│   ├── templates/            # 6종 템플릿
│   ├── commands/             # 5종 슬래시 커맨드
│   ├── hooks/                # 3종 hook + _lib.sh
│   ├── bin/                  # sdd + lib/{common,state}.sh
│   └── claude-fragments/     # settings.json / CLAUDE.md fragment
│
├── stacks/                   # 스택 어댑터 (install 시 1개 선택 복사)
│   ├── generic.sh
│   ├── nodejs.sh
│   └── nestjs.sh
│
├── tests/fixtures/           # 자체 검증용 임시 디렉토리
│
└── docs/
    ├── USAGE.md              # 본 가이드와 짝
    ├── REFERENCE.md          # 이 문서
    ├── design/               # Harness Engineering Review 등
    └── decisions/            # ADR
```
