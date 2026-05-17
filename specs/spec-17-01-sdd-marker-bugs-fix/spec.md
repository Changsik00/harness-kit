# spec-17-01: sdd CLI marker 버그 3 종 fix

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-17-01` |
| **Phase** | `phase-17` |
| **Branch** | `spec-17-01-sdd-marker-bugs-fix` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | yes |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황 (3 버그 root cause)

**Bug #1 — `cmd_spec_new` (sources/bin/sdd:1170)**

```bash
local row="| \`${short_id}\` | ${slug} | P? | Active | \`specs/${id}/\` |"
if sdd_marker_grep "$phase_file" "specs" "\`${short_id}\`"; then
  ... update ...
else
  sdd_marker_append "$phase_file" "specs" "$row"
fi
```

`sdd_marker_grep` 가 `` `${short_id}` `` (backtick) 만 검색. 그러나 phase-N.md 의 *수동 작성* Backlog 행 ID 는 *plain text* (예: `| spec-17-01 | ...`). 매칭 실패 → append. 결과: Backlog 행 + Active 행 중복.

**Bug #2 — `cmd_ship` (sources/bin/sdd:1433-1440)**

```bash
awk -v sid="$spec_id" '
  index($0, sid) && (/\| In Progress \|/ || /\| Active \|/ || /\| Done \|/) {
    sub(/\| In Progress \|/, "| Merged |")
    ...
  }
'
```

`spec_id` 가 full slug 포함 (예: `spec-17-01-sdd-marker-bugs-fix`). Backlog 행은 short id 만 (`spec-17-01`) — full slug 미포함 → `index($0, sid)` 0. Active 행만 Merged 로 변경, Backlog 행은 잔류.

**Bug #3 — `queue_mark_done` (sources/bin/sdd:993)**

```bash
queue_mark_done() {
  local phase_id="${1:-$(state_get phase)}"
  ...
  local pf="$SDD_BACKLOG/${phase_id}.md"
  ...
  [ -f "$pf" ] && title=$(head -1 "$pf" | sed ...)
  sdd_marker_append "$q" "done" "- **${phase_id}** — ${title:-?} — completed ..."
}
```

사용자가 `sdd phase done 16` (prefix 없이) 호출 시 `phase_id = "16"`. 경로 `backlog/16.md` 잘못 → 파일 없음 → title 빈문자. 출력: `- **16** — ? — completed`. 다른 phase 의 `**phase-N** — 제목 — completed` 형식과 불일치.

### 문제점

- **RCA-001 invariant 위반의 직접 원인** — phase-16 내내 4 회 재발, 매번 수동 dedupe commit 필요.
- **본 spec-17-01 spec 생성 시점에도 재현** — phase-17.md 의 spec-17-01 행이 *지금 중복* (sdd spec new 가 방금 append). meta dogfood 상황 — 본 spec 의 *Pre-flight Task 1-2* 에서 다시 수동 dedupe 필요.
- reliability layer phase 가 자기 RCA prevention 을 못 지키는 self-credibility 손상.

### 해결 방안 (요약)

3 함수 각각 다음 fix:

1. **`cmd_spec_new`**: marker 매칭을 *backtick OR plain text* 둘 다 인식하도록 확장. 발견 시 in-place update (status → Active, format → backtick + full path).
2. **`cmd_ship`**: Active/In Progress/Done 행을 Merged 로 변경 + *동일 short_id 의 Backlog 행 제거* (한 spec = 한 행).
3. **`queue_mark_done`**: `phase_id` 진입부에서 `phase-` prefix 없으면 자동 추가 (normalize).

TDD: fixture phase 만들어 멱등 테스트 RED → fix GREEN → install 미러 sync → 통합 시나리오 (phase-17.md 시나리오 1).

## 🎯 요구사항

### Functional Requirements

1. **`cmd_spec_new` fix** — `sdd_marker_grep` 호출에 *backtick OR plain* 패턴 매칭. 발견 시 `sdd_marker_update_row` 로 Backlog → Active 변경 + format 통일 (backtick + 전체 경로).
2. **`cmd_ship` fix** — Active/In Progress/Done → Merged 변경 후, 동일 short_id (예: `spec-17-01`) 의 plain text Backlog 행을 *삭제*. awk 로 단일 패스 처리.
3. **`queue_mark_done` fix** — function 진입부에서 `phase_id` 가 `phase-` prefix 부재 시 자동 추가:
   ```bash
   case "$phase_id" in
     phase-*) ;;
     *) phase_id="phase-$phase_id" ;;
   esac
   ```
4. **단위 테스트** — `tests/test-sdd-marker-idempotent.sh` 신규. 3 시나리오:
   - spec new 후 spec new (동일 slug) → 행 수 변동 0 (이미 존재 시 거부 OR 멱등)
   - 임시 phase fixture 에 spec new + ship 반복 → spec 표 행 수 1 (Backlog 제거됨)
   - phase done `16` / `phase-16` 둘 다 → 출력 형식 동일 (`**phase-N** — 제목`)
5. **install 미러 동기화** — `sources/bin/sdd` ↔ `.harness-kit/bin/sdd` diff 없음.
6. **회귀 방지** — `tests/test-drift-stale-adr.sh` (spec-16-03) 도 PASS 유지.

### Non-Functional Requirements

1. **bash 3.2+ 호환** — 모든 패치 코드.
2. **backward compatibility** — 기존 phase 파일 (phase-08 ~ 16) 의 *이미 작성된* 행 형식 (`| \`spec-N-NN\` | ... | Merged | ...`) 영향 없음.
3. **fixture 격리** — 테스트 fixture (임시 phase / spec) 는 trap cleanup 으로 격리.

## 🚫 Out of Scope

- **marker helper 함수 (`sdd_marker_grep`, `sdd_marker_append`, `sdd_marker_update_row`) 자체 리팩토링** — 호출 측 3 함수만 fix.
- **`phase_done` 의 archive fallback path** — `if [ ! -f "$pf" ]; then pf="archive/backlog/..."; fi` 부분은 그대로. archive 경로의 phase done 시나리오는 본 spec 범위 밖.
- **`phase_activate` 의 base branch 자동 생성** — phase-17 활성화 시 수동 `git checkout -b` 필요했던 이슈. 별 spec 또는 spec-17-03 에서 검토.
- **plain text Backlog 행 → backtick 형식 전체 마이그레이션 도구** — 본 spec 의 fix 가 *자연스럽게* 새 작성 spec 의 행을 backtick 형식으로 만듦. 기존 phase 의 backfill 은 별도.

## ✅ Definition of Done

- [ ] `cmd_spec_new` / `cmd_ship` / `queue_mark_done` 3 함수 fix (sources/bin/sdd)
- [ ] `.harness-kit/bin/sdd` 동기화 (diff 빈 출력 + chmod +x 보존)
- [ ] `tests/test-sdd-marker-idempotent.sh` 신규 작성 — 3 시나리오 PASS
- [ ] `tests/test-drift-stale-adr.sh` 회귀 없음 (3/3 PASS 유지)
- [ ] phase-17.md 의 *본 spec 자체 중복 행* 도 fix 적용 후 자동 정리 시연 (또는 수동 정리 — fix 가 신규 동작에만 적용되므로)
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] `spec-17-01-sdd-marker-bugs-fix` 브랜치 push 완료 + PR 생성 (target: `phase-17-coherence-fix`)
