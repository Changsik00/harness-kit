# harness-kit — Claude Code 작업 가이드

> 대상 환경, 디렉토리 구조 → [`docs/project-guide.md`](docs/project-guide.md)

## 이 프로젝트는 무엇인가

`harness-kit` 은 **Claude Code 용 SDD 거버넌스 부트스트랩 툴킷**입니다.
즉, *다른 프로젝트에 설치되는* 메타 도구입니다.

따라서 이 프로젝트에서 작업할 때는 두 가지 시점을 분리해야 합니다.

| 시점 | 의미 |
|------|------|
| **키트 원본** (this repo) | `sources/`, `install.sh` 등 — 다른 프로젝트로 *복사될* 파일들 |
| **키트 적용 결과** (대상 프로젝트) | `install.sh` 가 실행된 후 대상 프로젝트에 생기는 `.claude/`, `scripts/harness/`, `agent/` 등 |

> 같은 파일이라도 어느 시점인지 항상 의식해야 합니다. 키트 원본을 수정한다고 자동으로 이미 설치된 프로젝트가 갱신되지 않습니다 (`update.sh` 가 그 역할).

## 작업 원칙 (이 프로젝트 자체에 적용)

1. **도그푸딩 가능성**: 모든 변경은 결국 `nextmarket-api` 에 install 되어야 함. 추상화는 첫 사용자(NestJS)에서 검증된 후에만.
2. **컨텍스트 비용 0 우선**: bash 스크립트 > Slash 커맨드 > Skill > MCP
3. **bash 3.2+ 호환**: 모든 스크립트는 `#!/usr/bin/env bash` (이식성 우선) + `set -euo pipefail` 필수. bash 4+ 전용 기능 (`declare -A`, `mapfile`/`readarray`, `**` globstar, `${var,,}`/`${var^^}`, `coproc` 등) 사용 금지.
4. **한국어 산출물**: 사용자 검토 가능성 우선
5. **Hook 단계론 (정제)**: *휴리스틱* hook(오탐 예측이 어려운 것 — 예: test-trust 칸0)은 경고 모드로 시작해 1주 운영 후 차단 승격. 단 **결정론적·테스트 고정** hook 은 즉시 차단 가능하며, 특히 **모드별로 fail-safe 방향이 다르면 모드 차등**을 적용한다 — 예: check-irreversible 는 auto(unattended)에선 block 이 fail-safe(멈추고 대기)·warn 이 fail-dangerous(파괴 명령 실행)라 auto=block, attended=warn (spec-25-04 후속, 2026-06-22). 즉 "1주 경고"는 절대 규칙이 아니라 *오탐 비용이 차단 이득보다 클 때*의 기본값이다.
6. **No Over-engineering**: NestJS 1차 타깃

## 릴리스 전략 (이 프로젝트 전용)

새 버전 출시 절차는 [`docs/release-strategy.md`](docs/release-strategy.md) 참조. "배포하자" / "릴리스하자" 명령 시 alignment 없이 그 문서의 절차를 즉시 수행한다.

## 본 프로젝트의 거버넌스

> ⚠️ 본 프로젝트는 *자기 자신을 만드는 중* 이라, Phase 4 도그푸딩 시점까지는 거버넌스를 자기에게 적용하지 않았습니다.
> Phase 4 부터 `install.sh` 를 자기 자신에게도 실행하여 도그푸딩을 시작합니다.

도그푸딩 이후로는 `sources/governance/` 의 원본이 install 을 거쳐 `.harness-kit/agent/` 디렉토리로 복사되며, 그 시점부터는 `.harness-kit/agent/constitution.md` / `.harness-kit/agent/agent.md` 가 본 프로젝트 작업의 *실제 강제 규약* 이 됩니다. 키트 원본을 수정하는 PR 도 같은 규약을 따르게 됩니다.

## 두 시점이 한 파일에 공존함에 주의

본 `CLAUDE.md` 는 install 후 끝부분에 HARNESS-KIT 블록이 append 됩니다.

- **위쪽** (이 문단까지): 키트를 *만드는 사람* (키트 작업자) 을 위한 가이드. 키트 원본 시점.
- **아래쪽** (HARNESS-KIT 블록): 키트가 *적용된 프로젝트* 에서 작업하는 사람을 위한 운영 규약. 도그푸딩 결과 시점.

도그푸딩이 진행 중인 본 프로젝트에서는 두 가지 모두 유효합니다. 키트 원본 (`sources/`, `install.sh` 등) 을 수정할 때는 위쪽 가이드를 따르고, 도그푸딩 결과물 (`.harness-kit/`, `.claude/` 등) 을 사용해 SDD 작업을 할 때는 아래 HARNESS-KIT 블록의 규약을 따릅니다.

<!-- HARNESS-KIT:BEGIN -->
@.harness-kit/CLAUDE.fragment.md
<!-- HARNESS-KIT:END -->
