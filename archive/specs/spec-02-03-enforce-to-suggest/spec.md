# spec-02-03: Hook 모드 분리 및 전환 UX

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-02-03` |
| **Phase** | `phase-02` |
| **Branch** | `spec-02-03-enforce-to-suggest` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

hook 시스템은 `_lib.sh`의 `HARNESS_HOOK_MODE` 환경변수로 모드를 제어:
- `warn` (기본): 위반 시 stderr 경고만, exit 0 (통과)
- `block`: 위반 시 stderr + exit 2 (차단)
- `off`: hook 비활성

3개 hook 모두 동일한 환경변수를 공유하여 **개별 제어 불가**.

### 문제점

1. **check-branch.sh가 warn 모드**: main 보호는 안전 관련이므로 항상 `block`이어야 하지만, 현재 기본값이 `warn`. 실수로 main에 commit해도 경고만 표시.
2. **모드 전환이 불편**: 환경변수 설정이 필요하여 에이전트/사용자가 직관적으로 전환하기 어려움.
3. **Per-hook 모드 없음**: check-branch는 block, check-plan-accept는 warn으로 설정하는 것이 불가능.

### 해결 방안 (요약)

1. `_lib.sh`에 per-hook 모드 지원 추가 (`HARNESS_HOOK_MODE_{HOOK_NAME}`)
2. check-branch.sh 기본 모드를 `block`으로 변경
3. `sdd hooks` 서브커맨드로 상태 조회/전환 UX 제공

## 🎯 요구사항

### Functional Requirements
1. `_lib.sh`가 per-hook 환경변수 (`HARNESS_HOOK_MODE_BRANCH`, `HARNESS_HOOK_MODE_PLAN_ACCEPT`, `HARNESS_HOOK_MODE_TEST_PASSED`)를 우선 참조하고, 없으면 글로벌 `HARNESS_HOOK_MODE`를 사용.
2. check-branch.sh 기본 모드: `block` (main/master 보호는 항상 차단).
3. check-plan-accept.sh, check-test-passed.sh 기본 모드: `warn` (기존 유지).
4. `sdd hooks` 서브커맨드:
   - `sdd hooks` (인자 없음): 각 hook의 현재 모드 표시
   - `sdd hooks block <hook-name>`: 특정 hook을 block 모드로 전환
   - `sdd hooks warn <hook-name>`: 특정 hook을 warn 모드로 전환

### Non-Functional Requirements
1. 기존 `HARNESS_HOOK_MODE` 글로벌 설정과 하위 호환.
2. `sources/hooks/`와 `scripts/harness/hooks/` 동기화.

## 🚫 Out of Scope

- hook 로직 자체 변경 (화이트리스트, 검사 대상 등)
- 새로운 hook 추가
- settings.json의 hook 등록 구조 변경

## ✅ Definition of Done

- [ ] per-hook 모드 환경변수 지원
- [ ] check-branch.sh 기본 block 모드
- [ ] `sdd hooks` 서브커맨드 동작
- [ ] 테스트 PASS
- [ ] `sources/` ↔ `scripts/harness/` 동기화
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-02-03-enforce-to-suggest` 브랜치 push 완료
