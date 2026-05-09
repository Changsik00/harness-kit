# Walkthrough: spec-x-hook-allow-ff-when-no-spec

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| FF 마커 도입 vs state.spec 활용 | 별도 마커 / state.spec 활용 | state.spec | constitution §2.3 의 FF 정의 ("state 변경 안 함") 와 일치. 추가 도입 없이 기존 state 의미로 해결 |
| spec 필드 누락 (legacy state) 처리 | 차단 / 통과 | 통과 | 새 state 스키마 미보유 환경 호환. 누락 = 활성 SPEC 없음 으로 해석이 자연스러움 |
| pre-commit + check-plan-accept 동시 수정 | 하나만 / 둘 다 | 둘 다 | 두 hook 정책이 동일 (whitelist + planAccepted) → 일관되게 둘 다 spec 검사 추가 |

## 💬 사용자 협의

- **주제**: 이전 PR (install.sh self-host header fix) commit 시 hook 차단 발견
  - **사용자 의견**: "FF 는 바로 커밋 할 정도인데.. plan-accept 이 ff 에도 영향을 주고 받나?"
  - **합의**: hook 의 진짜 의도는 활성 SPEC 작업 중 무계획 commit 차단 → spec=null 시 통과 로직 추가
- **주제**: 슬러그 결정
  - **합의**: `hook-allow-ff-when-no-spec`

## 🧪 검증 결과

### 단위 테스트
- `bash tests/test-git-precommit-hook.sh` → ✅ 13/13 PASS (Test 12, 13 신규)
- `bash tests/test-hook-modes.sh` → ✅ 12/12 PASS (sync check 포함)
- `bash tests/test-staged-lint.sh` → ✅ 6/6 PASS

### 수동 검증
1. **Action**: TDD Red — Test 12, 13 추가
   - **Result**: 11 PASS / 2 FAIL — 예상대로 spec=null 및 spec 누락에서 차단
2. **Action**: pre-commit.sh + check-plan-accept.sh 에 spec 검사 추가
   - **Result**: 13/13 PASS
3. **Action**: 도그푸딩 sync (`cp sources/hooks/* .harness-kit/hooks/`)
   - **Result**: hook-modes Check 5 (sync 일관성) PASS

## 🔍 발견 사항

- **Test fixture 의 spec 필드 부재**: 기존 `_inject_state` 헬퍼는 `{"planAccepted":...}` 만 주입. spec 필드 부재 시 본 fix 로 통과되어 Test 2 의도 ("planAccepted=false 면 차단") 가 깨질 위험. 헬퍼 시그니처를 `(repo, plan, spec?)` 로 확장하고 Test 2 에 `"spec-x-active"` 명시 → 회귀 안전망 유지.
- **두 hook 의 정책 중복**: pre-commit.sh (git side) 와 check-plan-accept.sh (Claude PreToolUse side) 가 동일 정책을 별도 구현. 향후 정책 변경 시 양쪽 같이 갱신 필요. 통합 라이브러리 (예: `_lib.sh` 의 `hook_check_plan_gate`) 후보.
- **"# harness-kit" 헤더 잡음 fix (commit 85d2462) 가 본 PR 의 동기**: 직전 FF 시도 시 hook 차단으로 `--no-verify` 사용 → constitution 와 모순 노출.

## 🚧 이월 항목

- pre-commit.sh ↔ check-plan-accept.sh 정책 로직 통합 (DRY) → 별개 spec-x 후보.
- `sdd archive` 의 git add 패턴 점검 (PR #103 walkthrough 이월) → 별개.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 |
| **최종 commit** | (Ship 후 갱신) |
