# spec-13-05: spec 의존성 선언 (spec-dependency)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-13-05` |
| **Phase** | `phase-13` |
| **Branch** | `spec-13-05-spec-dependency` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-22 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
spec들 사이에 묵시적 의존성이 존재하지만(예: spec-13-02는 spec-13-01이 완료되어야 의미 있음), 이를 선언하거나 강제하는 방법이 없다.

### 문제점
- 선행 spec이 미완료인 상태에서 후행 spec을 시작할 수 있음
- 에이전트가 의존성을 파악하려면 phase.md 전체를 읽어야 함
- 의존성 위반을 감지하는 자동화 장치 없음

### 해결 방안 (요약)
`spec.md` 메타 테이블에 `depends_on` 행을 추가한다. `sdd plan accept` 실행 시 해당 필드를 읽어 선행 spec들의 Merged 여부를 phase.md에서 확인하고, 미완료 spec이 있으면 경고를 출력한다(exit 0 — 차단하지 않음).

## 🎯 요구사항

### Functional Requirements
1. `sources/templates/spec.md` 메타 테이블에 `depends_on` 행 추가 (기본값: `-`)
2. `sdd plan accept` 실행 시:
   - active spec.md에서 `depends_on` 값 파싱
   - `-` 또는 비어있으면 검사 생략
   - 값이 있으면 phase.md에서 해당 spec-id의 상태 확인
   - Merged가 아닌 항목 발견 시 경고 출력 + exit 0 (차단하지 않음)
3. 경고 형식: `⚠ [depends_on] <spec-id> 가 아직 Merged 가 아닙니다 (현재: <상태>)`

### Non-Functional Requirements
1. depends_on 파싱 실패 시 경고 없이 skip (구문 오류가 플로우를 막지 않음)
2. phase.md 없거나 spec-id 미발견 시 경고 없이 skip

## 🚫 Out of Scope

- depends_on 위반 시 강제 차단 (exit 2) — 첫 버전은 경고만
- cross-phase 의존성 (같은 phase 내 spec만 검사)
- `sdd spec new` 시점 의존성 검사 (plan accept 시점이 더 자연스러움)

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-spec-dependency.sh`)
- [ ] `sources/templates/spec.md`에 `depends_on` 행 추가 확인
- [ ] `sdd plan accept` 에서 depends_on 경고 동작 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-13-05-spec-dependency` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
