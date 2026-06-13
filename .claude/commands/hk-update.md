# /hk-update

현재 프로젝트에 설치된 harness-kit 버전을 확인하고, 새 버전이 있으면 업데이트를 안내합니다.

## 절차

### 1. 설치 정보 읽기

```bash
INSTALLED_JSON="$(pwd)/.harness-kit/installed.json"
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

`kitOrigin` 에서 `owner/repo` 를 도출합니다.

**비-GitHub 저장소**: `kitOrigin` 이 github.com 이 아니면 아래 "수동 실행" 안내만 출력하고 종료합니다.

#### GitHub 저장소인 경우 — 에이전트가 직접 실행

사용자가 step 4 에서 Y (또는 "응" / "네" / "실행해줘" / "업데이트해줘") 로 승인한 경우, **에이전트가 Bash 툴로 직접 실행**합니다:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh) --update --yes
```

> `--yes` 필수: 에이전트 Bash 환경엔 controlling TTY 가 없어 `update.sh` 의 확인 프롬프트(`read < /dev/tty`)가 빈 값으로 읽혀 항상 "취소됨"으로 종료됩니다. step 4 에서 이미 사용자 승인을 받았으므로 재확인은 생략합니다. (사람이 `!` prefix 나 터미널에서 직접 실행하는 아래 경로는 TTY 가 있으므로 `--yes` 없이 둡니다.)

실행 완료 후 새 버전을 확인합니다:

```bash
jq -r '.kitVersion' .harness-kit/installed.json
```

#### 업데이트 후 — 산물 커밋 (필수 안내)

`update.sh` 는 `.harness-kit/*` · `.claude/*` 를 덮어쓰지만 **자동 커밋하지 않습니다**. 미커밋 상태로 두면 이후 새 spec 브랜치를 만들 때 그대로 따라붙어 PR scope 를 오염시킵니다. 업데이트 직후 **별도 커밋**을 안내하세요:

```bash
git add .harness-kit .claude
git commit -m "chore: apply harness-kit update <new-version>"
```

> `update.sh` 종료 메시지에도 동일 안내가 출력됩니다. 미커밋 산물이 없으면 안내는 생략됩니다.

#### 사용자가 N 으로 거절한 경우 — 수동 실행 안내

```
수동으로 실행하려면 (로컬 클론 불필요):

  curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh | bash -s -- --update

Claude Code 프롬프트에서 바로 실행하려면 ! prefix 사용:

  ! curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh | bash -s -- --update

특정 버전 설치: --version <ver> 를 --update 앞에 추가
```

### 6. 캐시 업데이트

업데이트 조회 성공 시 `.harness-kit/cache.json` 을 갱신합니다 (spec-17-03 에서 `installed.json` 으로부터 분리되었습니다 — `.gitignore` 대상):

```bash
jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg v "$latest" \
  '{lastVersionCheck: $ts, latestKnownVersion: $v}' > .harness-kit/cache.json
```

## 주의

- github.com 이 아닌 저장소는 지원하지 않습니다 (graceful skip).
- 오프라인 환경에서는 캐시된 `latestKnownVersion` 값으로 대체 표시합니다.
