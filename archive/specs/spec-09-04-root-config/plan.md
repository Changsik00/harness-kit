# Implementation Plan: spec-09-04

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-04-root-config`
- 시작 지점: `phase-09-install-conflict-defense`

## 🎯 핵심 전략

### 변경 1: install.sh — rootDir 항상 기록

현재: prefix 없으면 `harness.config.json` 미생성
변경: 항상 생성, `rootDir` 포함

```bash
# prefix 없는 경우
printf '{"rootDir":"%s"}\n' "$TARGET" > "$TARGET/.harness-kit/harness.config.json"

# prefix 있는 경우
printf '{"rootDir":"%s","backlogDir":"%s","specsDir":"%s"}\n' \
  "$TARGET" "$BACKLOG_DIR" "$SPECS_DIR" > "$TARGET/.harness-kit/harness.config.json"
```

### 변경 2: sources/bin/lib/common.sh — rootDir 우선 읽기

현재 흐름:
```
sdd_find_root: CWD → parent → ... → / (무한 탐색)
```

변경 후 흐름:
```
1. CWD에서 최대 10단계 내 .harness-kit/harness.config.json 찾기
2. rootDir 필드 있으면 → 그 값 반환 (탐색 종료)
3. 없으면 → 기존 installed.json / current.json 폴백
```

```bash
sdd_find_root() {
  local d="${1:-$PWD}"
  local depth=0
  while [ "$d" != "/" ] && [ $depth -lt 10 ]; do
    if [ -f "$d/.harness-kit/harness.config.json" ]; then
      # rootDir 있으면 바로 반환
      local root=""
      if command -v jq >/dev/null 2>&1; then
        root=$(jq -r '.rootDir // empty' "$d/.harness-kit/harness.config.json" 2>/dev/null)
      else
        root=$(grep -o '"rootDir":"[^"]*"' "$d/.harness-kit/harness.config.json" 2>/dev/null | cut -d'"' -f4)
      fi
      if [ -n "$root" ] && [ -d "$root" ]; then
        echo "$root"
        return 0
      fi
    fi
    if [ -f "$d/.harness-kit/installed.json" ] || [ -f "$d/.claude/state/current.json" ]; then
      echo "$d"
      return 0
    fi
    d="$(dirname "$d")"
    depth=$((depth + 1))
  done
  return 1
}
```

### 변경 3: tests/ — 테스트 업데이트

`test-path-config.sh` Check A 변경:
- 기존: "기본값 시 harness.config.json 미생성" → 실패로 바뀜
- 변경: "기본값 시 harness.config.json 생성 (rootDir 포함)"
- 추가: `rootDir` 값이 fixture 경로와 일치하는지 확인

## 📂 Proposed Changes

| 파일 | 변경 내용 |
|---|---|
| `install.sh` | `harness.config.json` 항상 생성, `rootDir` 포함 |
| `sources/bin/lib/common.sh` | `sdd_find_root` rootDir 우선 읽기 |
| `.harness-kit/bin/lib/common.sh` | sources/ 동기화 |
| `tests/test-path-config.sh` | Check A 수정 + rootDir 검증 추가 |

## 🧪 검증

```bash
bash tests/test-path-config.sh
bash tests/test-hook-modes.sh
bash tests/test-two-tier-loading.sh
bash tests/test-install-claude-import.sh
```
