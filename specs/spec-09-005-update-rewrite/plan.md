# Implementation Plan: spec-09-005

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-005-update-rewrite`
- 시작 지점: `phase-09-install-conflict-defense`

## 🎯 핵심 전략

### 새 update.sh 구조

```bash
#!/usr/bin/env bash
# update.sh — uninstall + install + cleanup

# 1. 설치 확인
# 2. prefix 읽기 (uninstall 전에, harness.config.json 에서)
# 3. 버전 출력
# 4. 사용자 확인 (--yes 시 스킵)
# 5. uninstall --yes --keep-state
# 6. install --yes [--prefix ...] [--shell ...]
# 7. cleanup (.harness-backup-* / .harness-uninstall-backup-*)
# 8. doctor
```

### prefix 보존 로직

```bash
# uninstall 전에 config 읽기
HK_PREFIX=""
_CONFIG="$TARGET/.harness-kit/harness.config.json"
if [ -f "$_CONFIG" ] && command -v jq >/dev/null 2>&1; then
  _bd=$(jq -r '.backlogDir // empty' "$_CONFIG" 2>/dev/null || true)
  # backlogDir 에서 prefix 역산: "hk-backlog" → "hk-"
  if [ -n "$_bd" ]; then
    HK_PREFIX="${_bd%backlog}"
  fi
fi
```

### cleanup 로직

```bash
_cleanup_backups() {
  local count
  count=$(find "$TARGET" -maxdepth 1 \
    \( -name '.harness-backup-*' -o -name '.harness-uninstall-backup-*' \) \
    -type d 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" -gt 0 ]; then
    find "$TARGET" -maxdepth 1 \
      \( -name '.harness-backup-*' -o -name '.harness-uninstall-backup-*' \) \
      -type d -exec rm -rf {} + 2>/dev/null || true
    ok "백업 디렉토리 ${count}개 정리"
  fi
}
```

## 📂 Proposed Changes

| 파일 | 변경 내용 |
|---|---|
| `update.sh` | 전면 재작성 (~60줄) |

## 🧪 검증 계획

### update.sh 직접 테스트

```bash
# 설치된 상태에서:
bash update.sh --yes
# → state 보존 확인
# → .harness-kit/ 새로 생성 확인
# → doctor 통과 확인
```

### 기존 테스트 회귀 확인

```bash
bash tests/test-path-config.sh
bash tests/test-hook-modes.sh
```
