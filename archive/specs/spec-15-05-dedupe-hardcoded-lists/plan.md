# Implementation Plan: spec-15-05

## 📋 Branch Strategy

- 신규 브랜치: `spec-15-05-dedupe-hardcoded-lists`
- **시작 지점**: `phase-15-upgrade-safety`
- PR target: `phase-15-upgrade-safety`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **state exclusion 정책** — `kitVersion`, `installedAt` 만 제외. 다른 install-managed 필드가 향후 추가될 가능성? 본 plan 은 *현재 install.sh 가 fresh 작성하는 두 키만* 으로 결정.
> - [ ] **glob 정책** — `*.md` 만. dotfiles (`.DS_Store` 등) 는 자연스럽게 제외됨 (glob 표준).
> - [ ] **templates / governance drift 감지 강도** — 본 spec 의 회귀 테스트가 sources 디렉토리 명단 vs install 결과 1:1 비교. 향후 *원치 않는 .md* 가 sources/ 에 들어가면 install 됨 — 컨벤션 위반으로 간주.

> [!WARNING]
> - [ ] update.sh exclusion 변경 — 사용자 환경에 *예상 못한 키* 가 있으면 그것도 보존됨. Schema Drift 의 *반대 방향* (사용자가 직접 state.json 편집) 위험. 단, 본 프로젝트 컨벤션상 사용자가 state 직접 편집 안 함.

## 🎯 핵심 전략 (Core Strategy)

### 변경 비교

#### install.sh:257-259 (governance) — Before / After

```bash
# Before (3 files hardcoded)
for f in constitution.md agent.md align.md; do
  do_cp "$KIT_DIR/sources/governance/$f" "$TARGET/.harness-kit/agent/$f"
done

# After (디렉토리 glob, 동일 패턴 commands/hooks 와 일관)
for f in "$KIT_DIR/sources/governance"/*.md; do
  [ -e "$f" ] || continue
  do_cp "$f" "$TARGET/.harness-kit/agent/$(basename "$f")"
done
```

#### install.sh:262-264 (templates) — Before / After

```bash
# Before (8 files hardcoded)
for f in queue.md phase.md phase-ship.md spec.md plan.md task.md walkthrough.md pr_description.md; do
  do_cp "$KIT_DIR/sources/templates/$f" "$TARGET/.harness-kit/agent/templates/$f"
done

# After
for f in "$KIT_DIR/sources/templates"/*.md; do
  [ -e "$f" ] || continue
  do_cp "$f" "$TARGET/.harness-kit/agent/templates/$(basename "$f")"
done
```

#### update.sh:113-122 (state 백업) — Before / After

```bash
# Before (inclusion / 6 fields whitelist)
_SAVED_JSON=$(jq -c \
  '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}' \
  "$_STATE" 2>/dev/null || echo '{}')

# After (exclusion / install-managed 키만 제외)
# install.sh 가 fresh 작성하는 키: kitVersion, installedAt
_SAVED_JSON=$(jq -c 'del(.kitVersion, .installedAt)' "$_STATE" 2>/dev/null || echo '{}')
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **glob 패턴** | `*.md` (commands/hooks 와 동일) | bash 표준 glob, dotfile 자연 제외, 본 프로젝트 컨벤션 일관 |
| **state 백업** | exclusion (`del`) | inclusion 은 새 필드마다 동기화 필요, exclusion 은 install template 에 새 키 추가 시에만 영향 |
| **회귀 감지** | `find sources/<dir> -name '*.md'` 와 install 후 결과 비교 | drift 발생 시 즉시 빨간 신호 |
| **명단 기록 (installedCommands 류)** | 추가 안 함 | glob 은 install 시점 파일 = 그대로 install 결과. uninstall 도 동일 디렉토리 통째 제거 (`.harness-kit/`) — drift 위험 0 |

## 📂 Proposed Changes

### [MODIFY] `install.sh` (line 257-259, 262-264)

위 §변경 비교 의사코드 그대로.

### [MODIFY] `update.sh` (line 113-122)

위 §변경 비교 의사코드 그대로. `# 보존 키 화이트리스트` 주석을 `# 보존 정책: install 이 fresh 작성하는 키 (kitVersion, installedAt) 만 제외, 나머지 보존` 로 갱신.

### [NEW] `tests/test-install-manifest-sync.sh`

```bash
#!/usr/bin/env bash
# governance / templates 디렉토리의 파일 명단과 install 결과의 1:1 일치 검증.
# 새 .md 파일이 sources/ 에 추가되었지만 install.sh 갱신이 누락된 경우 즉시 fail.

# Check 1: governance 명단 일치
sources_count=$(find "$ROOT/sources/governance" -maxdepth 1 -name '*.md' | wc -l)
installed_count=$(find "$F/.harness-kit/agent" -maxdepth 1 -name '*.md' | wc -l)
[ "$sources_count" = "$installed_count" ] && ok || fail

# Check 2: templates 명단 일치
sources_count=$(find "$ROOT/sources/templates" -maxdepth 1 -name '*.md' | wc -l)
installed_count=$(find "$F/.harness-kit/agent/templates" -maxdepth 1 -name '*.md' | wc -l)
[ "$sources_count" = "$installed_count" ] && ok || fail

# Check 3: governance 의 각 파일 내용 일치 (cp 정합성)
# Check 4: templates 의 각 파일 내용 일치
```

총 ≥ 4 checks.

### [MODIFY] `tests/test-update-stateful.sh` 또는 [NEW] `tests/test-state-exclusion.sh`

state exclusion 회귀 테스트:

```bash
# Scenario: 사용자 환경의 임의 신규 필드가 update 후 보존되는지
F=$(make_fixture)
jq '. + {"_testCustomField": "preserved"}' "$F/.claude/state/current.json" > /tmp/_s
mv /tmp/_s "$F/.claude/state/current.json"

bash update.sh --yes "$F" >/dev/null

val=$(jq -r '._testCustomField // empty' "$F/.claude/state/current.json")
[ "$val" = "preserved" ] && ok || fail
```

본 plan 은 `tests/test-update-stateful.sh` 의 시나리오 1 후반부에 *Check 추가* 또는 새 테스트 파일 둘 중 선택. **선택: 새 시나리오 추가** (`Scenario 6: state exclusion`) — 시나리오 별 분리가 가독성 우수.

## 🧪 검증 계획

### 단위 테스트
```bash
bash tests/test-install-manifest-sync.sh
bash tests/test-update-stateful.sh   # 추가된 시나리오 6 포함
```

### 회귀
```bash
bash tests/test-version-bump.sh   # 전체 스위트 자동
```

### 도그푸딩
- 본 변경은 install.sh 와 update.sh — 본 프로젝트 자기 자신의 install/update 흐름이 영향. PR 생성 후 사용자가 수동으로 `bash install.sh` / `bash update.sh` 실행 검증 가능 (선택).

## 🔁 Rollback Plan

- 본 spec 은 *동작 동치* — Before/After 결과 동일. revert 단순.

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] install.sh / update.sh 수정
- [ ] tests/test-install-manifest-sync.sh 신규 (≥ 4 checks)
- [ ] tests/test-update-stateful.sh 시나리오 6 추가 (≥ 2 checks)
- [ ] 기존 회귀 PASS
- [ ] walkthrough.md / pr_description.md ship + PR
