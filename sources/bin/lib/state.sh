#!/usr/bin/env bash
# state.sh — .claude/state/current.json 읽기/쓰기 헬퍼
# common.sh 가 먼저 source 되어 있어야 함 (SDD_STATE 사용)

# 단일 키 읽기
state_get() {
  local key="$1"
  if [ -f "$SDD_STATE" ]; then
    jq -r ".${key} // empty" "$SDD_STATE" 2>/dev/null
  fi
}

# 단일 키 쓰기 (jq 로 in-place)
# 단순화: bool/null 만 raw 로, 그 외(문자열·숫자·타임스탬프 등)는 모두 --arg 로 안전 처리.
state_set() {
  local key="$1" val="$2"
  [ -f "$SDD_STATE" ] || die "state 파일 없음: $SDD_STATE"
  local tmp
  tmp="$(mktemp)"
  case "$val" in
    true|false|null)
      jq ".${key} = ${val}" "$SDD_STATE" > "$tmp"
      ;;
    *)
      jq --arg v "$val" ".${key} = \$v" "$SDD_STATE" > "$tmp"
      ;;
  esac
  mv "$tmp" "$SDD_STATE"
}

# 전체 state 출력
state_dump() {
  if [ -f "$SDD_STATE" ]; then
    cat "$SDD_STATE"
  else
    echo '{}'
  fi
}

# 현재 phase 디렉토리 경로 (없으면 빈 문자열)
state_phase_dir() {
  local p
  p="$(state_get phase)"
  [ -z "$p" ] || [ "$p" = "null" ] && return 1
  echo "$SDD_BACKLOG/$p"
}

# 현재 spec 디렉토리 경로
state_spec_dir() {
  local s p
  p="$(state_get phase)"
  s="$(state_get spec)"
  [ -z "$p" ] || [ -z "$s" ] || [ "$p" = "null" ] || [ "$s" = "null" ] && return 1
  echo "$SDD_BACKLOG/$p/specs/$s"
}
