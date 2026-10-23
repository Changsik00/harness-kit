#!/usr/bin/env bash
# tests/test-wiki-verify.sh
#
# spec-30-02: wiki 사실 검증 (`sdd doctor` W-5 / `sdd status` 진단)
#   1. 표가 hook 선언과 일치 → 침묵
#   2. hook 기본값을 바꾼 fixture (표는 그대로) → 불일치 보고
#   3. 코드에 hook 이 있는데 표에 없음 → 보고
#   4. 마커 아래에 표가 없음 → 보고
#   5. 알 수 없는 verify 키 → 보고
#   6. frontmatter sources:/covers: 경로가 존재하지 않음 → 보고
#   7. 페이지 크기 상한 초과 → 보고
#   9. 본 저장소 실측 → 불일치 0건 / status 진단 노출
#   8. wiki 없음 / 마커·components 없음 → 침묵
#
# 임시 git repo 만 사용 (실제 repo 는 변경하지 않음). bash 3.2+ 호환.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

# new_fixture <name> → installed 프로젝트 + hook 선언 3개 + 일치하는 wiki
new_fixture() {
  local d="$TMP_ROOT/$1"
  mkdir -p "$d/.harness-kit/hooks" "$d/docs/wiki/components" "$d/docs/decisions" "$d/backlog" "$d/specs"
  echo '{"kitVersion":"0.0.0"}' > "$d/.harness-kit/installed.json"
  echo '# Backlog Queue' > "$d/backlog/queue.md"
  printf 'hook_resolve_mode "BRANCH" "block"\n' > "$d/.harness-kit/hooks/check-branch.sh"
  printf 'hook_resolve_mode "DIFF_SIZE" "warn"\n' > "$d/.harness-kit/hooks/check-diff-size.sh"
  printf '_sr_default="block"\nhook_resolve_mode "STOP_RULES" "$_sr_default"\n' > "$d/.harness-kit/hooks/check-irreversible.sh"
  printf -- '---\nkind: catalog\n---\n# index\n' > "$d/docs/wiki/index.md"
  printf -- '---\nkind: catalog\n---\n# log\n' > "$d/docs/wiki/log.md"
  write_hooks_page "$d" "block" "warn" "auto=block / attended=warn"
  (cd "$d" && git init -q && git config user.email t@t && git config user.name t && git add -A && git commit -q -m init)
  echo "$d"
}

# write_hooks_page <dir> <branch-default> <diffsize-default> <irreversible-default>
write_hooks_page() {
  cat > "$1/docs/wiki/components/hooks.md" <<PAGE
---
kind: synthesis
sources: []
updated: 2026-10-23
---

# 컴포넌트 — hooks

## 현재 설계

<!-- verify: hooks-defaults -->
| hook | 걸리는 곳 | 기본 | 비고 |
|---|---|---|---|
| check-branch | PreToolUse Bash | **$2** | main 차단 |
| check-diff-size | PreToolUse Bash | $3 | 크기 |
| check-irreversible | PreToolUse Bash | **$4** | 모드별 |
PAGE
}

run_doctor() { (cd "$1" && bash "$SDD" doctor 2>&1 || true); }

echo "═══════════════════════════════════════════"
echo " wiki 사실 검증 (spec-30-02)"
echo "═══════════════════════════════════════════"

echo ""
echo "▶ Case 1: 표가 선언과 일치 → 침묵"
d="$(new_fixture match)"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실"*"불일치"*) fail "일치인데 불일치 보고" "$out" ;; *) pass "침묵" ;; esac
case "$out" in *"wiki 사실 검증 OK"*) pass "doctor 에 통과 표시" ;; *) fail "doctor 통과 표시 없음" "$out" ;; esac

echo ""
echo "▶ Case 2: hook 기본값 변경 (표는 그대로) → 불일치 보고"
d="$(new_fixture changed)"
printf 'hook_resolve_mode "BRANCH" "warn"\n' > "$d/.harness-kit/hooks/check-branch.sh"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*"check-branch"*) pass "check-branch 불일치 보고" ;; *) fail "불일치 미보고" "$out" ;; esac

echo ""
echo "▶ Case 3: 코드에 hook 이 있는데 표에 없음 → 보고"
d="$(new_fixture missing-row)"
printf 'hook_resolve_mode "SCOPE" "warn"\n' > "$d/.harness-kit/hooks/check-scope.sh"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*"표에 없는 hook"*"check-scope"*) pass "표에 없는 hook 보고" ;; *) fail "미보고" "$out" ;; esac

echo ""
echo "▶ Case 4: 마커 아래에 표가 없음 → 보고"
d="$(new_fixture no-table)"
printf -- '---\nkind: synthesis\nsources: []\n---\n# x\n\n<!-- verify: hooks-defaults -->\n\n그냥 문단\n' > "$d/docs/wiki/components/hooks.md"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*"표 없음"*) pass "표 없음 보고" ;; *) fail "미보고" "$out" ;; esac

