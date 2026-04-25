# Implementation Plan: spec-14-04

## 📋 Branch Strategy

- 신규 브랜치: `spec-14-04-marker-append-guard`
- 시작 지점: `main` (PR #78 머지 직후)
- 첫 task 가 브랜치 생성을 수행
- 첫 commit 에 다음 변경분 포함:
  - `backlog/queue.md` — sdd spec new 결과 active 갱신
  - `backlog/phase-14.md` — sdd:specs 마커에 spec-14-04 행 수동 추가 (sdd 가 sync 못함 — 본 spec 이 근본 수정하는 버그의 직접 결과)
  - `specs/spec-14-04-marker-append-guard/` — spec/plan/task

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **Scope 확장 동의**: 원래 plan 은 `sdd_marker_append` 멱등 가드만이었으나, 본 spec 진행 중 `spec_new` 의 grep 범위 미한정 버그를 발견 — phase-14.md sync 누락의 직접 원인. 같은 종류 (마커 정합성) 이므로 본 spec 에 통합. 추가 LOC ≈ 15줄 (helper 1개 + 호출 1줄).

> [!WARNING]
> - [ ] `sdd_marker_append` 의 awk 변경은 **모든 호출자에 영향**. 4 호출 지점 (`queue_mark_done`, `spec_new`, `specx_new`, `specx_done`) 의 의도가 모두 "유일한 라인 추가" 이므로 회귀 위험 낮으나, 회귀 테스트로 정상 케이스 (다른 라인 추가) 동작 확인 필요.

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
[변경 전]                                    [변경 후]
sdd_marker_append → 무조건 append            sdd_marker_append → in-marker 동일 라인 검사 후 append
spec_new          → grep 파일 전체           spec_new          → sdd_marker_grep (마커 내부)
                                              sdd_marker_grep   → 신규 헬퍼
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **`sdd_marker_append`** | awk 한 패스로 in-marker 추적 + 동일 라인 발견 시 append skip | 별도 grep 호출 회피 (한 번의 awk 로 처리) |
| **`sdd_marker_grep`** | 신규 헬퍼 — `sdd_marker_replace` 와 동일 awk 컨벤션 | 마커 내 검색 표준화 — 향후 다른 곳에서도 재사용 |
| **`spec_new`** | grep -q → sdd_marker_grep 으로 1 줄 교체 | 가장 작은 수술 |
| **호출자 4 곳** | 코드 변경 없음 | 가드는 함수 레벨에서 — 호출자는 그대로 |
| **회귀 테스트 단위** | A: lib 직접 호출 (단위) / B-D: sdd CLI (통합) | 가드 로직은 lib 단위, 사용자 시나리오는 CLI 통합 |

## 📂 Proposed Changes

### sdd_marker_append 멱등 가드

#### [MODIFY] `sources/bin/lib/common.sh:80-89`

```diff
 sdd_marker_append() {
   local file="$1" name="$2" line="$3"
   [ -f "$file" ] || die "파일 없음: $file"
   local start="<!-- sdd:${name}:start -->"
   local end="<!-- sdd:${name}:end -->"
   awk -v s="$start" -v e="$end" -v ln="$line" '
-    $0 == e { print ln; print; next }
+    BEGIN { in_section = 0; found = 0 }
+    $0 == s { in_section = 1; print; next }
+    $0 == e {
+      in_section = 0
+      if (!found) print ln
+      print; next
+    }
+    in_section && $0 == ln { found = 1 }
     { print }
   ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
 }
```

> **불변량**: 호출 후 마커 영역에 `line` 이 정확히 ≥ 1 회. 이미 ≥ 1 회 있으면 변화 없음.

### sdd_marker_grep 신규 헬퍼

#### [NEW] `sources/bin/lib/common.sh` 함수 추가 (sdd_marker_update_row 다음)

```bash
# 마커 영역 내부에서 needle 검색 — exit 0 (찾음) / 1 (못찾음)
sdd_marker_grep() {
  local file="$1" name="$2" needle="$3"
  [ -f "$file" ] || return 1
  local start="<!-- sdd:${name}:start -->"
  local end="<!-- sdd:${name}:end -->"
  awk -v s="$start" -v e="$end" -v n="$needle" '
    BEGIN { in_section = 0; found = 0 }
    $0 == s { in_section = 1; next }
    $0 == e { in_section = 0; next }
    in_section && index($0, n) > 0 { found = 1 }
    END { exit (found ? 0 : 1) }
  ' "$file"
}
```

### spec_new 검색 영역 한정

#### [MODIFY] `sources/bin/sdd:744-750`

```diff
   local row="| \`${short_id}\` | ${slug} | P? | Active | \`specs/${id}/\` |"
-  if grep -q "${short_id}" "$phase_file" 2>/dev/null; then
+  if sdd_marker_grep "$phase_file" "specs" "${short_id}"; then
     local updated_row="| \`${short_id}\` | ${slug} | P? | Active | \`specs/${id}/\` |"
     sdd_marker_update_row "$phase_file" "specs" "${short_id}" "$updated_row"
   else
     sdd_marker_append "$phase_file" "specs" "$row"
   fi
```

### 도그푸딩 동기화

#### [MODIFY] `.harness-kit/bin/lib/common.sh`

`sources/bin/lib/common.sh` 와 동일 변경.

#### [MODIFY] `.harness-kit/bin/sdd`

`sources/bin/sdd` 와 동일 변경.

### 회귀 테스트

#### [NEW] `tests/test-marker-append-guard.sh`

| ID | 시나리오 | 검증 |
|---|---|---|
| A-1 | `sdd_marker_append` 같은 라인 두 번 | 마커 안에 1 회 |
| A-2 | `sdd_marker_append` 다른 라인 두 번 | 두 라인 모두 존재 (정상 동작 회귀 점검) |
| B   | `sdd specx done <slug>` 두 번 | done 섹션에 해당 라인 1 회 |
| C   | `sdd phase done <id>` 두 번 | done 섹션에 해당 라인 1 회 |
| D   | phase-N.md 본문에 spec ID 텍스트 + sdd spec new | sdd:specs 마커 안에 행 정확히 1 회 추가 |

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-marker-append-guard.sh
```

회귀 점검:
```bash
bash tests/test-sdd-queue-redesign.sh
bash tests/test-sdd-status-cross-check.sh
bash tests/test-sdd-phase-done-accuracy.sh
bash tests/test-sdd-spec-completeness.sh
bash tests/test-sdd-queued-marker-removed.sh   # spec-14-01
bash tests/test-doctor-bash-version.sh         # spec-14-02
bash tests/test-gitignore-idempotent.sh        # spec-14-03
```

### 통합 테스트

`Integration Test Required = no` — 별도 통합 테스트 없음. 단, 본 spec 의 *효과* 는 본 phase 의 통합 시나리오 4 (sdd specx done 멱등) 와 정확히 일치.

### 수동 검증 시나리오

1. 본 프로젝트에서 `sdd specx done <slug>` 두 번 호출 → queue.md done 섹션 1줄 확인.
2. 본 프로젝트에서 `sdd spec new <slug>` 후 phase-N.md 의 sdd:specs 마커에 새 행이 자동 추가되는지 확인.

## 🔁 Rollback Plan

- `common.sh` 의 함수 한 개 추가 + 한 개 본문 변경 + sdd 한 줄 변경. `git revert <merge-commit>` 즉시 복원.
- 회귀 위험은 정상 케이스 동작 (다른 라인 추가) 에서 영향 없음 — 신규 가드는 *동일 라인 부재* 시 기존 동작과 동일.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
