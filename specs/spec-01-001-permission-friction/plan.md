# Implementation Plan: spec-01-001

## 📋 Branch Strategy

- 신규 브랜치: `spec-01-001-permission-friction`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] agent.md에 "단일 명령 원칙" 규칙 추가 — 에이전트 행동을 제약하는 규칙이므로 사용자 확인 필요
> - [ ] `/align` 커맨드 내용 변경 — 기존 폴백 체인을 제거하고 `sdd status` 단일 호출로 단순화

> [!WARNING]
> - [ ] sources/ 원본과 agent/ 설치본이 동시에 변경됨 (도그푸딩 프로젝트 특성)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **agent.md** | 단일 명령 원칙 추가 | 근본 원인(에이전트가 복합 명령 생성)을 차단 |
| **sdd status** | 내부 폴백 로직 추가 | 에이전트가 체이닝할 필요 제거 |
| **settings.json** | 중복 규칙 정리 | `./scripts/` vs `scripts/` 이중 등록 제거 |
| **/align 커맨드** | 복합 명령 지시 제거 | 단일 명령 원칙과 일관성 |

## 📂 Proposed Changes

### 거버넌스 규칙

#### [MODIFY] `sources/governance/agent.md`
§6 Execution Phase에 "Bash 호출 규칙" 서브섹션 추가:
- Bash 호출 시 단일 명령만 사용
- `||`, `&&`, `;` 체이닝 금지 (파이프 `|` 는 허용)
- 여러 명령 필요 시 순차 Tool 호출 또는 sdd CLI 위임

#### [MODIFY] `agent/agent.md`
위 sources 변경을 도그푸딩 대상인 agent/에도 동일 반영

### sdd CLI

#### [MODIFY] `sources/bin/sdd`
`status` 서브커맨드의 폴백 로직 강화:
- `.claude/state/current.json` 없을 때 자체적으로 git branch + git log + ls backlog/ + ls specs/ 실행
- 에이전트는 `./scripts/harness/bin/sdd status` 한 줄만 호출

#### [MODIFY] `scripts/harness/bin/sdd`
위 sources 변경을 도그푸딩 대상에도 동일 반영

### 설정 파일

#### [MODIFY] `sources/claude-fragments/settings.json.fragment`
중복 allow 규칙 제거:
- `Bash(./scripts/harness/bin/sdd:*)` 와 `Bash(scripts/harness/bin/sdd:*)` → 하나만 유지
- `Bash(./scripts/harness/bin/bb-pr:*)` 와 `Bash(scripts/harness/bin/bb-pr:*)` → 하나만 유지
- `Bash(./scripts/harness/doctor.sh:*)` 와 `Bash(scripts/harness/doctor.sh:*)` → 하나만 유지
- `Bash(./scripts/harness/hooks/*)` 와 `Bash(scripts/harness/hooks/*)` → 하나만 유지

### 슬래시 커맨드

#### [MODIFY] `sources/commands/align.md`
§2 컨텍스트 점검의 폴백 bash 블록을 제거하고, `sdd status`가 자체 폴백하므로 단일 호출만 지시:
```
./scripts/harness/bin/sdd status
```

#### [MODIFY] `.claude/commands/align.md`
위 sources 변경을 도그푸딩 대상에도 동일 반영

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오

1. `/align` 호출 → 권한 프롬프트 없이 상태 출력 확인
2. `sdd status`를 `.claude/state/current.json` 삭제 후 실행 → 폴백 출력 확인
3. settings.json.fragment에서 중복 규칙 0건 확인 (`grep -c` 검증)

## 🔁 Rollback Plan

- git revert로 커밋 단위 롤백 가능
- agent.md 규칙은 제거하면 원복
- sdd status 폴백은 기존 동작에 추가이므로 부작용 없음

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
