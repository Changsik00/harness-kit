# spec-8-001: 작업 분류 모델 정의 & Queue 재설계

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-8-001` |
| **Phase** | `phase-8` |
| **Branch** | `spec-8-001-queue-redesign` |
| **Base** | `phase-8-work-model` (just-in-time 생성 — 첫 hk-ship 시 자동) |
| **상태** | Plan Accepted |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`backlog/queue.md`는 진행 중 phase, 대기 phase, 완료 phase를 나열하는 단순 대시보드다.
`sdd status`는 Active Phase / Active Spec / Branch / Plan Accept를 출력한다.
작업 유형(Phase, Spec, spec-x, Icebox)의 역할과 경계는 어디에도 명문화되어 있지 않다.

### 문제점

1. **"지금 뭐 해야 하나?"를 queue만 보고 즉시 알 수 없다.** Active phase는 보이지만 그 안에서 어떤 spec을 하고 있는지, 다음은 무엇인지 queue.md에 없다.
2. **spec-x, Icebox 항목의 위치가 없다.** spec-x는 queue에 흔적이 없고, Icebox(아이디어 보관소)는 개념조차 없다.
3. **작업 유형 모델이 없어 판단이 흔들린다.** "이건 spec-x로 해야 하나, phase에 넣어야 하나, Icebox에 넣어야 하나"의 기준이 constitution에 없다.
4. **`sdd status`가 NEXT를 모른다.** 현재 spec은 알지만 다음 spec을 계산하지 않는다.

### 해결 방안 (요약)

- constitution에 작업 유형 모델(Phase/Spec/spec-x/Icebox)을 정의한다.
- queue.md 구조를 NOW/NEXT/Icebox를 포함한 형태로 재설계하고 sdd가 자동 관리한다.
- `sdd status`에 NEXT 출력을 추가하고, `sdd queue`를 구조화 출력으로 개선한다.

## 📊 개념도

```
작업 유형 라이프사이클:

아이디어 발생
    ↓
🧊 Icebox  ──────────────────────────────┐
    ↓ (꺼낼 때 판단)                       │
    ├─ 단발성 → spec-x (standalone PR)    │
    └─ 묶임 → 새 Phase (Epic)             │
                                          │
Phase                                     │
  └── Spec들 (PR 단위, 순차)              │ 다시 넣기
        ↓ all merged                      │
      Phase Done → main                  │
                                          │
spec-x                                    │
  ↓ merged                               │
  완료 → queue 완료 섹션 이동             │
                                          │
queue.md NOW/NEXT 포커스:                 │
  🔴 NOW  [현재 spec]                     │
  ⏭ NEXT [다음 spec]                     │
  🧊 Icebox ────────────────────────────┘
```

## 🎯 요구사항

### Functional Requirements

1. `constitution.md`에 작업 유형 정의 섹션 추가
   - **Phase**: 연관 spec의 묶음(Epic). opt-in으로 base branch 보유 가능. 독립된 통합 테스트 가능.
   - **Spec**: Phase 내 단일 PR 단위. 독립적으로 테스트 가능해야 함. PR base = phase 브랜치 또는 main.
   - **spec-x**: Phase 비소속 단독 PR. `chore`/`fix`/`docs`/소규모 `refactor`만 허용. Icebox에서 승격되거나 즉시 생성.
   - **Icebox**: 아이디어·보류 항목 보관소. 실행 불가(backlog law). 관련 항목 쌓이면 Phase로 승격, 단발이면 spec-x로 승격.
2. `sources/templates/queue.md` 구조 재설계 — 아래 섹션 순서로:
   - `🔴 NOW` / `⏭ NEXT` (sdd 자동 갱신 마커)
   - `📦 진행 중 Phase` — 진행률 표시 포함 (sdd 자동)
   - `📥 spec-x 대기` (sdd 자동)
   - `🧊 Icebox` (수동 관리)
   - `📋 대기 Phase` (sdd 자동)
   - `✅ 완료` (sdd 자동)
3. `sources/templates/phase.md` spec 표에 In Progress 상태 값 추가 및 active spec 마킹 규칙 명시
4. `sdd status` 출력에 `NEXT` 항목 추가 — phase.md spec 표에서 첫 번째 Backlog 상태 spec을 찾아 출력
5. `sdd queue` 명령을 raw cat에서 NOW/NEXT 하이라이트 포함 구조화 출력으로 개선
6. 현재 `backlog/queue.md`와 `agent/constitution.md`에 도그푸딩 반영

### Non-Functional Requirements

1. 기존 `<!-- sdd:*:start/end -->` 마커 호환성 유지 — 신규 마커 추가 방식
2. `sdd status` 응답 시간 변화 없음 — NEXT 계산은 phase.md 단순 파싱으로 처리
3. queue.md 수동 Icebox 섹션은 sdd가 건드리지 않음

## 🚫 Out of Scope

- Phase base branch 생성/관리 로직 (→ spec-8-002)
- hk-ship archive 강제 (→ spec-8-003)
- hk-align 출력 개선 (→ spec-8-004)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-8-001-queue-redesign` 브랜치 push 완료 (→ phase-8 브랜치 타깃)
- [ ] 사용자 검토 요청 알림 완료
