---
id: ADR-006
type: decision
date: 2026-06-03
status: proposed
---

# ADR-006: 디렉터 모드 — context-orchestration 의 사용자 호출형 운영 프로토콜

## 📚 Context

ADR-005 가 "메인 에이전트 = context orchestrator"(orchestrator–worker + offloading)를 *암묵 정책*으로 박았다. 그러나 ① 사용자가 켜는 명시적 모드가 없고, ② SDD 워크플로 내부의 *구체적 분업 계약*(누가 무엇을)이 비어 있으며, ③ 다중 에이전트 간 설계 협상을 *중재*하는 메커니즘이 없다. 동시에 phase/SDD ceremony 의 토큰 비용·피로·속도(ADR-002/004 의 동기)가 누적됐는데, ceremony 의 상당 부분은 판단이 아니라 *기계적 노동*이라 디렉터(Opus)가 직접 할 필요가 없다.

핵심 재정의: 오퍼스의 큰 context 윈도우는 *의도의 단일 보관소*이며, 주목적은 비용 절감이 아니라 **긴 작업에서 의도의 흐름(context) 보존**이다. 비용 분산은 부수 효과.

## 🎯 Decision

ADR-005 전략을 **사용자가 `/hk-director` 로 켜는 명시적 운영 프로토콜**로 구체화한다. 디렉터 모드에서 Opus 디렉터는: ① 사용자 의도를 합의(되물어 확정)한 뒤 팀을 편성·위임하고, ② SDD ceremony 작성·실행을 Sonnet 워커에 내려 *문서에 직접 쓰게* 하고 **증류 계약만** 반납받으며, ③ 도메인 에이전트 간 설계 대화에 *중재자*로 참여해 아키텍처·over-engineering 을 교정하고, ④ review/critique 를 단일 Opus 가 아니라 *페르소나 부여한 워커 패널*로 오케스트레이션하고 그 보고를 종합·중재한다. 모델 티어는 director/worker/scout 역할 기반으로 `harness.config.json` 에 매핑하여 모델 이름 하드코딩을 제거한다.

## 📊 Consequences

- **긍정**: 디렉터 context 가 워커의 토큰 무거운 노동에 오염되지 않아 긴 작업에서도 의도 흐름 유지. ceremony 노동이 싼 티어로 내려가 비용·속도 개선.
- **긍정**: 역할→모델 config 분리로 모델 세대 churn 에 거버넌스가 견딤(constitution §13 결).
- **부정**: 디렉터의 검수 의무 증가 — 워커 결과 맹신 시 silent 결함 유입(ADR-005 와 동일 위험). 검토 시 워커 *전문*을 재흡수하면 context 보존 목적이 반감 → 워커는 distilled contract 만 반납해야 함(불변식).
- **중립**: 모드는 런타임 커널이 아니라 *지시 주입* — hk-align 이 거버넌스를 강제하는 것과 같은 규약 강도. 강제력 기대치를 명시해야 함.

## 🔀 Alternatives

- **ADR-005 암묵 정책 유지(명시 모드 없음)**: 단순. — 비채택 이유: 사용자가 켤 수 없고 SDD 내 분업 계약이 비어 위임이 임의적.
- **모든 작업 무조건 워커 디스패치**: 분업 최대화. — 비채택 이유: 단발(git commit 등)까지 디스패치하면 over-dispatch 로 느리고 비쌈(§6.7 threshold 위반).
- **모델 이름 거버넌스 하드코딩**: 단순 명시. — 비채택 이유: 모델 세대 churn 마다 거버넌스 재수정(부채).
- **중재 패턴을 정식 기능으로 즉시 구현**: 강력. — 비채택 이유: 종료조건·증류 난점 미검증 — research-only 로 먼저 실험.

## 📌 Status

Proposed (2026-06-03). phase-20 산출 예정. 첫 적용: `sources/commands/hk-director.md` + agent.md 디렉터 프로토콜 절.

## 🔗 Related

- ADR-005 (context-orchestration) — 본 ADR 의 토대, 이를 운영 프로토콜로 구체화
- ADR-002 (planning-economy) · ADR-004 (phase-FF) — ceremony 비용 절감 계열
- phase-20 (director-mode)
- agent.md §6.6 · §6.7
