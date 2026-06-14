---
id: ADR-007
type: decision
date: 2026-06-14
status: accepted
---

# ADR-007: extend — 외부 도구 opt-in 통합 규약

## 📚 Context

Claude Code 기본 루프는 코드 탐색을 텍스트 도구(`Grep`/`Read`)로 수행해, 심볼 rename·find-references 같은 리팩토링이 LSP 기반 IDE 대비 느리고 토큰 왕복이 많다. LSP 코드 인텔리전스(Serena 등)는 이를 개선하지만 MCP 서버 형태라 **상시 컨텍스트 비용**이 든다. harness-kit 의 1순위 원칙은 "컨텍스트 비용 0 우선: bash > Slash > Skill > MCP" 이며, 진행 중인 ceremony cost 절감 노력과 MCP 상시 비용은 충돌한다. 동시에 "좋은 외부 도구를 키트가 직접 다 구현하지 말고 연결하자"는 요구가 있었다. 이 둘을 어떻게 양립시킬지 규약이 필요하다.

## 🎯 Decision

키트에 **extend** — 외부 도구를 **opt-in(default-off)** 으로 붙이는 경로 — 를 도입한다. 세 가지 불변 규칙을 둔다.

1. **default-off**: 어떤 확장도 기본 설치/활성화하지 않는다. 사용자가 명시적으로 `/hk-extend` 로 켠 경우에만, 그리고 켠 사람만 비용을 부담한다.
2. **등록 위임**: MCP 등록은 키트가 설정 파일(사용자 홈의 ~/.claude.json, 프로젝트 `.mcp.json`)을 직접 편집하지 않고 Claude Code 네이티브 `claude mcp add --scope <local|user>` 에 위임한다. 기본 스코프는 `local`(이 프로젝트·개인). 커밋되는 `.mcp.json`(팀 공유, `project` 스코프)은 팀 전원에게 상시 비용을 강요하므로 지원하지 않는다.
3. **검증 후 추출**: 확장 *레지스트리/프레임워크* 를 선설계하지 않는다. 확장은 한 개씩 정직하게 하드코딩하고, **검증된 확장이 3개 누적된 후에만** 공통 패턴을 일반화(레지스트리)로 추출한다("추상화는 첫 사용자 검증 후").

첫 확장은 Serena(LSP)이며 `sources/bin/lib/extend.sh` + `sources/commands/hk-extend.md` 로 구현한다.

## 📊 Consequences

- **긍정**: 리팩토링·심볼 탐색의 토큰/정확도 개선 경로 확보. 키트가 외부 자산을 재구현하지 않음. opt-in 이라 컨텍스트 비용 0 원칙과 ceremony cost 절감 노력이 깨지지 않음. 등록을 네이티브에 위임해 설정 파일 충돌·소유권 문제 회피.
- **부정**: 진짜 등록 상태의 SSOT 는 `claude mcp list` 이고 키트의 `installed.json` 흔적과 갈라질 수 있음(키트가 사용자 홈의 ~/.claude.json 을 소유하지 않음). `claude`/`uv` CLI 선행조건 의존이 새로 생김.
- **중립**: 확장이 3개 모이기 전까지는 의도적으로 중복(하드코딩)을 감수한다.

## 🔀 Alternatives

- **MCP 기본 탑재**: 키트가 Serena 를 default 로 설치 — 비채택 이유: 컨텍스트 비용 0 원칙·ceremony cost 절감과 정면충돌, 켜지 않은 팀원에게도 비용 전가.
- **선(先) 레지스트리 프레임워크**: 처음부터 확장 카탈로그/플러그인 런타임 설계 — 비채택 이유: 검증된 확장이 없는 상태의 선추상화 함정(over-engineering). 첫 사용자(Serena) 검증 후 추출이 키트 철학.
- **키트가 설정 파일 직접 편집**: 사용자 홈의 ~/.claude.json 이나 프로젝트 `.mcp.json` 을 키트가 직접 머지 — 비채택 이유: 소유권·충돌·스코프 처리를 재구현하게 됨. 네이티브 `claude mcp add` 가 이미 스코프(local/user/project)를 정확히 제공.

## 📌 Status

Accepted (2026-06-14, spec-22-01 머지 시점). 첫 사용자: `sources/bin/lib/extend.sh` (Serena/LSP).

## 🔗 Related

- spec-22-01-extend-serena (첫 구현)
- phase-22 (extend)
