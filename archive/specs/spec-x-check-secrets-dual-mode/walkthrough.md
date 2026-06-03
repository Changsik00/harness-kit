# Walkthrough: spec-x-check-secrets-dual-mode

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| git hook 모드 감지 방법 | cmd=empty vs 명시적 env var | `HARNESS_GIT_HOOK_MODE=1` 명시 | cmd=empty 는 Claude Code 가 env var 미제공 시에도 발생해 false positive 유발. 명시적 신호가 유일하게 정확 |
| Private Key grep 호환성 | `'-----BEGIN...'` 직접 vs `--` 추가 vs `+` 라인 필터 | `+` 라인 필터 + `--` 유지 | macOS BSD grep 이 `-----BEGIN` 을 옵션으로 오해(unrecognized option). `--` 로 고치더라도 staged diff 내 제거 라인에서 self-trigger. `+` 필터가 근본 해결 |
| 모든 패턴 `+` 라인 필터 | AWS 키만 / 전 패턴 | 전 패턴 통일 | self-trigger 는 AWS/GitHub 토큰에도 동일하게 발생 가능. 패턴 일관성 + pre-commit hook 의 의미 상 추가 라인만 검사가 더 정확 |

### ADR 승격 가이드

- [ ] 없음 — hook 내부 구현 결정으로, cross-spec 의존성 없음

## 💬 사용자 협의

- **주제**: 작업 모드 및 구현 방식 선택
  - **사용자 의견**: SDD-x + 옵션 A (dual mode, 단일 SSOT) 선택
  - **합의**: check-secrets.sh 에 듀얼 모드 추가, pre-commit.sh 에서 호출

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트

**신규**: `bash tests/test-check-secrets-dual-mode.sh`
- **결과**: ✅ PASS 11 / FAIL 0

```
═══════════════════════════════════════════════════════
 test-check-secrets-dual-mode (spec-x-check-secrets-dual-mode)
═══════════════════════════════════════════════════════
  ✅ PASS: Test 1: check-secrets.sh 존재
  ✅ PASS: Test 2: git hook 모드에서 AWS 키 staged → 차단됨 (exit=2)
  ✅ PASS: Test 3: git hook 모드에서 정상 파일 → 통과 (exit=0)
  ✅ PASS: Test 4: Claude Code 모드에서 AWS 키 staged → 차단됨 (exit=2)
  ✅ PASS: Test 5: git status 명령 → secret 검사 skip (exit=0)
  ✅ PASS: Test 6: 환경변수 없음 → 안전 탈출 (exit=0)
  ✅ PASS: Test 7: pre-commit.sh 에 HARNESS_GIT_HOOK_MODE=1 호출 존재
  ✅ PASS: Test 8: pre-commit.sh 경유 AWS 키 staged → 차단됨 (exit=1)
  ✅ PASS: Test 9: git hook 모드에서 .env staged → 차단됨 (exit=2)
  ✅ PASS: Test 10: pre-commit.sh 경유 정상 파일 → 통과 (exit=0)
  ✅ PASS: Test 11: Private Key staged → 차단됨 (exit=2)
PASS: 11  FAIL: 0
```

**회귀**: `bash tests/test-git-precommit-hook.sh`
- **결과**: ✅ PASS 13 / FAIL 0 — 기존 pre-commit 동작 회귀 없음

### 2. 수동 검증

1. **Action**: `HARNESS_GIT_HOOK_MODE=1 bash .harness-kit/hooks/check-secrets.sh` (AKIA 키 staged 상태)
   - **Result**: ❌ block 모드로 차단 (exit=2)

2. **Action**: 일반 `bash tests/...` Bash 도구 호출 (cmd=empty, HARNESS_GIT_HOOK_MODE 미설정)
   - **Result**: ✅ 안전 탈출 (exit=0) — false positive 없음

## 🔍 발견 사항

- **초기 설계 오류**: `cmd=empty` → git hook 모드 가정이 잘못됨. Claude Code PreToolUse hook 도 일부 상황에서 `CLAUDE_TOOL_INPUT_command` env var 를 미제공해 cmd=empty 가 되어 false positive 유발. `HARNESS_GIT_HOOK_MODE=1` 명시 신호로 해결.

- **BSD grep self-trigger 체인**: `-----BEGIN` 패턴 → BSD grep unrecognized option (최초 발견) → `--` 추가 → staged diff 제거 라인 self-trigger → `+` 라인 필터로 근본 해결. 세 이슈가 연쇄적으로 발견됨.

- **self-trigger 패턴 일반화**: mock 시크릿 패턴(AKIA, Private Key)을 테스트 소스에 리터럴로 쓰면 check-secrets.sh 가 테스트 파일 staged 시 self-trigger. 변수 분리 패턴으로 회피 필요 — 향후 테스트 작성 관례로 삼을 것.

## 🚧 이월 항목

- 없음

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-23 |
| **최종 commit** | `9687d6c` |
