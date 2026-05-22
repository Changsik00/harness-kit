# spec-x-check-secrets-dual-mode: check-secrets.sh 듀얼 모드 — 직접 git commit 시 secret 검사 우회 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-check-secrets-dual-mode` |
| **Phase** | 없음 (solo spec-x) |
| **Branch** | `spec-x-check-secrets-dual-mode` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-23 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sources/hooks/check-secrets.sh`는 Claude Code PreToolUse hook으로 등록되어 있어, Claude Code 에이전트가 `git commit`을 실행할 때만 시크릿 패턴 검사를 수행한다.

`.git/hooks/pre-commit` (→ `sources/hooks/pre-commit.sh`)은 staged-lint와 plan-accept 검사를 수행하지만, `check-secrets.sh`는 호출하지 않는다.

### 문제점

사용자가 터미널에서 직접 `git commit`을 실행하면 `.git/hooks/pre-commit`이 실행되지만 시크릿 검사가 누락된다. `check-secrets.sh`는 `hook_tool_input command`로 Claude Code 환경 변수를 읽는데, 직접 실행 시에는 해당 환경변수가 없어 `cmd=""` → `exit 0` 즉시 통과한다.

결과적으로:
- Claude Code 에이전트 `git commit` → secret 검사 ✓
- 사용자 터미널 `git commit` → secret 검사 ✗ (보안 허점)

### 해결 방안 (요약)

`check-secrets.sh`에 듀얼 모드를 적용한다. Claude Code 환경(hook_tool_input이 반환값 있음)이면 현재 로직 유지, 그렇지 않으면 명령어 매칭 단계를 건너뛰고 바로 staged diff 검사를 수행한다. `pre-commit.sh`에서 `check-secrets.sh`를 호출하여 두 경로 모두 검사가 발동되도록 한다.

## 🎯 요구사항

### Functional Requirements
1. 사용자가 터미널에서 직접 `git commit`을 실행해도 staged 파일의 시크릿 검사가 수행되어야 한다.
2. `check-secrets.sh`는 Claude Code 환경과 직접 git hook 환경 모두에서 올바르게 동작해야 한다.
3. Claude Code 에이전트가 `git commit`이 아닌 다른 Bash 명령 실행 시에는 여전히 skip되어야 한다.
4. `.git/hooks/pre-commit` 실행 시 `check-secrets.sh`가 호출되어야 한다.

### Non-Functional Requirements
1. bash 3.2+ 호환 유지 (macOS 기본 bash)
2. `set -uo pipefail` 준수
3. `check-secrets.sh`가 단일 SSOT (새 파일 추가 없음 — 옵션 A)
4. HARNESS_HOOK_MODE_SECRETS 환경변수로 모드 제어 가능 유지

## 🚫 Out of Scope

- `gitleaks`, `git-secrets` 등 외부 도구 도입 (옵션 C)
- 시크릿 패턴 자체의 추가/변경
- 다른 hook 파일 동작 변경

## 📑 ADR 후보

- [ ] 없음

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-check-secrets-dual-mode` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
