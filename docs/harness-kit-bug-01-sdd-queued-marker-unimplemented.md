# [Bug] `sdd:queued` marker 가 구현되지 않음 — queue.md 대기 Phase 표가 영구적으로 stale 됨

## 요약

`queue.md` 의 `📋 대기 Phase` 섹션에는 `<!-- sdd:queued:start --> ~ <!-- sdd:queued:end -->` marker 가 정의되어 있고, 파일 상단에는 "sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요" 라는 안내가 있다.

그러나 **`sdd` 바이너리에는 `sdd:queued` marker 를 읽거나 쓰는 코드가 전혀 존재하지 않는다**. 그 결과 `phase new` / `phase done` 등 어느 상태 전이에서도 queued 표가 갱신되지 않고, 한 번 쓰여진 이후 영구적으로 stale 상태로 유지된다.

## 환경

- harness-kit: **0.6.0** (`.harness-kit/installed.json`)
- macOS: Darwin 25.4.0
- bash: 3.2.57 (sdd 는 `#!/usr/bin/env bash` 로 실행)

## 재현 절차

1. `queue.md` 에 `sdd:queued` marker 영역 내부에 Phase 상태 표를 수기로 작성 (또는 과거 버전에서 쓰여진 표 유지).
   ```md
   <!-- sdd:queued:start -->
   | Phase | 제목 | 상태 |
   |---|---|---|
   | `phase-4` | [협업 Flow 정의](phase-4.md) | Active |
   | `phase-5` | [PoC 검증](phase-5.md) | Queued |
   <!-- sdd:queued:end -->
   ```
2. `sdd phase done phase-4` 실행.
3. `queue.md` 확인:
   - `sdd:active` → "(active phase 없음. ...)" 로 비워짐 ✅
   - `sdd:done` → `- **phase-4** — ... — completed YYYY-MM-DD` 추가됨 ✅
   - **`sdd:queued` → phase-4 의 상태 컬럼이 여전히 `Active`** ❌

**결과**: phase-4 는 done 섹션에 있으면서 동시에 queued 표에서는 Active 로 표시되어, 같은 문서 안에서 상호 모순되는 상태가 공존한다.

## 근본 원인 (코드 근거)

### 1. sdd 바이너리에 `queued` marker 처리 코드 0건

```bash
$ grep -n "queued" .harness-kit/bin/sdd
34:  phase done [phase-N]          phase 를 완료 처리 (queue 의 done 으로 이동)
174:          warnings="${warnings}  ℹ 모든 spec Merged — phase done 가능 여부 확인 필요\n"
196:            warnings="${warnings}  ℹ git 기준 모든 spec 머지 완료 — phase done 가능 (phase.md 상태 갱신 필요)\n"
198:            warnings="${warnings}  ℹ Active Spec 없음 — 다음 spec 시작 필요\n"
```

matching 이 있지만 모두 help 문구나 무관한 "완료 필요" 워딩이다. **실제 `sdd:queued:start/end` marker 를 읽거나 쓰는 함수가 없다.**

### 2. `queue_mark_done()` — active + done 만 갱신 (`.harness-kit/bin/sdd:570-585`)

```bash
queue_mark_done() {
  local phase_id="${1:-$(state_get phase)}"
  [ -z "$phase_id" ] || [ "$phase_id" = "null" ] && return 0
  local q="$(state_queue_file)"
  ensure_queue_file
  local title=""
  local pf="$SDD_BACKLOG/${phase_id}.md"
  if [ ! -f "$pf" ]; then
    pf="$SDD_ROOT/archive/backlog/$(basename "$pf")"
  fi
  [ -f "$pf" ] && title=$(head -1 "$pf" | sed 's|^# *phase-[0-9]*: *||')
  sdd_marker_append "$q" "done" "- **${phase_id}** — ${title:-?} — completed $(date -u +%Y-%m-%d)"
  # active 를 비움
  sdd_marker_replace "$q" "active" "(active phase 없음. \`bin/sdd phase new <slug>\` 로 시작)"
}
```

`sdd_marker_append` / `sdd_marker_replace` 호출이 **`active`, `done` 두 marker 에만** 있고, `queued` 는 누락이다.

### 3. `phase_new()` 도 마찬가지 (`.harness-kit/bin/sdd:451-517`)

