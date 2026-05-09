# Implementation Plan: spec-x-hook-allow-ff-when-no-spec

## 📋 Branch Strategy
- 신규 브랜치: `spec-x-hook-allow-ff-when-no-spec`
- 시작 지점: `main`

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **state.spec 이 없거나 빈 경우 동작**: 새로 생긴 state 또는 fixture 가 spec 필드 자체를 안 가질 수 있음. `jq -r '.spec // empty'` 로 통일 — null / "null" / 누락 → 모두 빈 문자열로 처리. 빈 문자열 = 활성 SPEC 없음 = 통과.

> [!WARNING]
> - [ ] **기존 Test 2 fixture 갱신 필요**: `_inject_state` 에서 spec 필드 미주입 → 본 fix 후 Test 2 가 Pass 처리되어 의도와 어긋남. fixture 에 `"spec":"spec-x-active"` 명시 추가 필요.

## 🎯 핵심 변경

### `sources/hooks/pre-commit.sh`

```diff
   plan_accepted="$(jq -r '.planAccepted // false' "$STATE_FILE" 2>/dev/null || echo "false")"
   [ "$plan_accepted" = "true" ] && exit 0

+  # 활성 SPEC 없음 (FF / 유지보수 / 휴지) → 통과
+  active_spec="$(jq -r '.spec // empty' "$STATE_FILE" 2>/dev/null || echo "")"
+  [ "$active_spec" = "null" ] && active_spec=""
+  [ -z "$active_spec" ] && exit 0
+
   # Plan Accept 전 — staged 파일 중 whitelist 외 파일 있으면 차단
```

### `sources/hooks/check-plan-accept.sh`

```diff
   plan_accepted="$(hook_state planAccepted)"
   if [ "$plan_accepted" = "true" ]; then
     exit 0
   fi

+  # 활성 SPEC 없음 → 통과 (FF / 유지보수)
+  active_spec="$(hook_state spec)"
+  [ "$active_spec" = "null" ] && active_spec=""
+  [ -z "$active_spec" ] && exit 0
+
   hook_violation \
```

### `tests/test-git-precommit-hook.sh`

- `_inject_state` 헬퍼 시그니처 확장: `_inject_state <repo> <plan_accepted> [spec]` (기본 spec="spec-x-active")
- Test 2: 명시적으로 `_inject_state "$REPO2" "false" "spec-x-active"` 로 active SPEC 주입
- 신규 Test 12: spec=null + planAccepted=false + production 파일 → 통과
- 신규 Test 13: spec 필드 누락 (legacy) + planAccepted=false + production 파일 → 통과

### `.harness-kit/hooks/` sync
- `cp sources/hooks/{pre-commit,check-plan-accept}.sh .harness-kit/hooks/`

## 📂 Proposed Changes

| 파일 | 변경 |
|---|---|
| `sources/hooks/pre-commit.sh` | spec=null bypass 4줄 추가 |
| `sources/hooks/check-plan-accept.sh` | 동일 |
| `.harness-kit/hooks/pre-commit.sh` | sync |
| `.harness-kit/hooks/check-plan-accept.sh` | sync |
| `tests/test-git-precommit-hook.sh` | Test 2 fixture 갱신 + Test 12, 13 추가 |

## 🧪 검증 계획

```bash
bash tests/test-git-precommit-hook.sh
bash tests/test-hook-modes.sh           # 회귀
bash tests/test-staged-lint.sh          # 회귀
```

### 도그푸딩 검증
- 본 PR 머지 후 main 에서 install.sh 같은 production 코드를 직접 commit 시도 → hook 통과 확인 (`--no-verify` 없이)

## 🔁 Rollback
- 단일 PR git revert.

## 📦 Deliverables
- [ ] task.md
- [ ] Plan Accept
- [ ] 모든 task 완료
- [ ] walkthrough / pr_description ship
