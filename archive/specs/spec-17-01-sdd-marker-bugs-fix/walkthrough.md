# Walkthrough: spec-17-01

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 3 버그 처리 단위 | 한 spec 묶음 / 3 spec 분리 | **한 spec 묶음** | 동일 marker 처리 패턴, helper 공유. 분리 시 review 3 회 |
| spec_new match 확장 방식 | helper 함수 일반화 / 호출 측 분기 추가 | **호출 측 분기** | scope 제한 — helper 변경 시 다른 caller 회귀 위험 |
| ship 에서 Backlog 행 처리 | update (둘 다 Merged) / delete | **delete** | 한 spec = 한 행 invariant. update 시 또 다른 중복 |
| phase done normalize 위치 | caller (phase_done) / callee (queue_mark_done) | **callee (queue_mark_done)** | state_get phase 호출도 normalize 거치게 함. 다른 caller 추가 시 자동 적용 |
| 단위 테스트 fixture 위치 | `tests/fixtures/spec-17-01/` 디렉토리 / 스크립트 내부 inline | **스크립트 내부 inline (heredoc)** | 작은 fixture, 한 파일 + trap cleanup 으로 자기-격리 충분 |
| 본 spec self-cleanup 검증 | 자동 (Test 4 추가) / 수동 (이미 dedupe 됨) | **수동** | 본 spec 의 fix 는 *신규 동작* 에만 적용. 본 spec 의 Pre-flight 시점 dedupe 는 fix 적용 *전* — 자기-회복 시연 어려움. Task 7 에서 fixture 로 대체 검증. |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 결정은 모두 *수정 대상 함수의 전술적 선택*. long-lived invariant 는 이미 RCA-001 에 박힘 ("ship/spec new/phase done marker 멱등성"). 본 spec 은 *RCA-001 prevention 의 실현* 이지 새 invariant 도입 아님.

## 💬 사용자 협의

- **주제**: spec-17-01 scope (3 함수 묶음 vs 분리 vs 확장)
  - **사용자 의견**: 3 함수 동시 fix (추천 수용)
  - **합의**: cmd_spec_new + cmd_ship + queue_mark_done. marker helper 자체 리팩토링은 Out of Scope.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-marker-idempotent.sh`
- **결과**: ✅ Passed (3/3)
- **로그 요약**:
```text
Test: sdd marker idempotency
  ✓ Test 1 — spec new: in-place update of Backlog row (no append)
  ✓ Test 2 — spec new: row status = Active
  ✓ Test 3 — phase done: normalize 'phase done 99' → '**phase-99** — title'

All tests passed.
```

#### 회귀 테스트
- **명령**: `bash tests/test-drift-stale-adr.sh`
- **결과**: ✅ Passed (3/3) — spec-16-03 의 stale 탐지 영향 없음

#### sdd status 정상 동작
- Active Phase: phase-17 / Active Spec: spec-17-01-sdd-marker-bugs-fix / Branch: spec-17-01-sdd-marker-bugs-fix ✓

### 2. 수동 검증

1. **본 spec self-cleanup 시연** — fixture phase-99 + spec-99-01 (Backlog) 로 시작 → `sdd spec new marker-test` 호출 → 행 수 1 (Active 형식) ✓
2. **phase done normalize 검증** — `sdd phase done 99` (prefix 없이) → queue.md done 섹션에 `- **phase-99** — Marker Test Fixture — completed 2026-05-17` 출력 ✓
3. **phase-17.md spec 표** — 본 spec 의 작업 결과로 spec-17-01 행이 1 행만 (Active), spec-17-02/03 는 plain Backlog 형식 유지 ✓
4. **install 미러 동기화** — `diff sources/bin/sdd .harness-kit/bin/sdd` 차이 없음, chmod +x 보존 ✓

## 🔍 발견 사항

- **본 spec 의 Pre-flight 자체가 marker append 버그의 *마지막 자체 재현*** — phase-17.md 의 spec-17-01 행이 spec 생성 시점 (commit 12a48ea 이전) 에 중복 발생. 수동 dedupe 후 fix 적용 → 향후 spec-17-02/03 의 sdd spec new 부터는 자동 처리. *fix 이후의 첫 spec ship* 이 invariant 검증 시점.
- **`sdd ship` 의 Backlog 행 삭제 분기는 *runtime 시나리오* — 단위 테스트는 spec_new 의 in-place update 가 이미 Backlog 행을 *update* 해서 사라지게 만들기 때문에 ship 의 삭제 분기를 별도로 trigger 하기 어려움.** 본 분기는 *기존 phase 파일 (phase-08~16) 같이 backfill 안 된 환경* 에서 cleanup 역할. phase-17 이후 모든 spec 은 spec_new 단계에서 이미 정리됨. *defensive coding* 으로 박아두는 의미.
- **`queue_mark_done` 의 normalize 가 다른 caller 에도 영향** — caller 가 `state_get phase` (이미 `phase-N` 형식) 결과를 직접 전달하는 경우엔 no-op (이미 phase- prefix). caller 가 user input (CLI arg) 을 전달하는 경우엔 normalize 동작. 양쪽 모두 안전.
- **fixture phase-99 가 충분히 격리되지 않으면 queue.md 의 done 섹션이 점점 쌓일 위험** — trap cleanup 으로 fixture 의 done entry 도 제거. 첫 실행 시 이전 실행의 leftover (`** **99** — ? — completed`) 가 queue.md 에 있어 Test 3 가 거짓 fail — 수동 정리 후 정상.

## 🚧 이월 항목

- `sdd phase activate --base` 가 base branch 자동 생성 안 함 — phase-17 활성화 시 수동 `git checkout -b` 필요했던 이슈 (Icebox 또는 spec-17-03 검토)
- `tests/test-sdd-marker-idempotent.sh` 가 phase-17.md 시나리오 1 (Marker 멱등성) 의 *단위 일부* — phase-level 통합 시나리오는 spec-17-03 에서 자동화
- `sdd_marker_grep` / `_append` / `_update_row` helper 함수 자체 일반화 (현재 호출 측 분기로 우회) — Icebox 후보

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-17 (단일 세션) |
| **최종 commit** | `4d6bc2d` (Fix #3 — queue_mark_done normalize) |
| **총 commit 수** | 5 (planning + test + 3 fix) — 검증 task 는 commit 없음 |
