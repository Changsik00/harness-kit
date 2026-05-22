# fix(spec-x-check-secrets-dual-mode): check-secrets.sh 듀얼 모드 — 직접 git commit 시 secret 검사 우회 수정

## 📋 Summary

### 배경 및 목적

`check-secrets.sh`는 Claude Code PreToolUse hook으로만 동작해 사용자가 터미널에서 직접 `git commit`을 실행할 때 시크릿 검사가 완전히 우회되는 보안 허점이 있었다.

### 주요 변경 사항
- [x] `check-secrets.sh`: `HARNESS_GIT_HOOK_MODE=1` 명시 신호 기반 듀얼 모드 구현. Claude Code 환경(`CLAUDE_TOOL_INPUT_command` 설정) / git hook 환경(`HARNESS_GIT_HOOK_MODE=1`) / 그 외(안전 탈출) 3가지 경로로 분기
- [x] `pre-commit.sh`: `HARNESS_GIT_HOOK_MODE=1 bash "$HARNESS_HOOKS/check-secrets.sh"` 호출 추가 — 사용자 직접 commit 시 secret 검사 발동
- [x] BSD grep 호환성 수정: `-----BEGIN` 패턴에 `--` 추가 (`grep -qE -- "${_pk_begin}..."`)
- [x] 모든 시크릿 패턴 `+` 라인 필터링: staged diff 제거 라인(`-`)의 self-trigger false positive 방지
- [x] `tests/test-check-secrets-dual-mode.sh` 신규 (11개 테스트)

### Phase 컨텍스트
- **Phase**: 없음 (spec-x)
- **본 SPEC의 역할**: 독립 버그픽스

## 🎯 Key Review Points

1. **`HARNESS_GIT_HOOK_MODE=1` 설계**: 기존 `cmd=empty → git hook 모드` 가정을 폐기. `cmd=empty`는 Claude Code가 env var 미제공 시에도 발생해 PreToolUse에서 false positive를 유발했음. 명시적 env var만이 정확한 경로 구분 가능.

2. **`+` 라인 필터**: `grep -E '^\+[^+]' | grep -qE PATTERN` 패턴으로 staged diff의 추가 라인만 검사. 제거 라인(`-`)에 존재하는 이전 시크릿 패턴 리터럴이 scanner 자신의 업데이트 시 self-trigger하는 문제를 근본적으로 해결. pre-commit hook 의 의미 상 추가 라인만 검사가 더 정확함.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-check-secrets-dual-mode.sh
bash tests/test-git-precommit-hook.sh
```

**결과 요약**:
- ✅ `test-check-secrets-dual-mode.sh`: 11 PASS / 0 FAIL
- ✅ `test-git-precommit-hook.sh`: 13 PASS / 0 FAIL (회귀 없음)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-check-secrets-dual-mode.sh`: 듀얼 모드 검증 11개 테스트
- `specs/spec-x-check-secrets-dual-mode/`: spec/plan/task/walkthrough/pr_description

### 🛠 Modified Files
- `sources/hooks/check-secrets.sh` (+32, -11): 듀얼 모드 분기, BSD grep 수정, + 라인 필터
- `sources/hooks/pre-commit.sh` (+3, -1): check-secrets.sh 호출 추가
- `.harness-kit/hooks/check-secrets.sh`: sources 동기화
- `.harness-kit/hooks/pre-commit.sh`: sources 동기화

**Total**: 8 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (11개)
- [x] 기존 테스트 회귀 없음 (13개)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-check-secrets-dual-mode/walkthrough.md`
