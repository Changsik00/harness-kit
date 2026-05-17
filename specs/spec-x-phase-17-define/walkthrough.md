# Walkthrough: spec-x-phase-17-define

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Phase 정의 방식 | spec-x 정식 정의 / 직접 sdd phase new | **spec-x-phase-17-define** | 과거 phase-{14,15,16}-define 동일 패턴. phase 정의 자체가 review 가능 |
| Phase scope (spec 수) | 2 / 3 / 4 | **3 spec** | sdd marker 3종 묶음 (P0) + cache 분리 (P1) + integration test+doctor (P1). W1/W3/W4/W7 잡탕 spec-04 는 분리 가치 낮음 — Icebox 잔류 |
| Base branch 시점 | 처음부터 / mid-phase / 미사용 | **처음부터** | phase-16 mid-phase 전환 cost (rebuild + force-push + 회고 fix) 학습 |
| W1/W3/W4/W7/W9 + 접근성 개선 처리 | phase-17 포함 / Icebox 잔류 | **Icebox 잔류** | 소형 문구 수정 / metric 누적 대기 / 외부 노출 — *코드 정합성* 테마와 다름 |
| 통합 시나리오 fixture 격리 | 공통 prefix / 임시 디렉토리 | **prefix + trap cleanup** | flakiness 회피, spec-17 prefix 사용 |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 결정은 모두 *phase 정의 전술* (scope / base branch 시점 / 묶음 단위). long-lived invariant 아님. phase-17 진행 중 결정들에서 ADR 후보 식별 가능성 더 큼.

## 💬 사용자 협의

- **주제**: phase-17 정의 방식 (spec-x vs 직접 `sdd phase new`)
  - **사용자 의견**: spec-x-phase-17-define 로 정식 정의 (추천 수용)
  - **합의**: spec-x 1 PR → 머지 후 별도 `sdd phase activate phase-17 --base`
- **주제**: phase-17 scope (3 spec 추천)
  - **사용자 의견**: alignment 의 3 spec 그대로 진행 ("승인")
  - **합의**: spec-17-01 (P0) + spec-17-02 (P1) + spec-17-03 (P1). 4번째 spec 부재 — W1/W3/W4/W7 Icebox 잔류
- **주제**: phase-16/17 우선순위 (정합성 fix 먼저 vs 접근성 개선 먼저)
  - **사용자 의견**: 정합성 fix (B) 우선
  - **합의**: phase-17 = 정합성, phase-18 = 접근성 후보. *내부 일관성* → *외부 노출* 순서

## 🧪 검증 결과

### 1. 자동화 테스트 (단위 검증)
- **명령**: plan.md §검증 계획 5 항목
- **결과**: ✅ Passed (5/5)
- **로그 요약**:
```text
=== 1. 파일 존재 ===          ✓ phase-17.md exists
=== 2. Phase ID ===            ✓ phase-17
=== 3. Base Branch ===         ✓ phase-17-coherence-fix
=== 4. SPECs 3 행 ===          ✓ 3
=== 5. 회고 ref ===            ✓ 4 hits (W5, W10, C3, W2, W6 모두 포함)
```

### 2. 수동 검증
1. phase-17.md 본문 가독성 — phase-16.md 동일 구조 ✓
2. SPECs 표가 `sdd:specs:start ~ end` marker 안에 (자동 갱신 가능) ✓
3. 결정 기록 표 4 결정 모두 명시 ✓

## 🔍 발견 사항

- **phase 템플릿이 결정 기록 / 통합 테스트 시나리오 표를 강제** — phase-17 처럼 명확한 4 결정이 있는 경우 잘 동작하나, *상황이 모호한 phase* 에선 빈 placeholder 가 될 위험. 향후 phase 정의 시 *결정 기록 표 미작성 = phase 정의 불충분* 신호로 활용 가능.
- **회고 ref (W5/W10 등) 가 phase-17 SPECs 에 명시되어 phase-16 회고 항목의 *closed/open 상태 추적* 가능** — 다음 phase 회고 시 *어떤 warning 이 처리됐고 어떤 것이 잔류* 인지 한눈에 보임.
- **`sdd specx new` 가 walkthrough.md 도 자동 생성** — 다른 spec 종류 (sdd spec new) 와 다른 동작인지 미확인. spec-16-04 까지는 walkthrough 가 Ship task 에서 작성됐는데 spec-x 는 처음부터 비어있는 walkthrough 존재. 일관성 점검 후보 (Icebox 추가 검토).

## 🚧 이월 항목

- phase-17 활성화: 본 spec 머지 후 `sdd phase activate phase-17 --base` — 사용자 호출 필요
- W1/W3/W4/W7/W9 + 접근성 개선 Phase: Icebox 잔류 (phase-17 종료 후 재논의)
- `sdd specx new` 의 walkthrough.md auto-create 일관성 점검 — Icebox 후보

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-16 |
| **최종 commit** | `823c3f3` (Task 2 — phase-17.md 작성) |
| **총 commit 수** | 2 (planning + phase-17.md) — Task 3 검증만 |
