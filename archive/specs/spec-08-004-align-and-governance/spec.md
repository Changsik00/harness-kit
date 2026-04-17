# spec-08-004: hk-align 강화 & 거버넌스 통합 & README 최신화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-08-004` |
| **Phase** | `phase-08` |
| **Branch** | `spec-08-004-align-and-governance` |
| **Base** | `phase-08-work-model` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- hk-align 상태 보고에 NOW/NEXT/Icebox 현황이 없다 — "다음 작업은?"에 즉시 답할 수 없다.
- agent.md에 작업 유형(Phase/Spec/spec-x/Icebox)별 행동 규칙이 명문화되어 있지 않다.
- agent.md §6.3에 FF/spec-x/phase 완료 후 필수 체크리스트가 없다.
- README가 phase-08 변경사항(NOW/NEXT/Icebox queue, phase base branch, archive completion gate, specx done 등)을 반영하지 않는다.

### 문제점

- 새 세션 시작 시 "지금 뭘 하고 있고 다음은 뭔지" 파악하려면 별도로 `sdd status` + `sdd queue`를 해야 함
- 에이전트가 FF 완료 후 state.json을 건드리거나, spec-x 완료 후 queue 갱신을 빼먹는 등 행동 규칙 불일치
- README가 오래된 슬래시 커맨드 목록과 sdd 명령을 보여줘서 사용자 혼란

### 해결 방안 (요약)

hk-align 상태 보고에 NOW/NEXT 섹션을 추가한다. agent.md에 작업 유형별 행동 규칙 표와 완료 체크리스트를 명문화한다. README를 phase-08까지의 변경사항으로 최신화한다.

## 🎯 요구사항

### Functional Requirements

1. **hk-align 상태 보고 — NOW/NEXT 추가**
   - Step 4 상태 요약 보고에 NOW(현재 spec)와 NEXT(다음 spec) 표시
   - `sdd status` 출력에서 이미 NOW/NEXT 제공하므로 중복 파싱 불필요

2. **agent.md §3 — 작업 유형별 행동 규칙 표 추가**
   - Alignment Phase에서 에이전트가 작업 유형별로 어떻게 행동해야 하는지 표로 명시
   - Phase/Spec/spec-x/FF/Icebox 각 유형의 진입·실행·종료 행동

3. **agent.md §6.3 — 완료 체크리스트 명문화**
   - FF 완료 후: state.json 변경 금지 확인
   - spec-x 완료 후: `sdd specx done` 호출 필수
   - phase 완료 후: 모든 spec Merged 확인 + `sdd phase done` 호출

4. **README.md 최신화**
   - sdd 명령 표 갱신 (`phase new --base`, `phase done`, `specx done`, `queue`)
   - 슬래시 커맨드 표 갱신 (이름 변경 반영)
   - 작업 유형 모델 섹션 추가 (Phase/Spec/spec-x/Icebox)
   - 워크플로 요약 갱신 (NOW/NEXT/Icebox 반영)

### Non-Functional Requirements

1. 기존 hk-align 동작(규약 로딩, 단 하나의 질문) 유지
2. agent.md 영어 문서 유지 (한국어 혼용 최소화)

## 🚫 Out of Scope

- sdd status 출력 포맷 변경 (이미 spec-08-001에서 완료)
- hk-align의 규약 로딩 순서 변경
- 신규 hook 추가

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (해당 시)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-08-004-align-and-governance` 브랜치 push 완료 (→ `phase-08-work-model`)
- [ ] 사용자 검토 요청 알림 완료
