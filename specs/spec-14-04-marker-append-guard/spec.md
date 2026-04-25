# spec-14-04: sdd 마커 정합성 — append 멱등 가드 + 영역 한정 grep

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-14-04` |
| **Phase** | `phase-14` |
| **Branch** | `spec-14-04-marker-append-guard` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-25 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

#### 버그 #1 — `sdd_marker_append()` 멱등 가드 부재

`sources/bin/lib/common.sh:80`:

```bash
sdd_marker_append() {
  local file="$1" name="$2" line="$3"
  awk -v s="$start" -v e="$end" -v ln="$line" '
    $0 == e { print ln; print; next }
    { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}
```

→ 같은 라인을 두 번 호출하면 그대로 두 번 들어감. 호출자 4 곳 모두 잠재 중복 위험:
- `sdd:582` `queue_mark_done` (done 섹션 — 같은 phase 두 번 done 시)
- `sdd:749` `spec_new` (specs 표 행 — fallback)
- `sdd:1180` `specx_new` (specx 섹션 — 같은 slug 두 번)
- `sdd:1214` `specx_done` (done 섹션 — `sdd specx done <slug>` 두 번)

특히 `sdd specx done` 두 번 호출 시나리오는 사용자가 실수로 재실행하면 즉시 중복 발생 — bug-01 보고서가 인용한 본 phase 의 핵심 동기.

#### 버그 #2 — `spec_new()` 의 grep 영역 미한정

`sources/bin/sdd:745`:

```bash
if grep -q "${short_id}" "$phase_file" 2>/dev/null; then
  sdd_marker_update_row ...    # 마커 안에 있으면 갱신
else
  sdd_marker_append ...         # 없으면 추가
fi
```

→ `grep -q "spec-14-04" backlog/phase-14.md` 가 **파일 전체** 를 검색. phase-14.md 본문(설명 섹션)에 "### spec-14-04 — marker-append-guard" 텍스트가 있으므로 매치됨. **마커 영역 내부에는 행이 없음에도** `sdd_marker_update_row` 가 호출되어 no-op (update_row 는 마커 안에서 needle 매치 시만 갱신).

**결과**: `sdd spec new marker-append-guard` 가 "✓ phase 파일 spec 표 자동 갱신" 메시지를 출력했지만, 실제 phase-14.md 의 sdd:specs 마커는 그대로 비어있음 — 본 phase 진행 중 spec-14-02, 03, 04 시작 시 매번 수동 보정 필요했던 직접 원인.

### 문제점

두 버그 모두 sdd 의 *마커 정합성* 약화. 사용자/에이전트가 "마커는 sdd 가 자동 관리" 라고 믿게 만들면서 실제로는:
1. 같은 라인을 두 번 등록 가능 (#1)
2. spec 행이 phase 마커에 영영 추가 안 됨 (#2)

→ phase 진행 중 매번 수동 보정 → 자동화 가치 무력화.

### 해결 방안 (요약)

**버그 #1 — `sdd_marker_append` 동일 라인 중복 가드**:

awk 에서 마커 영역을 추적하다가, end 마커 도달 직전 동일 라인이 *이미* 영역 내부에 있으면 append 생략.

```awk
BEGIN { in_section=0; found=0 }
$0 == s { in_section=1; print; next }
$0 == e {
  in_section=0
  if (!found) print ln
  print; next
}
in_section && $0 == ln { found=1 }
{ print }
```

**버그 #2 — `spec_new` 의 검색 영역 한정**:

신규 헬퍼 `sdd_marker_grep(file, name, needle)` 도입 — 마커 *내부* 에서만 needle 검색. `spec_new` 의 grep -q 를 이 헬퍼로 교체.

## 🎯 요구사항

### Functional Requirements

1. `sdd_marker_append()` 에 in-marker 동일 라인 중복 가드 추가. 4 호출 지점 코드 변경 불필요.
2. `sdd_marker_grep()` 신규 함수 추가 — 마커 영역 내부에서 needle 검색 (exit 0 / 1 반환).
3. `spec_new()` 의 `grep -q "${short_id}" "$phase_file"` 를 `sdd_marker_grep "$phase_file" "specs" "${short_id}"` 로 교체.
4. `.harness-kit/bin/sdd` 와 `.harness-kit/bin/lib/common.sh` 도그푸딩 동기화.
5. 회귀 테스트 추가 — `tests/test-marker-append-guard.sh`:
   - **A**: `sdd_marker_append` 직접 호출 — 같은 라인 두 번 → 1줄 (단위 테스트, lib 직접 호출)
   - **B**: `sdd specx done <slug>` 두 번 → done 섹션에 해당 라인 1줄
   - **C**: `sdd phase done` 동일 phase 두 번 → done 섹션에 해당 라인 1줄
   - **D**: phase-N.md 본문에 "spec-N-NN" 텍스트 미리 적힌 상태에서 `sdd spec new` → 마커에 행 정확히 1줄 추가 (spec-14-04 의 정확한 회귀 케이스)

### Non-Functional Requirements

1. **호환성**: 기존 4 호출 지점 동작은 정상 케이스에서 변화 없음 — 이미 멱등인 호출 (예: 다른 라인 추가) 영향 없음.
2. **bash 3.2 호환** (spec-14-02 정책): awk + 순수 bash 만 사용.
3. **마커 영역 추적의 단일 패턴**: `sdd_marker_append`, `sdd_marker_replace`, `sdd_marker_update_row`, `sdd_marker_grep` 모두 같은 awk 컨벤션 (start/end 비교, in_section 플래그) 으로 일관.

## 🚫 Out of Scope

- `sdd_marker_replace`, `sdd_marker_update_row` 의 별도 멱등 가드 — 이미 idempotent (replace 는 통째 교체, update_row 는 매치 못하면 no-op).
- `spec_new` 자체의 다른 로직 (Backlog → Active 전환, P? 프라이오리티 기본값 등) — 본 spec 은 grep 범위만.
- `specx_new` / `specx_done` 의 행 형식 자체 변경 — 가드는 함수 레벨에서 동작.
- phase-14.md 본문의 "spec-14-04 — ..." 형태 자체 변경 — 본문 텍스트가 grep 매치되는 *원인 회피* 가 아닌, grep *결과* 를 마커 안으로 한정하는 방향으로 해결.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = no 이므로 해당 사항 없음)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-14-04-marker-append-guard` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
