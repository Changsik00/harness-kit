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

> ⚠️ 본 프로젝트는 *자기 자신을 만드는 중* 이라 거버넌스를 자기에게 적용하지 않습니다.
> Phase 3 (툴킷 빌드) 완료 후, Phase 4 에서 `nextmarket-api` 와 함께 *자기 자신에게도* install 합니다 (도그푸딩).

지금은 `sources/governance/constitution.md` 와 `agent.md` 가 *작업 원료* 일 뿐, *자기 자신에 대한 강제 규약* 은 아닙니다.

## 현재 단계

본 답변 시점: **Phase 2 완료 직후, Phase 3 사용자 승인 대기**.
