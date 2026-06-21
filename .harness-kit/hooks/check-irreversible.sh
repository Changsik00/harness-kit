#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# 목적: 비가역/파괴 행동(정지규칙 ②, ADR-009)을 실행 *전* 에 감지. auto 의 사전 안전판.
#   사후 검증으로도 못 되돌리는 행동(force push·history rewrite·광범위 삭제·외부 발행)을 대상으로 함.
#
# 훅 단계론: 경고 모드로 시작 (HARNESS_HOOK_MODE_STOP_RULES=block 으로 차단 승격).
# 감지는 narrow — false-positive 최소화. 경계(`git reset --hard`·`--force-with-lease` 등 제외)는
# tests/test-stop-rules.sh 가 고정한다.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "STOP_RULES" "warn"

cmd="$(hook_tool_input command)"
[ -z "$cmd" ] && exit 0

reason=""

# ① force push (--force / -f / forced refspec) — --force-with-lease 는 narrow 하게 제외
if echo "$cmd" | grep -qE 'git[[:space:]].*\bpush\b'; then
  if echo "$cmd" | grep -qE '(\-\-force([[:space:]]|$)|[[:space:]]\-f([[:space:]]|$))'; then
    reason="force push (히스토리 비가역 덮어쓰기)"
  fi
fi

# ② git history rewrite
if [ -z "$reason" ] && echo "$cmd" | grep -qE 'git[[:space:]]+filter-(branch|repo)\b'; then
  reason="git history rewrite (filter-branch/repo)"
fi

# ③ 광범위 삭제: rm -rf 의 root/home/glob 타깃
if [ -z "$reason" ] && \
   echo "$cmd" | grep -qE '\brm\b[[:space:]]+(-[A-Za-z]*r[A-Za-z]*f[A-Za-z]*|-[A-Za-z]*f[A-Za-z]*r[A-Za-z]*|-r[[:space:]]+-f|-f[[:space:]]+-r)'; then
  if echo "$cmd" | grep -qE '[[:space:]](/|~|\*|/\*|~/?\*?)([[:space:]]|$)'; then
    reason="광범위 파일 삭제 (rm -rf 의 root/home/glob 타깃)"
  fi
fi

# ④ git clean -fd (untracked 파괴)
if [ -z "$reason" ] && echo "$cmd" | grep -qE 'git[[:space:]]+clean[[:space:]]+(-[A-Za-z]*f[A-Za-z]*d|-[A-Za-z]*d[A-Za-z]*f)'; then
  reason="git clean -fd (untracked 파일 파괴)"
fi

# ⑤ 외부 발행/배포 (비가역 외부 효과)
if [ -z "$reason" ] && echo "$cmd" | grep -qE '\b(npm|yarn|pnpm)[[:space:]]+publish\b|gh[[:space:]]+release[[:space:]]+create\b'; then
  reason="외부 발행/배포 (publish/release)"
fi

[ -z "$reason" ] && exit 0

hook_violation \
  "비가역/파괴 행동 감지 (정지규칙 ②, ADR-009)" \
  "명령: $cmd" \
  "분류: $reason" \
  "auto(unattended) 라면 사람 확인이 필요한 hard-stop 대상입니다" \
  "오탐이면 그대로 진행 — 감지 경계 조정은 tests/test-stop-rules.sh"
