#!/usr/bin/env bash
# harness-kit managed — git pre-commit hook
# 목적:
#   1. staged 파일 기반 lint 실행 (check-staged-lint.sh 위임)
#   2. Plan Accept 전 whitelist 외 production 파일 staged 시 커밋 차단
#
# 이 파일은 install.sh 이 .git/hooks/pre-commit 에 설치합니다.
# 직접 편집하지 마세요 — update.sh 실행 시 재생성됩니다.

set -uo pipefail

HARNESS_ROOT="${HARNESS_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null)}"
export HARNESS_ROOT
HARNESS_HOOKS="$HARNESS_ROOT/.harness-kit/hooks"

# staged-lint 실행 (경고 모드 — 실패해도 커밋은 진행)
if [ -f "$HARNESS_HOOKS/check-staged-lint.sh" ]; then
  bash "$HARNESS_HOOKS/check-staged-lint.sh" || true
fi

# secret 검사 (차단 모드 — 시크릿 발견 시 커밋 중단)
if [ -f "$HARNESS_HOOKS/check-secrets.sh" ]; then
  bash "$HARNESS_HOOKS/check-secrets.sh" || exit 1
fi

# Plan Accept 검사
STATE_FILE="$HARNESS_ROOT/.claude/state/current.json"
[ -f "$STATE_FILE" ] || exit 0

plan_accepted="$(jq -r '.planAccepted // false' "$STATE_FILE" 2>/dev/null || echo "false")"
[ "$plan_accepted" = "true" ] && exit 0

# 활성 SPEC 없음 (FF / 유지보수 / 휴지) → 통과
# spec 필드가 null 또는 누락이면 활성 SPEC 없는 상태로 간주
active_spec="$(jq -r '.spec // empty' "$STATE_FILE" 2>/dev/null || echo "")"
[ "$active_spec" = "null" ] && active_spec=""
[ -z "$active_spec" ] && exit 0

# Plan Accept 전 — staged 파일 중 whitelist 외 파일 있으면 차단
blocked=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    .harness-kit/*|docs/*|backlog/*|specs/*|.claude/*|\
    .gitignore|README.md|CLAUDE.md|version.json) continue ;;
    *.md) continue ;;
    *)
      echo "⛔ [plan-accept] Plan Accept 전 production 코드 커밋 차단: $f" >&2
      blocked=1
      ;;
  esac
done < <(git -C "$HARNESS_ROOT" diff --cached --name-only 2>/dev/null)

if [ "$blocked" -eq 1 ]; then
  echo "   → /hk-plan-accept 호출 후 재시도 (constitution §5.3)" >&2
  exit 1
fi

exit 0
