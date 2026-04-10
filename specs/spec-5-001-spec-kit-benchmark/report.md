# Research Report: spec-5-001 — spec-kit 워크플로 벤치마크

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-5-001` |
| **Phase** | `phase-5` |
| **타입** | Research |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

---

## 1. 조사 대상

### GitHub Spec Kit

| 항목 | 값 |
|---|---|
| **URL** | `github.com/github/spec-kit` |
| **Stars** | 86,823 |
| **최신 릴리스** | v0.6.0 (2026-04-09) |
| **라이선스** | MIT |
| **언어** | Python (CLI 도구, `uv tool install` 설치) |

### 핵심 워크플로

1. `/speckit.constitution` — 프로젝트 원칙/가이드라인 수립
2. `/speckit.specify` — 구조화된 spec.md 자동 생성 (자동 브랜치 + 디렉토리 + 넘버링)
3. `/speckit.plan` — 구현 계획 생성 (plan.md, data-model.md, contracts/, research.md)
4. `/speckit.tasks` — 실행 가능한 태스크 목록 (병렬 실행 가능 태스크 표시)
5. `/speckit.implement` — 태스크 실행하여 코드 구현

### 핵심 철학

"Vibe Coding" 대신 Spec-Driven Development. **Power Inversion**: 스펙이 source of truth, 코드는 스펙의 표현물.

---

## 2. harness-kit vs spec-kit 비교

| 관점 | harness-kit | spec-kit |
|---|---|---|
| **워크플로** | Spec → Plan → Task → Implement | Specify → Plan → Tasks → Implement |
| **거버넌스** | constitution + agent.md (강제) | constitution (선택적) |
| **에이전트 지원** | Claude Code 전용 | 멀티 에이전트 (Claude, Copilot, Gemini 등) |
| **설치 방식** | bash install.sh (파일 복사) | Python CLI (`uv tool install`) |
| **확장성** | 스택 어댑터 (NestJS 등) | 커뮤니티 Extension 50개+ |
| **Hook 시스템** | Claude Code hooks (check-branch, check-plan-accept 등) | 없음 (프롬프트 기반) |
| **강제력** | Hook이 tool-call 차단 가능 | 프롬프트 지시만 (우회 가능) |
| **산출물 언어** | 한국어 | 영어 |
| **프리셋 시스템** | 없음 | 커뮤니티 프리셋으로 템플릿 커스터마이즈 |

---

## 3. spec-kit에서 도입할 패턴

### 3-A. 병렬 태스크 표시 (Go)

spec-kit의 `/speckit.tasks`는 병렬 실행 가능한 태스크를 표시한다. harness-kit의 task.md에도 병렬 가능 태스크를 명시하면 실행 효율이 올라갈 수 있다.

**적용 방안**: task.md 템플릿에 `[parallel]` 마커 추가 검토.

### 3-B. 다중 산출물 구조 (Conditional Go)

spec-kit은 plan 단계에서 `data-model.md`, `contracts/`, `research.md` 등 다양한 산출물을 생성한다. 현재 harness-kit은 plan.md 하나에 모든 것을 담는다.

**판단**: 현재 규모에서는 과도함. 프로젝트가 커지면 재검토.

### 3-C. 커뮤니티 Extension 구조 (No-Go)

50개+ Extension 생태계는 인상적이나, harness-kit의 현재 사용자(1명)에게는 YAGNI.

---

## 4. spec-kit에서 도입하지 않을 패턴

### 4-A. Python CLI 의존성 (No-Go)

harness-kit은 bash 스크립트만으로 동작하는 것이 핵심 가치. Python 의존성 추가는 설치 마찰을 늘린다.

### 4-B. 프롬프트 기반 거버넌스 (No-Go)

spec-kit은 프롬프트로만 규칙을 지시하므로 에이전트가 우회할 수 있다. harness-kit의 Hook 기반 강제 시스템이 더 강력하다. 이 차별화를 유지한다.

### 4-C. 멀티 에이전트 지원 (No-Go, 현재)

spec-kit은 여러 AI 에이전트를 지원하지만, harness-kit은 Claude Code 전용으로 깊이를 추구한다. 이 방향은 spec-5-002 (AGENTS.md 호환)에서 별도 검토.

---

## 5. SDD 생태계 현황

| 프로젝트 | 특징 |
|---|---|
| **Fission-AI/OpenSpec** | AI 코딩 어시스턴트용 SDD |
| **gsd-build/get-shit-done** | Claude Code용 경량 메타프롬프팅 |
| **Priivacy-ai/spec-kitty** | Kanban 대시보드 + git worktree + auto-merge |
| **formulahendry/mcp-server-spec-driven-development** | SDD MCP 서버 |

SDD 패턴이 빠르게 표준화되고 있으며, spec-kit이 사실상 표준 위치를 차지하고 있다.

---

## 6. 권고사항

### Go
1. **병렬 태스크 표시**: task.md에 병렬 가능 마커 도입 검토 (phase-6에 추가 가능)
2. **spec-kit 워크플로 용어 정렬**: harness-kit의 워크플로가 spec-kit과 거의 동일하므로, 사용자가 spec-kit 문서를 참조할 때 혼동이 없도록 용어 매핑 문서 작성

### No-Go
3. **Python 의존성**: bash-only 원칙 유지
4. **Extension 시스템**: 현재 규모에서 불필요
5. **멀티 에이전트**: Claude Code 전용 깊이 유지 (AGENTS.md로 최소 호환만)

### 전체 평가: **Conditional Go**
- harness-kit의 핵심 가치(Hook 기반 강제, bash-only, Claude Code 전용)는 유지
- spec-kit에서 선별적으로 패턴 차용 (병렬 태스크, 용어 정렬)
- 장기적으로 spec-kit 생태계 모니터링 (6개월 후 재검토)
