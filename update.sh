#!/usr/bin/env bash
# harness-kit updater
# 기존 설치 위에 새 키트 버전을 덮어씁니다. state 와 사용자 산출물은 보존됩니다.
#
# Usage:
#   ./update.sh                    # 현재 디렉토리 갱신
#   ./update.sh /path/to/project   # 지정 디렉토리 갱신
#
# 동작:
#   1. 현재 .claude/state/current.json 을 읽어 stack 정보 보존
#   2. install.sh 를 --yes 로 호출 (백업 자동)
#   3. doctor.sh 실행

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)"

if [ ! -f "$TARGET/.claude/state/current.json" ]; then
  echo "⚠ $TARGET 에 harness-kit 이 설치되어 있지 않은 것 같습니다."
  echo "  최초 설치는: $KIT_DIR/install.sh $TARGET"
  exit 1
fi

# 기존 stack 보존
STACK_ARG=""
if command -v jq >/dev/null; then
  prev_stack=$(jq -r '.stack // ""' "$TARGET/.claude/state/current.json")
  if [ -n "$prev_stack" ] && [ "$prev_stack" != "null" ]; then
    STACK_ARG="--stack=$prev_stack"
  fi
fi

echo "[update] 기존 설치를 갱신합니다."
"$KIT_DIR/install.sh" --yes $STACK_ARG "$TARGET"

echo ""
echo "[update] doctor 점검"
"$KIT_DIR/doctor.sh" "$TARGET" || true
