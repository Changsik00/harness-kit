# spec-10-01: archive 상태 전이 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-10-01` |
| **Phase** | `phase-10` |
| **Branch** | `spec-10-01-archive-status-fix` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd archive`는 spec 작업 완료 후 phase.md의 해당 spec 상태를 `| Merged |`로 갱신하는 역할을 한다. 이 갱신은 `cmd_archive()` 함수 내 awk 스크립트로 처리된다.

### 문제점

awk 패턴이 `| In Progress |`와 `| Active |`만 매칭한다:

```awk
index($0, sid) && (/\| In Progress \|/ || /\| Active \|/) {
  sub(/\| In Progress \|/, "| Merged |")
  sub(/\| Active \|/, "| Merged |")
}
```

`| Done |` 상태의 spec은 매칭되지 않아 `| Merged |`로 전환되지 않는다. Phase-9에서 13개 spec 중 10개가 "Done"으로 잔류한 실제 사례가 발생했다.

### 해결 방안 (요약)

awk 조건에 `| Done |` 매칭을 추가하고, 상태 전이 모델을 코드 주석으로 명시하여 향후 동일 문제를 방지한다.

## 🎯 요구사항

### Functional Requirements
1. `sdd archive` 실행 시 phase.md의 `| Done |` 상태 spec이 `| Merged |`로 정상 전환된다.
2. `| Active |`, `| In Progress |` 매칭은 기존대로 유지된다.
3. `sources/bin/sdd`와 `.harness-kit/bin/sdd` 양쪽 모두 수정한다.

### Non-Functional Requirements
1. 기존 테스트 전체 PASS (회귀 없음).
2. 상태 전이 모델이 코드 주석으로 문서화되어 있다.

## 🚫 Out of Scope

- `sdd status`의 교차 검증 로직 추가 (spec-10-02)
- phase 완료 감지 로직 개선 (spec-10-04)
- 상태 전이를 코드로 강제하는 state machine 구현

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-10-01-archive-status-fix` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
