# phase-10: sdd 상태 진단 신뢰성 강화

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-10-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-10` |
| **Base Branch** | `phase-10-status-reliability` |
| **상태** | Planning |
| **시작일** | 2026-04-16 |
| **목표 종료일** | 미정 |
| **소유자** | ck |

## 🎯 배경 및 목표

### 현재 상황

`sdd status`와 `sdd archive`의 상태 진단/갱신 로직에 구조적 결함이 있다.

1. **archive 상태 전이 누락**: `cmd_archive`의 awk 패턴이 `| In Progress |`와 `| Active |`만 매칭하여, `| Done |` 상태인 spec은 `| Merged |`로 갱신되지 않는다. Phase-9에서 13개 spec 중 10개가 "Done"으로 잔류한 실제 사례 발생.

2. **status가 phase.md를 맹신**: `sdd status`는 phase.md의 spec 테이블을 SSOT로 취급하지만, 이 테이블은 `sdd archive` 실행 누락이나 상태 전이 버그로 실제 git 이력과 불일치할 수 있다. 교차 검증이 전혀 없다.

3. **state.json ↔ 현실 불일치 미감지**: `spec=null`인데 phase가 active, `planAccepted=true`인데 plan.md가 없는 등의 모순을 감지하지 못한다.

4. **spec 완성도 미확인**: active spec의 필수 산출물(spec.md, plan.md, task.md, walkthrough.md, pr_description.md) 존재 여부를 확인하지 않아, archive 시점에야 문제를 발견한다.

5. **phase 완료 시점 판단 부정확**: `_check_phase_all_merged()`가 phase.md 테이블만 보므로, 테이블이 부정확하면 phase done 유도를 놓친다.

### 목표 (Goal)

- `sdd archive`의 상태 전이가 모든 유효한 상태(Active, In Progress, Done)에서 Merged로 정확히 전환된다.
- `sdd status`가 phase.md, state.json, git 이력, specs/ 디렉토리를 교차 검증하여 불일치 시 경고를 출력한다.
- phase의 모든 spec이 실제로 완료되었는지 git 기반으로 판단하여 phase-ship을 정확히 유도한다.

### 성공 기준 (Success Criteria)

1. `sdd archive` 실행 시 `| Done |` 상태의 spec도 `| Merged |`로 정상 전환된다. (spec-10-001 완료)
2. `sdd status`가 브랜치 패턴에서 work mode(SDD-P/SDD-x/phase-base)를 자동 추론하여 표시한다.
3. `sdd status`가 phase.md ↔ git 불일치 감지 시 경고 + 구체적 정리 명령을 안내한다.
4. `sdd status`가 state.json 모순(spec=null + phase active, planAccepted=true + plan.md 부재)을 감지하고 경고한다.
5. `sdd status`가 active spec의 필수 산출물 누락을 감지하고 안내한다.
6. `_check_phase_all_merged`가 Done 상태를 미완료로 정확히 카운트한다.
7. `compute_next_spec`이 Done(archive 누락) spec을 NEXT에 포함한다.
8. phase의 모든 spec이 실제 머지 완료 시 phase-ship 유도 메시지가 정확히 출력된다.
9. 모든 기존 테스트(`bash tests/run-all.sh`) PASS.

## 🧩 작업 단위 (SPECs)

> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-10-001` | archive-status-fix | P1 | Merged | `specs/spec-10-001-archive-status-fix/` |
| `spec-10-002` | status-cross-check | P1 | Merged | `specs/spec-10-002-status-cross-check/` |
| `spec-10-003` | spec-completeness | P2 | Merged | `specs/spec-10-003-spec-completeness/` |
| `spec-10-004` | phase-done-accuracy | P2 | Backlog | `specs/spec-10-004-phase-done-accuracy/` |
<!-- sdd:specs:end -->

### spec-10-001 — archive 상태 전이 수정

