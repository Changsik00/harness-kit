# harness-kit

> **Claude Code 를 위한 SDD (Spec-Driven Development) 거버넌스 부트스트랩 툴킷**
> 한 번 만들어두고, 다음 프로젝트에서는 한 줄로 같은 하네스를 깐다.

[![version](https://img.shields.io/badge/version-0.5.0-blue)](./VERSION)
[![target](https://img.shields.io/badge/target-macOS%20%2B%20Claude%20Code-green)](#-대상-환경-target-platform)
[![status](https://img.shields.io/badge/status-alpha-orange)](#-현재-진행-상태)

---

## 왜 필요한가

Claude Code 를 *그냥 쓰면* 강력한 일반 비서지만, **반복 가능한 절차** 와 **위반 방지** 는 약합니다.
이 키트는 그 격차를 메꿉니다:

| | 기능 | 설명 |
|:---:|---|---|
| 1 | **거버넌스** | constitution / agent.md 로 에이전트 행동 규약을 *명문화* |
| 2 | **자동 강제** | hook 으로 main 브랜치 작업·Plan Accept 우회·테스트 미실행 commit 을 *물리적으로* 차단 |
| 3 | **재현성** | 슬래시 커맨드와 `.harness-kit/bin/sdd` 메타 명령으로 자주 하는 절차를 *한 단어로* |
| 4 | **재사용** | install.sh 한 번으로 *다음 프로젝트* 에 같은 환경 즉시 도입 |
| 5 | **모델 분배** | Opus 로 기획·판단, Sonnet 으로 태스크 실행, Opus sub-agent 로 독립 코드 리뷰 |

> "**의도(Intent)** 를 문서로 적는 것" 에서 끝나지 않고 "**강제(Enforcement)** 까지 코드로 박는다" 가 핵심입니다.

---

## 주요 사용 목적

1. **새 프로젝트 시작 시** — `install.sh` 한 번으로 SDD 거버넌스 + Hook 강제 + 슬래시 커맨드 일괄 설치
2. **기존 프로젝트에 적용** — Claude Code 와 함께 작업할 때 에이전트의 품질 바닥선을 보장
3. **팀 표준화** — 같은 키트를 여러 프로젝트에 설치하여 동일한 워크플로 유지

---

## 대상 환경

| 항목 | 지원 | 비고 |
|---|:---:|---|
| **macOS** | ✅ 1차 | Sonoma+, Apple Silicon / Intel |
| **Linux** | △ | bash 4.0+, jq, git 이 있으면 동작 가능 (best-effort) |
| **Windows** | ❌ | WSL2 내에서는 Linux 와 동일 |
| **AI 호스트** | Claude Code 전용 | `.claude/` 구조 + hooks + settings.json 에 의존 |
| **Shell** | bash 4.0+ | 모든 스크립트는 `#!/usr/bin/env bash` (bash 4.0+ 전용) |

### 필수 의존성

```bash
brew install bash jq git
# macOS 기본 bash 는 3.2 — 4.0+ 필요
```

---

## 작업 유형 모델

harness-kit 은 다섯 가지 작업 유형을 정의합니다:

| 유형 | 역할 | PR? | 진입 | 완료 |
|---|---|:---:|---|---|
| **Phase** | 연관 Spec 묶음 (Epic) | — | `sdd phase new <slug> [--base]` | 모든 Spec Merged → `sdd phase done` |
| **Spec** | Phase 내 단일 PR 단위 | ✅ | `sdd spec new <slug>` + Plan Accept | ship → push → PR merge |
| **spec-x** | Phase 비소속 단독 PR | ✅ | `sdd spec new <slug>` (Phase 없이) | PR merge + `sdd specx done <slug>` |
| **FF** | 인라인 수정 (Fast Flow) | ❌ | 사용자 승인만 | state.json 변경 없음 |
| **Icebox** | 아이디어 보관소 | — | queue.md Icebox 섹션에 기록 | Phase 또는 spec-x 로 승격 |

> 자세한 정의: `.harness-kit/agent/constitution.md` §3 Work Type Model

### Phase Base Branch (opt-in)

Phase 는 선택적으로 **base branch** 를 가질 수 있습니다:

```
sdd phase new work-model --base
  → state.json: baseBranch = "phase-8-work-model"
  → 실제 브랜치는 첫 hk-ship 시 자동 생성 (just-in-time)

Spec PR → phase base branch (main 이 아님)
모든 Spec 완료 후 → phase base branch → main PR
```

---

## Quick Start

### 1. 설치

```bash
# 대상 프로젝트에 설치
~/path/to/harness-kit/install.sh ~/Project/my-app

# 미리 보기 (변경 없음)
~/path/to/harness-kit/install.sh --dry-run ~/Project/my-app
```

### 2. Claude Code 에서 부트스트랩

```bash
cd ~/Project/my-app
claude
```

Claude Code 안에서:

```
/hk-align
```

`/hk-align` 이 자동으로:
1. constitution / agent / align 규약 로딩
2. `sdd status` 로 현재 상태 확인
3. **단 하나의 질문**: "어떤 컨텍스트로 진행할까요?"

### 3. 워크플로 시작

```
사용자: "결제 안정성 관련 이슈를 phase 로 묶고 싶어"

에이전트: sdd phase new payment-stability
         → backlog/phase-1.md 생성
         → spec 표 + 통합 테스트 시나리오 작성 (PLANNING 모드)

사용자: Plan Accept (1 / Y / accept)
         → Strict Loop 진입 (테스트 → 구현 → 커밋 반복)

에이전트: 모든 task 완료 후 → /hk-ship → push → PR 생성
```

---

## install.sh 가 설치하는 것

```
<target>/
├── .harness-kit/                   # 키트 런타임
│   ├── agent/                      #   거버넌스
│   │   ├── constitution.md         #     헌법 (불변 규칙)
│   │   ├── agent.md                #     에이전트 작업 절차
│   │   ├── align.md                #     /hk-align 부트스트랩
│   │   └── templates/             #     산출물 양식 7종
│   ├── bin/                        #   에이전트 전용 메타 명령
│   │   ├── sdd                     #     메인 메타 명령 (사용자 실행 불필요)
│   │   └── lib/{common,state}.sh
│   ├── hooks/                      #   PreToolUse 후크
│   │   ├── check-branch.sh         #     main 보호
│   │   ├── check-plan-accept.sh    #     PLANNING 모드 가드
│   │   └── check-test-passed.sh    #     No Test, No Commit
│   └── CLAUDE.fragment.md          #   CLAUDE.md @import 대상
│
├── .claude/                        # Claude Code 통합
│   ├── settings.json               #   permissions + hooks (jq 머지)
│   ├── commands/                   #   슬래시 커맨드 (hk- prefix)
│   │   ├── hk-align.md, hk-ship.md, hk-plan-accept.md
│   │   ├── hk-pr-gh.md, hk-pr-bb.md
│   │   ├── hk-code-review.md, hk-spec-critique.md
│   └── state/current.json          #   런타임 state (gitignore)
│
├── backlog/                        # phase 정의 (평면 파일)
│   ├── queue.md                    #   대시보드 — 진행 중 Phase/Icebox (sdd 자동 갱신)
│   └── phase-{N}.md               #   phase 별 spec 표 + 통합 테스트
│
├── specs/                          # 실제 작업 (work log)
│   └── spec-{N}-{NNN}-{slug}/
│       ├── spec.md, plan.md, task.md
│       └── walkthrough.md, pr_description.md
│
└── CLAUDE.md                       # @import 3줄 추가 (`.harness-kit/CLAUDE.fragment.md` 참조)
```

### 사용자 보존 (멱등성)
- `.claude/settings.json` 기존 `permissions`, `env` 는 **합쳐짐**, hooks 만 키트가 권위
- `CLAUDE.md` 사용자 내용 보존, @import 3줄만 추가 (`.harness-kit/CLAUDE.fragment.md` 참조)
- 두 번째 install: 중복 없음

---

## 명령 요약

### 키트 진입점

| 명령 | 설명 |
|---|---|
| `install.sh [TARGET]` | 설치 (`--dry-run`, `--force`, `--yes`, `--no-gitignore`) |
| `update.sh [TARGET]` | 키트 갱신 (state 보존) |
| `uninstall.sh [TARGET]` | 제거 (산출물 보존) |
| `doctor.sh [TARGET]` | 점검 (의존성, 구조, 권한, hook, state) |
| `cleanup.sh [TARGET]` | 버전별 deprecated 파일 정리 |

### 슬래시 커맨드 (Claude Code 안에서)

| 커맨드 | 설명 |
|---|---|
| `/hk-align` | 세션 부트스트랩 (규약 로드 + `sdd status` 로 현재 상태 확인) |
| `/hk-plan-accept` | plan.md 승인 → Strict Loop 시작 |
| `/hk-ship` | Spec 완료 — 검증 + ship + push + PR 생성 |
| `/hk-phase-ship` | Phase 완료 — 성공 기준 검증 + 통합 테스트 + go/no-go + main PR |
| `/hk-pr-gh` | GitHub PR 생성 (gh CLI) |
| `/hk-pr-bb` | Bitbucket PR 생성 |
| `/hk-code-review` | 독립 sub-agent 코드 리뷰 |
| `/hk-spec-critique` | spec.md 비평 (Opus sub-agent) |
| `/hk-cleanup` | 프로젝트 정리 — 동기화 불일치, 잔여 파일 감지 |

> `sdd`는 에이전트가 내부적으로 사용하는 메타 명령입니다. 사용자가 직접 실행할 필요 없습니다.

---

## 모델 분배 전략

메인 세션은 **Opus** 로 운영하고, 역할별로 sub-agent 모델을 분배합니다:

| 역할 | 모델 | 이유 |
|---|---|---|
| Spec / Plan / Task 작성 | Opus (메인) | 아키텍처 판단에 깊은 추론 필요 |
| Task 실행 | Sonnet (sub-agent) | 상대적으로 기계적, 빠르고 저렴 |
| 코드 리뷰 / 비평 | Opus (sub-agent) | 미묘한 문제를 잡으려면 별도 컨텍스트의 깊은 분석 필요 |
| 코드 분석 | Opus (sub-agent) | 구조 파악, 영향 범위 판단 |

---

## Bitbucket PR 설정

`/hk-pr-bb` 사용 시 Bitbucket App Password 가 필요합니다:

1. **Bitbucket 설정** → Personal Settings → App passwords
2. **Create app password** 클릭
3. 권한 선택:
   - **Repositories**: Read, Write
   - **Pull requests**: Read, Write
4. 생성된 토큰을 저장:

```bash
mkdir -p ~/.config/bitbucket
echo "YOUR_APP_PASSWORD" > ~/.config/bitbucket/token
chmod 600 ~/.config/bitbucket/token
```

5. username 설정 (토큰과 별도):

```bash
echo "YOUR_BITBUCKET_USERNAME" > ~/.config/bitbucket/username
chmod 600 ~/.config/bitbucket/username
```

> GitHub 사용자는 `gh auth login` 만 하면 `/hk-pr-gh` 이 바로 동작합니다.

---

## Hook 모드

| 모드 | 동작 | 사용 시점 |
|:---:|---|---|
| `warn` (기본) | stderr 메시지 + exit 0 (통과) | 첫 1주 — 관찰 |
| `block` | stderr 메시지 + exit 2 (차단) | 익숙해진 후 — 강제 |
| `off` | 검사 비활성 | 일회성 우회 |

```bash
# 영구 설정
export HARNESS_HOOK_MODE=block

# 일회성 우회
HARNESS_HOOK_MODE=off git commit -m "..."
```

---

## 워크플로 요약

```
/hk-align (새 세션)
    ↓
현재 상태: Active Spec / NEXT 확인
    ↓
sdd phase new <slug> [--base]   ← phase 생성 (base branch opt-in)
    ↓
sdd spec new <slug>             ← spec 생성 (1 PR 단위)
    ↓
spec.md / plan.md / task.md 작성  (PLANNING 모드 — 코드 금지)
    ↓
Plan Accept (1 / Y / accept)    ← 사용자 승인
    ↓
┌─ Strict Loop ─────────────────────────────────┐
│  1. 테스트 작성 (Fail)                          │
│  2. 구현 (Pass)                                │
│  3. git commit (One Task = One Commit)         │
│  4. task.md 갱신                               │
│  5. 이슈 없으면 자동 진행, 이슈 시 멈추고 보고    │
└───────────────────────────────────────────────┘
    ↓
/hk-ship (ship + push + PR 생성)
    ↓
sdd ship → Merged 갱신 + state 초기화 + NEXT 안내
    ↓
PR merge → sdd status 로 NEXT 확인 → 다음 Spec 시작
    ↓
모든 Spec merge → /hk-phase-ship → 통합 테스트 → Done
```

---

## 키트 디렉토리 구조

```
harness-kit/
├── README.md, CLAUDE.md, VERSION
├── install.sh, update.sh, uninstall.sh, doctor.sh
│
├── sources/                  # 대상 프로젝트로 복사될 파일들
│   ├── governance/           #   constitution, agent, align
│   ├── templates/            #   산출물 양식 7종
│   ├── commands/             #   슬래시 커맨드 7종 (hk- prefix)
│   ├── hooks/                #   PreToolUse 후크
│   ├── bin/                  #   sdd + lib
│   └── claude-fragments/     #   settings.json / CLAUDE.md fragment
│
└── docs/
    ├── design/               #   설계 근거
    └── decisions/            #   ADR
```

---

## FAQ

**Q. Plan Accept 전에 코드를 못 만지는 이유는?**
A. `check-plan-accept.sh` hook 이 `Edit/Write/MultiEdit` 을 검사합니다. 안전 경로만 통과. constitution §5.3 의 Premature Execution = Critical Violation 을 코드로 강제합니다.

**Q. 테스트 통과했는데 commit 이 차단됩니다.**
A. `sdd test passed` 를 호출해 시각을 기록하세요. 임계는 기본 30분 (`HARNESS_TEST_WINDOW_MIN` 으로 조정).

**Q. main 에서 정말 commit 해야 하면?**
A. `HARNESS_HOOK_MODE=off git commit ...` 으로 일회성 우회.

**Q. settings.json 에 추가한 권한이 update 시 사라지나요?**
A. 아닙니다. `permissions.allow/deny` 는 합집합. `hooks` 만 키트가 덮어씁니다.

**Q. Phase base branch 모드는 언제 쓰나요?**
A. Spec 간 의존성이 있거나, main merge 전에 phase 전체 통합 테스트를 돌리고 싶을 때. `sdd phase new <slug> --base` 로 선언합니다.
