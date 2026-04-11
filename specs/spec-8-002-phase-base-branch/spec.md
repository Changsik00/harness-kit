# spec-8-002: Phase base branch 지원 (opt-in)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-8-002` |
| **Phase** | `phase-8` |
| **Branch** | `spec-8-002-phase-base-branch` |
| **Base** | `phase-8-work-model` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

Phase는 `backlog/phase-N.md` 문서로만 존재하고 git에 대응하는 브랜치가 없다. 모든 spec PR이 `main`을 타깃으로 한다. Phase 내 spec들이 서로 의존하거나, phase 전체를 main 진입 전에 검증하고 싶어도 구조적으로 불가능하다.

### 문제점

- spec 간 의존성 처리 불가 — spec-8-001 결과물 위에서 spec-8-002를 작업하려면 main merge를 기다려야 함
- Phase 전체 통합 테스트를 main merge 전에 실행할 수단이 없음
- Phase rollback이 spec 단위로만 가능해서 복잡함

### 해결 방안 (요약)

`sdd phase new <slug> --base` 플래그로 phase base branch 모드를 선언한다. 실제 브랜치 생성은 첫 spec의 hk-ship 시점에 just-in-time으로 수행된다. hk-ship이 phase base branch 존재 여부를 확인하고 없으면 자동 생성 후 PR 타깃을 phase 브랜치로 지정한다.

## 📊 개념도

```
sdd phase new work-model --base
  → state.json: baseBranch = "phase-8-work-model"
  → phase-8.md: Base Branch = phase-8-work-model
  (브랜치 생성 안 함)

첫 spec hk-ship 시점:
  → origin/phase-8-work-model 존재 확인
  → 없으면: git checkout -b phase-8-work-model main
            git push -u origin phase-8-work-model
  → PR target = phase-8-work-model

이후 spec들:
  → phase-8-work-model에서 분기
  → PR target = phase-8-work-model

모든 spec merge 후:
  → phase-8-work-model → main PR
```

## 🎯 요구사항

### Functional Requirements

1. `sdd phase new <slug> --base` — phase 생성 시 base branch 모드 선언
   - `state.json`에 `baseBranch: "phase-{N}-{slug}"` 기록
   - `phase.md` 메타 테이블 `Base Branch` 필드에 브랜치명 기록
   - 실제 git 브랜치는 생성하지 않음 (just-in-time 원칙)

2. `sdd status --json` — `baseBranch` 필드 포함 출력
   - baseBranch가 없으면 `null`

3. `hk-ship` Step 4 (Push 확인) — phase base branch 감지 및 처리
   - `sdd status --json`에서 `baseBranch` 읽기
   - baseBranch가 설정된 경우:
     - `origin/{baseBranch}` 존재 여부 확인
     - 없으면: `git checkout -b {baseBranch} main && git push -u origin {baseBranch}`
     - Push 확인 블록의 타깃을 `baseBranch`로 표시
     - PR 생성 시 `--base {baseBranch}` 적용

4. `sdd phase done` — `baseBranch` 필드 null로 초기화

### Non-Functional Requirements

1. `--base` 없이 `sdd phase new <slug>` 시 기존 동작 유지 (baseBranch = null)
2. baseBranch 브랜치 자동 생성은 hk-ship에서 한 번만 실행 (이미 존재하면 skip)

## 🚫 Out of Scope

- hk-ship의 `sdd archive` 강제 및 phase done 유도 (→ spec-8-003)
- hk-align NOW/NEXT/Icebox 출력 개선 (→ spec-8-004)
- phase-8-work-model → main 최종 PR 절차 (수동)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-8-002-phase-base-branch` 브랜치 push 완료 (→ `phase-8-work-model`)
- [ ] 사용자 검토 요청 알림 완료
