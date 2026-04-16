# Implementation Plan: spec-07-003

## 📋 Branch Strategy

- 신규 브랜치: `spec-07-003-plan-accept-consistency`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 허용 응답 목록 범위 확인 — 현재 제안: `Y`, `y`, `yes`, `ok`, `accept`, `plan accept`, `/hk-plan-accept`

> [!WARNING]
> - [ ] constitution §4.2 수정은 에이전트 행동 규칙 변경이므로 내용 검토 필수

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **요청 문구** | `agent.md §4.4`에 고정 블록 추가 | spec-07-002의 선택 프롬프트와 동일 위치에 배치 |
| **허용 응답 SSOT** | `constitution.md §4.2`에만 목록 정의 | 3곳 중복 대신 단일 출처. 변경 시 한 곳만 수정 |
| **커맨드/agent 참조** | `→ constitution §4.2 참조` 한 줄로 대체 | DRY 원칙. 목록 불일치 가능성 제거 |
| **목록 외 응답** | "선택을 다시 요청" 규칙 추가 | 모호한 응답("ㅇㅇ", "진행해") 임의 해석 방지 |

### Plan Accept 표준 요청 문구 (안)

```
📋 spec/plan/task 작성 완료. 다음 단계를 선택하세요:
  1. Plan Accept (/hk-plan-accept)   — 바로 실행 단계 진입
  2. Critique    (/hk-spec-critique) — 요구사항 비판 먼저 (Opus 서브에이전트, 선택)

→ 선택 (1 또는 2):
```

- Plan Accept가 기본 경로이므로 1번에 배치
- 슬래시 커맨드를 괄호로 병기하여 직접 호출과 번호 선택 모두 안내

### 허용 응답 목록 (안)

| 표현 | 처리 |
|---|---|
| `1`, `Y`, `y`, `yes`, `ok`, `accept`, `plan accept`, `/hk-plan-accept` | Plan Accept → Execution 모드 진입 |
| `2`, `/hk-spec-critique` | Critique 단계 진입 |

## 📂 Proposed Changes

### [거버넌스 문서]

#### [MODIFY] `sources/governance/agent.md` + `agent/agent.md`

§4.4 Hard Stop for Review 내 선택 프롬프트에 허용 응답 안내 추가:

```text
→ 선택 (1 또는 2):
  - 숫자 1 또는 `/hk-spec-critique` → critique 단계
  - 숫자 2, Y/y/yes/ok/accept/plan accept, /hk-plan-accept → Plan Accept
```

#### [MODIFY] `sources/governance/constitution.md` + `agent/constitution.md`

§4.2 Plan Rules에 허용 응답 인식 규칙 + 목록 외 응답 행동 규칙 추가 (SSOT):

```text
- **Plan Accept 인식**: 다음 표현은 모두 Plan Accept로 처리한다 (대소문자 무시):
  `1`, `Y`, `yes`, `ok`, `accept`, `plan accept`, `/hk-plan-accept`
- **Critique 진입**: `2` 또는 `/hk-spec-critique`
- **목록 외 응답**: 위 목록에 없는 응답을 받은 경우 에이전트는 선택을 다시 요청한다.
```

#### [MODIFY] `sources/governance/agent.md` + `agent/agent.md`

§4.4 선택 프롬프트 순서 변경 (Plan Accept → 1번, Critique → 2번) + 허용 응답은 `constitution §4.2` 참조 한 줄로 대체:

```text
📋 spec/plan/task 작성 완료. 다음 단계를 선택하세요:
  1. Plan Accept (/hk-plan-accept)   — 바로 실행 단계 진입
  2. Critique    (/hk-spec-critique) — 요구사항 비판 먼저 (Opus 서브에이전트, 선택)

→ 허용 응답: constitution §4.2 참조
```

#### [MODIFY] `sources/commands/hk-plan-accept.md` + `.claude/commands/hk-plan-accept.md`

도입부에 허용 응답 목록 대신 `constitution §4.2` 참조 안내로 대체.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
# 거버넌스 문서 변경만 — 자동화 테스트 없음
echo "수동 검증으로 대체"
```

### 수동 검증 시나리오

1. `agent.md §4.4` 선택 프롬프트에 허용 응답 안내 포함 여부 확인
2. `constitution.md §4.2`에 허용 응답 목록 존재 여부 확인
3. `hk-plan-accept.md`에 동일 목록 명시 여부 확인
4. `sources/`와 `agent/` 양쪽 모두 반영 여부 확인

## 🔁 Rollback Plan

- 문서 변경만이므로 git revert로 즉시 복구 가능
- 에이전트 행동에 영향: 없음 (문서를 에이전트가 읽어 동작하므로 revert 후 재로드)

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
