# Implementation Plan: spec-x-kit-update-hook

## 📋 Branch Strategy

- 브랜치: `spec-x-kit-update-hook` (이미 생성, `main` 기준)
- 별도 phase 없음 — Solo Spec

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] SessionStart 시점에 stderr 1줄 알림 추가 정책에 동의 (자동 실행은 하지 않음)
> - [ ] 캐시는 `_drift_kit_version` 과 동일한 `installed.json` 필드(`lastVersionCheck`, `latestKnownVersion`)를 공유

> [!WARNING]
> - hook 은 사용자가 새 세션을 열 때마다 실행됨. 캐시가 valid (24h 이내) 인 동안은 curl 미발생 — 비용 0. 첫 호출 시에만 curl 한 번 (max-time 3s).
> - 네트워크 실패 / jq 부재 / origin 비-GitHub 시 silent skip (절대 차단 안 함).

## 🎯 핵심 전략 (Core Strategy)

### 동작 시퀀스

```
새 Claude Code 세션 시작
   ▼
SessionStart hook 시퀀스:
   1. .harness-kit/bin/sdd status --brief         ← 기존
   2. .harness-kit/hooks/check-kit-version.sh    ← 신규
   3. echo 'IMPORTANT: ... /hk-align ...'         ← 기존
       │
       └─ check-kit-version.sh 내부:
          - installed.json 검사 → kitOrigin github.com 여부
          - 24h 캐시 검사 → valid 면 latestKnownVersion 사용
          - cache miss 시 curl raw version.json → installed.json 캐시 갱신
          - latest > installed 인 경우만 stderr 1줄 출력
          - 어떤 경우든 exit 0
```

### 주요 결정

| 항목 | 전략 | 이유 |
|:---|:---|:---|
| **위치** | SessionStart hook 배열의 두 번째 entry | `sdd status --brief` 직후 → 사용자가 한눈에 같이 봄 |
| **차단 정책** | 절대 exit ≠ 0 안 함 | UX 알림용. 네트워크 등 실패가 세션 시작을 방해해선 안 됨 |
| **캐시 공유** | `_drift_kit_version` 과 동일 필드 사용 | hook 과 sdd status 가 서로의 결과를 재사용 → 비용 절감, 동작 일관 |
| **bash 3.2+** | _lib.sh 의 패턴(date -j / date -d 폴백) 답습 | macOS 기본 bash 3.2.57 동작 |
| **per-hook off** | `HARNESS_HOOK_MODE_KIT_VERSION=off` | 알림이 거슬리는 사용자 탈출구 |
| **메시지 형식** | `🆕 harness-kit X.X.X 사용 가능 (현재 Y.Y.Y) — /hk-update 로 갱신` | sdd status 라인보다 한층 명시적 (이모지 + 행동 지시) |

## 📂 Proposed Changes

### A. 신규 hook 스크립트

#### [NEW] `sources/hooks/check-kit-version.sh`

핵심 본문 (실제 구현은 task 1에서 확정):

```bash
#!/usr/bin/env bash
# SessionStart hook — 새 kit 버전이 있으면 stderr 1줄 알림 (차단 없음).
# 동작 조건: installed.json 존재 + kitOrigin=github.com + jq/curl 존재 + HARNESS_DRIFT_FETCH != 0
# 24h 캐시: installed.json 의 lastVersionCheck / latestKnownVersion (sdd status 와 공유)

set -uo pipefail

# 글로벌/per-hook off
[ "${HARNESS_HOOK_MODE:-}" = "off" ] && exit 0
[ "${HARNESS_HOOK_MODE_KIT_VERSION:-}" = "off" ] && exit 0
[ "${HARNESS_DRIFT_FETCH:-1}" = "0" ] && exit 0

HARNESS_ROOT="$(pwd)"
INSTALLED_JSON="$HARNESS_ROOT/.harness-kit/installed.json"

[ -f "$INSTALLED_JSON" ] || exit 0
command -v jq   >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

origin=$(jq -r '.kitOrigin // empty'   "$INSTALLED_JSON" 2>/dev/null || echo "")
installed_ver=$(jq -r '.kitVersion // empty' "$INSTALLED_JSON" 2>/dev/null || echo "")
{ [ -z "$origin" ] || [ -z "$installed_ver" ]; } && exit 0
echo "$origin" | grep -q "github.com" || exit 0

# 24h 캐시 검사
last_check=$(jq -r '.lastVersionCheck // empty'  "$INSTALLED_JSON" 2>/dev/null || echo "")
latest_known=$(jq -r '.latestKnownVersion // empty' "$INSTALLED_JSON" 2>/dev/null || echo "")
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
  tmp=$(jq --arg ts "$now_iso" --arg v "$latest" \
    '.lastVersionCheck=$ts | .latestKnownVersion=$v' "$INSTALLED_JSON" 2>/dev/null || echo "")
  [ -n "$tmp" ] && echo "$tmp" > "$INSTALLED_JSON"
fi

# latest == installed → skip
[ "$latest" = "$installed_ver" ] && exit 0
# latest <= installed → skip (다운그레이드/개발 브랜치 무시)
newer=$(printf '%s\n%s\n' "$installed_ver" "$latest" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
[ "$newer" != "$latest" ] && exit 0

# 색상 (stderr TTY)
if [ -t 2 ]; then Y=$'\033[33m'; R=$'\033[0m'; else Y=""; R=""; fi
echo "${Y}🆕 harness-kit ${latest} 사용 가능 (현재 ${installed_ver}) — /hk-update 로 갱신${R}" >&2
exit 0
```

