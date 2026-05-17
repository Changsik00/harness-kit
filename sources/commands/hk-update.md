# /hk-update

현재 프로젝트에 설치된 harness-kit 버전을 확인하고, 새 버전이 있으면 업데이트를 안내합니다.

## 절차

### 1. 설치 정보 읽기

```bash
INSTALLED_JSON="$SDD_ROOT/.harness-kit/installed.json"
```

`installed.json` 에서 다음을 읽습니다:
- `kitVersion` — 현재 설치 버전
- `kitOrigin` — kit 원격 저장소 URL

`installed.json` 없거나 `kitOrigin` 비어 있으면:

```
⚠ harness-kit 설치 정보를 찾을 수 없습니다.
  installed.json 이 없거나 kitOrigin 이 기록되지 않았습니다.
  → 재설치: bash <kit-dir>/install.sh .
```

출력 후 종료.

### 2. 최신 버전 조회

`kitOrigin` 에서 `owner/repo` 를 추출해 raw `version.json` 을 조회합니다:

```bash
slug=$(echo "$origin" | sed 's|git@github.com:||; s|https://github.com/||; s|\.git$||')
raw_url="https://raw.githubusercontent.com/${slug}/main/version.json"
latest=$(curl -sf --max-time 5 "$raw_url" | jq -r '.version // empty')
```

`curl` 실패 또는 결과 비어 있으면:

```
⚠ 최신 버전을 확인할 수 없습니다 (네트워크 오류 또는 지원되지 않는 저장소).
```

출력 후 종료.

### 3. 버전 비교

`latest == installed` 이거나 `installed > latest` 이면:

```
✓ 최신 버전입니다 (X.X.X)
```

출력 후 종료.

### 4. 업데이트 안내

새 버전이 있으면 정보 블록 표시 후 확인:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🆕 harness-kit 업데이트 가능
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  현재 버전   X.X.X
  최신 버전   Y.Y.Y
  저장소      <kitOrigin>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

업데이트할까요? [Y/n]
```

확인 규칙 → constitution §5.7

### 5. 업데이트 실행

승인 시, `kitOrigin` 에서 `owner/repo` 를 도출해 다음 안내를 출력합니다.

**1차 (권장) — 원격 직접 실행 (로컬 클론 불필요)**:

```
업데이트를 시작합니다. 다음 명령어를 실행하세요:

  bash <(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh) --update

# 자동 수락:    위 명령 끝에 --yes 추가
# 특정 버전 핀: --version <ver> 를 --update 앞에 추가
```

**2차 (Fallback) — 로컬 클론 보유 / 오프라인 환경**:

```
  bash <kit-dir>/update.sh .

# <kit-dir> 를 모르는 경우:
#   git clone <kitOrigin> ~/harness-kit && bash ~/harness-kit/update.sh .
```

**비-GitHub 저장소**: `kitOrigin` 이 github.com 이 아니면 1차 안내를 생략하고 2차만 출력합니다 (`get.sh` 가 GitHub raw URL 을 가정).

> **에이전트가 직접 `update.sh` (또는 원격 변형) 를 실행하지 않습니다** — 사용자가 직접 입력해야 합니다.
> (update 는 uninstall → install 재실행으로 파일을 교체하는 파괴적 작업)

### 6. 캐시 업데이트

업데이트 조회 성공 시 `.harness-kit/cache.json` 을 갱신합니다 (spec-17-03 에서 `installed.json` 으로부터 분리되었습니다 — `.gitignore` 대상):

```bash
jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg v "$latest" \
  '{lastVersionCheck: $ts, latestKnownVersion: $v}' > .harness-kit/cache.json
```

## 주의

- github.com 이 아닌 저장소는 지원하지 않습니다 (graceful skip).
- 오프라인 환경에서는 캐시된 `latestKnownVersion` 값으로 대체 표시합니다.
