# spec-x-phase-17-define: phase-17 (정합성 fix) 정의

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-phase-17-define` |
| **Phase** | (spec-x — Phase 비소속) |
| **Branch** | `spec-x-phase-17-define` |
| **상태** | Planning |
| **타입** | Docs |
| **Integration Test Required** | no |
| **작성일** | 2026-05-16 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

phase-16 (Reliability Layer 강화) 완료 후 *self-credibility 손상* 이 회고에서 명시됨:
- RCA-001 의 invariant ("sdd ship 산출물 누락 금지") 가 *phase 내내 4 회 위반*
- `sdd ship` / `sdd spec new` / `sdd phase done` 3 종의 marker 관련 버그 (append 대신 update, 제목 추출 누락)
- `.harness-kit/installed.json` 의 캐시 필드가 tracked 파일에 있어 *매 SessionStart 마다 워킹트리 dirty* — phase-ship cleanliness 가정 위배

또한 phase-16 회고에서 식별된 *얇은 보강 가능* warnings (W2, W6 등) — phase-level integration test 자동화 부재, doctor.sh 신규 경로 점검 누락.

### 문제점

- *reliability layer phase* 가 자기 invariant 를 못 지키는 아이러니 → 외부 사용자에게 키트의 자기-신뢰성 손상.
- 매 phase 마다 동일한 productivity tax (marker dedupe 수동, installed.json checkout 수동) 가 반복.
- phase-ship 시 시나리오 검증을 매번 수동 grep 으로 — 자동화 진입점 부재.

### 해결 방안 (요약)

phase-17 (= "정합성 fix" / "coherence fix") 을 정식 phase 로 정의. 3 spec 으로 분해:
1. sdd CLI marker 버그 3 종 fix (RCA-001 직접 prevention)
2. installed.json 캐시 분리 (구조 fix)
3. phase-level integration test 자동화 + doctor.sh 확장

base branch 모드로 *처음부터* 설계 (phase-16 의 mid-phase 전환 경험 적용).

본 spec-x 의 산출물: `backlog/phase-17.md` 단일 파일.

## 🎯 요구사항

### Functional Requirements

1. **`backlog/phase-17.md` 작성** — phase 템플릿 (`.harness-kit/agent/templates/phase.md`) 준수.
2. **Phase ID**: `phase-17`. Base Branch: `phase-17-coherence-fix` (메타 테이블 명시).
3. **목표 / 성공 기준 / 통합 테스트 시나리오 / SPECs 표 / 결정 기록 / 위험 요소 / Phase Done 조건** 모두 채움.
4. **SPECs 표** — 3 spec (spec-17-01 ~ 03) 등록, 모두 Backlog 상태:
   - spec-17-01 sdd-marker-bugs-fix (P0)
   - spec-17-02 installed-cache-separation (P1)
   - spec-17-03 phase-integration-test-and-doctor (P1)
5. **결정 기록 표** — 본 phase 의 핵심 결정 4 개 박음:
   - Base branch 처음부터 사용 (phase-16 경험)
   - sdd marker 버그 3 종 한 spec 묶음 (개별 분리 아님)
   - phase-16 회고 W1/W3/W4/W7/W9 는 Out of Scope (Icebox 잔류)
   - 접근성 개선 Phase (phase-18 후보) 와 분리

### Non-Functional Requirements

1. **한국어 작성** — 거버넌스 4 파일 외 모든 산출물은 한국어 (메모리 룰).
2. **phase 템플릿 준수** — 빈 섹션 없음, placeholder 없음.
3. **회고 추적성** — 각 spec / 결정에 phase-16 회고 항목 ref (W5/W10 등) 명시.

## 🚫 Out of Scope

- **phase-17.md 활성화** — 본 spec-x 머지 후 별도 `sdd phase activate phase-17 --base` 호출. 본 spec 은 *문서 작성* 만.
- **spec-17-01/02/03 의 spec/plan/task 작성** — 각각 phase-17 활성화 후 별 spec 으로 진행.
- **Icebox 의 잔여 항목 (W1/W3/W4/W7/W9/접근성 개선)** — phase-17 SPECs 표에 포함 안 함. 명시적으로 다음 phase 또는 spec-x 후보로 보존.
- **기존 phase-16 산출물 수정** — phase-16 은 이미 main 머지 완료. 본 spec 은 phase-17 신규 정의만.

## ✅ Definition of Done

- [ ] `backlog/phase-17.md` 생성 — phase 템플릿 7 섹션 모두 채움
- [ ] SPECs 표에 3 spec 모두 Backlog 상태로 등록
- [ ] 결정 기록 표에 4 결정 박음
- [ ] 통합 테스트 시나리오 3 개 (정량 검증 가능 형식) 명시
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] `spec-x-phase-17-define` 브랜치 push 완료
- [ ] PR 생성 (target: `main`, spec-x 는 항상 main 직 PR)
- [ ] 사용자 검토 요청 알림 — 머지 후 `sdd phase activate phase-17 --base` 절차 안내
