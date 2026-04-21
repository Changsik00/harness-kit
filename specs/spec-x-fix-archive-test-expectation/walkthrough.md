# Walkthrough: spec-x-fix-archive-test-expectation

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 로컬 main 에 2 개 커밋이 직접 쌓여 있음 | (A) push 강행 (B) FF 추가 수정 (C) spec-x 로 정상화 | **C** | (A) 는 §10.1 위반 + Check 4 회귀까지 덮게 됨. (B) 는 main 직접 커밋 패턴을 고착. (C) 는 정식 PR 리뷰 경로로 복귀 + 감사 중 발견한 다른 이슈도 같은 PR 에 수용 가능 |
| 작업 범위를 Check 4 복원만으로 한정할지 | (A) 좁게 (B) 감사 후 확대 | **B** | f601417 의 한 주장(Check 4)이 거짓으로 밝혀진 이상, 나머지 주장도 미검증 상태. 동 커밋의 다른 두 주장도 검증해야 일관성이 맞음. 감사 결과 P2, P3 가 실제 문제로 확인됨 |
| 테스트 fixture 의 3-digit spec-id 정규화 포함 여부 | (A) 포함 (B) 별도 spec-x | **B** | 7 개 테스트 fixture 를 고쳐야 하고 각각 동작 영향 검증 필요. 범위 폭주 우려로 본 PR 에서 제외 (사용자 지시: "과거 이력 냅둬도 됨") |
| `backlog/phase-12.md` 내부 3-digit 헤더 참조 교정 | (A) 포함 (B) 보존 | **B** | 사용자가 "이전 기록으로 냅둬라" 지시. 참조 깨짐은 있지만 역사 기록 성격 존중 |
| P3 테스트 위치 | 새 파일 vs 기존 `test-sdd-ship-completion.sh` Check 확장 | **기존 파일 확장** | Check 6 (sdd specx done 기본) 과 같은 맥락이라 옆에 두면 리뷰어가 한눈에 비교 가능 |

## 💬 사용자 협의

- **주제**: main 에 직접 쌓인 2 개 커밋을 어떻게 정리할 것인가
  - **제안 흐름**: 에이전트가 "spec-x + 체리픽" 접근을 처음 권장 → 사용자가 "체리픽 vs. 브랜치 생성 후 main 리셋" 을 비교 제안 → 후자(A 방식) 채택
  - **합의**: 현재 main HEAD 그대로 새 브랜치로 가져가고, 로컬 main 포인터를 `origin/main` 으로 되돌림 (destructive, 하지만 브랜치 보존이므로 복구 가능)
- **주제**: f601417 의 나머지 주장도 검증해야 하는가
  - **사용자 의견**: "이전 커밋이 의도대로 모든 게 구현되었는지 혹은 문제점이 다 해결된 건지는 확인 안 된 거 아냐?"
  - **합의**: 감사 단계 추가. 결과에 따라 범위를 넓힘
- **주제**: 감사 후 어떤 항목을 포함할 것인가
  - **사용자 의견**: "과거 이력 냅둬도 됨, 룰 위반/누락 위주로 .md 에서 찾아라"
  - **합의**: A1 (phase-12.md 헤더) 패스, B (활성 .md 소문자 통일) 포함, C (Check 4) 필수, D (회귀 테스트) 중요하면 포함 — 최종 C1+B+D 로 확정

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `for t in tests/test-*.sh; do bash "$t" 2>&1 | tail -3; done`
- **결과**: ✅ Passed — 19/19 테스트 파일 모두 FAIL=0
- **핵심 회귀 확인**:
```text
=== tests/test-sdd-dir-archive.sh ===
  결과: PASS=10  FAIL=0    ← Check 4 기대값 복원 후 전부 통과

=== tests/test-sdd-ship-completion.sh ===
  결과: PASS=9  FAIL=0    ← Check 6b/6c 추가로 9 개 PASS
```

#### 통합 테스트
해당 없음 (Integration Test Required = no).

### 2. 수동 검증

1. **Action**: `git log origin/main..HEAD --oneline`
   - **Result**: 6 commits (`120d0f2`, `f601417`, scaffold `8702523`, fix `49175b8`, docs `cbb636e`, test `2e03ee0`)
2. **Action**: `git log main..origin/main --oneline`
   - **Result**: 출력 없음 (로컬 main 이 origin/main 과 동기)
3. **Action**: `git branch --show-current`
   - **Result**: `spec-x-fix-archive-test-expectation`

## 🔍 발견 사항

- **거짓 커밋 근거가 쉽게 발생한다**. `f601417` 의 커밋 메시지는 "PR #64 반영" 이라고 적었으나 실제로는 PR #65 에서 되돌려진 상태를 놓쳤다. PR 이 merge 된 직후 작업할 때 *중간에 취소된 변경* 을 놓치기 쉽다 — 가드가 없다.
- **회귀 테스트 공백이 있었다**. `f601417` 이 `sdd specx done` 에 두 가지 동작(prefix 정규화, state 리셋)을 추가하면서 기존 Check 6 외 추가 테스트가 없었다. 본 PR 의 P3 가 그 공백을 메움.
- **.md 표기 불일치 vs constitution 선언이 드리프트한다**. constitution 이 `spec-{phaseN}-{seq}` 를 선언해도 사용자 상태 리포트를 출력하는 `align.md` / `hk-plan-accept.md` 는 대문자 `SPEC-{N}-{NN}` 를 썼다. 이런 드리프트는 "사용자가 ID 를 어떻게 써야 하는지" 혼동으로 이어진다.

## 🚧 이월 항목

- **테스트 fixture 의 3-digit spec-id → 2-digit 정규화**: 7 개 테스트 파일. 기능 영향 없음, 일관성 개선 목적. 별도 spec-x 후보.
- **`backlog/phase-12.md` 내부 헤더/참조 정리**: 사용자 보존 지시에 따라 유지. 나중에 phase-12 완료 시점에 archive 되면서 자연히 역사 기록으로 고착됨.
- **main 직접 커밋 재발 방지**: `check-branch.sh` 훅이 작동 중이나 이번 경우는 어떻게 뚫렸는지 원인 조사 필요.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-21 |
| **최종 commit** | `2e03ee0` (ship 커밋 전) |
