# spec-21-06: SDD 산출물 경량화 — spec+plan 통합 및 템플릿 트림

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-21-06` |
| **Phase** | `phase-21` |
| **Branch** | `spec-21-06-template-merge` |
| **상태** | Planning |
| **타입** | Refactor |
| **작성일** | 2026-06-13 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`sdd spec new` 는 spec.md + plan.md + task.md 3개 파일을 생성한다. spec.md 는 "무엇/왜", plan.md 는 "어떻게"를 담는다는 분리 의도가 있으나, 실제로는 **같은 세션에서 에이전트가 연속으로 작성**하고 Plan Accept 게이트도 두 파일 모두 작성한 후에야 열린다. 분리가 만드는 안전장치가 없는 반면 비용은 실재한다.

### 문제점

- **중복 섹션**: ADR 후보·Mermaid 다이어그램이 spec.md와 plan.md 양쪽에 등장
- **메타 ceremony**: task.md Pre-flight 섹션이 spec/plan/task 작성 자체를 task로 추적
- **빈 placeholder**: walkthrough.md의 관련 문서·메타 테이블·ADR 승격 가이드 prose는 거의 항상 비어있음
- **파일 수**: spec 하나당 3개 파일 → 산출물 부담

### 해결 방안

spec.md + plan.md를 **단일 spec.md**로 통합. task.md · walkthrough.md의 실질 가치 없는 섹션 제거. `sdd spec new`가 spec.md + task.md 2개만 생성하도록 변경. 거버넌스 문서·테스트도 일관 업데이트.

## 요구사항

1. `sdd spec new` 실행 결과: spec.md + task.md 2파일 (plan.md 미생성)
2. 통합 spec.md에 "사용자 검토 필요" 섹션 포함 — Plan Accept 게이트 역할 유지
3. task.md Pre-flight 섹션 제거, 진행 요약 테이블 제거
4. walkthrough.md 관련 문서·메타 테이블·ADR 승격 가이드 prose 제거
5. sdd status 출력에서 plan.md 유무 체크 제거
6. 기존 테스트 전체 PASS (plan.md 참조 테스트 업데이트 포함)

## Out of Scope

- phase.md, adr.md, rca.md 등 다른 템플릿 변경
- 기존 spec 디렉토리의 plan.md 소급 삭제 (과거 산출물 보존)
- Turbo / Governed 모드 동작 변경 (문서 구조만)

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 기존 spec 디렉토리(spec-21-01~05 등)의 plan.md는 그대로 유지 — 소급 삭제 안 함
> - [ ] `planAccepted` 상태값은 sdd binary에 그대로 유지 (plan 파일 존재와 분리)

> [!WARNING]
> - [ ] `test-sdd-status-cross-check.sh` Check 4 제거 → planAccepted+plan.md 누락 경고 동작 삭제
> - [ ] `test-sdd-spec-completeness.sh` Planning 단계 판정 변경 (spec+plan → spec만)

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|---|---|---|
| spec.md | spec 상단 + plan 핵심 섹션 병합 | "사용자 검토 필요"가 Plan Accept 역할 유지 |
| plan.md 템플릿 | 삭제 | 과거 파일은 건드리지 않음 |
| sdd status | has_plan 체크 제거 | 파일 없는데 ✗ 표시는 혼란만 가중 |
| Planning 단계 판정 | spec.md 존재 = Planning | task.md 없으면 Planning으로 충분 |

## Proposed Changes

#### [MODIFY] `sources/templates/spec.md` + `.harness-kit/agent/templates/spec.md`
spec 기존 섹션 유지 + plan.md의 "사용자 검토 필요", "핵심 전략", "Proposed Changes", "검증 계획" 섹션 추가. Mermaid·ADR 후보·관련 문서 중복 제거.

#### [DELETE] `sources/templates/plan.md` + `.harness-kit/agent/templates/plan.md`

#### [MODIFY] `sources/templates/task.md` + `.harness-kit/agent/templates/task.md`
Pre-flight 섹션 제거. 진행 요약 테이블 제거.

#### [MODIFY] `sources/templates/walkthrough.md` + `.harness-kit/agent/templates/walkthrough.md`
ADR 승격 가이드 prose → 1줄 참조. 관련 문서 섹션 제거. 메타 테이블 제거.

#### [MODIFY] `sources/bin/sdd` + `.harness-kit/bin/sdd`
- `spec_new()`: `for f in spec plan task` → `for f in spec task`; 안내 메시지 업데이트
- `sdd_status()` 내 `planAccepted=true + plan.md 없음` 경고 제거
- `spec_show()` 내 has_plan 체크·표시 제거

#### [MODIFY] `sources/governance/agent.md` + `.harness-kit/agent/agent.md`
spec.md + plan.md 언급 → spec.md 단일 언급으로 교체.

#### [MODIFY] `sources/governance/constitution.md` + `.harness-kit/agent/constitution.md`
동일.

#### [MODIFY] `tests/test-install-layout.sh`
템플릿 목록에서 `plan.md` 제거.

#### [MODIFY] `tests/test-sdd-status-cross-check.sh`
Check 4 (plan.md 누락 경고) 제거.

#### [MODIFY] `tests/test-sdd-spec-completeness.sh`
Planning 단계 = spec.md 존재. plan.md fixture 생성 코드 제거.

#### [MODIFY] `tests/test-turbo-hooks.sh` + `tests/test-turbo-mode.sh`
plan.md fixture → spec.md fixture로 대체.

## 검증 계획

```bash
bash tests/run.sh
```

핵심 확인:
- `test-install-layout.sh`: plan.md 없음, spec.md 존재
- `test-sdd-spec-completeness.sh`: spec.md만으로 Planning 판정
- `test-sdd-status-cross-check.sh`: Check 4 제거 후 나머지 PASS
- 전체: 기존 6 pre-existing FAIL 외 신규 FAIL 없음

## ✅ Definition of Done

- [ ] `sdd spec new` 실행 시 spec.md + task.md 2파일만 생성
- [ ] `tests/run.sh` 전체 PASS (신규 FAIL 없음)
- [ ] `.harness-kit/` 미러 동기화 확인
- [ ] walkthrough.md + pr_description.md 작성 및 ship commit
