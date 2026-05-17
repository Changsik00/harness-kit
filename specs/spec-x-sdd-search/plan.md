# Implementation Plan: spec-x-sdd-search

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-sdd-search` (브랜치 이름 = spec 디렉토리 이름)
- 시작 지점: `main` (clean)
- 첫 task 가 브랜치 생성 수행

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] CLI 명 `sdd search` 확정 (대안: `sdd grep`, `sdd find` — `search` 가 가장 user-facing)
> - [ ] scope 명 5종 (`active` / `archive` / `decisions` / `rca` / `backlog`) — 추후 추가 가능

> [!WARNING]
> - [ ] 슬래시 커맨드 (`/hk-search`) **미생성** — CLI 만으로 충분하다는 판단. 사용자가 다르게 보면 본 PR 안에 한 줄 추가 가능

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
사용자  →  sdd search <keyword> [--scope] [--ignore-case]
                │
                ├─ scope 별 디렉토리 결정 (case 분기)
                ├─ find ... -name '*.md' | xargs grep -nE [-i] <keyword>
                ├─ 카테고리별 헤더 + 출력 그룹화
                └─ 전체 0 건이면 exit 1
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **검색 엔진** | `grep -nE` (extended regex) | bash 기본. 일관된 정규식 문법 |
| **파일 수집** | `find <dir> -name '*.md'` per scope | 깊이 무제한. globstar (`**`) 의존 회피 (bash 3.2) |
| **카테고리 그룹** | scope 별 함수 호출 → 헤더 + 결과 묶음 | 출력 가독성. 0 건은 헤더 생략 |
| **컬러 처리** | `[ -t 1 ]` 일 때만 ANSI | pipe / 리다이렉트 시 plain |
| **slash 커맨드 미생성** | CLI 만 | 사용 빈도 낮음 + agent.md §6.4 단일명령 원칙 부합 |
| **`xargs` vs find -exec** | `grep -l ... $(find ...)` 또는 `find ... -exec grep` | 인자 폭발 회피 + 파일명에 공백 가능성 낮음 (모두 spec dir 규약) → `find -exec` 채택 |

### 📑 ADR 후보

- [x] 없음 — grep wrapper.

## 📂 Proposed Changes

### CLI (sdd)

#### [MODIFY] `sources/bin/sdd`

1. **도움말 헤더 추가** (`cmd_help` 의 명령 목록):

```
  search <keyword> [--scope=<s>] [--ignore-case]
                                마크다운 자산 통합 검색 (active/archive/decisions/rca/backlog/all)
```

2. **dispatcher**: `case` 분기 (`cmd_main` 또는 main case) 에 `search) cmd_search "$@" ;;` 추가.

3. **`cmd_search` 함수** 신설 (sdd 끝부분 또는 cmd 그룹에 추가):

```bash
cmd_search() {
  local keyword="" scope="all" ic=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --scope=*) scope="${1#--scope=}"; shift ;;
      --ignore-case|-i) ic="-i"; shift ;;
      --*) die "알 수 없는 옵션: $1" ;;
      *) [ -z "$keyword" ] && keyword="$1" || die "키워드는 하나만 허용"; shift ;;
    esac
  done
  [ -z "$keyword" ] && die "사용법: sdd search <keyword> [--scope=<s>] [--ignore-case]"
  # scope 검증
  case "$scope" in all|active|archive|decisions|rca|backlog) ;; *) die "잘못된 scope: $scope" ;; esac
  _search_dispatch "$keyword" "$scope" "$ic"
}

