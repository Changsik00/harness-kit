# harness-kit

*Not an AI coding framework. A reliability layer for AI-assisted engineering.*

> Claude Code를 위한 SDD(Spec-Driven Development) 거버넌스 부트스트랩 툴킷
> 한 번 만들어두고, 다음 프로젝트에서는 한 줄로 같은 하네스를 깐다.

[![version](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/Changsik00/harness-kit/main/version.json&query=$.version&label=version&color=blue)](./version.json)
[![target](https://img.shields.io/badge/target-macOS%20%2B%20Claude%20Code-green)](#대상-환경)
[![status](https://img.shields.io/badge/status-alpha-orange)](#)

---

## 💡 이 키트는 무엇인가

Claude Code를 그냥 쓰면 강력한 일반 비서지만, **반복 가능한 절차**와 **위반 방지**는 약합니다. "테스트를 먼저 써야 한다", "Plan을 검토한 뒤에 코드를 짜야 한다", "main 브랜치에서는 직접 커밋하지 않는다" — 이런 규칙들은 말로 하면 금방 잊힙니다.

harness-kit은 그 격차를 메꿉니다. **의도를 문서로 적는 것**에서 끝나지 않고, **강제까지 코드로 박는다**가 핵심입니다. 거버넌스 문서를 설치하고, hook으로 위반을 물리적으로 차단하고, 슬래시 커맨드로 자주 하는 절차를 한 단어로 줄입니다.

| | 기능 | 설명 |
|:---:|---|---|
| 1 | **거버넌스** | constitution / agent.md로 에이전트 행동 규약을 명문화 |
| 2 | **자동 강제** | hook으로 main 브랜치 작업·Plan Accept 우회·테스트 미실행 커밋을 물리적으로 차단 |
| 3 | **재현성** | 슬래시 커맨드와 `sdd` 메타 명령으로 자주 하는 절차를 한 단어로 |
| 4 | **재사용** | `install.sh` 한 번으로 다음 프로젝트에도 같은 환경 즉시 도입 |
| 5 | **모델 분배** | Opus로 기획·판단, Sonnet으로 태스크 실행, Opus sub-agent로 독립 코드 리뷰 |

### 🎯 왜 이 구조인가

에이전트가 빠르게 코드를 뽑는 시대에 가장 비싼 비용은 **나중에 그 코드를 설명하지 못하는 것** (이해 부채, understanding debt) 입니다. 잘못된 가정 위에 PR 다섯 개가 쌓인 뒤에야 깨닫는 사고, "사흘 뒤 자기 코드 동작을 설명 못 하는" 상태가 그 결과입니다. harness-kit은 그 부채가 쌓이지 않도록 세 가지를 구조로 강제합니다.

- **선언형 명세 우선** — `spec.md`가 배경·요구사항·실행 계획을 한 문서에 담고, 사람이 검토한 뒤에야 에이전트가 코드를 만집니다.
- **Plan Accept = 가정 검증 게이트** — 단순 "go" 신호가 아니라, 잘못된 전제 위에 코드가 쌓이는 것을 막는 마지막 검문소입니다.
- **walkthrough.md** — 구현 내용 나열이 아니라 *예상 못한 발견·디버깅·결정 이유*만 기록해, 6개월 뒤에도 자기 코드를 설명할 수 있게 합니다.

---

## 🖥 대상 환경 및 의존성

| 항목 | 지원 | 비고 |
|---|:---:|---|
| **macOS** | ✅ 1차 | Sonoma+, Apple Silicon / Intel — 기본 bash 3.2 로 동작 |
| **Linux** | △ | bash 3.2+, jq, git 이 있으면 동작 가능 (best-effort) |
| **Windows** | △ 미검증 | Git Bash + jq 환경에서 동작 가능성 있음. WSL2 권장 |
| **AI 호스트** | Claude Code 전용 | `.claude/` 구조 + hooks + settings.json에 의존 |

```bash
# 필수 의존성 설치 (macOS) — bash 는 기본 3.2 로 충분
brew install jq git
```

---

## 📦 설치

```bash
curl -fsSL https://raw.githubusercontent.com/Changsik00/harness-kit/main/get.sh | bash -s -- --yes ~/Project/my-app
```

| 옵션 | 설명 |
|---|---|
| `--yes` | 모든 프롬프트 자동 수락 |
| `--version 0.8.0` | 특정 버전 설치 (git tag 기준) |
| `--update` | 기존 설치 갱신 |
| `--uninstall` | 제거 (backlog/, specs/, archive/ 산출물 보존) |
| _(대상 생략)_ | 현재 디렉토리에 설치 |

### 개발자용 — 로컬 clone으로 설치

```bash
git clone https://github.com/Changsik00/harness-kit.git
cd harness-kit

# 설치
bash install.sh ~/Project/my-app

# Cursor IDE용 .cursorrules 함께 생성
bash install.sh --export-format=cursor ~/Project/my-app

# GitHub Copilot용 .github/copilot-instructions.md 함께 생성
bash install.sh --export-format=copilot ~/Project/my-app

# 미리 보기 (변경 없음)
bash install.sh --dry-run ~/Project/my-app
```

---

## 📖 핵심 개념

**SDD (Spec-Driven Development)** — 코드를 작성하기 전에 Spec(명세)과 Plan(실행 계획)을 문서로 먼저 작성하고, 사람이 검토·승인한 뒤에만 구현에 들어가는 개발 방식입니다. 에이전트의 "먼저 짜고 나중에 생각하는" 충동을 구조적으로 막습니다.

### 작업 유형

| 유형 | 역할 | PR? | 언제 쓰나 |
|---|---|:---:|---|
| 🏗 **Phase** | 연관 Spec 묶음 (Epic) | ✅ | 3개+ Spec이 묶이거나 통합 테스트가 필요할 때. `--base`로 Phase 전용 브랜치 생성 가능 |
| 📝 **Spec** | Phase 내 단일 PR 단위 | ✅ | 1 Spec = 1 PR. `spec.md` → `task.md` 작성 후 Plan Accept |
| 🔧 **spec-x** | Phase 없이 독립 단발 PR | ✅ | 버그 수정, 문서 정리 등. `sdd specx done <slug>`으로 마무리 |
| ⚡ **FF** | PR 없이 직접 커밋 | ❌ | 오탈자, 설정 변경 등 사소한 수정. state.json 변경 없음 |
| 🧊 **Icebox** | 아이디어 보관소 | — | 실행 불가. `queue.md`에 기록 후 나중에 Phase나 spec-x로 승격 |

### 프로젝트 구조와 상태 관리

| 경로 | 역할 |
|---|---|
| `backlog/queue.md` | 📊 대시보드 — 진행 중/대기/완료 Phase + Icebox. `sdd`가 자동 갱신 |
| `backlog/phase-{NN}.md` | 📋 Phase별 작업 지도 — Spec 표 + 통합 테스트 시나리오 |
| `specs/spec-{NN}-{NN}-{slug}/` | 📁 작업 산출물 — spec.md, task.md, walkthrough.md, pr_description.md |
| `archive/` | 🗄 완료 항목 보관 — `sdd archive`로 정리. 조회 시 `(archived)` 표시 |
| `.claude/state/current.json` | ⚙️ 런타임 상태 — `phase`, `spec`, `planAccepted`, `lastTestPass` 등. hook이 읽어 Plan Accept·테스트 통과 여부를 판단. `.gitignore` 대상 |

### 🔒 핵심 규칙

| | 규칙 | 강제 수단 |
|---|---|---|
| 🛑 | **Plan Accept 전 코드 편집 금지** | `check-plan-accept.sh` hook |
| 1️⃣ | **One Task = One Commit** | task.md 체크박스 |
| 🚫 | **main 브랜치 직접 작업 금지** | `check-branch.sh` hook |
| 🧪 | **TDD: 테스트 → 구현 → 커밋** | `check-test-passed.sh` hook |
| 🤖 | **Auto 정지규칙 — 비가역 행동에서 멈춤** | `check-irreversible.sh` hook (auto=차단/attended=경고) |
| ✅ | **사후 검증 — 가짜 green·테스트 실패 방어** | `check-test-trust.sh`·`post-commit-verify.sh` hook |

### ⚡ 실행 모드

"사람이 얼마나 붙어 있는가"에 따라 **네 가지** 모드를 선택합니다. 핵심 원칙(ADR-009): 거버넌스를 *agent 신뢰도에 반비례·blast-radius 에 비례* 해 적용하고, 예산을 **사전 게이트 → 사후 검증** 으로 이동한다.

| 모드 | 사람 | 전환 | Plan Accept | 동작 |
|---|---|---|:---:|---|
| 🔵 **Governed** (기본) | 붙어 있음 | `sdd mode governed` | ✅ 필수 | 완전한 SDD 절차. spec.md → task.md → Plan Accept → Strict Loop |
| ⚡ **Turbo** | 붙어 있음 | `sdd mode turbo` | ⬜ 생략 | Plan Accept 없이 즉시 편집. 커밋 후 `post-commit-verify` 자동 — 테스트 실패 시 `git revert` 자동 |
| 🤖 **Auto** (자율·unattended) | **없음** | `sdd mode auto` | ⬜ 생략 | phase 전체를 fire-and-forget. 결정은 기본값+로그(논블로킹), `phase-ship` PR 1회 검토. 안전은 **정지규칙 + 사후 검증** 이 담당 (↓ Auto 모드) |
| 🏃 **FF** (Fast-Forward) | 붙어 있음 | 수동 | — | spec/PR 없이 직접 커밋. 오탈자·설정 등 극소 수정에만 |

> 전환: `/hk-turbo` (governed↔turbo 토글), `/hk-auto` (governed↔auto 토글), `sdd mode auto|turbo|governed`. 현재 모드는 `sdd status` 에 항상 표시됩니다.
>
> **turbo vs auto** — 둘 다 Plan Accept 를 생략하고 `post-commit-verify` 로 사후 검증한다(공유 엔진). 차이는 *사람이 붙어 있는가* 단 하나: **turbo = attended** (결정 때 질문하면 사람이 답하고, 비가역 행동은 경고), **auto = unattended** (그 위에 질문 차단·정지규칙 실제 block·결정 로그를 얹음). 즉 `auto ≈ turbo + 무인 안전망`. 사람이 붙어 빠르게 가려면 turbo, 걸어두고 떠나려면 auto.

#### 🤖 Auto 모드 — "걸어두고 딴 일"

`sdd mode auto` 는 phase 전체를 **사람 없이** 자율 수행하기 위한 모드입니다 (ADR-009 구현). turbo 가 *attended 빠른 모드* 라면 auto 는 *unattended* — 결정 지점에서 멈추지 않고, 안전은 사전 질문이 아니라 **사후 검증·정지규칙** 으로 지킵니다.

**동작 방식**
- **논블로킹 결정**: 결정이 필요한 순간(통상 `AskUserQuestion`) 합리적 기본값을 채택하고 그 근거를 결정 로그(`sdd decision add`)에 남긴 뒤 진행합니다. `AskUserQuestion` 호출은 PreToolUse hook(`check-askquestion-auto`)이 auto 에서 **기계적으로 차단**해, 습관적 질문으로 세션이 멈추는 일을 막습니다.
- **정지규칙 (hard stop)** — 이 세 가지에서만 멈추고 사람을 기다립니다:
  - ① 기본값을 정당화할 수 없는 **진짜 방향 모호** → `decision add "미해결"` + 턴 종료(알림 발송)
  - ② **비가역·파괴 행동** (force push·대량 삭제·외부 발행·`reset --hard` 등) → `check-irreversible` 가 정지. auto 에선 **실제 차단(block)**, attended 에선 경고만 (모드 차등)
  - ③ **스스로 못 푸는 반복 테스트 실패** (N회 후) → `post-commit-verify` 가 hard-stop
- **사후 검증이 안전망**: spec 사이 테스트 게이트 + `post-commit-verify`(실패 시 자동 revert) + 가짜 green 휴리스틱(`check-test-trust`, #212 검증 0단계)이 항상 작동. 누적된 결정 로그는 `phase-ship` PR 에 일괄 노출되어 사람이 한 번에 검토합니다(`sdd decision list --phase`).

```bash
sdd mode auto            # 자율 모드 진입
sdd decision list --phase  # auto 가 내린 결정 일괄 검토 (phase-ship 시 자동 노출)
sdd mode governed        # 복귀
```

> ⚠️ auto 는 unattended 라 *잘못된 기본값으로 멀리 진행* 할 위험이 있습니다. 안전이 정지규칙·사후 테스트 품질에 전적으로 의존하므로, **고위험·비가역 변경** 에는 `/hk-refute`(의도에 앵커한 적대적 반증, #212 검증 2단계)를 함께 권장합니다. 자세한 거버닝 원칙 → `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md`.

---

### 🧩 확장 (extend) — 외부 도구 opt-in

"있으면 더 좋은" 외부 도구를 **opt-in(default-off)** 으로 붙입니다. `/hk-extend` 로 설치하며, 켠 사람만 비용을 부담합니다.

| 확장 | 무엇 | 설치 |
|---|---|---|
| **Serena** (LSP) | 심볼 rename / find-references 를 grep 다단계 대신 단일 호출로 — 리팩토링 토큰/정확도 개선 | `/hk-extend` → 스코프 선택 |

```bash
# Claude Code 안에서
/hk-extend                       # 확장 안내 + 스코프 질문 후 설치

# 또는 직접
sdd extend serena --scope local  # 이 프로젝트, 나만 (기본·권장)
sdd extend serena --scope user   # 내 모든 프로젝트
sdd extend serena --dry-run      # 실행될 커맨드 미리보기
sdd extend serena --remove       # 제거
```

> 🆕 설치 시 "확장 우선" 사용 규칙이 설치본 `CLAUDE.fragment.md` 에 자동 주입됩니다 — `/hk-align` 없이도 매 세션 컨텍스트에 노출되어, LSP 언어에서 심볼 작업 시 grep 대신 serena 를 우선 쓰도록 유도합니다. 켠 프로젝트만 비용을 부담하며(원본 fragment 는 불변), `--remove` 시 함께 제거됩니다.

> ⚠️ 확장은 MCP 서버라 **상시 컨텍스트 비용**이 듭니다. 그래서 default-off 이고, 등록은 Claude Code 네이티브 `claude mcp add` 에 위임합니다(키트가 설정 파일을 직접 편집하지 않음). 선행조건: `uv`, `claude` CLI. 규약 → `docs/decisions/ADR-007-extend-opt-in.md`.

---

## 🚀 시작하기: 첫 세션부터 첫 PR까지

### Step 1: Claude Code 시작 + `/hk-align`

프로젝트 디렉토리에서 Claude Code를 엽니다.

```bash
cd ~/Project/my-app
claude
```

Claude Code 안에서 `/hk-align`을 실행합니다. 이 커맨드가 자동으로:

1. constitution / agent / align 거버넌스 문서를 로딩합니다.
2. `sdd status`로 현재 상태(Active Phase, Active Spec, 다음 작업)를 확인합니다.
3. **단 하나의 질문**을 합니다: "어떤 컨텍스트로 진행할까요?"

이 질문에 지금 하려는 작업을 간단히 설명하면 에이전트가 적절한 작업 유형을 제안합니다.

#### 작업 중 다음 행동이 헷갈리면 — `/hk`

`/hk-align` 은 *세션 시작 시* 전체 컨텍스트 부트스트랩이고, **`/hk`** 는 *작업 중* 현재 상태에서 권장되는 다음 행동을 1 줄로 알려줍니다 (Plan Accept 가 필요한지, Ship 가능한지, phase 가 완료됐는지 등). 전체 슬래시 커맨드를 외울 필요 없이 `/hk` 한 번이면 *지금 무엇을 해야 하는지* 안내 받습니다.

```
/hk
```

### Step 2: Phase 생성 (큰 작업일 때)

여러 PR에 걸친 큰 작업이라면 Phase를 먼저 만듭니다.

```
사용자: "결제 안정성 관련 이슈를 phase로 묶고 싶어"

에이전트: sdd phase new payment-stability
```

`sdd phase new`가 실행되면 `backlog/phase-{N}.md`가 생성됩니다. 이 파일에 Phase의 목표, 성공 기준, Spec 목록, 통합 테스트 시나리오를 작성합니다. 작성은 에이전트가 초안을 만들고 사용자가 검토·수정합니다.

단독 PR이면 Phase 없이 바로 Step 3로 넘어갑니다.

### Step 3: Spec 생성 (1 PR 단위)

```
에이전트: sdd spec new retry-logic
```

`sdd spec new`가 실행되면 `specs/spec-{N}-{NN}-retry-logic/` 디렉토리가 생성되고 두 개의 파일이 만들어집니다:

- **`spec.md`** — 무엇을 왜 어떻게 만드는가. 배경·요구사항·범위·기술 결정·실행 계획을 한 문서에 담습니다.
- **`task.md`** — 단계별 체크리스트. 각 항목이 하나의 커밋이 됩니다.

이 시점에서는 **PLANNING 모드**입니다. 코드 편집은 허용되지 않습니다. 에이전트가 두 파일의 초안을 작성하고 사용자가 검토합니다.

### Step 4: Plan Accept (승인)

이 단계는 단순 승인이 아니라 **가정·범위·접근법을 명시적으로 검증하는 게이트**입니다 — 잘못된 전제 위에 코드가 쌓이는 것을 막습니다.

두 파일을 검토한 뒤 만족스러우면 승인합니다. 다음 중 어느 방법이든 됩니다:

- `1`, `Y`, `yes`, `ok`, `accept`를 입력
- `/hk-plan-accept` 커맨드 실행

승인되면 `sdd plan accept`가 실행되어 `planAccepted=true`가 기록되고, **Strict Loop**가 시작됩니다. 이후 `check-plan-accept.sh` hook이 해제되어 코드 편집이 가능해집니다.

> 💡 **Turbo 모드**(`sdd mode turbo`)에서는 Plan Accept 없이 즉시 편집이 가능합니다. 커밋 후 `post-commit-verify`가 자동으로 테스트를 실행하고, 실패 시 `git revert`를 수행합니다.

spec.md 또는 task.md에 아직 템플릿 placeholder가 남아있으면 accept가 거부됩니다.

### Step 5: Strict Loop (자동 실행)

Plan Accept 후 에이전트는 task.md의 각 항목을 순서대로 처리합니다:

```
For 각 task:
  1. 테스트 작성 (실패 확인)
  2. 구현 (테스트 통과)
  3. sdd test passed  ← 테스트 통과 시각 기록
  4. git commit       ← One Task = One Commit
  5. sdd task done N  ← task.md 체크박스 완료
  6. 이슈 없으면 자동으로 다음 task 진행
     이슈 발생 시 멈추고 사용자에게 보고
```

모든 task가 완료될 때까지 에이전트가 자동으로 진행합니다. 사용자가 개입할 필요 없습니다.

`sdd test passed`를 호출하지 않고 커밋하면 `check-test-passed.sh` hook이 경고(또는 차단)합니다. 기본 임계는 30분(`HARNESS_TEST_WINDOW_MIN`으로 조정).

### Step 6: Ship (`/hk-ship`)

모든 task가 완료되면 `/hk-ship`을 실행합니다. 이 커맨드가:

1. `walkthrough.md`를 작성합니다 — 예상 못한 발견, 디버깅 과정, 기술 결정 이유, 기존 이슈 등 의미 있는 내용만.
2. `pr_description.md`를 작성합니다 — PR 본문.
3. ship 커밋을 생성합니다.
4. origin에 push합니다.
5. PR을 생성합니다 (`/hk-pr-gh` 또는 `/hk-pr-bb`).

PR merge 후 에이전트는 `sdd status`로 NEXT Spec을 확인하고 다음 작업을 안내합니다.

### Step 7: Phase 완료 (`/hk-phase-ship`)

Phase의 모든 Spec이 merge되면 `/hk-phase-ship`을 실행합니다. 이 커맨드가:

1. Phase의 성공 기준을 검증합니다.
2. 통합 테스트를 실행합니다.
3. go/no-go 판단을 합니다.
4. Phase base branch → main PR을 생성합니다 (base branch 모드일 때).
5. `sdd phase done`으로 Phase를 완료 처리합니다.

### 워크플로 한눈에 보기

```mermaid
flowchart TD
    A["/hk-align"] --> B["Phase / Spec 생성"]
    B --> C["📝 PLANNING\nspec.md + task.md"]
    C --> D{"⚡ 실행 모드"}

    D -->|"🔵 Governed (기본)"| PA{"✅ Plan Accept?"}
    PA -->|Yes| SL["🔁 Strict Loop\nTest → Impl → Commit"]
    PA -->|No| C

    D -->|"⚡ Turbo"| TE["즉시 편집 → Commit"]
    TE --> PCV{"post-commit-verify"}
    PCV -->|"✅ PASS"| G
    PCV -->|"❌ FAIL"| RV["git revert"]
    RV --> TE

    D -->|"🤖 Auto"| AU["자율 실행\n결정=기본값+로그"]
    AU --> SR{"정지규칙 ①②③?"}
    SR -->|"No"| AU
    SR -->|"Yes"| STOP["멈춤 + 사람 대기"]
    AU --> PS["phase-ship: 일괄 검토"]

    SL --> G["/hk-ship: push + PR"]
    G --> H{"모든 Spec 완료?"}
    H -->|No| B
    H -->|Yes| I["/hk-phase-ship: Phase PR"]
```

---

## 🗄 디렉토리 아카이브

`specs/`에 Spec 디렉토리가 20개 이상 쌓이면 `sdd status`가 아카이브를 제안합니다. 아카이브는 완료된 Phase의 Spec과 backlog 파일을 `archive/` 디렉토리로 이동합니다.

```bash
# 미리 보기 (변경 없음)
sdd archive --dry-run

# 모든 완료 phase 아카이브
sdd archive

# 최근 N개 완료 phase는 남기고 아카이브
sdd archive --keep=2

# Claude Code 안에서
/hk-archive
```

아카이브된 항목도 `sdd phase list`, `sdd spec list`, `sdd phase show`, `sdd spec show`에서 `(archived)` 표시와 함께 조회됩니다. 데이터는 사라지지 않습니다.

---

## 📂 install.sh가 설치하는 것

```
<target>/
├── .harness-kit/                   # 키트 런타임
│   ├── agent/                      #   거버넌스
│   │   ├── constitution.md         #     헌법 (불변 규칙)
│   │   ├── agent.md                #     에이전트 작업 절차
│   │   ├── align.md                #     /hk-align 부트스트랩
│   │   └── templates/              #     산출물 양식 (spec, plan, task, walkthrough 등)
│   ├── bin/                        #   에이전트 전용 메타 명령
│   │   ├── sdd                     #     메인 메타 명령
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
│   │   ├── hk.md
│   │   ├── hk-align.md
│   │   ├── hk-plan-accept.md
│   │   ├── hk-ship.md
│   │   ├── hk-phase-ship.md
│   │   ├── hk-phase-review.md
│   │   ├── hk-pr-gh.md
│   │   ├── hk-pr-bb.md
│   │   ├── hk-code-review.md
│   │   ├── hk-spec-critique.md
│   │   ├── hk-cleanup.md
│   │   ├── hk-archive.md
│   │   ├── hk-ask-mode.md
│   │   ├── hk-doctor.md
│   │   └── hk-update.md
│   └── state/current.json          #   런타임 state (gitignore)
│
├── backlog/                        # phase 정의 (평면 파일)
│   ├── queue.md                    #   대시보드 — 진행 중 Phase/Icebox
│   └── phase-{N}.md                #   phase별 spec 표 + 통합 테스트
│
├── specs/                          # 실제 작업 (work log)
│   └── spec-{N}-{NN}-{slug}/
│       ├── spec.md, task.md
│       └── walkthrough.md, pr_description.md
│
├── archive/                        # 완료 항목 보관
│   ├── specs/
│   └── backlog/
│
├── telegram.sh / discord.sh        # 알림 채널 런처 (선택 사용)
├── .env.telegram.example           #   토큰 템플릿 (실제 .env.*는 키트가 생성 안 함)
├── .env.discord.example
│
└── CLAUDE.md                       # @import 3줄 추가
```

### 사용자 보존 (멱등성)

- `.claude/settings.json` 기존 `permissions`, `env`는 **합쳐짐**, hooks만 키트가 권위
- `CLAUDE.md` 사용자 내용 보존, @import 3줄만 추가 (`.harness-kit/CLAUDE.fragment.md` 참조)
- 두 번째 install 시 중복 없음

---

## ⌨ 명령 요약

### 키트 진입점

| 명령 | 설명 |
|---|---|
| `install.sh [TARGET]` | 설치 (`--dry-run`, `--force`, `--yes`, `--no-gitignore`, `--export-format=cursor\|copilot`) |
| `curl -fsSL ... get.sh \| bash -s -- --update` | **권장** — 원격에서 직접 갱신 (로컬 clone 불필요) |
| `update.sh [TARGET]` | 로컬 clone 보유 시 갱신 (state 보존) |
| `uninstall.sh [TARGET]` | 제거 (작업 산출물 보존) |
| `doctor.sh [TARGET]` | 점검 (의존성, 구조, 권한, hook, state) |
| `cleanup.sh [TARGET]` | 버전별 deprecated 파일 정리 |

### 슬래시 커맨드 (Claude Code 안에서)

| 커맨드 | 설명 |
|---|---|
| `/hk` | **단일 진입점** — `sdd status` 기반 현 상태 1 줄 + 다음 행동 1 줄 (8 상태 분기). 전체 커맨드 암기 회피용 |
| `/hk-align` | 세션 부트스트랩 — 거버넌스 로드 + `sdd status`로 현재 상태 확인 |
| `/hk-update` | 키트 원격 갱신 (`curl -fsSL ... get.sh \| bash -s -- --update` 또는 로컬 `update.sh` fallback) |
| `/hk-report-issue` | 키트 자체 버그를 kit GitHub 저장소에 이슈로 리포팅 (gh CLI, 컨텍스트 수집 + 사용자 확인 후 게시) |
| `/hk-doctor` | 설치 환경 점검 — 필수 도구, 파일 구조, hook 상태 PASS/FAIL 출력 |
| `/hk-plan-accept` | spec.md 승인 → Strict Loop 시작 (Governed 모드) |
| `/hk-turbo` | Turbo ↔ Governed 모드 토글 (attended 빠른 모드) |
| `/hk-auto` | Auto ↔ Governed 모드 토글 (unattended 자율 — 정지규칙·사후검증이 안전 담당) |
| `/hk-ship` | Spec 완료 — walkthrough/pr_description 검증 후 ship + push + PR 생성 |
| `/hk-phase-ship` | Phase 완료 — 성공 기준 검증 + 통합 테스트 + go/no-go + main PR |
| `/hk-phase-review` | Phase 회고 — 독립 Opus sub-agent로 비판적 검증 (목표 달성도, 테스트 품질, 잔재 탐지) |
| `/hk-pr-gh` | GitHub PR 생성 (gh CLI, pr_description.md 기반) |
| `/hk-pr-bb` | Bitbucket PR 생성 (pr_description.md 기반) |
| `/hk-code-review` | 독립 Opus sub-agent 코드 리뷰 (spec 대비 구현 + 품질 + 커버리지) |
| `/hk-spec-critique` | spec.md 비평 — Opus sub-agent로 유사 기법 조사 + 대안 제안 |
| `/hk-refute` | 고위험 변경을 **spec 의도에 앵커해 적대적 반증** — "테스트 다 통과해도 의도가 깨지는 경우"를 찾음 (#212 검증 2단계) |
| `/hk-director` | 디렉터 모드 토글 — 구현을 worker sub-agent로 위임, 디렉터는 게이트·검증만 보유 |
| `/hk-cleanup` | 프로젝트 정리 — 동기화 불일치, 잔여 파일, stale 요소 감지 및 정리 |
| `/hk-archive` | 완료된 phase의 spec/backlog를 `archive/`로 정리 |
| `/hk-ask-mode` | AskUserQuestion UX 모드 토글 — `interactive` ↔ `text` |
| `/hk-extend` | 외부 도구 opt-in 통합 — Serena(LSP) 설치/제거 (default-off) |

### sdd 서브커맨드 (에이전트 내부용)

에이전트가 내부적으로 사용하는 메타 명령입니다. 사용자가 직접 실행할 필요는 없지만, 상태를 직접 확인하거나 조작할 때 쓸 수 있습니다.

| 명령 | 설명 |
|---|---|
| `sdd status [--brief\|--verbose\|--json]` | 현재 상태 출력 |
| `sdd doctor` | 설치 환경 진단 — 필수 도구, 파일 구조, hook 실행 권한 PASS/FAIL 출력 |
| `sdd queue` | `backlog/queue.md` 대시보드 출력 |
| `sdd phase new <slug> [--base]` | 새 Phase 생성 |
| `sdd phase list` | 모든 Phase와 Spec 카운트 |
| `sdd phase show [phase-N]` | Phase 상세 (생략 시 active) |
| `sdd phase done [phase-N]` | Phase를 완료 처리 |
| `sdd spec new <slug>` | active Phase 안에 새 Spec 생성 |
| `sdd spec list [--phase=N]` | Spec 목록 |
| `sdd spec show [spec-NN-NN-slug]` | Spec 상세 (생략 시 active) |
| `sdd plan accept` | 현재 Spec의 실행 계획(spec.md) 승인 → Strict Loop 진입 |
| `sdd mode [governed\|turbo\|auto\|status]` | 실행 모드 전환/조회 (governed↔turbo↔auto) |
| `sdd decision add "<이슈>" "<선택>" "<근거>"` | auto 논블로킹 결정을 결정 로그(walkthrough)에 기록 |
| `sdd decision list [--phase]` | 결정 로그 조회 (`--phase`: phase 전체 spec rollup — phase-ship 검토용) |
| `sdd config ux-mode [interactive\|text\|toggle\|effective]` | AskUserQuestion 모드 설정 (`effective`: auto→text 해석값) |
| `sdd config precheck list` | 등록된 precheck 명령 목록 출력 |
| `sdd config precheck add <command>` | precheck 명령 추가 (중복 시 warn + skip). 활성 spec task.md 마커 자동 동기화 |
| `sdd config precheck remove <index>` | precheck 명령 제거 (1-기반 인덱스). 마커 자동 동기화 |
| `sdd task done <num>` | task.md의 N번 항목을 완료 마킹 |
| `sdd test passed` | 테스트 통과 시각 기록 (`lastTestPass` 갱신) |
| `sdd ship [--check]` | walkthrough/pr_description 검증 후 ship 커밋 생성 |
| `sdd archive [--keep=N] [--dry-run]` | 완료 Phase의 파일을 `archive/`로 이동 |
| `sdd pr-watch <pr-number>` | PR merge 자동 감지 (30초 폴링, 60분 타임아웃) — merge 시 post-merge 절차 출력 |
| `sdd run-test <cmd...>` | 테스트 결과 자동 기록 wrapper — exit 0 시 `sdd test passed` 자동 호출 |
| `sdd search <keyword> [--scope=<s>] [--ignore-case]` | 마크다운 자산 통합 검색 (spec/task/walkthrough 등) |
| `sdd specx new <slug>` | spec-x-{slug} 디렉토리 생성 + 템플릿 복사 |
| `sdd specx done <slug>` | spec-x 작업을 queue.md done으로 이동 |
| `sdd phase activate <phase-NN> [--base]` | 비활성 Phase를 active로 전환 |
| `sdd hooks [status]` | hook 모드 현황 출력 |
| `sdd hooks block\|warn\|off <name>` | 특정 hook 모드 전환 안내 |
| `sdd help` | 도움말 |
| `sdd version` | 키트 버전 |

---

## 🧠 모델 분배 전략

메인 세션은 **Opus**로 운영하고, 역할별로 sub-agent 모델을 분배합니다:

| 역할 | 모델 | 이유 |
|---|---|---|
| Spec / Plan / Task 작성 | Opus (메인) | 아키텍처 판단에 깊은 추론 필요 |
| Task 실행 | Sonnet (sub-agent) | 상대적으로 기계적, 빠르고 저렴 |
| 코드 리뷰 / 비평 | Opus (sub-agent) | 미묘한 문제를 잡으려면 별도 컨텍스트의 깊은 분석 필요 |
| 코드 분석 | Opus (sub-agent) | 구조 파악, 영향 범위 판단 |

**예외 — docs-only 태스크**: 모든 task가 마크다운 파일 생성·편집만인 Spec (코드·스크립트·테스트 없음) 은 메인 스레드에서 직접 실행합니다. sub-agent 스핀업 오버헤드가 작업 자체보다 크기 때문입니다.

---

## 🔒 Hook 모드

세 개의 hook이 각각 독립적으로 모드를 가집니다:

| Hook | 기본 모드 | 역할 |
|---|:---:|---|
| `check-branch.sh` | `block` | main 브랜치에서 Edit/Write 차단 |
| `check-plan-accept.sh` | `warn` | Plan Accept 전 Edit/Write 차단 |
| `check-test-passed.sh` | `warn` | 테스트 미통과 상태에서 커밋 차단 |

| 모드 | 동작 | 사용 시점 |
|:---:|---|---|
| `warn` (기본) | stderr 메시지 + exit 0 (통과) | 첫 1주 — 관찰 |
| `block` | stderr 메시지 + exit 2 (차단) | 익숙해진 후 — 강제 |
| `off` | 검사 비활성 | 일회성 우회 |

```bash
# 글로벌 모드 변경
export HARNESS_HOOK_MODE=block

# 특정 hook만 변경
export HARNESS_HOOK_MODE_PLAN_ACCEPT=block
export HARNESS_HOOK_MODE_TEST_PASSED=block

# 일회성 우회
HARNESS_HOOK_MODE=off git commit -m "..."
```

---

## ⚙️ Precheck 설정

PR 전 lint, type-check 등을 **`hk-ship` 전 자동 실행**하도록 `installed.json`의 `precheck` 배열에 명령을 등록합니다.

```bash
# 명령 추가
sdd config precheck add "npm run lint"
sdd config precheck add "npm run typecheck"

# 목록 확인
sdd config precheck list
# 1. npm run lint
# 2. npm run typecheck

# 제거 (1-기반 인덱스)
sdd config precheck remove 1
```

`add` / `remove` 시 활성 spec의 `task.md`에 `<!-- sdd:precheck:start/end -->` 마커가 있으면 체크리스트를 자동으로 동기화합니다. 마커가 없으면 경고 후 계속합니다.

> spec-18-02: task.md 템플릿 마커 자동 삽입 (예정)
> spec-18-03: `hk-ship` precheck 자동 실행 + 실패 UX (예정)

---

## 🔗 Bitbucket PR 설정

`/hk-pr-bb` 사용 시 Bitbucket Cloud API 토큰이 필요합니다.

1. **Bitbucket 설정** → Personal Settings → API Key (또는 App Password)
2. 필요 권한: **Pull Request — Read + Write** (`pullrequest:read`, `pullrequest:write` 스코프)
3. 토큰을 파일로 저장:

```bash
mkdir -p ~/.config/bitbucket
echo "YOUR_API_TOKEN" > ~/.config/bitbucket/token
chmod 600 ~/.config/bitbucket/token
```

> 다른 경로를 사용하려면 `BITBUCKET_TOKEN_FILE` 환경변수로 지정할 수 있습니다.

> GitHub 사용자는 `gh auth login`만 하면 `/hk-pr-gh`가 바로 동작합니다.

---

## 🔔 알림 채널 (Telegram / Discord)

Claude Code가 **입력을 기다리며 멈춘 순간**(예: 권한 확인, Plan Accept 대기)을 Telegram·Discord로 알려줍니다. 자리를 비운 사이에도 에이전트가 멈춘 걸 놓치지 않습니다.

install 시 프로젝트 루트에 다음이 생성됩니다:

| 파일 | 역할 |
|---|---|
| `telegram.sh` / `discord.sh` | 채널을 켠 채 Claude Code를 실행하는 런처 (`NM_NOTIFY_CHANNEL` export) |
| `.env.telegram.example` / `.env.discord.example` | 토큰 템플릿. 실제 `.env.telegram` / `.env.discord`는 키트가 만들지도 덮어쓰지도 않습니다 (시크릿 안전) |

`.env.telegram` / `.env.discord`는 install이 `.gitignore`에 자동 등록합니다.

```bash
# 1. 템플릿을 복사해 토큰을 채운다 (커밋 금지 — gitignore 처리됨)
cp .env.telegram.example .env.telegram
#   TELEGRAM_BOT_TOKEN=...   (BotFather 발급)
#   TELEGRAM_CHAT_ID=...     (수신 chat_id)

# 2. 런처로 Claude Code 실행 — 입력 대기 시 Telegram 알림
./telegram.sh
```

Discord도 동일하게 `.env.discord`(`DISCORD_BOT_TOKEN` / `DISCORD_CHANNEL_ID`)를 채우고 `./discord.sh`로 실행합니다.

| 환경변수 | 기본 | 설명 |
|---|:---:|---|
| `HARNESS_SKIP_PERMISSIONS` | `0` | `1`이면 런처가 `--dangerously-skip-permissions`로 실행. 기본은 비활성 |

> 토큰 파일(`.env.telegram` / `.env.discord`)이 없으면 알림은 조용히 건너뜁니다(silent skip) — 런처는 토큰이 있을 때만 동작합니다.

---

## ❓ FAQ

**Q. Plan Accept 전에 코드를 못 만지는 이유는?**

`check-plan-accept.sh` hook이 `Edit/Write/MultiEdit` 도구 호출을 검사합니다. `.harness-kit/`, `backlog/`, `specs/` 등 산출물 경로는 통과되지만, 실제 소스 코드 편집은 차단됩니다. constitution의 "Premature Execution = Critical Violation" 원칙을 코드로 강제하는 장치입니다.

**Q. 테스트 통과했는데 커밋이 차단됩니다.**

`sdd test passed`를 호출해 통과 시각을 기록하세요. 기본 임계는 30분입니다. `HARNESS_TEST_WINDOW_MIN` 환경변수로 조정할 수 있습니다.

**Q. main에서 정말 커밋해야 하면?**

`HARNESS_HOOK_MODE=off git commit ...`으로 일회성 우회하거나, 해당 hook의 모드를 `off`로 설정합니다.

**Q. settings.json에 추가한 권한이 update 시 사라지나요?**

아닙니다. `permissions.allow/deny`는 합집합으로 병합됩니다. `hooks` 섹션만 키트가 덮어씁니다.

**Q. Phase base branch 모드는 언제 쓰나요?**

Spec 간 의존성이 있거나, main merge 전에 Phase 전체 통합 테스트를 돌리고 싶을 때 씁니다. `sdd phase new <slug> --base`로 선언하면 Phase 전용 브랜치가 생성되고 각 Spec PR이 main이 아닌 그 브랜치로 병합됩니다. 모든 Spec이 완료된 뒤 `/hk-phase-ship`이 Phase 브랜치 → main PR을 생성합니다.

**Q. archive 후에도 이전 Spec을 조회할 수 있나요?**

네. `sdd spec list`, `sdd spec show`, `sdd phase list`, `sdd phase show` 모두 `archive/` 디렉토리도 함께 조회합니다. 아카이브된 항목에는 `(archived)` 표시가 붙습니다.

**Q. spec-x와 FF의 차이는?**

spec-x는 PR을 만들고 리뷰를 받는 독립 작업입니다. FF는 PR 없이 main에 직접 커밋하는 사소한 수정입니다. FF는 `HARNESS_HOOK_MODE=off`로 hook을 우회하거나, 사용자가 명시적으로 승인한 뒤 진행합니다.

**Q. walkthrough.md에는 무엇을 써야 하나요?**

구현 내용 나열은 피합니다. 예상 못한 발견, 디버깅 과정, 기술 결정의 이유, 해결한 기존 이슈처럼 나중에 다시 봤을 때 의미 있는 내용을 씁니다.

