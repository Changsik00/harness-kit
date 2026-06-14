# spec-21-05: Turbo 모드 통합 테스트

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-21-05` |
| **Phase** | `phase-21` |
| **Branch** | `spec-21-05-integration-test` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-06-13 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

spec-21-01~04를 통해 Turbo 모드의 모든 컴포넌트가 구현됐다:
- `sdd mode turbo/governed/status` (spec-21-01)
- 훅 분기 + `post-commit-verify.sh` (spec-21-02)
- `sdd intent` + intent.yaml (spec-21-03)
- 거버넌스 문서 + `/hk-turbo` (spec-21-04)

각 컴포넌트는 개별 단위 테스트로 검증됐으나, end-to-end 흐름 — 모드 전환 → 훅 분기 → 커밋 → 사후 검증 → revert — 을 전체적으로 검증하는 통합 테스트는 아직 없다.

### 문제점

- 컴포넌트 간 연동 버그(예: mode state 읽기 실패, intent 경로 불일치)가 단위 테스트에서 잡히지 않을 수 있다
- phase-21 Done 조건 중 `tests/test-turbo-mode.sh` + `tests/run.sh` 전체 PASS 가 명시돼 있다

### 해결 방안 (요약)

`tests/test-turbo-mode.sh` 를 작성해 phase-21.md 의 4가지 통합 시나리오를 커버한다. `tests/run.sh` 로 전체 기존 테스트도 실행하여 회귀 없음을 확인한다.

## 🎯 요구사항

### Functional Requirements

1. `tests/test-turbo-mode.sh` 작성 — 4개 통합 시나리오:
   - **S1 (happy path)**: `sdd mode turbo` 활성화 후 plan accept 없이 편집 시도 시 `check-plan-accept` exit 0 (무차단)
   - **S2 (auto-revert)**: turbo + intent.test FAIL → `post-commit-verify` 가 revert 수행
   - **S3 (governed 복귀)**: `sdd mode governed` 후 `check-plan-accept` 다시 차단 (violation 출력)
   - **S4 (회귀)**: governed 기본 상태에서 `check-plan-accept` + `check-scope` 정상 차단
2. `tests/run.sh` 전체 실행 → PASS (기존 테스트 회귀 없음)

### Non-Functional Requirements

1. bash 3.2+ 호환 — 격리된 tmpdir 사용, 실제 `.claude/state/` 변경 없음
2. 각 시나리오 독립 실행 — setup/teardown으로 이전 상태 영향 차단
3. 실행 시간 60초 이내

## 🚫 Out of Scope

- CI 파이프라인 연동
- `tests/run.sh` 내용 수정
- Windows/비-bash 환경 호환성

## 📑 ADR 후보

- [ ] 없음

## 🔗 관련 문서

- 관련 spec: `specs/spec-21-01-mode-schema/`, `specs/spec-21-02-turbo-hooks/`, `specs/spec-21-03-intent-block/`, `specs/spec-21-04-governance-update/`
- 관련 phase: `backlog/phase-21.md`

## ✅ Definition of Done

- [ ] `tests/test-turbo-mode.sh` 4개 시나리오 PASS
- [ ] `tests/run.sh` 전체 PASS (회귀 없음)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-21-05-integration-test` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
