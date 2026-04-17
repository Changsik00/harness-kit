# Implementation Plan: spec-10-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-10-02-status-cross-check`
- 시작 지점: `phase-10-status-reliability`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] git 머지 감지 방식: `git log --oneline <base> | grep <spec-id>` — squash merge 커밋 메시지에 spec ID가 포함되는 전제
> - [ ] 브랜치 패턴 해석이 `cmd_status` 기본 출력에 포함됨 — 기존 출력 형식 소폭 변경

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **브랜치 해석** | regex 패턴 매칭 (`spec-{N}-{seq}`, `phase-{N}`, `spec-x-`) | 명명 규칙이 constitution §6에 고정됨 |
| **git 머지 감지** | `git log --oneline <base> \| grep <spec-id>` | 별도 API 불필요, squash merge 메시지에 spec ID 포함 |
| **진단 출력** | 기본 출력 하단 `🔍 진단` 섹션 | 항상 노출되어야 실질적 가치 |
| **행동 제안** | 경고마다 `→ <구체적 명령>` 패턴 | "무엇이 잘못됐는지"만이 아닌 "어떻게 고치는지"까지 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd` — `cmd_status()` 내부

1. Branch 라인 출력 후 work mode 추론 결과 추가:
```text
  Branch:       spec-10-01-archive-status-fix (SDD-P, phase-10)
```

2. 기본 출력 끝(task 카운트 이후, verbose 블록 전)에 `_status_diagnose` 호출 삽입

#### [NEW] `sources/bin/sdd` — `_status_diagnose()` 함수

```text
_status_diagnose(phase, spec, plan_accepted):
  warnings=[]

  # 1. phase.md ↔ git 교차 검증
  if phase exists:
    non_merged_specs = phase.md에서 Merged 아닌 spec 추출
    for each spec_id in non_merged_specs:
      if git log <base-branch> | grep spec_id:
        warnings += "⚠ {spec_id}: phase.md({status}) ↔ git(머지됨) → sdd archive 실행 권장"

  # 2. state.json 정합성
  if spec=null && phase!=null:
    warnings += "ℹ Active Spec 없음 — 다음 spec 시작 또는 phase done 확인 필요"
  if plan_accepted=true && plan.md 부재:
    warnings += "⚠ planAccepted=true이지만 plan.md 없음"

  # 3. 출력
  if warnings not empty:
    print "🔍 진단"
    for w in warnings: print "  {w}"
```

#### [NEW] `sources/bin/sdd` — `_infer_work_mode()` 함수

```text
_infer_work_mode(branch):
  case branch:
    spec-{N}-{seq}-* → "SDD-P (phase-{N})"
    phase-{N}-*      → "phase base (phase-{N})"
    spec-x-*         → "SDD-x"
    main             → "대기"
    *                → "미식별"
```

### 동기화

#### [MODIFY] `.harness-kit/bin/sdd`

`sources/bin/sdd` 변경 사항을 도그푸딩용으로 복사.

### 테스트

#### [NEW] `tests/test-sdd-status-cross-check.sh`

- 시나리오 1: 브랜치 패턴 → work mode 추론 정확성
- 시나리오 2: phase.md Done + git 머지됨 → 경고 + 행동 제안 출력
- 시나리오 3: state.json `spec=null` + `phase=active` → 안내 메시지
- 시나리오 4: `planAccepted=true` + plan.md 없음 → 경고

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-sdd-status-cross-check.sh
```

### 전체 회귀 테스트
```bash
bash tests/run-all.sh
```

### 수동 검증 시나리오
1. 현재 phase-10 상태에서 `sdd status` → `spec=null` + `phase=phase-10` 안내 확인
2. spec 브랜치에서 `sdd status` → work mode 표시 확인

## 🔁 Rollback Plan

- `sources/bin/sdd`의 변경만 revert. 진단은 읽기 전용이므로 상태 변경 부작용 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
