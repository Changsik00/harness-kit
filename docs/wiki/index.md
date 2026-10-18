---
kind: catalog
sources: []
linked:
  - "[[wiki/purpose]]"
  - "[[wiki/decisions]]"
  - "[[wiki/patterns]]"
updated: 2026-10-19
---

# Wiki Index

> harness-kit 지식 그래프 카탈로그. wiki 페이지 + ADR/RCA 인벤토리.

## Wiki 페이지

| 파일 | kind | 설명 |
|---|---|---|
| [[wiki/purpose]] | catalog | wiki 목적·스키마·컨벤션 |
| [[wiki/index]] | catalog | 이 문서 — 전체 카탈로그 |
| [[wiki/log]] | catalog | 인제스트 이벤트 이력 |
| [[wiki/decisions]] | synthesis | 핵심 결정 증류 (ADR·RCA 합성) |
| [[wiki/patterns]] | synthesis | good pattern + anti-pattern 증류 |

## ADR 인벤토리

| ID | 제목 | type | 날짜 | 상태 |
|---|---|---|---|---|
| [[ADR-001]] | Knowledge Type Vocabulary (5어휘 closure) | decision | 2026-05-16 | accepted |
| [[ADR-002]] | Planning Economy & Inter-Spec Re-Validation | invariant | 2026-05-17 | accepted |
| [[ADR-003]] | Wiki Frontmatter — `kind:` vs `type:` 네임스페이스 분리 | convention | 2026-05-27 | accepted |
| [[ADR-004]] | phase-FF 를 phase 내 1급 작업 모드로 | decision | 2026-06-01 | accepted |
| [[ADR-005]] | 메인 에이전트 = context orchestrator | decision | 2026-06-01 | accepted |
| [[ADR-006]] | 디렉터 모드 — context-orchestration 의 사용자 호출형 운영 프로토콜 | decision | 2026-06-03 | accepted |
| [[ADR-007]] | extend — 외부 도구 opt-in 통합 규약 | decision | 2026-06-14 | accepted |
| [[ADR-008]] | 외부 확장(MCP) 조건부 우선 사용 | tradeoff | 2026-06-14 | accepted |
| [[ADR-009]] | 거버넌스를 신뢰도·blast-radius 기준으로 재배분 + 자율(auto) 모드 | decision | 2026-06-19 | accepted |

## RCA 인벤토리

| ID | 제목 | type | 날짜 | 상태 |
|---|---|---|---|---|
| [[RCA-001]] | sdd ship이 spec/plan/task를 git add 안 함 | failure-pattern | 2026-05-15 | active |

## 빠른 참조

- 설계 결정 맥락 → [[wiki/decisions]]
- 반복 패턴 / 함정 → [[wiki/patterns]]
- wiki 작동 방식 → [[wiki/purpose]]
- 최근 인제스트 이력 → [[wiki/log]]
