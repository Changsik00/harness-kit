#!/usr/bin/env bash
# SessionStart hook — kit 새 버전이 있으면 stderr 1줄로 알린다 (차단 없음).
#
# 동작 조건:
#   - $HARNESS_ROOT/.harness-kit/installed.json 존재
#   - installed.json 의 kitOrigin 이 github.com
#   - jq / curl 모두 존재
#   - HARNESS_DRIFT_FETCH != 0
#   - HARNESS_HOOK_MODE != off, HARNESS_HOOK_MODE_KIT_VERSION != off
#
# 캐시: .harness-kit/cache.json 의 lastVersionCheck / latestKnownVersion 을 24h 캐시로 사용
# (sources/bin/sdd:285-341 _drift_kit_version 와 동일 필드).
# 이전엔 installed.json 에 저장했으나 tracked 파일이라 매 SessionStart drift 발생 — cache.json 으로 분리 (spec-17-03).
#
# 어떤 실패도 silent skip — exit 0 보장.

set -uo pipefail

[ "${HARNESS_HOOK_MODE:-}" = "off" ] && exit 0
[ "${HARNESS_HOOK_MODE_KIT_VERSION:-}" = "off" ] && exit 0
[ "${HARNESS_DRIFT_FETCH:-1}" = "0" ] && exit 0

HARNESS_ROOT="$(pwd)"
INSTALLED_JSON="$HARNESS_ROOT/.harness-kit/installed.json"
CACHE_JSON="$HARNESS_ROOT/.harness-kit/cache.json"

[ -f "$INSTALLED_JSON" ] || exit 0
command -v jq   >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

origin=$(jq -r '.kitOrigin // empty'    "$INSTALLED_JSON" 2>/dev/null || echo "")
installed_ver=$(jq -r '.kitVersion // empty' "$INSTALLED_JSON" 2>/dev/null || echo "")
{ [ -z "$origin" ] || [ -z "$installed_ver" ]; } && exit 0
echo "$origin" | grep -q "github.com" || exit 0

# Migration (1회만): installed.json 의 캐시 필드가 있으면 cache.json 으로 이동 + installed.json 정리
if jq -e 'has("lastVersionCheck") or has("latestKnownVersion")' "$INSTALLED_JSON" >/dev/null 2>&1; then
  legacy_last=$(jq -r '.lastVersionCheck // empty'   "$INSTALLED_JSON" 2>/dev/null || echo "")
  legacy_known=$(jq -r '.latestKnownVersion // empty' "$INSTALLED_JSON" 2>/dev/null || echo "")
  if [ -n "$legacy_last" ] || [ -n "$legacy_known" ]; then
    jq -n --arg ts "$legacy_last" --arg v "$legacy_known" \
      '{lastVersionCheck: $ts, latestKnownVersion: $v}' > "$CACHE_JSON" 2>/dev/null
  fi
  tmp=$(jq 'del(.lastVersionCheck, .latestKnownVersion)' "$INSTALLED_JSON" 2>/dev/null || echo "")
  [ -n "$tmp" ] && echo "$tmp" > "$INSTALLED_JSON"
fi

last_check=""
latest_known=""
if [ -f "$CACHE_JSON" ]; then
  last_check=$(jq -r '.lastVersionCheck // empty'   "$CACHE_JSON" 2>/dev/null || echo "")
  latest_known=$(jq -r '.latestKnownVersion // empty' "$CACHE_JSON" 2>/dev/null || echo "")
fi
cache_valid=0
if [ -n "$last_check" ]; then
  now_epoch=$(date -u +%s 2>/dev/null || echo "0")
  cache_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_check" +%s 2>/dev/null \
    || date -d "$last_check" +%s 2>/dev/null || echo "0")
  [ $((now_epoch - cache_epoch)) -lt 86400 ] && cache_valid=1
fi

if [ "$cache_valid" -eq 1 ] && [ -n "$latest_known" ]; then
  latest="$latest_known"
else
  slug=$(echo "$origin" | sed 's|git@github.com:||; s|https://github.com/||; s|\.git$||')
  [ -z "$slug" ] && exit 0
  raw_url="https://raw.githubusercontent.com/${slug}/main/version.json"
  latest=$(curl -sf --max-time 3 "$raw_url" 2>/dev/null \
    | jq -r '.version // empty' 2>/dev/null || echo "")
  [ -z "$latest" ] && exit 0
  now_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq -n --arg ts "$now_iso" --arg v "$latest" \
    '{lastVersionCheck: $ts, latestKnownVersion: $v}' > "$CACHE_JSON" 2>/dev/null || true
fi

[ "$latest" = "$installed_ver" ] && exit 0
newer=$(printf '%s\n%s\n' "$installed_ver" "$latest" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
[ "$newer" != "$latest" ] && exit 0

if [ -t 2 ]; then Y=$'\033[33m'; R=$'\033[0m'; else Y=""; R=""; fi
echo "${Y}🆕 harness-kit ${latest} 사용 가능 (현재 ${installed_ver}) — /hk-update 로 갱신${R}" >&2
exit 0
