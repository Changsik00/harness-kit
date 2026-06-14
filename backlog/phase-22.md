# phase-22: extend — 외부 도구 opt-in 통합

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-22-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-22` |
| **상태** | Planning |
| **시작일** | 2026-06-14 |
| **목표 종료일** | 미정 |
| **소유자** | dennis |
| **Base Branch** | 없음 (각 spec → main 직접 머지) |

## 🎯 배경 및 목표

### 현재 상황

harness-kit 는 거버넌스(SDD) 부트스트랩 툴킷이며, 현재 외부 도구(MCP 서버 등)를 다룬 적이 없다. 한편 Claude Code 기본 루프는 코드 탐색을 `Grep`/`Read` 같은 텍스트 기반 도구로 수행하므로, 심볼 rename·find-references 같은 리팩토링 작업이 VSCode(LSP) 대비 느리고 토큰 왕복이 많다. 사용자는 이미 토큰 소비가 크다고 느끼며 ceremony cost 를 줄이는 중이다.

LSP 기반 코드 인텔리전스(예: **Serena** MCP)는 grep 다단계 탐색을 단일 atomic 호출로 압축해 리팩토링·심볼 탐색의 토큰/정확도를 개선할 수 있다. 다만 MCP 는 키트의 1순위 원칙("컨텍스트 비용 0 우선: bash > Slash > Skill > MCP")상 *가장 비싼* 수단이며, 상시 켜두면 ceremony cost 절감 노력과 충돌한다.

### 목표 (Goal)

"있으면 더 좋은" 외부 도구를 **opt-in(default-off)** 으로 연결하는 **extend** 개념을 도입한다. 단, 확장 *프레임워크/레지스트리* 를 선설계하지 않고 — **검증된 첫 확장 한 개(Serena/LSP)** 를 구체적으로 구현해 도그푸딩으로 효용을 실측한 뒤, 후속 확장이 누적되면 그때 공통 패턴을 추출한다(추상화는 첫 사용자 검증 후).

### 성공 기준 (Success Criteria) — 정량 우선

1. `/hk-extend` 로 Serena 를 **스코프 선택(local=이 프로젝트·나만 기본 / user=모든 프로젝트)** 하여 설치·등록할 수 있다. 커밋되는 `.mcp.json`(팀 공유)은 기본 경로에서 제외된다.
2. 설치/제거가 **멱등**하며(이미 설치 시 재설치 안내, `claude mcp remove` 로 깔끔히 해제), `claude mcp list` 에 `serena` 가 노출된다.
3. extend 규약(**default-off**, 등록은 `claude mcp add` 에 위임, **검증된 확장 3개 누적 후에만 레지스트리 추출**)이 ADR-007 로 명문화된다.
4. (도그푸딩 검증) 동일 리팩토링 작업을 grep 방식 vs Serena 방식으로 수행해 스텝/토큰 차이를 1회 이상 실측하고 phase 검증 결과에 기록한다.

## 🧩 작업 단위 (SPEC + phase-FF)

> 본 절은 phase 의 *작업 지도* 입니다. 실질적/불확실 → **SPEC**(아래 표), 작고 가역적인 1–2 commit → **phase-FF**(맨 아래 목록).
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-22-01` | extend-serena | P? | Active | `specs/spec-22-01-extend-serena/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-22-01 — extend-serena (확장 1호: Serena/LSP 설치 커맨드)

- **요점**: `/hk-extend` 슬래시 커맨드 + `sdd extend` 헬퍼를 신설해, Serena(LSP MCP)를 opt-in 스코프 선택으로 설치/등록/제거한다.
- **방향성**:
  - 슬래시 커맨드(`sources/commands/hk-extend.md`)는 *오케스트레이션*만 — 사용 가능한 확장(현재 Serena 1개) 안내 + 스코프 질문 + 헬퍼 호출.
  - 실제 로직은 bash 헬퍼(`sdd extend ...`)에 둔다(컨텍스트 비용 0 원칙). 선행조건(`uv`/`claude` CLI) 점검 → Serena 등록(`claude mcp add serena --scope <local|user> -- <serena 실행 커맨드>`) → `installed.json` 에 설치 흔적 기록.
  - 레지스트리/카탈로그 추상화는 만들지 않음 — Serena 한 개를 정직하게 하드코딩(후속 확장 누적 시 ADR-007 기준으로 추출).
- **참조**:
  - `docs/decisions/ADR-007-extend-opt-in.md` (본 spec 에서 신설)
  - Serena: https://github.com/oraios/serena (설치는 MCP 마켓플레이스 금지 — `uv`/`uvx` 정공법, 실행 커맨드는 구현 시점 공식 문서로 재확인)
- **연관 모듈**: `sources/commands/hk-extend.md`, `sources/bin/sdd`, `sources/bin/lib/`, `.harness-kit/installed.json`

<!-- 후속 확장(예: 검색 .sh, 다른 MCP)은 검증 후 spec-22-02+ 로 추가 -->

### phase-FF 예정 항목 (spec 미생성)

> 현재 없음. (extend 1호 검증 후 후속 항목 발생 시 추가)

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 확장 등록 스코프 | local / user / project(.mcp.json 커밋) | local 기본 + user 옵션, project 제외 | 커밋되는 `.mcp.json` 은 팀 전원에게 컨텍스트 비용을 강요해 opt-in(default-off) 원칙 위반 |
| 추상화 시점 | 지금 레지스트리 / 검증 후 | 검증 후(확장 3개) | "추상화는 첫 사용자 검증 후" — 선프레임워크 함정 회피 |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: Serena local 설치 → 확인 → 제거
- **Given**: `uv`, `claude` CLI 가 존재하는 환경
- **When**: `/hk-extend` → Serena 선택 → 스코프 local 선택 → 헬퍼 실행
- **Then**: `claude mcp list` 에 `serena` 노출 + `installed.json` 에 설치 흔적 기록. 재실행 시 "이미 설치됨" 안내(멱등). 제거 후 목록에서 사라짐.
- **연관 SPEC**: spec-22-01

### 시나리오 2: 선행조건 부재 처리
- **Given**: `uv` 미설치 환경
- **When**: 헬퍼 실행
- **Then**: 설치를 진행하지 않고 `uv` 설치 안내 메시지 출력 후 graceful 종료(비파괴).
- **연관 SPEC**: spec-22-01

### 통합 테스트 실행
```bash
# 키트 bash 테스트 하니스로 실행 (구현 시점 확인)
bash test/extend.test.sh
```

## 🔗 의존성

- **선행 phase**: 없음
- **외부 시스템**: `uv`(Python 패키지 매니저), `claude` CLI(MCP 등록), Serena(oraios/serena)
- **연관 ADR**:
  - `docs/decisions/ADR-007-extend-opt-in.md` (신설)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| Serena 실행 커맨드가 버전(v1.5.3+)에 따라 바뀜 | 등록 실패 | 구현 시점 공식 문서로 커맨드 재확인 후 핀, 등록 직후 `claude mcp list` 로 검증 |
| MCP 상시 비용으로 ceremony cost 절감과 충돌 | 토큰 비용 증가 | default-off 강제 + local 스코프 기본(켠 사람만 부담), README 에 비용 명시 |
| 키트가 ~/.claude.json(스코프 저장소)을 직접 못 다룸 | 설치 흔적 추적 한계 | 등록은 `claude mcp add` 에 위임, 키트는 `installed.json` 에 "설치 시도" 흔적만 기록 |
| `claude` CLI 부재(비대화 환경) | 등록 불가 | 선행조건 점검에서 graceful 안내 후 종료 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 기록 (특히 #4 도그푸딩 토큰 실측)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, grep vs Serena 토큰 실측값, 회귀 점검 결과 등을 여기 첨부 -->
