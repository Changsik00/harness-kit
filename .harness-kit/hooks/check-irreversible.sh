#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# 목적: 비가역/파괴 행동(정지규칙 ②, ADR-009)을 실행 *전* 에 감지. auto 의 사전 안전판.
#   사후 검증으로도 못 되돌리는 행동(force push·history rewrite·광범위 삭제·외부 발행)을 대상으로 함.
#
# 훅 단계론: 경고 모드로 시작 (HARNESS_HOOK_MODE_STOP_RULES=block 으로 차단 승격).
# 감지는 narrow — false-positive 최소화. 경계(`--force-with-lease`·`reset --soft` 등 제외)는
# tests/test-stop-rules.sh 가 고정한다.
#
# 비가역 행동 2층 모델 (spec-25-04, phase-review W3):
#   • settings `deny` = never-justify(어떤 맥락도 정당화 불가): rm -rf /·sudo·curl|bash·
#     공유 히스토리 force push. 프롬프트 없는 영구 완전 차단.
#   • 본 hook ② = context-dependent(복구 등에서 정당할 수 있음): git reset --hard·
#     rebase --onto·clean -fd. "멈추고 사람 확인" 이 맞는 부류.
#   현재 reset --hard·rebase --onto 는 deny 도 함께 막아 이중 방어(보호 공백 0).
#   ▶ 차단 승격 적격일: 2026-06-26 (check-irreversible 1주 운영 경과 후). 그때 phase-FF 로
#     기본값을 block 으로 + deny 에서 reset --hard·rebase --onto 를 제거해 본 hook 이 단독
#     "stop+confirm" 층을 떠맡는다. 적격일 전 플립 금지(CLAUDE.md #5).

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

# ⑥ context-dependent 파괴 (복구에서 정당할 수 있음 — 멈추고 사람 확인). spec-25-04 2층 모델.
#    reset --soft/--mixed, 평범한 rebase 는 제외(narrow).
if [ -z "$reason" ] && echo "$cmd" | grep -qE 'git[[:space:]]+reset[[:space:]]+(.*[[:space:]])?--hard([[:space:]]|$)'; then
  reason="git reset --hard (작업트리/인덱스 비가역 되돌림)"
fi
if [ -z "$reason" ] && echo "$cmd" | grep -qE 'git[[:space:]]+rebase[[:space:]]+.*--onto([[:space:]]|$)'; then
  reason="git rebase --onto (히스토리 재배치)"
fi

[ -z "$reason" ] && exit 0

hook_violation \
  "비가역/파괴 행동 감지 (정지규칙 ②, ADR-009)" \
  "명령: $cmd" \
  "분류: $reason" \
  "auto(unattended) 라면 사람 확인이 필요한 hard-stop 대상입니다" \
  "오탐이면 그대로 진행 — 감지 경계 조정은 tests/test-stop-rules.sh"
