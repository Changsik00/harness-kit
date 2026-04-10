# harness-kit — Claude Code 작업 가이드

## 대상 환경 (고정)

| | |
|---|---|
| **OS** | macOS (1차 타깃) — Sonoma+, Apple Silicon / Intel |
| **AI 호스트** | Claude Code 전용 |
| **Shell** | zsh 사용자 환경, 모든 스크립트는 `bash` shebang |
| **필수 도구** | `bash 4.0+`, `jq`, `git` (모두 Homebrew 로 설치) |

> 다른 OS / 다른 AI 호스트는 본 키트의 1차 지원 범위가 아닙니다. Linux 는 best-effort.

## 이 프로젝트는 무엇인가

`harness-kit` 은 **Claude Code 용 SDD 거버넌스 부트스트랩 툴킷**입니다.
즉, *다른 프로젝트에 설치되는* 메타 도구입니다.

따라서 이 프로젝트에서 작업할 때는 두 가지 시점을 분리해야 합니다.

| 시점 | 의미 |
|------|------|
| **키트 원본** (this repo) | `sources/`, `install.sh`, `stacks/` 등 — 다른 프로젝트로 *복사될* 파일들 |
| **키트 적용 결과** (대상 프로젝트) | `install.sh` 가 실행된 후 대상 프로젝트에 생기는 `.claude/`, `scripts/harness/`, `agent/` 등 |

> 같은 파일이라도 어느 시점인지 항상 의식해야 합니다. 키트 원본을 수정한다고 자동으로 이미 설치된 프로젝트가 갱신되지 않습니다 (`update.sh` 가 그 역할).

## 디렉토리 의미

- `sources/governance/` — constitution, agent.md, align.md (행동 규약)
- `sources/templates/` — Spec/Plan/Task 등 산출물 양식
- `sources/commands/` — 대상의 `.claude/commands/` 로 복사될 슬래시 커맨드
- `sources/hooks/` — 대상의 `scripts/harness/hooks/` 로 복사될 후크 스크립트
- `sources/bin/` — 대상의 `scripts/harness/bin/` 로 복사될 메타 명령
- `sources/claude-fragments/` — 대상의 `.claude/settings.json` / `CLAUDE.md` 에 머지될 조각
- `stacks/` — 언어/프레임워크별 어댑터 (`nestjs.sh`, `generic.sh` 등)
- `tests/fixtures/` — 키트 자체 검증용 임시 디렉토리
- `docs/design/` — 설계 근거 (Harness Engineering Review 등)
- `docs/decisions/` — ADR

## 작업 원칙 (이 프로젝트 자체에 적용)

1. **도그푸딩 가능성**: 모든 변경은 결국 `nextmarket-api` 에 install 되어야 함. 추상화는 첫 사용자(NestJS)에서 검증된 후에만.
2. **컨텍스트 비용 0 우선**: zsh 스크립트 > Slash 커맨드 > Skill > MCP
3. **bash 호환**: 사용자는 zsh 환경이지만 모든 스크립트는 `#!/usr/bin/env bash` 로 작성하여 다른 환경에서도 동작하도록 함 (단, `set -euo pipefail` 필수)
4. **한국어 산출물**: 사용자 검토 가능성 우선
5. **Hook 단계론**: 새 hook 은 항상 *경고 모드(exit 0 + stderr)* 로 시작. 1주 운영 후 차단 모드(exit 2) 로 승격
6. **No Over-engineering**: NestJS 1차 타깃. 다른 언어는 빈 어댑터 슬롯으로

## 본 프로젝트의 거버넌스

> ⚠️ 본 프로젝트는 *자기 자신을 만드는 중* 이라, Phase 4 도그푸딩 시점까지는 거버넌스를 자기에게 적용하지 않았습니다.
> Phase 4 부터 `install.sh` 를 자기 자신에게도 실행하여 도그푸딩을 시작합니다.

도그푸딩 이후로는 `sources/governance/` 의 원본이 install 을 거쳐 `agent/` 디렉토리로 복사되며, 그 시점부터는 `agent/constitution.md` / `agent/agent.md` 가 본 프로젝트 작업의 *실제 강제 규약* 이 됩니다. 키트 원본을 수정하는 PR 도 같은 규약을 따르게 됩니다.

## 현재 단계

본 답변 시점: **Phase 4 도그푸딩 시작 — 자기 자신에 대한 첫 install 실행 직전**.

## 두 시점이 한 파일에 공존함에 주의

본 `CLAUDE.md` 는 install 후 끝부분에 HARNESS-KIT 블록이 append 됩니다.

- **위쪽** (이 문단까지): 키트를 *만드는 사람* (키트 작업자) 을 위한 가이드. 키트 원본 시점.
- **아래쪽** (HARNESS-KIT 블록): 키트가 *적용된 프로젝트* 에서 작업하는 사람을 위한 운영 규약. 도그푸딩 결과 시점.

도그푸딩이 진행 중인 본 프로젝트에서는 두 가지 모두 유효합니다. 키트 원본 (`sources/`, `install.sh`, `stacks/` 등) 을 수정할 때는 위쪽 가이드를 따르고, 도그푸딩 결과물 (`agent/`, `.claude/`, `scripts/harness/` 등) 을 사용해 SDD 작업을 할 때는 아래 HARNESS-KIT 블록의 규약을 따릅니다.

<!-- HARNESS-KIT:BEGIN — 이 블록은 install/update.sh 가 관리합니다. 수동 편집 시 update 가 어려워질 수 있습니다. -->

## 에이전트 운영 규약 (harness-kit)

이 프로젝트는 harness-kit 의 거버넌스를 따릅니다.
SDD 작업 시작 시 `/align` 슬래시 커맨드를 호출하면 전체 거버넌스가 로드됩니다.

**핵심 규칙 요약**:
- Plan Accept 전에는 PLANNING 모드 (코드 편집 금지)
- One Task = One Commit
- Phase ID: `phase-{N}` (예: `phase-1`) — 디렉토리는 `backlog/phase-{N}/`
- Spec ID:  `spec-{phaseN}-{seq}` (예: `spec-1-001`) — 디렉토리는 `specs/spec-{phaseN}-{seq}-{slug}/`
- Branch: `spec-{phaseN}-{seq}-{slug}` (브랜치 = spec 디렉토리 이름, `feature/` prefix 없음)
- Commit subject: `<type>(spec-{phaseN}-{seq}): <설명>` (모두 소문자)
- 모든 산출물은 한국어
- main 브랜치 직접 작업 금지

자세한 내용은 `agent/constitution.md` 와 `agent/agent.md` 참조.

<!-- HARNESS-KIT:END -->
