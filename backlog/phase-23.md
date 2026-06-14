# phase-23: extension-first

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-23-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-23` |
| **상태** | Planning |
| **시작일** | 2026-06-14 |
| **목표 종료일** | 2026-06-14 |
| **소유자** | dennis |
| **Base Branch** | 없음 |

## 🎯 배경 및 목표

### 현재 상황

`/hk-extend` 로 Serena(LSP 코드 인텔리전스 MCP) 같은 외부 확장을 opt-in(default-off)으로 붙일 수 있다. 그러나 (1) 설치돼 있어도 에이전트가 자발적으로 사용하지 않으면 무용하고(이번 세션에서 serena 설치본이 있었음에도 직접 grep/Read 만 사용됨), (2) extend 의 톤이 "있으면 좋은 것" 수준이라 코드 집약 프로젝트에서도 설치가 유도되지 않는다.

동시에 키트는 "컨텍스트 비용 0 우선 (MCP 최후)" 원칙(CLAUDE.md #2)을 갖는다. 따라서 "외부 확장을 권장/우선 사용" 으로 전환하되, 이 원칙과 충돌하지 않도록 **조건부**(설치돼 있고, 그 도구의 강점 영역일 때)로 정의해야 한다.

### 목표 (Goal)

외부 확장을 "설치돼 있으면 강점 영역에서 우선 사용" 하도록 거버넌스에 명문화하고, extend 를 권장 톤으로 전환하며, 코드 프로젝트에서 미설치 시 설치를 자연스럽게 유도한다. 이 전환의 트레이드오프(MCP 상시비용 vs 컨텍스트 절감)를 ADR 로 못박는다.

### 성공 기준 (Success Criteria)

1. agent.md 에 "확장 우선 사용(조건부)" 규칙이 추가되고, sources/governance 미러와 byte-identical.
2. ADR-008(tradeoff)이 결정 근거를 기록한다.
3. `sdd status` drift 가 "코드 프로젝트 + 확장 미설치" 를 감지해 1줄 권장을 출력한다.
4. 거버넌스 워드 버짓(8,000) 초과 없음 (`sdd doctor`).

## 🧩 작업 단위 (SPEC + phase-FF)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-23-01` | prefer-extensions | P? | Merged | `specs/spec-23-01-prefer-extensions/` |
<!-- sdd:specs:end -->

### spec-23-01 — prefer-extensions

- **요점**: 외부 확장을 "설치 시 강점 영역 우선 사용"으로 거버넌스화 + extend 권장 톤 전환 + 미설치 감지 권장 1줄.
- **방향성**:
  - ADR-008(tradeoff): MCP 상시비용 vs 컨텍스트 절감 — 조건부 우선 사용 채택 근거.
  - agent.md §6.5 영역에 확장 우선 사용 규칙 추가(조건부: 설치됨 + LSP/심볼 등 강점 작업). 영어. sources 미러 동시 수정.
  - `sources/commands/hk-extend.md` 톤을 "권장"으로 조정(opt-in 원칙·상시비용 경고는 유지).
  - `sdd` drift: 코드 프로젝트(.ts/.py 등 존재) + 확장 미설치 감지 → "serena 미설치 — `/hk-extend` 권장" 1줄. `.harness-kit/bin/sdd` + `sources/bin/sdd` 미러. 테스트 추가.
- **참조**: `docs/decisions/ADR-008-extension-preferential-use.md`, `CLAUDE.md` 원칙 #2
- **연관 모듈**: `.harness-kit/agent/agent.md`, `sources/governance/agent.md`, `sources/commands/hk-extend.md`, `.harness-kit/bin/sdd`, `sources/bin/sdd`

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 우선 사용 강도 | 무조건 / 조건부 | 조건부 | 원칙 #2(MCP 최후)와 양립 — bash 등 비-LSP/단순 작업까지 강제 금지 |
| 일반화 범위 | serena 전용 / 확장 일반 | 확장 일반 | 향후 다른 확장에도 적용. serena 는 현재 인스턴스 |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: 미설치 코드 프로젝트 권장
- **Given**: 코드 파일(.ts 등) 존재 + serena 미설치
- **When**: `sdd status` 실행
- **Then**: 확장 권장 1줄 출력. 비-코드/이미 설치 시 미출력.
- **연관 SPEC**: spec-23-01

### 통합 테스트 실행
```bash
bash tests/run.sh --fast
```

## 🔗 의존성

- **선행 phase**: 없음
- **연관 ADR**: `docs/decisions/ADR-008-extension-preferential-use.md`

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| 우선 사용 무조건화 | 비-LSP 작업에 불필요한 MCP 비용 | 조건부 규칙 + 강점 영역 명시 |
| drift 권장 과다 노출 | 잡음 | "미설치 + 코드 프로젝트" 둘 다 만족 시에만, 1줄 |
| 워드 버짓 초과 | doctor 경고 | 규칙 추가는 최소 문장, 상세는 ADR 로 이관 |

## 🏁 Phase Done 조건

- [ ] spec-23-01 merge
- [ ] 통합 테스트 시나리오 PASS
- [ ] 성공 기준 측정 결과 기록
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값 -->
