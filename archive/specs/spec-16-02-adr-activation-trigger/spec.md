# spec-16-02: ADR 활성화 트리거

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-16-02` |
| **Phase** | `phase-16` |
| **Branch** | `spec-16-02-adr-activation-trigger` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-05-16 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- `constitution.md` §6.3 Layout 에 ADR 경로 (`docs/decisions/ADR-{NNN}-{slug}.md`) 가 *정의* 되어 있다.
- `constitution.md` §6.4 Knowledge Type Vocabulary 가 도입되어 RCA 가 `type: failure-pattern` 슬롯을 *첫 사용자* 로 채웠다 (spec-16-01 머지).
- 그러나 ADR 은 다음 두 가지 이유로 *작성 트리거가 살아있지 않다*:
  1. **템플릿 부재** — `sources/templates/adr.md` 없음. 작성 시작점이 없다.
  2. **트리거 부재** — spec/plan/walkthrough 산출물 어디에도 "이 결정이 ADR 가치 있는가" 를 *상기시키는 한 줄* 이 없다.
- `docs/decisions/` 디렉토리 자체가 아직 존재하지 않는다.

### 문제점

- ADR 가 *얇은 정의* 만 있고 *작성 경로* 가 비어 있어, 결정이 `walkthrough.md` 결정 표 안에서 *수명을 다하고 휘발* 된다.
- 새 사용자가 "ADR 가치 있는 결정인가?" 를 자문할 *접점* 이 없다 — Plan 단계에서도 walkthrough 단계에서도 critique 단계에서도.
- spec-16-01 의 *Knowledge Type Vocabulary 도입 결정* 자체가 long-lived architectural decision 이지만 ADR 로 박혀 있지 않다 (walkthrough 결정 표에만 남음). 첫 ADR 후보가 *비어있는 채로 머지* 된 상태.

### 해결 방안 (요약)

ADR 작성 경로를 *비강제* 로 활성화한다 — ADR 템플릿을 신설하고, spec/plan/walkthrough 본문에 "ADR 가치 있는 결정?" 체크박스를 박고, `/hk-spec-critique` 출력에 ADR 후보 섹션을 1 개 추가하고, 첫 ADR (`ADR-001-knowledge-types`) 을 작성하여 트리거가 *실증* 됨을 확인한다.

## 🎯 요구사항

### Functional Requirements

1. **ADR 템플릿 신설** — `sources/templates/adr.md` 와 install 미러 `.harness-kit/agent/templates/adr.md` 생성. RCA 템플릿과 대칭. frontmatter `type:` 슬롯 포함 (정규 어휘 — 보통 `decision`, 또는 `invariant` / `convention` / `tradeoff`).
2. **spec.md 템플릿 보강** — 본문에 "ADR 가치 있는 결정?" 체크박스 섹션 1 개 추가. grep 가능한 헤더로.
3. **plan.md 템플릿 보강** — 동일. "주요 결정" 표 직후 위치.
4. **walkthrough.md 템플릿 보강** — 결정 기록 섹션 옆에 *ADR 승격 가이드* 짧은 안내 + "ADR 가치 있는 결정?" 체크박스 1 줄.
5. **`/hk-spec-critique` 보강** — sub-agent prompt 에 "4. ADR 후보 추출" 섹션 추가 (체크 항목 형태, *자동 식별 강제 X*).
6. **첫 ADR 작성** — `docs/decisions/ADR-001-knowledge-types.md` 작성. spec-16-01 의 Knowledge Type Vocabulary 도입 결정을 *long-lived architectural decision* 으로 박는다. frontmatter `type: decision`.
7. **거버넌스 동기화** — `constitution.md` §6.3 의 ADR 정의에 *템플릿 경로* + *frontmatter type 의무* 한 줄 추가, §6.4 의 "(currently RCA; ADR adoption deferred to spec-16-02)" 문구를 ADR 도 정규 어휘 사용자임을 반영하는 표현으로 갱신.
8. **install/sync** — 변경된 sources 파일 (`templates/*`, `commands/hk-spec-critique.md`, `governance/constitution.md`) 의 install 미러 (`.harness-kit/agent/templates/*`, `.claude/commands/hk-spec-critique.md`, `.harness-kit/agent/constitution.md`) 도 동일 PR 에서 함께 갱신.

### Non-Functional Requirements

1. **비강제 (Non-coercive)** — 모든 체크박스는 *권장* 이며 미체크여도 ship 차단 없음. 외부 진단의 "Decision Ledger" 원칙은 *접점 노출* 이지 *강제* 가 아님.
2. **grep 가능성** — 체크박스 헤더와 frontmatter `type:` 가 모두 일관된 문구로 박혀 후속 spec-16-03 (stale 탐지) 의 검색 기반을 마련.
3. **Type 슬롯 의무** — 새 ADR 의 frontmatter `type:` 는 정규 어휘 (constitution §6.4) 중 하나여야 함. ADR-001 본 spec 에서 `type: decision` 사용.

## 🚫 Out of Scope

- **자동 ADR 추출 도구** (예: `sdd adr suggest` 또는 walkthrough → ADR 자동 변환) — 가이드 문서로만 처리. 자동화는 향후 spec-16-03 stale 탐지와 묶어 검토.
- **`/hk-spec-critique` sub-agent 의 ADR 후보 *자동 식별 휴리스틱*** — prompt 에 "체크 섹션" 만 추가하고, 식별은 reviewer 의 판단에 맡김.
- **ADR frontmatter 의 `type:` 외 필드 정규화** (예: `status`, `supersedes`) — RCA 처럼 본문 5 섹션 구조 + 최소 frontmatter 만 도입. 확장은 ADR 누적 후 별 spec.
- **기존 결정의 ADR 일괄 backfill** — ADR-001 (knowledge-types) 만 작성. 과거 walkthrough 결정 표를 ADR 로 옮기는 작업은 본 spec 에서 다루지 않음.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (체크박스 헤더 grep + type 슬롯 grep + ADR 파일 형식)
- [ ] `sources/templates/adr.md` 와 `.harness-kit/agent/templates/adr.md` 생성, 서로 동일
- [ ] `sources/templates/spec.md`, `plan.md`, `walkthrough.md` 보강 + install 미러 동기화
- [ ] `sources/commands/hk-spec-critique.md` 보강 + `.claude/commands/hk-spec-critique.md` 동기화
- [ ] `docs/decisions/ADR-001-knowledge-types.md` 작성 (`type: decision`)
- [ ] `sources/governance/constitution.md` §6.3 / §6.4 갱신 + `.harness-kit/agent/constitution.md` 동기화
- [ ] `grep -rh "^type:" docs/rca docs/decisions` 가 정규 어휘 집합으로 닫힘 (phase 통합 테스트 시나리오 1 대비)
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] `spec-16-02-adr-activation-trigger` 브랜치 push 완료
- [ ] PR 생성 및 사용자 검토 요청 알림
