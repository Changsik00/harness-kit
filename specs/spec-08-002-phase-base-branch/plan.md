# Implementation Plan: spec-08-002

## 📋 Branch Strategy

- 신규 브랜치: `spec-08-002-phase-base-branch` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `phase-08-work-model`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `baseBranch` 값을 state.json에 저장 — `phase-{N}-{slug}` 형식 (예: `phase-08-work-model`)
> - [ ] `sdd phase new --base` 에서 실제 git 브랜치 생성 **하지 않음** (just-in-time 원칙)
> - [ ] hk-ship은 markdown 문서이므로 — Step 4 텍스트 명세만 수정 (shell 스크립트 아님)

> [!WARNING]
> - [ ] `--base` 없이 기존 `sdd phase new <slug>` 호출 시 baseBranch = null 유지 (하위 호환)
> - [ ] `git ls-remote` 로 remote 존재 확인 후 없을 때만 브랜치 생성 (중복 생성 방지)

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
sdd phase new work-model --base
  ┌─ phase_new() 수정 ─────────────────────────────────────┐
  │  1. --base 플래그 파싱                                  │
  │  2. baseBranch = "phase-{N}-{slug}" 계산               │
  │  3. state_set baseBranch "{value}"                      │
  │  4. phase.md 메타 "Base Branch" 필드에 브랜치명 기재    │
  │  (실제 git 브랜치 생성 안 함)                           │
  └────────────────────────────────────────────────────────┘

sdd status --json
  ┌─ cmd_status() 수정 ────────────────────────────────────┐
  │  baseBranch: state_get baseBranch (없으면 null)         │
  └────────────────────────────────────────────────────────┘

hk-ship Step 4 (Push 확인) — markdown 명세 수정
  ┌─ baseBranch 감지 로직 추가 ────────────────────────────┐
  │  1. sdd status --json | jq -r '.baseBranch'            │
  │  2. null이 아니면:                                      │
  │     a. git ls-remote --exit-code origin {baseBranch}   │
  │     b. 없으면: git checkout -b {baseBranch} main        │
  │                git push -u origin {baseBranch}          │
  │                git checkout - (spec 브랜치 복귀)        │
  │     c. 확인 블록 타깃 = baseBranch                      │
  │     d. PR 생성 시 --base {baseBranch}                   │
  └────────────────────────────────────────────────────────┘

sdd phase done
  ┌─ phase_done() 수정 ────────────────────────────────────┐
  │  state_set baseBranch "null"                            │
  └────────────────────────────────────────────────────────┘
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **baseBranch 저장 위치** | state.json | sdd의 기존 상태 관리 패턴과 일치 |
| **브랜치 생성 시점** | hk-ship 실행 시 just-in-time | 미리 만들면 main 분기점이 달라질 수 있음 |
| **remote 존재 확인** | `git ls-remote --exit-code` | 이미 존재하면 skip (멱등성 보장) |
| **hk-ship 수정 범위** | markdown 명세 텍스트만 | hk-ship은 slash command 문서이므로 shell 코드 아님 |
| **sources/ 동기화** | `sources/bin/sdd`도 동일 수정 | 도그푸딩 SSOT 원칙 |

## 📂 Proposed Changes

### [sdd] `scripts/harness/bin/sdd` + `sources/bin/sdd`

#### [MODIFY] `phase_new()` 함수

`--base` 플래그 파싱 + `baseBranch` 저장 + `phase.md` 메타 갱신:

```bash
phase_new() {
  local slug="${1:-}"
  local base_mode=0
  shift || true
  for arg in "$@"; do
    case "$arg" in --base) base_mode=1 ;; esac
  done
  # ... (기존 로직) ...
  if [ $base_mode -eq 1 ]; then
    local base_branch="phase-${next}-${slug}"
    state_set baseBranch "$base_branch"
    # phase.md 메타 "없음" → 브랜치명으로 교체
    sed -i.tmp "s|없음 / phase-{N}-{slug} (opt-in)|${base_branch}|" "$file"
    rm -f "$file.tmp"
    ok "base branch 모드: $base_branch (첫 hk-ship 시 생성)"
  fi
}
```

#### [MODIFY] `cmd_status()` 함수 — `--json` 출력에 baseBranch 추가

```bash
# --json 분기에서:
local base_branch
base_branch="$(state_get baseBranch 2>/dev/null || echo "null")"
printf '{ "phase": "%s", "spec": "%s", ..., "baseBranch": %s }\n' \
  ... "$([ "$base_branch" = "null" ] && echo "null" || echo "\"$base_branch\"")"
```

#### [MODIFY] `phase_done()` 함수 — baseBranch null 초기화

```bash
state_set baseBranch "null"
```

### [hk-ship] `sources/commands/hk-ship.md`

#### [MODIFY] Step 4 Push 확인 섹션

baseBranch 감지 + JIT 브랜치 생성 + PR 타깃 변경 명세 추가:

```markdown
## 4. Push 확인 (사용자 승인 필요)

**[Phase base branch 감지]** Push 전 먼저 확인:

\`\`\`bash
base_branch=$(./scripts/harness/bin/sdd status --json | jq -r '.baseBranch // "null"')
if [ "$base_branch" != "null" ]; then
  # remote 존재 여부 확인
  if ! git ls-remote --exit-code origin "$base_branch" >/dev/null 2>&1; then
    echo "phase base branch 없음 — 생성: $base_branch"
    git checkout -b "$base_branch" main
    git push -u origin "$base_branch"
    git checkout -   # spec 브랜치로 복귀
  fi
  PR_BASE="$base_branch"
else
  PR_BASE="main"
fi
\`\`\`

확인 블록에 타깃 반영:
  브랜치    <head>  ▶  🎯 <PR_BASE>
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-base-branch.sh
```

테스트 케이스:
1. `sdd phase new slug --base` → `state.json`의 `baseBranch` = `"phase-N-slug"`
2. `sdd phase new slug` (no flag) → `baseBranch` = null
3. `sdd status --json` → `baseBranch` 키 포함
4. `sdd phase done` → `baseBranch` = null

### 수동 검증 시나리오

1. `sdd phase new test-base --base` 실행 → `sdd status --json | jq .baseBranch` 확인
2. `sdd status --json` → `"baseBranch": "phase-N-test-base"` 출력 확인
3. `sdd phase done` → `sdd status --json | jq .baseBranch` = `null` 확인

## 🔁 Rollback Plan

- state.json에서 `baseBranch` 키만 제거하면 기존 동작으로 복귀
- hk-ship.md는 텍스트 수정이므로 git revert 한 번으로 원복 가능
- phase base branch 모드는 opt-in이므로 기존 phase/spec에 영향 없음

## 📦 Deliverables 체크

- [x] spec.md 작성
- [x] plan.md 작성 (이 파일)
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
