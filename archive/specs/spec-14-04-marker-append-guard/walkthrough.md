# Walkthrough: spec-14-04

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 멱등 가드의 구현 위치 | A: `sdd_marker_append` 함수 본문 / B: 4 호출자 각각에서 grep 후 호출 | **A** | 함수 레벨 가드는 호출자 4 곳을 모두 보호 + 향후 새 호출자도 자동 보호. B 는 코드 중복 |
| `sdd_marker_append` awk 패턴 | A: awk 한 패스로 in-marker 추적 + skip / B: grep 으로 사전 체크 후 awk | **A** | 한 번의 awk pass — 파일 두 번 읽지 않음. 다른 마커 헬퍼와 일관 |
| 본 spec 의 scope 확장 (`spec_new` grep 버그 추가) | A: 본 spec 에 통합 / B: spec-14-05 신설 | **A** | 같은 종류 (마커 정합성). 사용자에게 plan 단계에서 명시적으로 제시 → Plan Accept (1) 으로 동의 |
| `spec_new` 의 grep 교체 vs `sdd_marker_update_row` 의 fallback | A: grep 영역 한정 (`sdd_marker_grep`) / B: update_row 가 매치 못하면 append fallback | **A** | A 가 의미상 더 명확 — "있으면 갱신, 없으면 추가" 의도가 코드에 직접 드러남. B 는 update_row 의 시맨틱이 모호해짐 |

## 💬 사용자 협의

- **주제 1**: scope 확장 동의 (sdd_marker_append 가드 + spec_new grep 버그 통합)
  - **사용자 의견**: Plan Accept (1) 으로 명시적 동의
  - **합의**: ≈15 LOC 추가, 같은 phase 의 마커 정합성 주제 내에서 통합 처리.

- **주제 2**: phase-14 의 `phase-14.md` sync 잔재
  - **사용자 의견**: spec-14-02, 03, 04 시작 시 매번 phase-14.md 마커 수동 보정. 본 spec 머지 후 자동 동기화 자가 회복 (도그푸딩의 정수).
  - **합의**: 본 PR 의 첫 commit 메시지에 "마지막 수동 보정" 명시.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 + 통합 테스트 (본 spec 신규)
- **명령**: `bash tests/test-marker-append-guard.sh`
- **결과**: ✅ Passed (5/5)
- **로그 요약**:
```text
▶ A: sdd_marker_append 단위 테스트
  ✅ A-1: 같은 라인 두 번 호출 → 1줄
  ✅ A-2: 다른 라인 추가 — 둘 다 보존 (정상 동작 회귀)
▶ B: sdd specx done 두 번 → done 섹션 1줄
▶ C: sdd phase done 두 번 → done 섹션 1줄
▶ D: 본문 매치 회피 — 마커 안 spec-01-01 행 정확히 1줄
ALL 5 CHECKS PASSED
```

#### 회귀 테스트
- `test-sdd-queue-redesign.sh` ✅ 5/5
- `test-sdd-phase-done-accuracy.sh` ✅ 4/4
- `test-sdd-spec-completeness.sh` ✅ 4/4
- `test-sdd-status-cross-check.sh` ✅ 7/7
- `test-sdd-queued-marker-removed.sh` ✅ 7/7 (spec-14-01)
- `test-doctor-bash-version.sh` ✅ 3/3 (spec-14-02)
- `test-gitignore-idempotent.sh` ✅ 22/22 (spec-14-03)

### 2. 수동 검증

1. **Action**: 본 spec 작성 시 `sdd spec new marker-append-guard` 호출 결과 확인
   - **Result**: phase-14.md 의 sdd:specs 마커에 spec-14-04 행 *부재* (예상된 회귀 케이스 직접 재현)
2. **Action**: 본 PR 머지 후 다음 phase 의 첫 spec 시작 시 phase.md 자동 sync 여부
   - **Result**: 다음 phase 진행 시 자가 검증 (본 PR 의 효과)

## 🔍 발견 사항

- **본 spec 의 가치는 phase 진행 자체에서 즉시 입증됨**: spec-14-02, 03, 04 시작 시 매번 phase-14.md 수동 보정 필요했던 것이 본 PR 의 회귀 케이스 그 자체. 도그푸딩이 "회귀를 자동 발견하는 메커니즘" 으로 작동한 명백한 사례.
- **awk 패턴의 일관성**: 4 헬퍼 (`sdd_marker_append`, `sdd_marker_replace`, `sdd_marker_update_row`, `sdd_marker_grep`) 가 모두 같은 컨벤션 (`in_section` 플래그 + start/end 비교) 으로 통일. 향후 다른 마커 연산 추가 시 기준점.
- **count_line 함수의 정규식 escape 함정 (test-marker-append-guard.sh)**: `[`, `]`, `(`, `)` 등 ERE 메타 escape 가 누락된 sed 패턴은 `grep -cE` 와 결합 시 매치 실패 또는 문법 오류. awk `$0 == target` 의 정확 매치가 더 견고. spec-14-03 의 count_line 도 같은 방향으로 수정 가능 (별건 cleanup 후보).
- **Plan Accept 후 scope 확장 패턴**: 본 spec 은 plan 작성 단계에서 발견된 추가 버그를 기존 plan 에 통합. constitution §5.5 (Idea Capture Gate) 와 §7.2 (Delegation Limits) 의 회색지대 — 같은 종류 + 작은 LOC + plan 단계라 통합이 합리적이었음. 만약 strict loop 진입 후 발견됐다면 Idea Capture 로 처리.

## 🚧 이월 항목

- 없음. 본 spec 으로 phase-14 의 4 spec 모두 완료.
- **다음 단계**: `/hk-phase-ship` — go/no-go 결정 + Phase 통합 시나리오 4 건 검증 + Phase PR 생성.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-25 |
| **최종 commit** | `ce68981` (fix: make marker_append idempotent + scope spec_new grep) |
