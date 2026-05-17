# spec-x-sdd-state-guard: sdd state 단일평면 footgun 단기 가드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-sdd-state-guard` |
| **Phase** | 없음 (SDD-x) |
| **Branch** | `spec-x-sdd-state-guard` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd` 의 state.json 은 단일 평면 namespace 입니다.

```
.claude/state/current.json
├── phase         : "phase-NN" | null
├── spec          : "spec-N-NN-..." | "spec-x-..." | null   ← SDD-P spec 과 spec-x 가 같은 슬롯
├── planAccepted  : true | false
├── baseBranch    : "phase-NN-slug" | null
└── lastTestPass  : ISO timestamp
```

`spec` 필드 하나가 *두 가지 이질적 컨텍스트*(SDD-P spec, spec-x) 를 담고, 어떤 컨텍스트인지는 *`phase` 값이 null 인지로 유추*해야 합니다 (암묵적 invariant).

각 destructive 명령은 이 invariant 를 *호출자가 챙기는* 전제로 구현되어 있어, 활성 spec 보호 가드가 누락된 진입점이 다수 존재합니다.

### 문제점

본 spec 직전 운영 세션에서 다음 시나리오로 footgun 확인:

> spec-x 진행 중 (`spec` 채워짐, `planAccepted=true`) → 다음 작업 준비 차 `sdd phase activate phase-01` 실행 → state 의 `spec` 이 silent 하게 null 로, `planAccepted` 가 false 로 reset 됨. 활성 spec-x 컨텍스트가 sdd 추적에서 사라짐. hook (check-plan-accept) 가 후속 Edit/Write 차단할 가능성.

코드 분석 결과 같은 패턴이 3 군데 존재:

| 함수 | 라인 | 증상 |
|---|---|---|
| `phase_activate` | sdd:905-923 | `cur_phase` 충돌만 검사. 활성 spec 인지 X → `spec=null` 무조건 reset |
| `phase_new` | sdd:860-862 | 동일. 활성 spec 있는 상태에서도 새 phase 생성 진행 + state 덮어쓰기 |
| `spec_new` | sdd:1251-1252 | 활성 spec(spec-x 포함) 있어도 새 spec 으로 덮어씀. 가드 없음 |

이 외에 ship 의 비대칭 reset, lastTestPass 의 글로벌 가시성 등 *구조적 이슈*가 있으나 본 spec 범위 밖.

### 해결 방안 (요약)

`state.sh` 에 `die_if_active_spec <action>` helper 를 추가하고, 위 3 군데 진입점에 호출 + `--force` 플래그를 추가합니다 (`phase_new` 는 기존 플래그 의미 확장). 활성 spec 이 있으면 sdd 가 즉시 die 하고 명확한 해결 경로 (`sdd specx done` / `sdd ship` / `--force`) 를 안내합니다.

## 🎯 요구사항

### Functional Requirements

1. `state.sh` 에 `die_if_active_spec <action>` helper 추가:
   - `state.spec` 이 비어있지 않고 `"null"` 도 아닌 경우 stderr 에 다음 출력 후 exit 1:
     - 활성 spec ID
     - 호출한 action 이름 (예: `phase activate`)
     - spec-x 인 경우 `sdd specx done <slug>` 안내 / SDD-P spec 인 경우 `sdd ship` 안내
     - `--force` 플래그 안내
2. `phase_activate` 에 가드 추가 + `--force` 플래그 신설.
3. `phase_new` 에 가드 추가 + 기존 `--force` 플래그가 활성 spec 가드도 함께 우회 (사전 정의 phase 가드와 동일 의미 확장).
4. `spec_new` 에 가드 추가 + `--force` 플래그 신설.
5. 회귀 테스트: 기존 `test-sdd-phase-activate.sh` 의 Check 1-9 모두 PASS (활성 spec 없는 fixture 라 가드 미발동, 기존 동작 보존).

### Non-Functional Requirements

1. **호환성**: 활성 spec 이 없는 상황에서는 기존 동작과 완전히 동일.
2. **명시성**: die 메시지는 한국어, 컨텍스트별로 정확한 해결 명령 제시.
3. **단순성**: helper 는 bash 3.2+, 50 줄 이내.
4. **도그푸딩**: 변경은 `sources/bin/` 과 `.harness-kit/bin/` 양쪽 동시 반영 (release 흐름과 일치).

## 🚫 Out of Scope

- **state 공간 분할** (`spec` → `pSpec` / `xSpec`) — ADR 후보로 별도 처리.
- **lastTestPass 의 spec 식별자 추가** — 별도 spec.
- **baseBranch 누수 / FF 모드 마커 부재** — Icebox 후보.
- **ship 의 비대칭 state reset** — 별도 검토.
- **agent.md / constitution.md 거버넌스 문서 갱신** — 본 spec 은 *명령 구현 fix*. 문서 갱신이 필요하면 후속 FF / spec-x.

## 📑 ADR 후보 (Architecture Decision Records)

- [x] ADR 가치 있는 결정 있음 → 후보 한 줄 요약: `state-namespace-split` (type: decision) — **별도 spec/ADR 작업**. 본 spec 은 단기 가드만.
- [ ] 없음

## ✅ Definition of Done

- [ ] `die_if_active_spec` helper 단위 동작 검증
- [ ] `phase_activate` / `phase_new` / `spec_new` 각각의 가드 동작 + `--force` 우회 동작 검증
- [ ] 기존 `test-sdd-phase-activate.sh` 회귀 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-sdd-state-guard` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