echo ""
echo "▶ Case 5: 알 수 없는 verify 키 → 보고"
d="$(new_fixture bad-key)"
printf -- '---\nkind: synthesis\nsources: []\n---\n# x\n\n<!-- verify: no-such-key -->\n| a |\n|---|\n| b |\n' > "$d/docs/wiki/components/hooks.md"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*"알 수 없는 verify 키"*"no-such-key"*) pass "알 수 없는 키 보고" ;; *) fail "미보고" "$out" ;; esac

echo ""
echo "▶ Case 6: sources:/covers: 경로 존재 확인 (path-exists)"
d="$(new_fixture bad-path)"
printf -- '---\nkind: synthesis\nsources:\n  - docs/decisions/ghost.md\n  - .harness-kit/hooks/check-branch.sh\ncovers:\n  - sources/nowhere/\n---\n# x\n' > "$d/docs/wiki/components/other.md"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*"존재하지 않는 경로"*"ghost.md"*"nowhere"*) pass "없는 경로 2개 보고" ;; *) fail "미보고" "$out" ;; esac
case "$out" in *"check-branch.sh 존재"*) fail "존재하는 경로를 오보고" "$out" ;; *) pass "존재하는 경로는 보고 안 함" ;; esac
d="$(new_fixture ok-path)"
printf -- '---\nkind: synthesis\nsources:\n  - .harness-kit/hooks/check-branch.sh\ncovers:\n  - .harness-kit/hooks/\n---\n# x\n' > "$d/docs/wiki/components/other.md"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*) fail "존재하는 경로인데 보고" "$out" ;; *) pass "존재하는 경로 침묵" ;; esac

echo ""
echo "▶ Case 7: 페이지 크기 상한 (components 200 / direction 150 / threads 300)"
d="$(new_fixture too-big)"
{ printf -- '---\nkind: synthesis\nsources: []\n---\n'; i=0; while [ "$i" -lt 210 ]; do echo "줄 $i"; i=$((i+1)); done; } > "$d/docs/wiki/components/big.md"
{ printf -- '---\nkind: synthesis\nsources: []\n---\n'; i=0; while [ "$i" -lt 160 ]; do echo "줄 $i"; i=$((i+1)); done; } > "$d/docs/wiki/direction.md"
out="$(run_doctor "$d")"
case "$out" in *"big.md"*"크기 상한 초과"*"direction.md"*"크기 상한 초과"*) pass "components/direction 초과 보고" ;; *) fail "미보고" "$out" ;; esac
{ printf -- '---\nkind: synthesis\nsources: []\n---\n'; i=0; while [ "$i" -lt 250 ]; do echo "줄 $i"; i=$((i+1)); done; } > "$d/docs/wiki/threads.md"
rm "$d/docs/wiki/components/big.md" "$d/docs/wiki/direction.md"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*) fail "threads 250줄(<=300)인데 보고" "$out" ;; *) pass "threads 상한 이내 침묵" ;; esac

echo ""
echo "▶ Case 8: wiki 없음 / 마커 없음 → 침묵"
d="$TMP_ROOT/no-wiki"
mkdir -p "$d/.harness-kit" "$d/backlog" "$d/specs"
echo '{"kitVersion":"0.0.0"}' > "$d/.harness-kit/installed.json"
echo '# Backlog Queue' > "$d/backlog/queue.md"
(cd "$d" && git init -q && git config user.email t@t && git config user.name t)
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*) fail "wiki 없는데 보고" "$out" ;; *) pass "wiki 없음 침묵" ;; esac
d="$(new_fixture no-marker)"
printf -- '---\nkind: synthesis\nsources: []\n---\n# x\n\n표 없음, 마커 없음\n' > "$d/docs/wiki/components/hooks.md"
out="$(run_doctor "$d")"
case "$out" in *"wiki 사실 불일치"*) fail "마커 없는데 보고" "$out" ;; *) pass "마커 없음 침묵" ;; esac

echo ""
echo "▶ Case 9: 본 저장소 실측 + status 진단"
out="$(cd "$ROOT" && bash "$SDD" doctor 2>&1 || true)"
case "$out" in *"wiki 사실 검증 OK"*) pass "본 저장소 wiki 사실 불일치 0건" ;; *) fail "본 저장소에 불일치 있음" "$(printf '%s\n' "$out" | grep '사실')" ;; esac
d="$(new_fixture status-line)"
printf 'hook_resolve_mode "BRANCH" "warn"\n' > "$d/.harness-kit/hooks/check-branch.sh"
out="$(cd "$d" && bash "$SDD" status --no-drift 2>&1 || true)"
case "$out" in *"wiki 사실 불일치"*"check-branch"*) pass "sdd status 진단에 노출" ;; *) fail "status 진단에 없음" "$out" ;; esac

echo ""
echo "✓ wiki 사실 검증 PASS"
