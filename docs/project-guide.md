# harness-kit — 프로젝트 참조 가이드

> 자주 참조되지 않는 레퍼런스 정보를 모아둡니다.
> 핵심 작업 규칙은 [CLAUDE.md](../CLAUDE.md) 참조.

## 대상 환경

| | |
|---|---|
| **OS** | macOS (1차 타깃) — Sonoma+, Apple Silicon / Intel |
| **AI 호스트** | Claude Code 전용 |
| **Shell** | 모든 스크립트는 `bash` shebang (이식성 우선) |
| **필수 도구** | `bash 3.2+`, `jq`, `git` — bash 는 macOS 기본 (3.2.57) 으로도 동작. jq/git 은 Homebrew 권장. |

> 다른 OS / 다른 AI 호스트는 본 키트의 1차 지원 범위가 아닙니다. Linux 는 best-effort.

## 디렉토리 의미

- `sources/governance/` — constitution, agent.md, align.md (행동 규약)
- `sources/templates/` — Spec/Plan/Task 등 산출물 양식
- `sources/commands/` — 대상의 `.claude/commands/` 로 복사될 슬래시 커맨드
- `sources/hooks/` — 대상의 `scripts/harness/hooks/` 로 복사될 후크 스크립트
- `sources/bin/` — 대상의 `scripts/harness/bin/` 로 복사될 메타 명령
- `sources/claude-fragments/` — 대상의 `.claude/settings.json` / `CLAUDE.md` 에 머지될 조각
- `tests/fixtures/` — 키트 자체 검증용 임시 디렉토리
- `docs/design/` — 설계 근거 (Harness Engineering Review 등)
- `docs/decisions/` — ADR
