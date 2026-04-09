#!/usr/bin/env bash
# Stack adapter: Node.js (모든 JS/TS 프로젝트 — NestJS, Next.js, Vite, ...)
#
# 패키지 매니저 자동 감지 우선순위:
#   1. package.json 의 "packageManager" 필드 (corepack 표준)
#   2. lockfile 존재 여부 (pnpm-lock.yaml > yarn.lock > bun.lockb > package-lock.json)
#   3. fallback: npm
#
# 본 어댑터는 *런타임* (sdd / hook / slash 가 source 할 때) 에 감지를 수행합니다.
# 따라서 사용자가 나중에 pnpm 으로 마이그레이션해도 키트는 자동으로 따라옵니다.

export HARNESS_STACK_NAME="nodejs"
export HARNESS_STACK_DESC="Node.js (auto-detected package manager)"

# ----- 패키지 매니저 감지 -----
__harness_detect_pm() {
  # 1. package.json 의 packageManager 필드 (가장 권위있음)
  if [ -f package.json ] && command -v jq >/dev/null 2>&1; then
    local pm
    pm=$(jq -r '.packageManager // empty' package.json 2>/dev/null | sed 's/@.*//')
    case "$pm" in
      pnpm|yarn|bun|npm) echo "$pm"; return ;;
    esac
  fi
  # 2. lockfile
  [ -f pnpm-lock.yaml ]    && { echo "pnpm"; return; }
  [ -f yarn.lock ]         && { echo "yarn"; return; }
  [ -f bun.lockb ]         && { echo "bun"; return; }
  [ -f package-lock.json ] && { echo "npm"; return; }
  # 3. fallback
  echo "npm"
}

HARNESS_PKG_MANAGER="$(__harness_detect_pm)"
export HARNESS_PKG_MANAGER

# ----- PM 별 binary 실행자 (npx 등) -----
case "$HARNESS_PKG_MANAGER" in
  pnpm) HARNESS_BIN_RUNNER="pnpm exec" ;;
  yarn) HARNESS_BIN_RUNNER="yarn" ;;       # yarn 1/berry 모두 local bin 호출 가능
  bun)  HARNESS_BIN_RUNNER="bunx" ;;
  *)    HARNESS_BIN_RUNNER="npx" ;;
esac
export HARNESS_BIN_RUNNER

# ----- 표준 명령 -----
# `<pm> test`, `<pm> run lint` 등 스크립트 호출은 모든 PM 에서 호환됨.
export HARNESS_TEST_CMD="$HARNESS_PKG_MANAGER test"
export HARNESS_LINT_CMD="$HARNESS_PKG_MANAGER run lint"
export HARNESS_BUILD_CMD="$HARNESS_PKG_MANAGER run build"
export HARNESS_TYPECHECK_CMD="$HARNESS_BIN_RUNNER tsc --noEmit"

# 통합 테스트: package.json 에 test:e2e / test:integration 스크립트가 있으면 사용,
# 없으면 일반 test 로 폴백
__harness_detect_integration_cmd() {
  if [ -f package.json ] && command -v jq >/dev/null 2>&1; then
    local s
    for s in "test:e2e" "test:integration" "e2e"; do
      if jq -e ".scripts | has(\"$s\")" package.json >/dev/null 2>&1; then
        echo "$HARNESS_PKG_MANAGER run $s"
        return
      fi
    done
  fi
  echo "$HARNESS_TEST_CMD"
}
export HARNESS_TEST_INTEGRATION_CMD
HARNESS_TEST_INTEGRATION_CMD="$(__harness_detect_integration_cmd)"

# ----- 테스트 파일 패턴 (NestJS, Jest, Vitest 모두 호환) -----
export HARNESS_TEST_FILE_GLOB="*.{test,spec}.{js,ts,jsx,tsx,mjs,cjs}"
export HARNESS_INTEGRATION_TEST_FILE_GLOB="*.{e2e-spec,e2e}.{js,ts}"
export HARNESS_SRC_DIR="src"

# ----- 정리 -----
unset -f __harness_detect_pm __harness_detect_integration_cmd
