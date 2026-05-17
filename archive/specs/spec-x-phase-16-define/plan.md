# Implementation Plan: spec-x-phase-16-define

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-phase-16-define` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main`
- 첫 task 가 브랜치 생성

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **Phase slug 결정**: `reliability-layer` (포지셔닝과 일치). 대안: `knowledge-system` / `long-term-stability`.
> - [ ] **Spec 분해 4 개 확정**: ① RCA+Type ② ADR 트리거 ③ Stale 탐지 ④ 포지셔닝.
> - [ ] **활성화 보류**: 본 PR 머지 후에도 `sdd status` 의 active phase 는 "없음" 유지. 시작 시점은 별도 결정.

> [!WARNING]
> - 없음 (백로그 등록만, breaking change 없음)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---|:---|:---|
| **Phase 활성화 시점** | 본 PR 에서는 *대기 등록만*. activate 는 별도 결정. | 백로그에 넣자는 사용자 의도 반영. 우선순위 비교 가능한 형태 유지. |
| **Phase slug** | `reliability-layer` | 포지셔닝 슬로건 ("A reliability layer for AI-assisted engineering") 과 일치. |
| **Spec 분해 단위** | 4 개 spec (RCA+Type / ADR 트리거 / Stale 탐지 / 포지셔닝) | Type 슬롯은 RCA 와 동시 도입이 자연스러움. ADR 트리거 → Stale 탐지의 의존 명시. 포지셔닝은 독립. |
| **Phase base branch** | 사용하지 않음 (default) | 4 spec, 의존 약함, 통합 테스트 매뉴얼 영역. base branch 의 오버헤드 > 가치. |
| **Knowledge Type 슬롯 위치** | RCA 와 함께 (spec-16-01) | RCA frontmatter 가 type 의 *첫 사용자* — 같은 spec 에서 도입해 응집성 확보. |
| **통합 테스트 시나리오** | phase-16.md 에 *3 개 시나리오 헤더만* 적고 세부 비움 | 본 spec-x 범위 밖. spec 들 실행 단계에서 채움. |

### 분해 사유 요약

```
spec-16-01 ─ RCA + Knowledge Type 슬롯
                     │  type frontmatter (decision/invariant/failure-pattern/...)
                     ▼
spec-16-02 ─ ADR 활성화 트리거 (Type 슬롯 활용)
                     │  ADR 들이 frontmatter 갖춤
                     ▼
spec-16-03 ─ Stale ADR / 결정 탐지 (sdd status drift 확장)

spec-16-04 ─ Reliability layer 포지셔닝 (독립 — 어느 시점이든 가능)
```

## 📂 Proposed Changes

### Backlog

#### [NEW] `backlog/phase-16-reliability-layer.md`

`.harness-kit/agent/templates/phase.md` 를 그대로 따른다. 다음 슬롯을 채운다:

- **메타**: `phase-16` / 상태 `Planning` / Base Branch 없음 / 시작·종료일 미정
- **배경**: 외부 진단 글 + 추가 제안서를 거쳐 도출된 4+1 영역 요약. *thin orchestration* 철학과 양립 가능한 *얇은 보강* 만 다루는 phase 임을 명시.
- **목표**: "AI 가 만든 복잡도를 *제어* 하는 reliability 계층 강화" — 4 개 spec 의 완료가 phase done 조건.
- **성공 기준 (정량 우선)**:
  1. `templates/rca.md` 도입 + `/hk-rca` 슬래시 커맨드 동작 확인 (1 회 이상 RCA 작성 가능)
  2. 산출물(ADR/RCA/walkthrough 결정 표) 의 frontmatter 에 `type:` 슬롯 정규화 — grep 으로 type 별 집계 가능
  3. `sdd status` drift 에 *stale ADR/결정 탐지* 라인 추가, 가짜 stale 케이스에서 감지
  4. README/슬로건/version.json description 정렬 — "reliability layer" 키워드 노출
- **SPEC 표** (sdd 마커 사이): 4 개 spec 후보를 `Backlog` 상태로 나열
- **각 spec 상세** (마커 밖): 요점 / 방향성 / 참조(외부 글 링크 포함) / 연관 모듈
- **통합 테스트 시나리오** (헤더만, 실행 명령 비움):
  1. *Knowledge Type 일관성 시나리오*: 산출물별로 type frontmatter 가 정합
  2. *Stale 탐지 회로 시나리오*: 가짜 ADR/RCA 가 지운 모듈 참조 시 drift 라인 출력
  3. *Reliability 슬로건 회귀 시나리오*: README/version.json/`.harness-kit/` 의 키워드 일관성
- **의존성**: 선행 phase 없음. 연관 ADR 없음 (spec-16-02 에서 첫 ADR 후보 발생 예정).
- **위험 요소**: ① Out-of-scope 슬라이드 (Capability matrix / Cost routing 등 무거운 항목으로 phase 가 비대해질 위험) — Out of Scope 섹션에 명시로 완화. ② RCA 사용 빈도 낮을 가능성 — phase done 조건의 *정량 기준 4* 충족만 요구하여 강제 도입 회피.

#### [MODIFY] `backlog/queue.md`

- "📋 대기 Phase" 섹션의 `없음` 을 1 줄 항목으로 교체:
  ```
  - **phase-16** — Reliability Layer 강화 (RCA / Knowledge Type / ADR 트리거 / Stale 탐지 / 포지셔닝) — `backlog/phase-16-reliability-layer.md`
  ```
- 다른 마커 영역(active / specx / done) 은 손대지 않는다.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트
없음 (docs only).

### 수동 검증 시나리오

1. `bash .harness-kit/bin/sdd status` 실행 → active phase 여전히 "없음" 확인.
2. `cat backlog/queue.md` → "📋 대기 Phase" 섹션에 phase-16 한 줄 등록 확인.
3. `head -50 backlog/phase-16-reliability-layer.md` → 메타 / 배경 / 목표 / 성공 기준 4 개 노출 확인.
4. `grep -c "spec-16-" backlog/phase-16-reliability-layer.md` → 최소 4 개 매치.
5. `git diff main` → 변경 범위가 (a) `backlog/phase-16-reliability-layer.md` 신규, (b) `backlog/queue.md` 대기 섹션, (c) spec-x 산출물 5 개로 한정.

## 🔁 Rollback Plan

- 단일 PR / docs only. revert 즉시 복원. 데이터/상태 영향 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
