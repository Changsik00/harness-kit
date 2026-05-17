# spec-x-sdd-search: 아카이브 통합 검색 — `sdd search <keyword>` wrapper

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-sdd-search` |
| **Phase** | `phase-x` (Solo Spec) |
| **Branch** | `spec-x-sdd-search` |
| **상태** | Planning |
| **타입** | Feature (small) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- `sdd archive` 는 단순 `git mv` — completed spec/backlog 를 `archive/` 디렉토리로 이동시킬 뿐.
- 본 저장소 archive 누적: **108 개 spec 디렉토리** + 다수의 phase backlog + ADR/RCA.
- 과거 결정/실패 패턴/Carry-over Items 는 `archive/specs/**/walkthrough.md` 에 묻혀 있고, 발견 수단은 `grep -rn` 수동 호출 뿐.

### 문제점

1. **knowledge 매장**: 어떤 결정이 어디서 내려졌는지 검색 비용이 높음. lat.md 가 active code 에 대해 풀려는 문제를 우리는 *과거 작업* 에 대해 갖고 있음.
2. **archive 의 의미 빈약**: "archive" 라는 이름이 무색하게 *접근성 없는 stash*. 1단계는 stash 라도 좋지만 검색 layer 가 없으면 archive 라 부를 가치가 떨어짐.
3. **dispersed targets**: `archive/specs/`, `docs/decisions/`, `docs/rca/`, `backlog/`, `specs/` (현역) 가 모두 markdown 자산인데, 한 번에 grep 하는 손쉬운 wrapper 없음.

### 해결 방안 (요약)

`sdd search <keyword>` 라는 bash-native wrapper 를 추가한다. 내부적으로 `grep` 을 호출하되, 카테고리별로 묶어 보여주고 (active / archive / decisions / rca / backlog), 라인넘버/파일경로를 일관되게 출력한다. 추가 색인 빌드 없음 — 호출 시점 검색.

## 🎯 요구사항

### Functional Requirements

1. **CLI**: `sdd search <keyword> [--scope=<scope>] [--ignore-case]`
   - `<keyword>` 는 grep extended regex (`grep -E`).
   - `--scope=<scope>`: `all` (기본), `active`, `archive`, `decisions`, `rca`, `backlog` 중 하나.
   - `--ignore-case` (기본 OFF): 대소문자 무시.
2. **검색 대상 디렉토리**:

   | scope | 대상 |
   |---|---|
   | `active` | `specs/**/*.md` (현역 spec) |
   | `archive` | `archive/specs/**/*.md` + `archive/backlog/*.md` |
   | `decisions` | `docs/decisions/*.md` |
   | `rca` | `docs/rca/*.md` |
   | `backlog` | `backlog/*.md` |
   | `all` | 위 모두 |
3. **출력 형식**: 카테고리별로 헤더 (`▶ archive (12 hits)`) + 매치 라인 (`<rel path>:<line>: <text>`). 컬러는 isatty 일 때만.
4. **No match**: 카테고리별 0 건은 헤더 자체 생략. 전체 0 건이면 `검색 결과 없음` 출력 + exit 1.
5. **도움말 갱신**: `sdd --help` 의 명령 섹션에 `search <keyword>` 한 줄 추가.

### Non-Functional Requirements

1. **bash 3.2+ 호환**: associative array / mapfile 등 4+ 전용 기능 금지 (CLAUDE.md 작업 원칙 §3).
2. **단일 명령 원칙**: 슬래시 커맨드는 미생성 (CLI 만으로 충분 — 자주 쓰는 명령 아님). 필요 시 후속 spec.
3. **무색인**: 별도 인덱스 파일 / sqlite / 캐시 없음. `find` + `grep` 의 ad-hoc 호출.
4. **테스트**: fixture 기반 단위 테스트 (시나리오 5+).

## 🚫 Out of Scope

- decision/finding 추출 후 별도 `decisions-index.md` 생성 (1 단계 — 본 spec 에서는 안 함, 검색만).
- `[[wiki link]]` 패턴 도입 / drift 검사 (3 단계 — lat.md 영역).
- 컬러 / TUI / interactive picker (예: fzf 연동) — 별건 후속 spec.
- 슬래시 커맨드 `/hk-search` (필요 시 후속).

## 📑 ADR 후보

- [x] 없음 — grep wrapper 라 architectural 결정 아님.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-sdd-search.sh` 신설, 시나리오 5+)
- [ ] `walkthrough.md` / `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-sdd-search` 브랜치 push + PR 생성 + URL 보고
