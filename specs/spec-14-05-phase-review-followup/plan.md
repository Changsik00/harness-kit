# Implementation Plan: spec-14-05

## 📋 Branch Strategy

- 신규 브랜치: `spec-14-05-phase-review-followup`
- 시작 지점: `main` (PR #79 머지 직후)
- 첫 task 가 브랜치 생성을 수행
- 첫 commit 에 다음 변경분 포함:
  - `backlog/queue.md` — sdd spec new active 갱신
  - `backlog/phase-14.md` — sdd 가 spec-14-05 row 자동 추가 (✅ spec-14-04 fix 효과로 수동 보정 불필요!)
  - `specs/spec-14-05-phase-review-followup/` — spec/plan/task

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **6 변경 한 PR 통합 동의** — Major 4 + Minor 2 가 모두 phase-14 의 직접 결과물 결함이라는 응집성으로 묶임. 변경 LOC ~30줄. 거부 시 spec 분리 (spec-14-05 marker, spec-14-06 install.sh + 헤더, spec-14-07 phase.md 정규화) 필요.
> - [ ] **m1 정확 토큰 매칭 방식**: `spec_new` 호출 측에서 needle 을 `\`${short_id}\`` (백틱 포함) 으로 변경 — `sdd_marker_grep` 자체는 변경 없음. 마커 row 의 ID 필드가 항상 백틱 포함인 점에 의존.

> [!WARNING]
> - [ ] M1 awk 변경은 `sdd_marker_append` 의 4 호출 지점 모두 영향. 정상 케이스 보존을 회귀 테스트로 확인.
> - [ ] M3 헤더 주석 갱신은 8 파일 — sources/ (4) + .harness-kit/ (4). install 시 sources → .harness-kit 복사 구조이므로 두 영역 동시 갱신 필요.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **`sdd_marker_append` awk** | `in_section` 게이트 + 첫 end 마커 직후 `found` reset | 다중 마커 쌍 안전. 단일 쌍 케이스 동작 동일 |
| **`sdd_marker_append` 마커 부재** | `grep -q "<!-- sdd:${name}:start -->"` 사전 체크 → stderr warn + rc=1 | 호출자가 실패 신호 받도록. silent 회피 |
| **헤더 주석 (M3)** | 일괄 sed 또는 명시적 Edit — 모든 "bash 4.0+" 를 "bash 3.2+" 로 | 정책-코드 일치 |
| **install.sh sed (M4)** | `sed -i.tmp ... && rm -f ... \|\| die "..."` 패턴 | bash compound 함정 회피 |
| **m1 정확 토큰 매칭** | `spec_new` 의 needle 을 백틱 포함으로 변경 | 헬퍼 변경 없이 호출자만 — 최소 침습 |
| **m2 phase-14.md 정규화** | 4 row 를 sdd auto-gen 양식 (백틱) 으로 수동 정규화 | 일회성 cleanup |

## 📂 Proposed Changes

### M1: sdd_marker_append awk 보강

#### [MODIFY] `sources/bin/lib/common.sh:80-99`

```diff
 sdd_marker_append() {
   local file="$1" name="$2" line="$3"
   [ -f "$file" ] || die "파일 없음: $file"
   local start="<!-- sdd:${name}:start -->"
   local end="<!-- sdd:${name}:end -->"
+  if ! grep -q "^${start}$" "$file" || ! grep -q "^${end}$" "$file"; then
+    warn "마커 영역 부재 ($name) — append 생략: $file" >&2
+    return 1
+  fi
   awk -v s="$start" -v e="$end" -v ln="$line" '
     BEGIN { in_section = 0; found = 0 }
-    $0 == s { in_section = 1; print; next }
+    $0 == s && !in_section { in_section = 1; found = 0; print; next }
     $0 == e {
-      in_section = 0
-      if (!found) print ln
+      if (in_section && !found) print ln
+      in_section = 0
+      found = 0
       print; next
     }
     in_section && $0 == ln { found = 1 }
     { print }
   ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
 }
```

> **불변량**: 각 마커 쌍 영역마다 line 이 정확히 1 회 (이미 있으면 skip). 마커 부재 시 즉시 rc=1 + stderr.

### M3: 헤더 주석 일괄 갱신 (8 파일)

#### [MODIFY] 다음 파일들의 헤더 주석에서 "bash 4.0+" → "bash 3.2+":

- `sources/bin/lib/common.sh:3`
- `sources/bin/bb-pr:4`
- `sources/bin/sdd:5`
- `sources/hooks/_lib.sh:19`
- `install.sh:24`
- `.harness-kit/bin/lib/common.sh:3` (도그푸딩)
- `.harness-kit/bin/bb-pr:4` (도그푸딩)
- `.harness-kit/bin/sdd:5` (도그푸딩)
- `.harness-kit/hooks/_lib.sh:19` (도그푸딩)

> 정확한 표현은 각 파일의 실제 문맥에 맞춰 결정 (Task 단계). "bash 4.0+ 전용" 표현은 모두 "bash 3.2+ 호환" 으로.

### M4: install.sh sed 견고화

#### [MODIFY] `install.sh:419, 422`

```diff
   if [ $HK_GITIGNORE -eq 1 ]; then
-    sed -i.tmp 's|^!\.harness-kit/$|.harness-kit/|' "$GI" && rm -f "${GI}.tmp"
+    sed -i.tmp 's|^!\.harness-kit/$|.harness-kit/|' "$GI" || die "sed 실패: $GI"
+    rm -f "${GI}.tmp"
     _hk_pat='^\.harness-kit/$';   _hk_line='.harness-kit/'
   else
-    sed -i.tmp 's|^\.harness-kit/$|!.harness-kit/|' "$GI" && rm -f "${GI}.tmp"
+    sed -i.tmp 's|^\.harness-kit/$|!.harness-kit/|' "$GI" || die "sed 실패: $GI"
+    rm -f "${GI}.tmp"
     _hk_pat='^!\.harness-kit/$';  _hk_line='!.harness-kit/'
   fi
```

> `die` 가 install.sh 안에서 정의되어 있는지 확인 → 없으면 inline `{ echo "..." >&2; exit 1; }` 패턴.

### m1: spec_new 정확 토큰 매칭

#### [MODIFY] `sources/bin/sdd:744-750`

```diff
-  local row="| \`${short_id}\` | ${slug} | P? | Active | \`specs/${id}/\` |"
-  if sdd_marker_grep "$phase_file" "specs" "${short_id}"; then
+  local row="| \`${short_id}\` | ${slug} | P? | Active | \`specs/${id}/\` |"
+  if sdd_marker_grep "$phase_file" "specs" "\`${short_id}\`"; then
     local updated_row="| \`${short_id}\` | ${slug} | P? | Active | \`specs/${id}/\` |"
     sdd_marker_update_row "$phase_file" "specs" "${short_id}" "$updated_row"
   else
     sdd_marker_append "$phase_file" "specs" "$row"
   fi
```

> 백틱 포함 매칭으로 `spec-14-01` 검색이 `spec-14-011` 또는 본문 텍스트 `spec-14-01 — sdd-queued-marker` 와 일치 안 함. 마커 row 형식이 *반드시* 백틱 포함이어야 한다는 가정 — sdd auto-gen 이 그렇게 출력하므로 안전.

### m2: phase-14.md row 정규화

#### [MODIFY] `backlog/phase-14.md`

수동 보정된 4 row 를 sdd auto-gen 양식 (`| \`spec-14-XX\` | slug | P? | Status | \`specs/...\` |`) 으로 정규화. spec-14-05 row 가 이미 새 양식이므로 다른 4 row 만 갱신.

```diff
 <!-- sdd:specs:start -->
 | ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
 |---|---|:---:|---|---|
-| spec-14-01 | sdd-queued-marker | P1 | Merged | `specs/spec-14-01-sdd-queued-marker/` |
-| spec-14-02 | doctor-bash-version | P1 | Merged | `specs/spec-14-02-doctor-bash-version/` |
-| spec-14-03 | gitignore-idempotent | P1 | Merged | `specs/spec-14-03-gitignore-idempotent/` |
-| spec-14-04 | marker-append-guard | P1 | Merged | `specs/spec-14-04-marker-append-guard/` |
+| `spec-14-01` | sdd-queued-marker | P1 | Merged | `specs/spec-14-01-sdd-queued-marker/` |
+| `spec-14-02` | doctor-bash-version | P1 | Merged | `specs/spec-14-02-doctor-bash-version/` |
+| `spec-14-03` | gitignore-idempotent | P1 | Merged | `specs/spec-14-03-gitignore-idempotent/` |
+| `spec-14-04` | marker-append-guard | P1 | Merged | `specs/spec-14-04-marker-append-guard/` |
 | `spec-14-05` | phase-review-followup | P? | Active | `specs/spec-14-05-phase-review-followup/` |
 <!-- sdd:specs:end -->
```

### 도그푸딩 동기화

`.harness-kit/bin/lib/common.sh` 와 `.harness-kit/bin/sdd` 도 sources 와 같이 갱신.

### 회귀 테스트

#### [NEW] `tests/test-marker-edge-cases.sh`

| ID | 시나리오 | 검증 |
|---|---|---|
| A-1 | 다중 마커 쌍 (test:start ~ end 2 쌍) + 같은 라인 두 번 append | 각 영역마다 1줄 (총 2줄) |
| A-2 | 다중 마커 쌍 + 다른 라인 추가 | 각 영역에 정상 추가 |
| B   | 마커 부재 파일 + append | rc=1 + stderr 메시지 |
| C-1 | 마커 안 `\`spec-14-011\`` 만 있고 phase 본문에 `spec-14-01` 텍스트 → grep `\`spec-14-01\`` | false (rc=1) |
| C-2 | 마커 안 `\`spec-14-01\`` 있을 때 grep `\`spec-14-01\`` | true (rc=0) |

#### [NEW] `tests/test-bash-policy-headers.sh`

| 검증 | 경로 |
|---|---|
| "bash 4.0+" 표현 0 매치 | `sources/`, `install.sh`, `.harness-kit/` (단, `.harness-kit/agent/templates/` 제외 — 사용자 산출물 영역) |

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-marker-edge-cases.sh
bash tests/test-bash-policy-headers.sh
```

회귀 점검 (phase-14 4 spec + sdd 핵심):
```bash
bash tests/test-sdd-queued-marker-removed.sh    # spec-14-01
bash tests/test-doctor-bash-version.sh          # spec-14-02
bash tests/test-gitignore-idempotent.sh         # spec-14-03
bash tests/test-marker-append-guard.sh          # spec-14-04
bash tests/test-sdd-queue-redesign.sh
bash tests/test-sdd-phase-done-accuracy.sh
bash tests/test-sdd-spec-completeness.sh
bash tests/test-sdd-status-cross-check.sh
```

### 통합 테스트

`Integration Test Required = no` — 별도 통합 테스트 없음.

### 수동 검증 시나리오

1. `grep -rn "bash 4\.0+" sources/ install.sh .harness-kit/` → 0 매치 (M3)
2. `bash .harness-kit/bin/sdd doctor` 정상 (회귀 — spec-14-02 효과 유지)
3. `bash install.sh --yes` 정상 동작 + `.gitignore` 라인별 1회 (회귀 — spec-14-03)

## 🔁 Rollback Plan

- 6 변경 모두 작은 수술 (≈30 LOC). `git revert <merge-commit>` 즉시 복원.
- M1 awk 변경이 만에 하나 회귀 트리거하면 phase-14 의 다른 spec 머지 결과는 영향 없음 (해당 회귀 테스트 PASS 상태).

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
