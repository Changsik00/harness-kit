# Walkthrough: spec-x-sdd-search

> 사용자 지적 — "아카이브가 그냥 파일 이동일 뿐 아카이브라 할 수 있을까?" 에 대한 1차 응답.
> lat.md ([1st1/lat.md](https://github.com/1st1/lat.md), Agent Lattice — active code 의 markdown 지식 그래프) 를 참고했으나, 우리 도메인 (*과거 작업* 의 검색) 에는 bash-native grep wrapper 가 더 맞다는 판단.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| lat.md 채택 여부 | A) 그대로 채택 (npm 의존성) / B) 미니 bash 버전 직접 | **B** | 의존성 추가 회피 + 우리는 active code 의 지식 그래프 아닌 *과거 작업 의 검색* 이 핵심 |
| 1+2+3 단계 묶음 | A) 1+2 같이 / B) 2만 / C) 1+2+3 phase | **B** | 사용자가 "2 만 spec-x" 명시. 1단계 (decisions 추출) 는 후속 spec 으로 |
| 색인 빌드 여부 | A) 사전 색인 (인덱스 파일/sqlite) / B) ad-hoc `find + grep` | **B** | 108 spec 규모에서 grep latency 무시 가능 (<1s). 색인 운영 부담 회피 |
| 파일 수집 방식 | A) `find -exec grep` / B) globstar `**/*.md` + xargs | **A** | bash 3.2 호환 (`**` globstar 는 bash 4+ 필요). CLAUDE.md 작업 원칙 §3 |
| 그룹 dispatch | A) 5 개 함수 호출 반복 / B) `pairs` 변수 + for loop | **B** | 5 줄 동일 패턴 반복 회피. 중첩 함수(closure) 는 처음 시도했으나 bash 의 dynamic scoping 이 brittle 해서 데이터 표 + 루프로 단순화 |
| 슬래시 커맨드 | A) `/hk-search` 도 만들기 / B) CLI 만 | **B** | `/hk-*` 자동완성 noise 회피. 검색은 expert workflow 라 CLI 가 더 자연스러움 |

### ADR 승격 가이드

- [x] 없음 — grep wrapper 의 ad-hoc 결정. cross-spec / long-lived 결정 아님.

## 💬 사용자 협의

- **주제**: "아카이브가 그냥 파일 이동일 뿐 아카이브라 할 수 있을까? lat.md 참고해서 우리도 기능을 쓰던가 아니면 기획하던가"
  - **사용자 의견**: 현재 `sdd archive` 가 stash 수준이라 archive 라 부르기 어려움. lat.md 의 knowledge graph 패턴 검토 요청
  - **합의**: 3 단계 점진안 제시 후 사용자가 **2 단계만 spec-x** 선택. (1: decisions-index 자동 추출, 2: `sdd search` wrapper, 3: wiki link + drift check)

- **주제**: 옵션 라벨링 형식
  - **사용자 의견**: "라벨링 하지마 — 한영 키 전환 불편"
  - **합의**: A/B/C 영문 라벨 금지. `AskUserQuestion` 또는 `1)/2)/3)` 또는 라벨 없이. 메모리에 영구 저장 ([[feedback_no_letter_labels]])

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-search.sh`
- **결과**: ✅ Passed (7/7)
- **로그 요약**:

```text
T1: 전체 scope, archive 매치 (▶ archive + ▶ active 헤더)    ✅
T2: 매치 없음 → exit 1 + "검색 결과 없음"                   ✅
T3: --scope=decisions 만 → 다른 그룹 헤더 없음              ✅
T4: --ignore-case 매치                                        ✅
T5: regex "foo|bar" 매치                                      ✅
T6: 인자 없음 → die                                           ✅
T7: invalid scope → die                                       ✅
```

#### 회귀 테스트
- `tests/test-sdd-config.sh` 7/7 PASS
- `tests/test-sdd-archive-search.sh` 11/11 PASS
- `tests/test-governance-dedup.sh` Check 2 (cp 정합) PASS / Check 3 (word count) pre-existing FAIL — Icebox 등록 항목 ([[feedback_walkthrough_content]] 따라 본 spec 무관 사항 명시)

### 2. 수동 검증

1. **Action**: `bash .harness-kit/bin/sdd search uxMode --ignore-case`
   - **Result**: active 1 hits + archive 50 hits + decisions/rca/backlog 등 다수 그룹 매치. 상대 경로 + 라인 번호 정상 출력
2. **Action**: `bash .harness-kit/bin/sdd search nonexistent_xyz`
   - **Result**: `검색 결과 없음 (keyword=nonexistent_xyz, scope=all)` + exit 1
3. **Action**: `bash .harness-kit/bin/sdd search 'lat.md' --scope=active`
   - **Result**: active 그룹만 매치 (본 spec 의 spec.md/plan.md/walkthrough.md). archive/decisions 그룹 헤더 없음

## 🔍 발견 사항

1. **bash dynamic scoping vs nested function closures**: 처음 작성 시 `_search_dispatch` 안에 `_search_group_if` 를 정의해 `sc`/`kw`/`ic` 를 closure 처럼 쓰려 했음. 동작은 하지만 dynamic scoping 이라 의존 관계가 안 보임 — 호출자 변수가 우연히 같은 이름이면 깨질 수 있음. 데이터 표(`pairs="active|specs ..."`)로 단순화한 게 더 robust.

2. **검색 latency 체감**: 108 archived spec + ADR + RCA 통합 grep 이 0.2~0.5초 수준. 색인 없이도 충분히 빠름 — 사전 색인 후 운영 부담 정당화하려면 1000+ spec 정도 필요할 듯.

3. **`SDD_BACKLOG` / `SDD_SPECS` 변수 미사용**: `common.sh` 에 이미 path 변수 (`SDD_SPECS`, `SDD_BACKLOG`) 가 있는데, `cmd_search` 는 하드코딩 (`specs`, `backlog`) 했음. 사용자가 `harness.config.json` 에 커스텀 path 를 설정하면 search 가 잘못된 곳을 본다. archive/docs 경로는 변수가 없어서 어차피 하드코딩. 일관성을 위해 *전부 하드코딩* 으로 결정 (관련 변수 통일은 별건 spec 후보).

## 🚧 이월 항목

- **`SDD_SPECS`/`SDD_BACKLOG` 변수 path 일관 사용** — 위 발견 3 → Icebox 등록 (custom path 사용자가 거의 없어 우선순위 낮음)
- **1 단계 (decisions-index 자동 추출)**: 후속 spec 후보. `sdd archive` 가 walkthrough 의 `📌 결정 기록` 섹션을 추출해 `archive/decisions-index.md` 누적.
- **3 단계 (wiki link + drift)**: lat.md 영역. 본 저장소 markdown 양 (~150 파일) 에서 ROI 검증 필요.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Opus 4.7) + dennis |
| **작성 기간** | 2026-05-17 |
| **최종 commit** | `fa3837f` (ship commit 작성 시점) |
