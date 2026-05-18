# Implementation Plan: spec-x-kit-update-notify

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-kit-update-notify` (브랜치 이름 = spec 디렉토리 이름)
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [x] `/hk-update` step 5: 사용자 step 4 승인 시 에이전트가 Bash 툴로 직접 실행 — 임시 동의 기반 실행 허용

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
SessionStart 훅 실행 순서 (변경 후):
  Hook 1: sdd status --brief
    → "harness-kit 0.12.0 →UPDATE:0.13.0 | phase=..."  ← compact에 포함 ✅
    → cache.json 파일 읽기 (네트워크 없음, graceful skip)
  Hook 2: check-kit-version.sh 2>&1  (유지 — cache 갱신 역할)
    → 캐시 갱신 또는 조용히 종료
  Hook 3: echo IMPORTANT  (갱신)
    → "→UPDATE: 패턴 있으면 사용자에게 즉시 보고하라" 추가
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **brief 버전 suffix** | cache.json 파일 읽기만, 네트워크 없음 | brief는 세션 시작 직후 — 응답 지연 없어야 함 |
| **check-kit-version.sh** | 유지 | cache.json 갱신 역할 (24h TTL) 담당 |
| **hk-update 실행** | 임시 동의 (step 4 Y/n) 후 Bash 직접 실행 | 사용자가 이미 확인했으므로 추가 복사-붙여넣기 불필요 |
| **dogfooding 동기화** | sources → .harness-kit 양쪽 모두 수정 | 이 프로젝트 자체가 harness-kit 적용 대상 |

### 📑 ADR 후보

- [x] 없음

## 📂 Proposed Changes

### sdd 스크립트 — brief 버전 suffix

#### [MODIFY] `sources/bin/sdd`

`cmd_status()` 내 `brief` 분기(현재 라인 627-631)에 cache.json 읽기 추가:

```bash
if [ $brief -eq 1 ]; then
  local update_suffix=""
  local cache_json="$SDD_ROOT/.harness-kit/cache.json"
  if [ -f "$cache_json" ] && command -v jq >/dev/null 2>&1; then
    local latest_known
    latest_known=$(jq -r '.latestKnownVersion // empty' "$cache_json" 2>/dev/null || echo "")
    if [ -n "$latest_known" ] && [ "$latest_known" != "$kit_ver" ]; then
      local newer
      newer=$(printf '%s\n%s\n' "$kit_ver" "$latest_known" \
        | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
      [ "$newer" = "$latest_known" ] && update_suffix=" →UPDATE:${latest_known}"
    fi
  fi
  printf '%s | phase=%s spec=%s branch=%s plan=%s\n' \
    "harness-kit ${kit_ver}${update_suffix}" \
    "${phase:-none}" "${spec:-none}" "${branch:-?}" "${plan_accepted:-false}"
  return 0
fi
```

#### [MODIFY] `.harness-kit/bin/sdd`

`sources/bin/sdd` 와 동일한 변경 (dogfooding 동기화).

---

### hk-update 커맨드 — step 5 실행 로직

#### [MODIFY] `sources/commands/hk-update.md`

Step 5를 다음으로 교체:

```
### 5. 업데이트 실행

사용자가 step 4 에서 Y(또는 "응"/"네"/"실행해줘"/"업데이트해줘") 로 승인한 경우:

**에이전트가 Bash 툴로 직접 실행**:

1. `kitOrigin` 에서 `owner/repo` 를 도출해 다음 명령을 Bash 툴로 실행:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh) --update
   ```
2. 실행 중 출력을 사용자에게 그대로 전달
3. 완료 후 새 버전 확인: `cat .harness-kit/installed.json | grep kitVersion`

사용자가 N 으로 거절한 경우 — 수동 실행 안내:
```
수동으로 실행하려면:
  bash <(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/get.sh) --update

Claude Code 프롬프트에서 바로 실행:
  ! bash <(curl -fsSL ...) --update
```

> 비-GitHub 저장소: get.sh 가 GitHub raw URL 을 가정하므로 2차(로컬 클론) 안내만 제공.
```

#### [MODIFY] `.claude/commands/hk-update.md`

`sources/commands/hk-update.md` 와 동일한 변경 (dogfooding 동기화).

---

### SessionStart IMPORTANT 에코 — 패턴 감지 지시

#### [MODIFY] `.claude/settings.json`

`SessionStart` 세 번째 훅 메시지 변경:

```
기존:
  "echo 'IMPORTANT: New session started. You MUST proactively recommend the user to run /hk-align before starting any work.' >&2"

변경 후:
  "echo 'IMPORTANT: New session started. (1) If session-start brief contains →UPDATE:, harness-kit has a new version — immediately report this to the user and suggest running /hk-update. (2) Recommend the user to run /hk-align before starting any work.' >&2"
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-install-claude-import.sh
bash tests/test-marker-append-guard.sh
bash tests/test-marker-edge-cases.sh
```

### 수동 검증 시나리오

1. **brief 버전 suffix 검증**: `cache.json`에 현재보다 높은 버전을 임시 기록 후 `sdd status --brief` 실행 → `→UPDATE:X.Y.Z` 포함 출력 확인
2. **brief graceful skip**: `cache.json` 없는 상태에서 `sdd status --brief` → 기존 포맷 그대로 출력 확인
3. **hk-update.md 내용 확인**: step 5에 실행 로직과 수동 `!` prefix 예시 포함 확인

## 🔁 Rollback Plan

- 스크립트 변경 실패 시 `git revert <commit>` — state 영향 없음
- `settings.json` 변경 실패 시 동일 revert

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