_search_dispatch() {
  local kw="$1" sc="$2" ic="$3"
  local total=0 hits
  if [ "$sc" = "all" ] || [ "$sc" = "active" ]; then
    hits=$(_search_in "specs" "*.md" "$kw" "$ic") && _print_group "active" "$hits" && total=$((total + $(echo "$hits" | grep -c '^') ))
  fi
  if [ "$sc" = "all" ] || [ "$sc" = "archive" ]; then
    hits=$(_search_in "archive/specs archive/backlog" "*.md" "$kw" "$ic") && _print_group "archive" "$hits" && total=$((total + $(echo "$hits" | grep -c '^') ))
  fi
  if [ "$sc" = "all" ] || [ "$sc" = "decisions" ]; then
    hits=$(_search_in "docs/decisions" "*.md" "$kw" "$ic") && _print_group "decisions" "$hits" && total=$((total + $(echo "$hits" | grep -c '^') ))
  fi
  if [ "$sc" = "all" ] || [ "$sc" = "rca" ]; then
    hits=$(_search_in "docs/rca" "*.md" "$kw" "$ic") && _print_group "rca" "$hits" && total=$((total + $(echo "$hits" | grep -c '^') ))
  fi
  if [ "$sc" = "all" ] || [ "$sc" = "backlog" ]; then
    hits=$(_search_in "backlog" "*.md" "$kw" "$ic") && _print_group "backlog" "$hits" && total=$((total + $(echo "$hits" | grep -c '^') ))
  fi
  if [ "$total" -eq 0 ]; then
    echo "검색 결과 없음 (keyword=$kw, scope=$sc)"
    return 1
  fi
  return 0
}

_search_in() {
  local dirs="$1" pat="$2" kw="$3" ic="$4"
  local d found=0
  for d in $dirs; do
    [ -d "$SDD_ROOT/$d" ] || continue
    # find + grep — 디렉토리 없으면 silent skip
    find "$SDD_ROOT/$d" -type f -name "$pat" -exec grep -nE $ic -- "$kw" {} + 2>/dev/null && found=1
  done
  [ "$found" -eq 1 ]
}

_print_group() {
  local title="$1" hits="$2" count
  count=$(echo "$hits" | grep -c '^')
  [ "$count" -eq 0 ] && return
  echo ""
  echo "▶ $title ($count hits)"
  # SDD_ROOT prefix 제거해 상대경로 출력
  echo "$hits" | sed "s|^$SDD_ROOT/||"
}
```

> 위 의사코드는 plan 단계 — 실제 구현은 task 3 에서 다듬는다. 핵심: `find ... -exec grep` + scope 별 dispatch.

#### [NEW] `tests/test-sdd-search.sh`

fixture 기반 5+ 시나리오:

| ID | 시나리오 | 기대 |
|---|---|---|
| T1 | `sdd search foo` (전체 scope, 매치 1건 in `archive/specs/`) | exit 0, `▶ archive (1 hits)` 출력 |
| T2 | `sdd search nomatch` | exit 1, `검색 결과 없음` 출력 |
| T3 | `sdd search --scope=decisions foo` (decisions 에만 매치) | exit 0, decisions 그룹만 출력, 다른 그룹 헤더 없음 |
| T4 | `sdd search FOO --ignore-case` (소문자 매치 존재) | 매치 |
| T5 | `sdd search "foo|bar"` (regex) | 매치 |
| T6 | `sdd search` (인자 없음) | die — 사용법 출력 |
| T7 | `sdd search foo --scope=invalid` | die — scope 에러 |

### 도그푸딩 동기화

#### [MODIFY] `.harness-kit/bin/sdd`

`sources/bin/sdd` 변경 후 동일 복사 (test-governance-dedup 의 cp 정합성 유지).

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-search.sh
```

기대: 7 시나리오 모두 PASS.

### 회귀 검증

```bash
bash tests/test-sdd-config.sh
bash tests/test-sdd-archive-search.sh
bash tests/test-governance-dedup.sh
```

이유:
- `test-sdd-config`: dispatcher 분기 추가가 기존 `config` 명령에 영향 없는지.
- `test-sdd-archive-search`: 같은 키워드 (archive search) 이지만 다른 기능 (spec list 가 archive 를 표시) → 무회귀 확인.
- `test-governance-dedup`: `sources/bin/sdd` ↔ `.harness-kit/bin/sdd` cp 정합성.

### 수동 검증 시나리오

1. `bash .harness-kit/bin/sdd search uxMode` → archive + decisions 등 여러 그룹 매치
2. `bash .harness-kit/bin/sdd search --scope=rca '.*'` → RCA 파일 전체 노출 (있는 경우)
3. `bash .harness-kit/bin/sdd search nonexistent_xyz` → `검색 결과 없음` + exit 1

## 🔁 Rollback Plan

- 단일 함수 추가 + dispatcher 한 줄 — revert 무영향.
- 검색은 호출 시점이라 데이터 손상 위험 0.

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] (실행 후) walkthrough.md / pr_description.md ship