- **요점**: `cmd_archive`의 awk 패턴에 `| Done |` 매칭을 추가하여 모든 유효 상태에서 Merged로 전환되도록 수정.
- **방향성**:
  - `sources/bin/sdd` `cmd_archive()` 함수의 awk 조건에 `|| /\| Done \|/` 추가
  - 상태 전이 모델을 주석으로 명시: `Backlog → Active → In Progress → Done → Merged` (어느 단계에서든 archive 가능)
  - 테스트: Done 상태 spec에 archive 실행 → Merged 전환 확인
- **연관 모듈**: `sources/bin/sdd`, `.harness-kit/bin/sdd`, `tests/test-sdd-archive-completion.sh`

### spec-10-002 — status 자기 진단 엔진

- **요점**: `sdd status`가 경고만 출력하는 게 아니라, 현재 상황을 스스로 판단하고 다음 행동을 제안하는 자기 진단 도구로 강화.
- **방향성**:
  - **브랜치 패턴 해석**: 현재 브랜치명에서 work mode 자동 추론
    - `spec-{N}-{seq}-*` → SDD-P, phase-{N}의 spec 작업 브랜치
    - `phase-{N}-*` → phase base 브랜치 (spec 전환 중)
    - `spec-x-*` → SDD-x, main 기반
    - `main` → 대기 상태
  - **phase.md ↔ git 교차 검증**: phase.md에서 "Merged" 아닌 spec에 대해, git log에 해당 spec의 머지 커밋이 phase 브랜치에 존재하는지 확인. 불일치 시 경고.
  - **state.json 정합성**: spec=null + phase active → 안내. planAccepted=true + plan.md 부재 → 경고.
  - **잔재 감지 + 행동 제안**: 이전 spec의 미정리 항목(archive 누락, task.md 미체크) 감지 시 구체적 정리 명령 안내. 예: `⚠ spec-10-001: phase.md(Done) ↔ git(머지됨) → sdd archive 실행 권장`
  - 기본 출력에 진단 섹션 포함. `--brief`/`--json` 에서는 생략.
- **연관 모듈**: `sources/bin/sdd` (`cmd_status`), `sources/bin/lib/state.sh`

### spec-10-003 — spec 완성도 검증

- **요점**: active spec의 필수 산출물(spec.md, plan.md, task.md) 존재 여부를 status에서 표시. archive 전 walkthrough.md, pr_description.md도 확인.
- **방향성**:
  - `cmd_status`에서 active spec이 있을 때 산출물 체크리스트 출력: `✓ spec.md ✓ plan.md ✓ task.md ✗ walkthrough.md ✗ pr_description.md`
  - 완성도 단계 표시: Planning(spec+plan), Executing(+task), Ship-ready(+walkthrough+pr_description)
  - `cmd_archive` 진입 시 기존 검증 유지 (walkthrough/pr_description 비어있으면 거부)
- **연관 모듈**: `sources/bin/sdd` (`cmd_status`, `cmd_archive`)

### spec-10-004 — phase 완료 판단 정확도

- **요점**: `_check_phase_all_merged()`와 `compute_next_spec()`의 상태 판별 정확도를 개선하여 phase-ship 유도와 NEXT 안내가 정확하게 동작.
- **방향성**:
  - **`_check_phase_all_merged` 수정**: awk 조건에 `Done` 상태 추가 — Done은 archive 안 된 것이므로 미완료로 카운트
  - **`compute_next_spec` 개선**: Backlog만 검색하는 현재 로직에서, Done(archive 누락) spec도 "아직 처리 필요"로 인식하여 NEXT에 포함
  - **git 기반 phase 완료 판별**: phase.md 테이블과 git 이력 모두 "전체 완료"일 때만 phase-ship 유도. phase.md가 부정확해도 git 기반으로 올바르게 판단 → 자동 보정 제안
- **연관 모듈**: `sources/bin/sdd` (`_check_phase_all_merged`, `compute_next_spec`, `cmd_archive`), `sources/bin/lib/common.sh`

