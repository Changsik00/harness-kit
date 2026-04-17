# Implementation Plan: spec-08-003

## 📋 Branch Strategy

- 신규 브랜치: `spec-08-003-ship-completion-gate`
- 시작 지점: `phase-08-work-model` (spec-08-002 merge 완료 기준)
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `sdd archive` 가 phase.md를 직접 수정함 — 파일이 없거나 행을 못 찾으면 warn + continue (exit 1 안 함)
> - [ ] phase done 유도는 메시지 출력만, 자동 실행 없음

> [!WARNING]
> - [ ] phase.md spec 표의 상태 컬럼은 `In Progress` 외에 다른 값이 올 수 있음 (예: PR-open 등 사용자 커스텀). sed는 `In Progress` → `Merged` 패턴만 교체

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
cmd_archive() 추가 로직:
  1. 기존: archive commit
  2. NEW: phase.md 현재 spec 행 In Progress → Merged
  3. NEW: phase.md 전체 스캔 → Backlog/In Progress 행 없으면 phase done 유도

hk-ship.md Step 6 추가:
  spec-x인 경우:
    → sdd queue mark-specx-done {slug}  (또는 직접 sed)
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **phase.md 상태 갱신** | `sed` in-place (spec 행 패턴 매칭) | jq 불필요, awk로 spec ID 기준 정확한 행 교체 |
| **전체 Merged 판단** | phase.md spec 표 파싱 (Backlog/In Progress 행 유무) | `compute_next_spec()` 와 동일한 파싱 패턴 재사용 |
| **spec-x queue 갱신** | hk-ship.md Step 6 명세 추가 (sdd 명령 경유) | sdd가 마커 기반 교체 담당 — 직접 sed 금지 |
| **sources/ 동기화** | sdd 변경 후 동일 반영 | SSOT 원칙 |

## 📂 Proposed Changes

### [sdd] `scripts/harness/bin/sdd` + `sources/bin/sdd`

#### [MODIFY] `cmd_archive()` — archive 후 phase.md 갱신 + phase done 유도

```bash
cmd_archive() {
  # ... (기존 검증 + commit 로직 동일) ...

  ok "archive commit 완료"

  # NEW: phase.md spec 상태 → Merged 갱신
  local phase_id spec_id
  phase_id="$(state_get phase)"
  spec_id="$(state_get spec)"
  if [ -n "$phase_id" ] && [ "$phase_id" != "null" ]; then
    local phase_file="$SDD_BACKLOG/${phase_id}.md"
    if [ -f "$phase_file" ]; then
      # spec 행에서 '| In Progress |' → '| Merged |' (해당 spec ID 행만)
      awk -v sid="$spec_id" '
        $0 ~ sid && /\| In Progress \|/ {
          sub(/\| In Progress \|/, "| Merged |")
        }
        { print }
      ' "$phase_file" > "$phase_file.tmp" && mv "$phase_file.tmp" "$phase_file"
      ok "phase.md spec 상태 → Merged: $spec_id"
    else
      warn "phase.md 없음, 수동 갱신 필요: $phase_file"
    fi
  fi

  # NEW: 모든 spec Merged 여부 확인
  _check_phase_all_merged "$phase_id"
}

_check_phase_all_merged() {
  local phase_id="$1"
  [ -z "$phase_id" ] || [ "$phase_id" = "null" ] && return
  local phase_file="$SDD_BACKLOG/${phase_id}.md"
  [ -f "$phase_file" ] || return

  local remaining
  remaining=$(awk -F'|' '
    /<!-- sdd:specs:start -->/ { in_t=1; next }
    /<!-- sdd:specs:end -->/ { in_t=0; next }
    in_t && (/\| Backlog \|/ || /\| In Progress \|/) {
      gsub(/[[:space:]]/, "", $2)
      if ($2 != "" && $2 !~ /^-+$/ && $2 !~ /^ID$/) { print $2 }
    }
  ' "$phase_file" | wc -l | tr -d ' ')

  if [ "$remaining" -eq 0 ]; then
    echo ""
    echo "🎉 모든 Spec이 Merged 상태입니다."
    echo "   sdd phase done 을 실행하여 phase를 완료하세요."
    echo ""
  fi
}
```

### [hk-ship] `sources/commands/hk-ship.md`

#### [MODIFY] Step 6 State 업데이트 — spec-x 완료 시 queue.md 갱신 추가

```markdown
## 6. State 업데이트

...

> **[spec-x 한정] queue.md 완료 갱신**
> spec-x (`spec-x-{slug}`) 인 경우 queue.md 갱신:
> ```bash
> # specx 섹션에서 항목 제거 후 done 섹션으로 이동
> sdd specx done {slug}
> ```
```

> 참고: `sdd specx done` 명령은 본 spec에서 함께 구현한다.

### [sdd] `sdd specx done <slug>` 명령 추가

```bash
cmd_specx() {
  local sub="${1:-}"; shift || true
  case "$sub" in
    done) specx_done "$@" ;;
    *)    die "사용법: sdd specx done <slug>" ;;
  esac
}

specx_done() {
  local slug="${1:-}"
  [ -z "$slug" ] && die "사용법: sdd specx done <slug>"
  local q; q="$(state_queue_file)"
  # specx 섹션에서 해당 slug 행 제거
  sdd_marker_remove_line "$q" "specx" "$slug"
  # done 섹션에 추가
  local entry="- [x] spec-x-${slug} (완료)"
  sdd_marker_append "$q" "done" "$entry"
  ok "spec-x-${slug} → queue.md done 섹션으로 이동"
}
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-archive-completion.sh
```

테스트 케이스:
1. `sdd archive` 후 phase.md spec 상태 `In Progress` → `Merged` 자동 갱신
2. `sdd archive` 후 잔여 Backlog/In Progress 없으면 phase done 유도 메시지 출력
3. `sdd archive` 후 잔여 Backlog 있으면 유도 메시지 없음
4. `sdd specx done <slug>` → queue.md specx 섹션 제거 + done 섹션 추가

### 수동 검증 시나리오

1. spec 작업 후 `sdd archive` 실행 → `backlog/phase-08.md` spec 행 상태 확인
2. 마지막 spec 이후 `sdd archive` → "🎉 모든 Spec이 Merged" 메시지 확인
3. `sdd specx done test-slug` → queue.md 변경 확인

## 🔁 Rollback Plan

- `cmd_archive()` 추가 로직은 archive commit 이후에 실행 — commit 자체에는 영향 없음
- phase.md 갱신 실패 시 warn만 출력하고 계속 진행 (non-blocking)
- `sdd specx done` 은 신규 명령이므로 롤백 시 함수 제거만으로 원복

## 📦 Deliverables 체크

- [x] spec.md 작성
- [x] plan.md 작성 (이 파일)
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
