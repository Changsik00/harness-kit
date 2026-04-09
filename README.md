# harness-kit

> **Claude Code 를 위한 SDD (Spec-Driven Development) 거버넌스 부트스트랩 툴킷**
> 한 번 만들어두고, 다음 프로젝트에서는 한 줄로 같은 하네스를 깐다.

[![version](https://img.shields.io/badge/version-0.1.0-blue)](./VERSION)
[![target](https://img.shields.io/badge/target-macOS%20%2B%20Claude%20Code-green)](#-대상-환경-target-platform)
[![status](https://img.shields.io/badge/status-alpha-orange)](#-현재-진행-상태)

---

## 🎯 프로젝트 목표

Claude Code 를 *그냥 쓰면* 강력한 일반 비서지만, **반복 가능한 절차** 와 **위반 방지** 는 약합니다.
이 키트는 그 격차를 다음 4가지로 메꿉니다:

| 1 | **거버넌스** | constitution / agent.md 로 에이전트 행동 규약을 *명문화* |
| :---: | --- | --- |
| **2** | **자동 강제** | hook 으로 main 브랜치 작업·Plan Accept 우회·테스트 미실행 commit 을 *물리적으로* 차단 |
| **3** | **재현성** | 슬래시 커맨드와 `bin/sdd` 메타 명령으로 자주 하는 절차를 *한 단어로* |
| **4** | **재사용** | install.sh 한 번으로 *다음 프로젝트* 에 같은 환경 즉시 도입 |

> 즉, "**의도(Intent)** 를 문서로 적는 것" 에서 끝나지 않고 "**강제(Enforcement)** 까지 코드로 박는다" 가 핵심입니다.

---

## 🖥 대상 환경 (Target Platform)

본 키트는 **macOS + Claude Code + zsh** 조합을 1차 타깃으로 설계·검증되었습니다.

| 항목 | 지원 등급 | 비고 |
|---|:---:|---|
| **OS — macOS** | ✅ **1차** | 14+ (Sonoma) 에서 검증, Apple Silicon / Intel 모두 |
| **OS — Linux** | △ best-effort | bash 4.0+, jq, git 이 있으면 동작 가능성 높음 (미검증) |
| **OS — Windows** | ❌ 미지원 | WSL2 안에서는 Linux 와 동일 (best-effort) |
| **AI 호스트 — Claude Code** | ✅ **1차** | `.claude/` 구조 + slash commands + hooks + settings.json 형식에 의존 |
| **AI 호스트 — 기타** | ❌ | Cursor / Cline / Continue 등은 어댑터 별도 (로드맵 외) |
| **Shell** | zsh ✅ / bash ✅ | 사용자 환경은 zsh 가정. 모든 스크립트는 `#!/usr/bin/env bash` |
| **언어 스택 (자동 감지)** | nodejs (npm/pnpm/yarn/bun) | 그 외 generic 폴백 |

### 필수 의존성 (Homebrew 권장)

```bash
brew install bash jq git
# bash 는 macOS 시스템 기본이 3.2 라 4.0+ 가 필요합니다 (키트가 일부 4+ 문법 사용)
```

> 본 README 와 모든 문서의 명령 예시는 **macOS + zsh + Homebrew** 환경을 전제합니다.

---

## ⚡ Quick Start (3 분)

### 1. 키트가 있는 위치 확인

이 저장소가 `~/Project/ai/claude` 에 있다고 가정합니다.

```bash
cat ~/Project/ai/claude/VERSION    # 0.1.0
```

### 2. 대상 프로젝트에 install

```bash
~/Project/ai/claude/install.sh ~/Project/my-app

# 미리 보기 (변경 없음)
~/Project/ai/claude/install.sh --dry-run ~/Project/my-app

# 점검
~/Project/ai/claude/doctor.sh ~/Project/my-app
```

### 3. Claude Code 켜고 부트스트랩

```bash
cd ~/Project/my-app
claude
```

Claude Code 안에서:

```
/align
```

`/align` 슬래시 커맨드가 자동으로:
1. constitution / agent / align 규약을 로딩
2. `bin/sdd status` 로 현재 상태 확인
3. **단 하나의 질문**: "어떤 컨텍스트로 진행할까요?"

이 시점에서 사용자가 결정합니다 — 새 phase 시작? 기존 spec 이어서? 다른 일?

---

## 📦 install.sh 가 깔아주는 것

대상 프로젝트에 다음 디렉토리/파일이 생깁니다 (기존 파일은 안전 백업):

```
<target>/
├── agent/                          # ← 거버넌스
│   ├── constitution.md             #    무조건 지키는 헌법
│   ├── agent.md                    #    에이전트 작업 절차
│   ├── align.md                    #    /align 부트스트랩
│   └── templates/                  #    6종 산출물 양식
│       ├── phase.md, spec.md, plan.md, task.md
│       └── walkthrough.md, pr_description.md
│
├── .claude/                        # ← Claude Code 통합
│   ├── settings.json               #    permissions + hooks (jq 머지)
│   ├── commands/                   #    슬래시 커맨드 5종
│   │   ├── align.md, spec-new.md, plan-accept.md
│   │   └── spec-status.md, handoff.md
│   └── state/current.json          #    런타임 state (gitignore)
│
├── scripts/harness/                # ← 키트 런타임
│   ├── bin/sdd                     #    메타 명령
│   ├── bin/lib/{common,state}.sh
│   ├── hooks/                      #    PreToolUse 후크
│   │   ├── _lib.sh
│   │   ├── check-branch.sh         #    main 보호
│   │   ├── check-plan-accept.sh    #    PLANNING 모드 가드
│   │   └── check-test-passed.sh    #    No Test, No Commit
│   └── lib/stack.sh                #    자동 감지된 스택 어댑터
│
├── backlog/                        # ← phase 정의 (TODO list 성향, git 추적)
│   ├── phase-1/
│   │   ├── phase.md                #    배경/목표/spec 표
│   │   └── integration-tests.md    #    phase 통합 테스트 계획
│   ├── phase-2/
│   └── ...
│
├── specs/                          # ← 실제 SPEC 작업 (work log, 평면 배치)
│   ├── spec-1-001-{slug}/
│   │   ├── spec.md, plan.md, task.md
│   │   └── walkthrough.md, pr_description.md
│   ├── spec-1-002-{slug}/
│   ├── spec-2-001-{slug}/
│   └── ...
│
└── CLAUDE.md                       # ← HARNESS-KIT 블록 추가 (사용자 내용 보존)
```

> **명명 규칙 (전부 소문자, 하이픈 구분)**
> - Phase ID: `phase-{N}` — `backlog/phase-{N}/`
> - Spec ID:  `spec-{phaseN}-{seq}` — `specs/spec-{phaseN}-{seq}-{slug}/`
> - **Branch**: `spec-{phaseN}-{seq}-{slug}` (브랜치 = spec 디렉토리 이름, **`feature/` prefix 없음**)
> - **Commit**: `<type>(spec-{phaseN}-{seq}): <설명>` (예: `feat(spec-1-001): webhook 락 실패 시 throw`)

### 사용자 보존 (멱등성)
- `.claude/settings.json` 의 기존 `permissions`, `env` 같은 키는 **합쳐짐 (union)**, hooks 만 키트가 권위
- `CLAUDE.md` 의 사용자 내용은 그대로, HARNESS-KIT 블록만 추가
- 두 번째 install (멱등): 중복 없음
- `update.sh` 로 키트 갱신 가능

---

## 🎬 사용 예시 — 한 SPEC 의 일생

> NestJS + pnpm 프로젝트에서 "결제 안정성" 을 다루는 PHASE 의 첫 SPEC 을 처음부터 끝까지 끌고가는 시나리오.

### Scene 1 — 새 Phase 시작

사용자: *"이전 코드 리뷰의 critical 이슈 4개를 한 phase 로 묶고 싶어."*

Claude Code (모델):
```bash
$ ./scripts/harness/bin/sdd phase new payment-stability
[sdd] phase 생성: phase-1  (제목: payment-stability)
✓ 생성 완료: backlog/phase-1
✓ active phase 설정: phase-1
```

이어서 모델이 `backlog/phase-1/phase.md` 를 사용자와 함께 작성합니다 (배경, 목표, 성공 기준, 포함될 SPEC 목록 등). **이 시점은 PLANNING 모드** — 코드 편집 불가.

### Scene 2 — 첫 SPEC 만들기

```bash
$ ./scripts/harness/bin/sdd spec new webhook-lock-fail-throw
[sdd] spec 생성: spec-1-001-webhook-lock-fail-throw
✓ 생성 완료: specs/spec-1-001-webhook-lock-fail-throw
✓ active spec 설정: spec-1-001-webhook-lock-fail-throw

다음 단계:
  1. spec.md 작성
  2. plan.md 작성
  3. task.md 작성
  4. 사용자 검토 후 sdd plan accept
  5. 첫 task: git checkout -b spec-1-001-webhook-lock-fail-throw
```

모델이 spec.md / plan.md / task.md 를 한국어로 작성. plan.md 의 핵심 주장:

> *"`webhooks.service.ts:44` 의 `if (!token) return fn();` 폴백을 `throw` 로 바꾼다. 다중 Pod 환경에서 Redis 락 실패 시 그냥 진행하던 것을 자연스러운 재시도 흐름으로 전환."*

### Scene 3 — Plan Accept (실행 모드 진입)

사용자가 `specs/spec-1-001-webhook-lock-fail-throw/{spec,plan,task}.md` 를 검토 후:
```
/plan-accept
```

모델:
```bash
$ ./scripts/harness/bin/sdd plan accept
✓ Plan Accepted: spec-1-001-webhook-lock-fail-throw
  hook (check-plan-accept) 가 production 코드 편집을 통과시킵니다.
  이제 task.md 의 첫 task 부터 Strict Loop 진행하세요.
```

### Scene 4 — Hook 가 실수를 잡아주는 순간

모델: *"좋아, 첫 task 는 테스트 작성이지. 바로 시작..."*

```bash
$ git commit -m "test(spec-1-001): add failing test"
```

```
❌ [hook:block] main 브랜치 직접 작업 금지 (constitution §9.1)
   현재 브랜치: main
   명령:        git commit -m "test(spec-1-001): add failing test"
   해결: feature 브랜치 생성 후 다시 시도
          git checkout -b spec-{N}-{NNN}-{slug}
```

모델: *"아 main 이었네요. 브랜치 만들고 다시 진행하겠습니다."*

```bash
$ git checkout -b spec-1-001-webhook-lock-fail-throw
$ git commit -m "test(spec-1-001): add failing test for lock fallback"
✓ commit 통과
```

### Scene 5 — Strict Loop (한 task = 한 commit)

```bash
# Task 1-2: 테스트 작성 (Red)
$ pnpm test -- webhooks.service       # FAIL ✗
$ git commit -m "test(spec-1-001): add failing test for lock fallback"
$ ./scripts/harness/bin/sdd test passed
$ ./scripts/harness/bin/sdd task done 1
✓ task #1 완료 마킹

# Task 1-3: 구현 (Green)
# webhooks.service.ts:44 한 줄 수정
$ pnpm test -- webhooks.service       # PASS ✓
$ git commit -m "fix(spec-1-001): throw on lock acquisition failure"
$ ./scripts/harness/bin/sdd test passed
$ ./scripts/harness/bin/sdd task done 2
```

각 task 마다 모델이 사용자에게 보고 + 다음 진행 신호 대기 (constitution §6.1 Strict Loop).

### Scene 6 — Hand-off

모든 task 완료 후:

```bash
$ ./scripts/harness/bin/sdd archive --check
✓ archive 검증 통과 (변경 없음)

$ ./scripts/harness/bin/sdd archive
[sdd] git add ...
✓ archive commit 완료
# 결과 commit: docs(spec-1-001): archive walkthrough and pr description

$ git push -u origin spec-1-001-webhook-lock-fail-throw

$ ./scripts/harness/bin/sdd plan reset
✓ Plan Accept 해제. 다음 spec 을 위해 깨끗한 상태로 전환됨.
```

모델:
> ✅ Push 완료. PR 본문에 `specs/spec-1-001-webhook-lock-fail-throw/pr_description.md` 를 그대로 복사해서 hosted git UI 에서 PR 만들어 주세요.

---

## 🧭 워크플로 한 장 요약

```
┌─────────────────────────────────────────────────────────────────┐
│  /align (새 세션)                                                │
│      ↓                                                           │
│  sdd phase new <slug>          ← 전략적 묶음                     │
│      ↓                                                           │
│  sdd spec new <slug>           ← 한 PR 단위 작업                 │
│      ↓                                                           │
│  spec.md / plan.md / task.md 작성  (PLANNING 모드 — 코드 금지)   │
│      ↓                                                           │
│  /plan-accept                  ← 사용자 명시적 승인              │
│      ↓                                                           │
│  ┌─ Strict Loop ────────────────────────────────────────┐        │
│  │  1. 테스트 작성 (Fail)                                │        │
│  │  2. 구현 (Pass)                                      │        │
│  │  3. sdd test passed                                  │        │
│  │  4. git commit -m "<type>(spec-N-NNN): ..."          │        │
│  │  5. sdd task done <num>                              │        │
│  │  6. 사용자에게 보고 → 대기                             │        │
│  └──────────────────────────────────────────────────────┘        │
│      ↓                                                           │
│  /handoff (또는 sdd archive + git push)                          │
│      ↓                                                           │
│  사용자가 hosted git UI 에서 PR 생성                              │
│      ↓                                                           │
│  Phase 의 모든 SPEC merge 후 → integration-tests 실행 → Phase Done│
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 명령 요약

### 키트 진입점 (키트 디렉토리에서)
| 명령 | 설명 |
|---|---|
| `install.sh [TARGET]` | 대상 프로젝트에 설치 (`--dry-run`, `--force`, `--stack=`, `--yes` 지원) |
| `update.sh [TARGET]` | 기존 설치 갱신 (state 보존) |
| `uninstall.sh [TARGET]` | 제거 (산출물 보존, 안전 백업 자동 생성) |
| `doctor.sh [TARGET]` | 6 카테고리 점검 (의존성, 구조, 권한, hook, state) |

### `bin/sdd` 메타 명령 (대상 프로젝트에서)
| 명령 | 설명 |
|---|---|
| `sdd status [--brief\|--verbose\|--json]` | 현재 상태 (사람용 색상 / 한 줄 / 자세히 / JSON) |
| `sdd phase new <slug>` | 새 PHASE + phase.md + integration-tests.md |
| `sdd phase list \| show` | 모든 phase / 상세 |
| `sdd spec new <slug>` | active phase 안에 새 SPEC + 5종 템플릿 |
| `sdd spec list \| show` | spec 목록 / 상세 |
| `sdd plan accept` | plan.md placeholder 검사 후 Plan Accept |
| `sdd plan reset` | Plan Accept 해제 |
| `sdd task done <num>` | task.md 의 N 번 항목 `[x]` 마킹 |
| `sdd test passed` | `lastTestPass = now` 기록 (commit 직전 호출) |
| `sdd archive [--check]` | walkthrough/pr_description 검증 + commit |

### 슬래시 커맨드 (Claude Code 안에서)
| 슬래시 | 설명 |
|---|---|
| `/align` | 세션 부트스트랩 (constitution 로드 + 상태 보고 + 단 하나의 질문) |
| `/spec-new <slug>` | 새 SPEC + spec.md 작성 시작 |
| `/plan-accept` | plan.md 명시적 승인 → Strict Loop 시작 |
| `/spec-status` | 현재 진행 상태 + 다음 task 미리보기 (읽기 전용) |
| `/handoff` | 검증 + archive + push 안내 |

---

## 🚦 Hook 모드 (HARNESS_HOOK_MODE)

| 모드 | 동작 | 사용 시점 |
|:---:|---|---|
| `warn` (기본) | stderr 메시지만 + exit 0 (통과) | **첫 1주** — 어떤 hook 가 자주 발동되는지 관찰 |
| `block` | stderr 메시지 + exit 2 (차단) | **익숙해진 후** — 진짜 강제 |
| `off` | 즉시 통과 (검사 자체 비활성) | 일회성 우회 (`HARNESS_HOOK_MODE=off git commit ...`) |

```bash
# 영구 설정
export HARNESS_HOOK_MODE=block

# 일회성
HARNESS_HOOK_MODE=off git commit -m "..."
```

---

## 🧰 패키지 매니저 자동 감지 (nodejs 어댑터)

런타임마다 재감지합니다 — 사용자가 npm → pnpm 으로 마이그레이션해도 키트는 자동으로 따라옵니다.

| 우선순위 | 감지 방법 | 결과 |
|:---:|---|---|
| 1 | `package.json` 의 `"packageManager"` 필드 (corepack 표준) | 명시된 PM |
| 2 | `pnpm-lock.yaml` | `pnpm` |
| 3 | `yarn.lock` | `yarn` |
| 4 | `bun.lockb` | `bun` |
| 5 | `package-lock.json` | `npm` |
| 6 | (그 외) | `npm` (fallback) |

| Export 변수 | 예시 (pnpm) |
|---|---|
| `HARNESS_PKG_MANAGER` | `pnpm` |
| `HARNESS_BIN_RUNNER` | `pnpm exec` |
| `HARNESS_TEST_CMD` | `pnpm test` |
| `HARNESS_LINT_CMD` | `pnpm run lint` |
| `HARNESS_BUILD_CMD` | `pnpm run build` |
| `HARNESS_TYPECHECK_CMD` | `pnpm exec tsc --noEmit` |
| `HARNESS_TEST_INTEGRATION_CMD` | `pnpm run test:e2e` (있으면) 또는 `pnpm test` |

---

## 📖 더 읽을거리

- 📘 [`docs/USAGE.md`](./docs/USAGE.md) — 일상 워크플로 가이드 (사용자 관점)
- 📗 [`docs/REFERENCE.md`](./docs/REFERENCE.md) — 모든 명령/슬래시/hook/state/환경변수 사전식
- 📙 [`sources/governance/constitution.md`](./sources/governance/constitution.md) — 거버넌스 헌법
- 📕 [`sources/governance/agent.md`](./sources/governance/agent.md) — 에이전트 작업 절차
- 📓 [`docs/design/`](./docs/design/) — Harness Engineering Review 등 설계 근거
- 📔 [`docs/decisions/`](./docs/decisions/) — ADR (의사결정 기록)

---

## 🗂 키트 디렉토리 구조

```
harness-kit/
├── README.md, CLAUDE.md, VERSION, .gitignore
├── install.sh, update.sh, uninstall.sh, doctor.sh
│
├── sources/                  # 대상 프로젝트로 *복사될* 파일들
│   ├── governance/           # constitution, agent, align
│   ├── templates/            # phase, spec, plan, task, walkthrough, pr_description
│   ├── commands/             # 슬래시 커맨드 5종
│   ├── hooks/                # _lib.sh, check-branch, check-plan-accept, check-test-passed
│   ├── bin/                  # sdd + lib/{common,state}.sh
│   └── claude-fragments/     # settings.json / CLAUDE.md fragment
│
├── stacks/                   # 스택 어댑터
│   ├── nodejs.sh             # 패키지 매니저 자동 감지 (npm/pnpm/yarn/bun)
│   └── generic.sh            # 폴백
│
├── tests/fixtures/           # 자체 검증용 임시 디렉토리
│
└── docs/
    ├── USAGE.md, REFERENCE.md
    ├── design/               # Harness Engineering Review 등
    └── decisions/            # ADR
```

---

## ❓ FAQ

### Q. Plan Accept 전에 모델이 코드를 못 만지는 이유는?
A. `check-plan-accept.sh` hook 가 `Edit/Write/MultiEdit` 도구 호출을 검사하기 때문입니다. 안전 경로 (`agent/`, `*.md`, `.claude/`, `backlog/`, `specs/`, `scripts/harness/`) 만 통과시킵니다. constitution §4.3 의 **Premature Execution = Critical Violation** 을 코드로 강제합니다.

### Q. 테스트 통과했는데 commit 이 차단됩니다.
A. `check-test-passed.sh` 가 `.claude/state/current.json` 의 `lastTestPass` 시각을 확인합니다. 테스트 직후 `./scripts/harness/bin/sdd test passed` 를 호출해 시각을 기록하세요. 임계는 기본 30분 (`HARNESS_TEST_WINDOW_MIN` 으로 조정).

### Q. `docs(...)` / `chore(...)` commit 은 검사 면제되나요?
A. 네. commit subject 가 `docs(...)`, `chore(...)`, `style(...)` 인 경우 `check-test-passed.sh` 는 통과시킵니다. 문서/잡일까지 테스트 강제는 과합니다.

### Q. main 브랜치에서 정말 commit 해야 하면?
A. `HARNESS_HOOK_MODE=off git commit ...` 으로 일회성 우회. 또는 hook 를 warn 모드로 두면 메시지만 출력되고 통과합니다.

### Q. 사용자가 settings.json 에 자기 권한을 추가하면 update 할 때 사라지나요?
A. 사라지지 않습니다. install/update 는 jq 로 머지하며 `permissions.allow/deny` 는 *합집합* 입니다. 단 `hooks` 는 키트가 권위 (덮어쓰기) — hook 변경은 키트 fragment 를 수정하는 게 정공법.

### Q. NestJS 가 아닌데도 nodejs 어댑터가 잘 동작하나요?
A. 네. NestJS / Next.js / Vite / 순수 Node 모두 같은 어댑터입니다. 명령은 모두 사용자의 `package.json` scripts 를 호출하므로 (`<pm> test`, `<pm> run lint`, `<pm> run build`) 프레임워크와 무관합니다.

### Q. Linux 에서도 되나요?
A. best-effort 입니다. bash 4.0+, jq, git 만 있으면 동작 가능성이 높지만 검증되지 않았습니다. 문제 발견 시 issue 부탁드립니다.

### Q. 키트 자체를 git 으로 추적해도 되나요?
A. 권장합니다. 키트가 곧 프로젝트의 거버넌스 일부이므로 버전 추적이 중요합니다. 다른 프로젝트와 공유하려면 키트를 별도 git 리포로 두고 `git submodule` 로 가져오는 것도 한 방법입니다.

---

## 🎓 설계 원칙

1. **Context Budget First** — 시스템 프롬프트 토큰은 비용. 가능한 모든 것을 *지연 로딩* 또는 *호출 시점* 으로
2. **Cost Order: Shell > Skills > Slash > MCP** — 같은 효과면 컨텍스트 비용이 적은 쪽
3. **Enforcement > Guideline** — "MUST" 라고 적기보다 코드로 막을 수 있으면 막는다
4. **Reproducibility** — 슬래시 한 번 = 항상 같은 결과. 자유 형식 프롬프트 의존 최소화
5. **Korean Docs** — 사용자의 빠른 검토를 위해
6. **No Over-engineering** — NestJS 1차 타깃. 다른 언어/프레임워크는 *사용자가 손댈 수 있는 빈 슬롯* 으로

---