## 🧪 통합 테스트 시나리오

### 시나리오 1: Done 상태 spec의 archive

- **Given**: phase.md에 spec-X가 `| Done |` 상태로 기록됨
- **When**: `sdd archive` 실행
- **Then**: phase.md에서 해당 spec이 `| Merged |`로 갱신됨
- **연관 SPEC**: spec-10-001

### 시나리오 2: 브랜치 패턴 기반 work mode 추론

- **Given**: 현재 브랜치가 `spec-10-001-archive-status-fix`
- **When**: `sdd status` 실행
- **Then**: `Work Mode: SDD-P (phase-10)` 표시 + 브랜치가 이전 spec의 것임을 감지
- **연관 SPEC**: spec-10-002

### 시나리오 3: phase.md ↔ git 불일치 + 행동 제안

- **Given**: phase.md에 spec-X가 `| Done |`이지만, git log에 해당 spec PR 머지 커밋이 존재
- **When**: `sdd status` 실행
- **Then**: `⚠ spec-X: phase.md(Done) ↔ git(머지됨) → sdd archive 실행 권장` 출력
- **연관 SPEC**: spec-10-002

### 시나리오 4: state.json 모순 감지

- **Given**: state.json에 `phase=phase-10`, `spec=null`
- **When**: `sdd status` 실행
- **Then**: "Active Spec 없음 — 모든 spec 완료 시 `/hk-phase-ship` 가능" 안내 출력
- **연관 SPEC**: spec-10-002

### 시나리오 5: spec 산출물 완성도 표시

- **Given**: active spec 디렉토리에 spec.md, plan.md만 존재 (task.md 없음)
- **When**: `sdd status` 실행
- **Then**: `산출물: ✓ spec ✓ plan ✗ task ✗ walkthrough ✗ pr_description` 표시
- **연관 SPEC**: spec-10-003

### 시나리오 6: _check_phase_all_merged Done 오판 수정

- **Given**: phase.md에 spec-X가 `| Done |` (archive 안 됨), 나머지는 `| Merged |`
- **When**: `_check_phase_all_merged` 호출
- **Then**: "모든 Spec Merged" 판정하지 않음 (Done은 미완료로 카운트)
- **연관 SPEC**: spec-10-004

### 시나리오 7: compute_next_spec Done 건너뛰기 수정

- **Given**: phase.md에 spec-X가 `| Done |` (archive 누락), spec-Y가 `| Backlog |`
- **When**: `compute_next_spec` 호출
- **Then**: NEXT로 spec-X를 반환 (Done이 Backlog보다 우선)
- **연관 SPEC**: spec-10-004

### 시나리오 8: git 기반 phase 완료 감지

- **Given**: phase.md에 일부 spec이 `| Done |`이지만, git log 상 모든 spec PR이 머지됨
- **When**: `sdd archive` (마지막 spec) 또는 `sdd status` 실행
- **Then**: "모든 spec 머지 완료 — `/hk-phase-ship` 실행 가능" 유도 메시지 출력
- **연관 SPEC**: spec-10-004

### 통합 테스트 실행

```bash
bash tests/run-all.sh
```

## 🔗 의존성

- **선행 phase**: phase-9 (완료, PR #44 머지됨)
- **외부 시스템**: 없음 (bash, jq, git만 사용)
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| git log 파싱의 오탐/미탐 | spec 머지 여부 오판 | spec ID 기반 grep + PR 번호 매칭으로 정확도 확보 |
| status 경고 과다로 노이즈 | 사용자가 경고를 무시 | 실질적 불일치만 경고, `--quiet` 옵션 제공 |
| phase.md 자동 보정의 부작용 | 의도치 않은 상태 변경 | 보정은 제안만 하고 실제 수정은 사용자 확인 후 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC이 main에 merge (위 표의 상태 = Merged)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 1~6 정량 측정 완료
- [ ] 사용자 최종 승인 (`/hk-phase-ship`)

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
