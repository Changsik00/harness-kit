# spec-10-004: phase 완료 판단 정확도 개선

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-10-004` |
| **Phase** | `phase-10` |
| **Branch** | `spec-10-004-phase-done-accuracy` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`_check_phase_all_merged()`는 `Backlog`와 `In Progress`만 미완료로 카운트한다. `compute_next_spec()`은 `Backlog`만 검색한다. 둘 다 `Done` 상태(archive 누락)를 무시한다.

### 문제점

1. **`_check_phase_all_merged` Done 오판**: Done 상태 spec이 남아있어도 remaining=0 → "모든 Spec Merged" 판정. 실제로는 archive가 안 된 상태인데 phase-ship을 유도함.
2. **`compute_next_spec` Done 건너뛰기**: Done(archive 누락) spec을 무시하고 다음 Backlog spec을 NEXT로 안내. archive가 필요한 spec을 놓침.
3. **`$0` 패턴 매칭 문제**: 두 함수 모두 `-F'|'` + `$0 ~ /\| ... \|/` 패턴을 사용하는데, `-F'|'`로 분리하면 `$0`에서 `|`가 제거되므로 패턴이 매칭되지 않을 수 있음. `$5` 필드 직접 비교로 전환 필요.

### 해결 방안 (요약)

`_check_phase_all_merged`에 `Done` 상태 추가 + `$5` 필드 비교로 전환. `compute_next_spec`도 Done spec을 NEXT에 포함하도록 개선.

## 🎯 요구사항

### Functional Requirements

1. **`_check_phase_all_merged` 수정**: Done 상태를 미완료로 카운트. `$0` 패턴 대신 `$5` 필드 직접 비교.
2. **`compute_next_spec` 개선**: Done 상태 spec도 "처리 필요"로 인식. Done이 Backlog보다 우선(archive 먼저 해야 하므로).
3. **git 기반 phase 완료 판별**: `_check_phase_all_merged`에서 phase.md 테이블뿐 아니라 git log도 참조. 테이블이 부정확해도 git 기반으로 올바르게 판단.

### Non-Functional Requirements

1. 기존 archive 흐름에 영향 없음 — `_check_phase_all_merged`는 archive 후 호출되는 읽기 전용 함수.
2. `compute_next_spec`의 기존 호출자(`cmd_status`)에 영향 없음 — 반환 형식 동일.

## 🚫 Out of Scope

- phase.md 자동 보정 (제안만, 실제 수정 안 함 — spec-10-002에서 이미 진단으로 커버)
- `--quiet` 플래그

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-10-004-phase-done-accuracy` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