```bash
phase_new() {
  ...
  ensure_queue_file
  queue_set_active "$id" "$slug"   # active marker 만 쓰고 끝
  ...
}
```

즉 Phase 생성 시에도 queued 표에 새 Phase 가 자동 등록되지 않는다.

### 4. Template 에는 marker 가 선언만 되어 있음 (`.harness-kit/agent/templates/queue.md:29-33`)

```md
## 📋 대기 Phase

<!-- sdd:queued:start -->
없음
<!-- sdd:queued:end -->
```

→ 구현은 없는데 marker 계약만 남은 **dead marker** 상태.

## 실제 피해

- `queue.md` 의 "📋 대기 Phase" 표가 Phase 전이를 반영하지 못함.
- 수기로 표를 한 번 채우면 이후 자동 갱신이 되지 않으므로, 사용자는 **문서 규약 (sdd 자동 관리) 과 실제 동작 (미구현) 의 불일치** 에 빠진다.
- AI 에이전트가 agent.md §4.3 "marker 영역은 sdd 자동 관리이므로 수기 편집 금지" 를 따르려 할수록 표가 영구적으로 낡은 상태로 남는다.
- `queue.md` 상단 안내문 ("sdd 가 마커 사이를 자동 갱신") 이 사용자/에이전트 모두에게 오해를 유발.

## 제안 수정

다음 중 **택일** 이 바람직하다.

### Option A — `sdd:queued` marker 구현 (권장)

`queue_mark_done()`, `queue_set_active()`, `phase_new()` 에서 queued 표 자동 갱신.

구체 동작:
- `sdd phase new` 시: queued 표에 신규 Phase 행 append (상태: Active 또는 Queued)
- `sdd phase done` 시: 해당 Phase 행의 상태 컬럼을 `Done` 으로 갱신
- `sdd spec new` / `sdd ship` 등 Phase 내부 진행 변화는 queued 표에 영향 없음 (필요하면 별도 논의)

제안 함수 스켈레톤:

```bash
queue_sync_queued_table() {
  local q="$(state_queue_file)"
  [ -f "$q" ] || return 0
  local active_phase="$(state_get phase)"
  [ "$active_phase" = "null" ] && active_phase=""

  # backlog/ + archive/backlog/ 의 모든 phase-*.md 스캔
  local rows=""
  rows="$rows| Phase | 제목 | 상태 |"$'\n'
  rows="$rows|---|---|---|"$'\n'

  local f id title status done_list
  done_list="$(sdd_marker_read "$q" "done")"

  for f in "$SDD_BACKLOG"/phase-*.md "$SDD_ROOT/archive/backlog"/phase-*.md; do
    [ -f "$f" ] || continue
    id="$(basename "$f" .md)"
    title=$(head -1 "$f" | sed 's|^# *phase-[0-9]*: *||')
    if echo "$done_list" | grep -q "\*\*${id}\*\*"; then
      status="Done"
    elif [ "$id" = "$active_phase" ]; then
      status="Active"
    else
      status="Queued"
    fi
    rows="$rows| \`${id}\` | [${title}](${id}.md) | ${status} |"$'\n'
  done

  sdd_marker_replace "$q" "queued" "$rows"
}
```

호출 지점:
- `phase_new()` 끝
- `queue_mark_done()` 끝
- 필요하면 `cmd_status` 에서도 한 번 강제 동기화

### Option B — marker / 안내 자체를 제거

`queue.md` template 에서 `sdd:queued` marker 를 삭제하고, 대기 Phase 표를 사용자가 수기로 관리하도록 문서 명시. 안내문도 "queued 섹션은 사람이 직접 편집" 으로 수정.

→ 구현 부담은 없으나 대시보드 정합성은 사용자 책임.

## 관찰 메모

- `phase_list` 명령 (`sdd phase list`) 은 `backlog/` + `archive/backlog/` 스캔으로 "정답" 상태를 계산할 수 있으므로, 동일 로직을 `queued` marker 자동 갱신에 재사용 가능 (Option A 의 base).
- `sdd_marker_append` / `sdd_marker_replace` 헬퍼는 이미 존재 — 새 marker 이름만 전달하면 동작할 것으로 보인다.
- 기존 프로젝트 사용자가 이미 수기로 표를 채워 놓은 케이스가 많을 수 있음. migration 경로 (기존 내용 읽어 보존 or 강제 재생성) 결정 필요.
