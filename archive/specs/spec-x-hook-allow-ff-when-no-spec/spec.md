# spec-x-hook-allow-ff-when-no-spec: plan-accept hook 이 활성 SPEC 없을 때 production 코드 commit 을 허용

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-hook-allow-ff-when-no-spec` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-hook-allow-ff-when-no-spec` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-09 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
두 hook 이 동일한 정책을 강제한다:
- `sources/hooks/pre-commit.sh:25-46` — git commit 시 staged 파일에서 whitelist 외 파일 발견 시 `planAccepted=false` 면 차단
- `sources/hooks/check-plan-accept.sh:44-54` — Edit/Write tool 사용 시 whitelist 외 path 면 `planAccepted=false` 일 때 차단

판단 기준은 **오직 `planAccepted` flag 하나**. `state.json` 의 `spec` 필드는 무시.

### 문제점
직전 FF 커밋 (commit 85d2462 install.sh 수정) 시도 중 발견:
- 활성 SPEC 없음 (spec=null), planAccepted=false
- install.sh 수정 → hook 차단
- `--no-verify` bypass 외에 우회 불가

이는 **constitution §2.3 의 FF 정의와 정면 모순**:
- FF = "Inline fixes, minor wording, config tweaks that do not warrant a PR" (코드 변경 가능 모드)
- FF 는 state.json 을 안 건드림 → planAccepted 영원히 false → 영구 차단

또 부수적으로 막히는 경우:
- 머지 직후 main 의 quick maintenance commit
- 도그푸딩 검증 후 작은 cosmetic fix

### 해결 방안 (요약)
hook 의 진짜 의도는 **"활성 SPEC 작업 중 무계획 commit 차단"**. 활성 SPEC 이 없으면 (spec=null) 차단 의미 없음 → hook 첫머리에서 `state.spec == null` 이면 통과시킴.

## 🎯 요구사항

### Functional Requirements
1. **F1**: `pre-commit.sh` — `state.json` 의 `spec` 필드가 null/빈문자열/없음 일 때, planAccepted 와 무관하게 즉시 통과 (exit 0).
2. **F2**: `check-plan-accept.sh` — 동일 로직 적용.
3. **F3**: `state.spec` 이 비어있지 않은 (활성 SPEC 존재) 경우 기존 동작 그대로 유지 — planAccepted 검사.

### Non-Functional Requirements
1. **N1**: 회귀 금지 — 기존 Test 2~4 (planAccepted true/false × production/whitelist) 가 활성 SPEC 가정 하에서 그대로 PASS.
2. **N2**: 도그푸딩 sync — `sources/hooks/` 와 `.harness-kit/hooks/` 일관성.
3. **N3**: state.json 에 `spec` 필드가 아예 없는 경우 (legacy 또는 fixture) 도 안전하게 통과 (= no active spec) 또는 기존처럼 차단 — Plan 에서 결정.

## 🚫 Out of Scope
- Hook 의 "FF 모드 마커" 명시적 도입 (commit subject 또는 environment 변수) — 본 fix 가 사실상 FF 인식 효과 제공하므로 불필요.
- check-plan-accept.sh 외 다른 PreToolUse hook 의 정책 변경.
- whitelist 확장.

## ✅ Definition of Done
- [ ] 단위 테스트 PASS — 신규 회귀 + 기존 Test 2~4 갱신 무손상
- [ ] walkthrough / pr_description ship
- [ ] push + PR