### B. SessionStart hook 등록

#### [MODIFY] `sources/claude-fragments/settings.json.fragment`

기존 SessionStart 배열에 hook entry 1개 추가 (`sdd status --brief` 와 IMPORTANT 메시지 사이):

```json
"SessionStart": [
  {
    "hooks": [
      { "type": "command", "command": ".harness-kit/bin/sdd status --brief 2>/dev/null || true" },
      { "type": "command", "command": ".harness-kit/hooks/check-kit-version.sh 2>&1 || true" },
      { "type": "command", "command": "echo 'IMPORTANT: New session started. You MUST proactively recommend the user to run /hk-align before starting any work.' >&2" }
    ]
  }
]
```

`install.sh:383-384` 의 hooks 머지 정책 (kit fragment 권위 + 사용자 추가 키만 보존) 에 의해, 기존 설치 갱신 시에도 새 entry 가 자동 반영된다.

### C. install.sh / update.sh

코드 변경 불필요. `install.sh:289-297` 이 `sources/hooks/*.sh` 를 자동 복사 + chmod +x 처리.

## 🧪 검증 계획 (Verification Plan)

### 정적 검증
```bash
bash -n sources/hooks/check-kit-version.sh   # 구문 검사
shellcheck sources/hooks/check-kit-version.sh || true  # 가능하면
```

### 수동 검증 시나리오

1. **알림 노출 확인**
   - 임시로 `.harness-kit/installed.json` 의 `kitVersion` 을 `0.0.1` 로 백업·교체
   - hook 직접 실행: `bash .harness-kit/hooks/check-kit-version.sh`
   - 기대: stderr 에 `🆕 harness-kit 0.9.0 사용 가능 (현재 0.0.1) — /hk-update 로 갱신`
   - 원상 복구

2. **silent skip 확인**
   - `HARNESS_HOOK_MODE_KIT_VERSION=off bash sources/hooks/check-kit-version.sh`
   - 기대: 출력 없음, exit 0
   - `HARNESS_DRIFT_FETCH=0 bash sources/hooks/check-kit-version.sh`
   - 기대: 출력 없음, exit 0

3. **최신 상태 확인**
   - 본 프로젝트 (`kitVersion=0.9.0`, 원격 = 0.9.0) 에서 `bash sources/hooks/check-kit-version.sh`
   - 기대: 출력 없음, exit 0

4. **fragment merge 시뮬레이션** (선택)
   - `jq` 로 fragment 의 SessionStart 배열 길이 확인 (3 entry)
   - 기존 설치된 `.claude/settings.json` 와 install.sh:370-385 의 jq 로직을 dry-run 으로 검증

## 🔁 Rollback Plan

- 두 파일(`check-kit-version.sh`, `settings.json.fragment`) 만 변경되므로 `git revert <commit>` 으로 즉시 복구.
- 사용자가 이미 hook 알림에 의존하더라도 hook 부재 시 단순 silent → 동작 회귀 없음 (`|| true` 로 묶여 있어 hook 호출 자체가 실패해도 세션 시작 정상).

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
