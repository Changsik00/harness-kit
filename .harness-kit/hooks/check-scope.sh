#!/usr/bin/env bash
# PreToolUse hook (matcher: Edit|Write|MultiEdit) + git pre-commit (HARNESS_GIT_HOOK_MODE=1)
# 목적: 변경 파일이 spec.md 의 Proposed Changes 범위 안인지 검증 (constitution §6.2)
#
# 두 모드:
#   - edit 모드(기본): Edit/Write 대상 1개 파일 검사. turbo/auto bypass, 차단형(mode 따름).
#   - commit 모드(HARNESS_GIT_HOOK_MODE=1): staged diff 전체 검사. mode 무관(blast-radius
#     가드 — MCP/Serena 편집도 커밋 시점에 포착), 경고만(exit 0). (spec-24-02 / ADR-009)

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "SCOPE" "warn"

# ── 공유 헬퍼 ──
# 안전 경로(거버넌스/산출물/설정/*.md)면 0
_scope_is_safe() {
  case "$1" in
    .harness-kit/*|docs/*|backlog/*|specs/*|.claude/*|\
    .gitignore|README.md|CLAUDE.md|version.json|\
    *.md) return 0 ;;
  esac
  return 1
}
# spec.md 에서 [MODIFY|NEW|DELETE] `path` 경로 추출
_scope_paths() {
  grep -oE '\[(MODIFY|NEW|DELETE)\][[:space:]]+`[^`]+`' "$1" | sed -E 's/.*`([^`]+)`.*/\1/'
}
# rel 이 scope_paths(개행 구분)에 포함(정확/디렉토리 prefix)되면 0
_scope_in() {
  local rel="$1" sp="$2" pattern dir_pattern
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    [ "$rel" = "$pattern" ] && return 0
    dir_pattern="${pattern%/*}/"
    case "$rel" in "$dir_pattern"*) return 0 ;; esac
  done <<< "$sp"
  return 1
}
# 공통 전제(plan-accepted + active spec + spec.md + scope 정의) → scope_paths 를 stdout.
# 전제 미충족이면 비-0 반환(검사 스킵).
_scope_prereq() {
  [ "$(hook_state planAccepted)" = "true" ] || return 1
  local spec; spec="$(hook_state spec)"
  [ -z "$spec" ] && return 1
  local pf="$HARNESS_ROOT/specs/$spec/spec.md"
  [ -f "$pf" ] || return 1
  local sp; sp="$(_scope_paths "$pf")"
  [ -z "$sp" ] && return 1
  printf '%s' "$sp"
}

# ── commit 모드: staged diff 전체, mode 무관, 경고만(exit 0) ──
if [ "${HARNESS_GIT_HOOK_MODE:-0}" = "1" ]; then
  scope_paths="$(_scope_prereq)" || exit 0
  spec="$(hook_state spec)"
  out=""
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    _scope_is_safe "$f" && continue
    _scope_in "$f" "$scope_paths" && continue
    out="$out $f"
  done < <(git -C "$HARNESS_ROOT" diff --cached --name-only 2>/dev/null)
  if [ -n "$out" ]; then
    echo "⚠ [scope:warn] Spec 범위 밖 파일이 staged 됨 (경고 — 커밋 진행, phase-ship 에서 검토):" >&2
    for f in $out; do echo "   $f" >&2; done
    echo "   active spec: $spec — spec.md Proposed Changes 외. 의도면 spec.md 갱신, 아니면 unstage." >&2
  fi
  exit 0
fi

# ── edit 모드 (기존): turbo/auto bypass, 단일 파일, 차단형 ──
_hk_mode="$(hook_state mode)"; { [ "$_hk_mode" = "turbo" ] || [ "$_hk_mode" = "auto" ]; } && exit 0

target="$(hook_tool_input file_path)"
[ -z "$target" ] && exit 0
case "$target" in
  /*) rel="${target#$HARNESS_ROOT/}" ;;
  *)  rel="$target" ;;
esac
_scope_is_safe "$rel" && exit 0

scope_paths="$(_scope_prereq)" || exit 0
spec="$(hook_state spec)"
_scope_in "$rel" "$scope_paths" && exit 0

hook_violation \
  "Spec 범위 밖 파일 편집 (constitution §6.2)" \
  "대상 파일: $rel" \
  "active spec: $spec" \
  "spec.md 의 Proposed Changes 에 명시된 파일만 편집 가능" \
  "해결: spec.md 에 해당 파일을 추가하거나 사용자와 재정렬"
