#!/usr/bin/env bash
# lib/extend.sh — sdd extend: 외부 도구 opt-in 통합 (phase-22)
#
# 현재 지원 확장: serena (LSP 기반 코드 인텔리전스 MCP 서버)
# 등록은 Claude Code 네이티브 `claude mcp add` 에 위임한다 (키트가 설정 파일을 직접 편집하지 않음).
# default-off / opt-in — 켠 사람만 상시 컨텍스트 비용을 부담한다.
# bash 3.2 호환 (declare -A / mapfile / ** 미사용).

# Serena 실행 커맨드 (uvx — 별도 바이너리 설치 없이 실행).
# 출처: https://oraios.github.io/serena/02-usage/030_clients.html (context=claude-code)
SERENA_LAUNCH_FROM="git+https://github.com/oraios/serena"

cmd_extend() {
  local target="${1:-}"; shift || true
  case "$target" in
    serena)            _extend_serena "$@" ;;
    ""|help|-h|--help) _extend_help ;;
    *)                 err "알 수 없는 확장: $target"; _extend_help; return 1 ;;
  esac
}

_extend_help() {
  cat <<'EOF'
sdd extend — 외부 도구 opt-in 통합

사용:
  sdd extend serena [--scope local|user] [--dry-run]
  sdd extend serena --remove

사용 가능한 확장:
  serena   LSP 기반 코드 인텔리전스(심볼 rename / find-references). MCP 서버.
           ⚠ 상시 컨텍스트 비용이 듭니다 — opt-in(default-off).

스코프:
  local  (기본) 이 프로젝트 + 나만 (gitignore, ~/.claude.json). 켠 사람만 비용 부담.
  user   내 모든 프로젝트.
  (커밋되는 .mcp.json 팀 공유는 지원하지 않습니다 — opt-in 원칙)
EOF
}

_extend_serena() {
  local scope="local" dry_run="false" remove="false"
  while [ $# -gt 0 ]; do
    case "$1" in
      --scope)   shift; scope="${1:-}" ;;
      --scope=*) scope="${1#--scope=}" ;;
      --dry-run) dry_run="true" ;;
      --remove)  remove="true" ;;
      -h|--help) _extend_help; return 0 ;;
      *)         err "알 수 없는 옵션: $1"; return 1 ;;
    esac
    shift || true
  done

  local installed_json="$SDD_ROOT/.harness-kit/installed.json"

  # 제거 경로
  if [ "$remove" = "true" ]; then
    _extend_serena_remove "$installed_json"
    return $?
  fi

  # 스코프 검증 — local | user 만 허용
  case "$scope" in
    local|user) : ;;
    project)
      err "스코프 'project'(.mcp.json 커밋)는 지원하지 않습니다 — 팀 전원에게 상시 컨텍스트 비용을 강요하기 때문입니다."
      err "허용 스코프: local(기본) | user"
      return 1 ;;
    *)
      err "알 수 없는 스코프: '$scope' — 허용: local(기본) | user"
      return 1 ;;
  esac

  # 등록 커맨드 구성 (eval 없이 배열로 — 인용/공백 안전)
  local ADD
  if [ "$scope" = "user" ]; then
    ADD=(claude mcp add serena --scope user -- \
         uvx --python 3.13 --from "$SERENA_LAUNCH_FROM" serena start-mcp-server \
         --context claude-code --project-from-cwd)
  else
    ADD=(claude mcp add serena --scope local -- \
         uvx --python 3.13 --from "$SERENA_LAUNCH_FROM" serena start-mcp-server \
         --context claude-code --project "$SDD_ROOT")
  fi

  # dry-run: 구성될 커맨드만 미리보기(부작용 없음)
  if [ "$dry_run" = "true" ]; then
    _extend_check_prereq || true
    echo "[dry-run] 다음 커맨드를 실행합니다:"
    echo "  ${ADD[*]}"
    return 0
  fi

  # 선행조건 점검 — 부재 시 graceful 종료(비파괴)
  if ! _extend_check_prereq; then
    return 0
  fi

  # 멱등성: 이미 등록돼 있으면 중복 설치 건너뜀
  if claude mcp get serena >/dev/null 2>&1; then
    warn "serena 가 이미 등록되어 있습니다 — 중복 설치를 건너뜁니다."
    _extend_record "$installed_json" "$scope"
    _extend_fragment_inject
    echo "제거하려면: sdd extend serena --remove"
    return 0
  fi

  # 등록
  echo "🔄 serena 등록 중 (scope=$scope)..."
  if ! "${ADD[@]}"; then
    err "claude mcp add 실패 — 수동 등록이 필요할 수 있습니다."
    return 1
  fi
  _extend_record "$installed_json" "$scope"
  _extend_fragment_inject
  ok "serena 등록 완료 (scope=$scope)."
  echo ""
  echo "  ▶ 다음 단계 (필수): Claude Code 를 재시작하세요."
  echo "    MCP 도구는 세션 시작 시 로드되므로, 재시작 전에는 serena 도구가 보이지 않습니다."
  echo "    재시작 후 'serena 도구로 ...' 처럼 시켜 보면 됩니다."
  echo ""
  echo "  제거: sdd extend serena --remove"
}

