---
id: ADR-005
type: decision
date: 2026-06-01
status: accepted
---

# ADR-005: 메인 에이전트 = context orchestrator (orchestrator–worker + context offloading)

## 📚 Context

에이전트 작업에서 가장 비싼 자원은 **메인 세션의 context 창**이다. 다파일 구현·광역 탐색·로그 분류 같은 토큰 무거운 노동을 메인이 직접 하면, 그 raw 산출물이 context 를 오염시켜 *의도의 흐름(thread of intent)* 을 잃는다 (잘못된 가정 위에 작업이 쌓이는 understanding debt).

관찰된 실제 동작: 메인(Opus)이 패턴 분석·기획 후 다파일 TDD 구현을 Sonnet sub-agent 에 위임 → sub-agent 가 **107k 토큰·111 tool use** 를 자기 context 에서 소모하고 **distilled 결과**("6 commit, 401 tests PASS")만 반환 → 메인은 Ship·검수만 직접 수행. 메인 context 는 깨끗하게 유지됐다. 이 동작이 우연이 아니라 *전략*이 되어야 한다.

기존 agent.md §6.6 은 **모델 분배(WHO)** 만 규정하고, **context 정책(무엇을 위임/주입/반환할지)** 은 비어 있었다.

## 🎯 Decision

메인 세션을 **context orchestrator** 로 명시하고, sub-agent 위임에 **context offloading 정책**을 규약화한다 (orchestrator–worker 패턴). 핵심 5축: ① 무엇을 위임(토큰 무거운/오염성 노동 vs 판단·조정), ② scoped slice 만 주입, ③ distilled result contract 만 반환, ④ 검증은 orchestrator 가 보유, ⑤ 독립 job 은 fan-out. agent.md §6.6 에 반영.

## 📊 Consequences

- **긍정**: 메인 context 가 토큰 무거운 노동에 오염되지 않아 긴 작업에서도 의도의 흐름 유지. 위임 시 컨텍스트·결과 형태가 명확해져 sub-agent 결과 품질·재현성 향상.
- **긍정**: 병렬 fan-out 으로 처리량 증가, 비용은 격리된 워커에 분산.
- **부정**: orchestrator 의 검증 의무가 커짐 — 워커 결과를 맹신하면 silent 결함 유입. (그래서 ④ 검증 의무를 명문화.)
- **중립**: 워커는 ephemeral — 자기 context 는 반환 후 폐기되므로, 필요한 추적 정보는 distilled result 에 반드시 담아야 함.

## 🔀 Alternatives

- **메인이 전부 직접 수행**: context 단순. — 비채택 이유: 토큰 무거운 노동이 메인 context 를 오염, 긴 작업 불가.
- **전체 transcript 반환**: 추적성 최대. — 비채택 이유: 그게 바로 context 를 오염시키는 원인. distilled contract 가 핵심.
- **모델만 분배(현 §6.6), context 정책 없음**: — 비채택 이유: WHO 만 정하고 WHAT/WHEN 이 비어 위임이 임의적.

## 📌 Status

Accepted (2026-06-01). 규약 반영: agent.md §6.6 (Model & Context Allocation Strategy), §6.7 (Parallel by default) 연계.

## 🔗 Related

- agent.md §6.6 · §6.7
- ADR-004 (phase-FF) — 둘 다 ceremony/context 비용 절감 계열.
