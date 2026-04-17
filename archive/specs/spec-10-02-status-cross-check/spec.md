# spec-10-02: sdd status 자기 진단 엔진

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-10-02` |
| **Phase** | `phase-10` |
| **Branch** | `spec-10-02-status-cross-check` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd status`는 state.json과 phase.md의 값을 그대로 출력만 한다. 브랜치명을 보여주지만 해석하지 않고, git 이력과의 교차 검증도 없으며, 불일치 발견 시 행동 제안도 없다.

### 문제점

1. **브랜치 패턴 미해석**: `spec-10-01-archive-status-fix` 브랜치에 있어도 "이건 phase-10의 이전 spec 작업 브랜치"라는 판단을 못함. 에이전트가 유저에게 "머지 됐나요?", "main으로 갈까요?" 같은 불필요한 질문을 반복하게 됨.
2. **phase.md ↔ git 불일치 미감지**: phase.md에 `Done`으로 남아있지만 실제로는 이미 머지된 spec이 있어도 경고 없음.
3. **state.json 모순 미감지**: `spec=null` + `phase=active`, `planAccepted=true` + plan.md 부재 등 논리적 모순을 감지하지 못함.
4. **경고만 있고 행동 제안 없음**: 문제를 감지해도 "어떻게 해야 하는지" 안내가 없으면 실질적 가치가 없음.

### 해결 방안 (요약)

`cmd_status`에 자기 진단 블록을 추가하여: (1) 브랜치 패턴에서 work mode 추론, (2) phase.md ↔ git 교차 검증, (3) state.json 정합성 검사를 수행하고, 불일치 발견 시 구체적 정리 명령까지 안내한다.

## 🎯 요구사항

### Functional Requirements

1. **브랜치 패턴 해석 + work mode 추론**:
   - `spec-{N}-{seq}-*` → `Work Mode: SDD-P (phase-{N})`
   - `phase-{N}-*` → `Work Mode: phase base (phase-{N})`
   - `spec-x-*` → `Work Mode: SDD-x`
   - `main` → `Work Mode: 대기`
   - 기타 → `Work Mode: 미식별`
   - 추론 결과를 기본 출력의 Branch 라인 옆에 표시

2. **phase.md ↔ git 교차 검증**:
   - phase.md spec 테이블에서 `Merged`가 아닌 spec 목록 추출
   - 각 spec에 대해 해당 spec ID가 포함된 머지 커밋이 phase 브랜치(또는 main)의 git log에 존재하는지 확인
   - 불일치 시 경고 + 행동 제안: `⚠ spec-X-NNN: phase.md(Done) ↔ git(머지됨) → sdd archive 실행 권장`

3. **state.json 정합성 검사**:
   - `spec=null` + phase active → `ℹ Active Spec 없음 — 다음 spec 시작 또는 phase done 확인 필요`
   - `planAccepted=true` + plan.md 파일 부재 → `⚠ planAccepted=true이지만 plan.md 없음`

4. **출력 형식**:
   - 진단 결과가 있을 때만 `🔍 진단` 섹션으로 기본 출력 하단에 표시
   - `--brief`, `--json` 모드에서는 진단 생략

### Non-Functional Requirements

1. git log 호출 최소화 — non-Merged spec이 있을 때만 실행
2. 기존 `sdd status` 출력 구조 유지 — 진단은 기존 출력 아래에 추가
3. 진단은 읽기 전용 — 상태를 변경하지 않음 (제안만)

## 🚫 Out of Scope

- phase.md 자동 보정 (경고 + 제안만, 실제 수정은 하지 않음)
- spec 산출물 완성도 검증 (spec-10-03 범위)
- `_check_phase_all_merged`, `compute_next_spec` 수정 (spec-10-04 범위)
- `--quiet` 플래그

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-10-02-status-cross-check` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