# 선행조건: uv(uvx 제공) + claude CLI 존재
_extend_check_prereq() {
  local missing=""
  command -v uv >/dev/null 2>&1 || missing="uv"
  command -v claude >/dev/null 2>&1 || missing="${missing:+$missing, }claude"
  if [ -n "$missing" ]; then
    warn "선행조건 미충족: $missing 가 필요합니다."
    case "$missing" in
      *uv*) echo "  uv 설치: curl -LsSf https://astral.sh/uv/install.sh | sh  (또는 brew install uv)" ;;
    esac
    echo "  설치 후 다시 실행하세요: sdd extend serena"
    return 1
  fi
  return 0
}

# ─────────────────────────────────────────────────────────
# CLAUDE.fragment.md 주입 — 확장 사용 규칙을 상시 컨텍스트에 노출.
#
# 평소 serena 사용 규칙은 agent.md(=`/hk-align` 시에만 로드)에 있어 align 없이
# 작업을 시작하면 보이지 않는다 (ADR-008 의 standing-cost 회피 설계). 확장을
# opt-in 한 프로젝트에 한해서만, 설치본 fragment(매 세션 @import) 에 마커 블록을
# 주입해 align 없이도 노출한다. 비용은 켠 사람만 부담 — fragment 직접 수정 대신
# 설치 시점 주입이라 일반화 원칙(over-fit 회피)에 부합한다.
# ─────────────────────────────────────────────────────────
_extend_fragment_path() { printf '%s/.harness-kit/CLAUDE.fragment.md' "$SDD_ROOT"; }

_extend_fragment_inject() {
  local frag; frag="$(_extend_fragment_path)"
  [ -f "$frag" ] || return 0
  grep -q 'hk-extend:serena BEGIN' "$frag" 2>/dev/null && return 0
  cat >> "$frag" <<'EOF'

<!-- hk-extend:serena BEGIN -->
## 확장 우선 — serena (LSP 코드 인텔리전스, opt-in)

LSP 지원 언어에서 심볼 정의·참조·구현·rename 은 grep 스윕 대신 serena MCP 도구를 우선 사용한다. 조건부 — bash·단발 grep·산문은 기존 도구 (context-cost-first). 상세 → `.harness-kit/agent/agent.md` Extension-First.
<!-- hk-extend:serena END -->
EOF
}

# 마커 블록(및 바로 앞 빈 줄 1개) 제거. 멱등 — 블록 없으면 no-op.
_extend_fragment_strip() {
  local frag; frag="$(_extend_fragment_path)"
  [ -f "$frag" ] || return 0
  grep -q 'hk-extend:serena BEGIN' "$frag" 2>/dev/null || return 0
  local tmp; tmp=$(mktemp) || return 0
  awk '
    { buf[NR] = $0 }
    /hk-extend:serena BEGIN/ { s = NR }
    /hk-extend:serena END/   { e = NR }
    END {
      lo = s
      if (s > 1 && buf[s-1] == "") lo = s - 1
      for (i = 1; i <= NR; i++) if (i < lo || i > e) print buf[i]
    }
  ' "$frag" > "$tmp" && mv "$tmp" "$frag" || rm -f "$tmp"
}

# installed.json 에 설치 흔적 기록 (진짜 등록 SSOT 는 `claude mcp list`)
_extend_record() {
  local installed_json="$1" scope="$2"
  [ -f "$installed_json" ] || return 0
  local now tmp
  now=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
  tmp=$(jq --arg s "$scope" --arg t "$now" \
        '.extensions = ((.extensions // {}) + {serena: {scope: $s, installedAt: $t}})' \
        "$installed_json" 2>/dev/null) || return 0
  echo "$tmp" > "$installed_json"
}

_extend_serena_remove() {
  local installed_json="$1"
  if command -v claude >/dev/null 2>&1; then
    claude mcp remove serena >/dev/null 2>&1 || true
  fi
  if [ -f "$installed_json" ]; then
    local tmp
    tmp=$(jq 'if .extensions then .extensions |= del(.serena) else . end
              | if (.extensions == {}) then del(.extensions) else . end' \
          "$installed_json" 2>/dev/null) || tmp=""
    [ -n "$tmp" ] && echo "$tmp" > "$installed_json"
  fi
  _extend_fragment_strip
  ok "serena 제거 완료."
}
