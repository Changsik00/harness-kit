# phase-28: docs-freshness

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-28-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-28` |
| **상태** | In Progress |
| **시작일** | 2026-10-19 |
| **목표 종료일** | - |
| **소유자** | changsik |
| **Base Branch** | `phase-28-docs-freshness` |

## 🎯 배경 및 목표

### 현재 상황

phase-27(docs-integrity)이 ADR 인덱스·무결성·archive 잔존을 도구로 지키게 했지만, 문서 계층의 나머지는 여전히 수기에 의존한다. 2026-10-19 점검에서 다음이 확인됐다.

1. **wiki 방치**: `docs/wiki/*` 가 2026-06-03 이후 갱신되지 않았고 `decisions.md` 에 ADR-005~009 가 0건이었다(phase 20~27, 25 walkthrough 가 미반영). `/hk-wiki-ingest` 수동 실행에만 의존하며 낡음을 알리는 신호가 없다.
2. **원본↔사본 drift**: 키트 원본(`sources/`)과 도그푸딩 설치본(`.harness-kit/`)의 불일치는 일부 테스트가 우연히 잡을 뿐 정식 검사가 없다(`harness.config.json` 이 두 위치로 갈라져 `sdd config models` 가 설치본 값을 무시하던 SSOT 분리가 실제로 발생, #231 에서 수습).
3. **검사기 한계**: `sdd doctor` wikilink 검사가 `[[ADR-NNN]]` 을 `ADR-NNN.md` 로 찾아 slug 파일명(`ADR-NNN-slug.md`)을 못 찾는다 → 고아 링크 65건 중 다수가 오탐.
4. **docs/ 위치 규약 부재**: `docs/` 루트에 bug 리포트·retrospective·design 문서가 분류 없이 섞여 있다.

### 목표 (Goal)

문서 계층의 *낡음* 과 *원본↔사본 불일치* 를 `sdd doctor`/`status` 가 결정론적으로 감지하게 하고, 검사기 오탐을 제거해 신호의 신뢰도를 회복한다.

### 성공 기준 (Success Criteria) — 정량 우선
1. wiki freshness 검사가 stale fixture(미반영 ADR 또는 `updated` 가 최신 archive 보다 N일 이상 뒤처짐)를 감지하고, 최신 fixture 에는 경고하지 않는다 (테스트로 고정).
2. 원본↔사본 drift 검사가 불일치 fixture 를 감지하고 일치 fixture 에는 침묵한다. 본 저장소에서 실행 시 의도된 차이만 제외하고 0건이다.
3. `sdd doctor` 고아 wikilink 오탐: `[[ADR-NNN]]` 형태로 인한 고아 0건 (현재 ADR 링크 전부 고아로 집계).
4. 전체 테스트 회귀 0 (기존 통과 테스트 유지).

## 🧩 작업 단위 (SPEC + phase-FF)

> 본 절은 phase 의 *작업 지도* 입니다. phase 설계 시 각 작업을 크기에 맞게 미리 배치합니다 — 실질적/불확실 → **SPEC**(아래 표), 작고 가역적인 1–2 commit → **phase-FF**(맨 아래 목록, spec 산출물 없음, → ADR-004).
> SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다. 자세한 spec/task 는 `specs/spec-28-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`
> sdd가 ship 시 자동으로 `Merged`로 갱신합니다 (PR 생성 시점 기준 — 반려 시에만 수동 정정). `In Progress`는 active spec에 자동 마킹됩니다.

### spec-28-01 — wiki 신선도 검사

- **요점**: wiki 가 낡았음을 `sdd doctor`(및 `status` 한 줄)가 결정론적으로 알린다.
- **방향성**: 각 wiki 페이지 frontmatter 의 `updated` 와 (a) `docs/decisions/` 의 미반영 ADR, (b) 마지막 인제스트 이후 archive 된 spec 수를 비교. 임계는 보수적으로 시작해 경고(exit 0)만 한다 — 휴리스틱이라 hook 단계론(경고→운영→승격) 적용. 판정 로직은 `adr-index` 와 같이 결정론적 bash(3.2 호환). 경고 문구에 `/hk-wiki-ingest` 안내.
- **참조**:
  - `docs/decisions/ADR-003-wiki-frontmatter-schema.md`
  - `sources/commands/hk-wiki-ingest.md`
  - spec-27-02 (`cmd_doctor` 확장 패턴, 서브셸 격리)
- **연관 모듈**: `sources/bin/sdd` (`cmd_doctor`, `_status_diagnose`), `tests/`

### spec-28-02 — 원본↔사본 drift 검사

- **요점**: `sources/` 원본과 설치본(`.harness-kit/`, `.claude/`)의 불일치를 정식 검사로 감지한다.
- **방향성**: 의도된 차이(설치 시 생성되는 파일, 설정값, 템플릿 렌더 결과)를 제외 목록으로 명시하고 나머지 diff 를 경고. 키트 원본 저장소(도그푸딩)에서만 의미가 있으므로 다운스트림에서는 침묵(자동 비활성). 기존 sync 테스트와 중복되지 않게 역할 구분.
- **참조**:
  - spec-26-01 walkthrough §발견 사항 (도그푸딩 사본 sync 가 테스트로 강제됨)
  - `docs/release-strategy.md` (self `update.sh` re-sync 검토 Icebox)
- **연관 모듈**: `sources/bin/sdd`, `update.sh`, `tests/`

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 phase base 브랜치에 직접 커밋(phase-FF, → ADR-004). phase 승인이 항목 실행을 위임하므로 항목별 재승인 불필요. 착수 시 §11.3 재검증으로 크기를 재확인하고, 커질 경우 SPEC 으로 승격합니다. (draft — 진행 중 조정 가능)

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| wikilink-adr-prefix | `sdd doctor` 고아 링크 검사가 `[[ADR-NNN]]` 을 `ADR-NNN-*.md` 접두로 해소. 회귀 테스트 포함 | 2 |
| diagnose-msg-fix | `_status_diagnose` 의 "sdd ship 실행 권장"(state 리셋 후엔 실행 불가)을 실행 가능한 안내로 교정 | 1 |
| docs-layout-guide | `docs/README.md` 로 위치 규약(bug/RCA/retrospective/design) 명시 및 기존 문서 분류 | 2 |
| icebox-cleanup | queue Icebox: `sdd ship` base 모드 갭을 "won't fix(ship=PR 생성 시점 Merged)"로 결정 기록, 해소된 항목 정리 | 1 |
| spec-x-ingest-dedup | 5월 일괄 인제스트와 중복 여부를 검증한 뒤 누락분만 wiki 에 증분 인제스트 | 1 |

## 📌 결정 기록 (Review)

> Phase PR review 중 발생한 결정·합의·발견을 누적합니다. Spec walkthrough 의 결정 기록과 동일 패턴이며 Phase 레벨 living decision log 역할 (→ agent.md §6.3.2).
> review 핑퐁으로 success criterion / 통합 테스트 시나리오 / spec 구성이 바뀌면 본 문서 해당 섹션을 직접 갱신하고, *왜* 그렇게 결정했는지의 이유를 본 표에 추가로 남깁니다.
> PR body 동기화가 필요하면 `gh pr edit --body-file` 사용.

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 작업 구성 | spec 3개 / 항목별 right-size / spec-x 1건 | **항목별 right-size** | 큰 건(검사 2종)만 spec, 1–2 commit 건은 phase-FF (ADR-004). 2026-10-19 사용자 선택 |
| `sdd ship` base 모드 갭 | ship 을 `In Progress`/`Done` 으로 + reconcile / 현행 유지 | **현행 유지 (won't fix)** | PR 반려는 드물고, 정확성을 위한 post-merge 보정 커밋이 오히려 toil. ship = PR 생성 시점에 Merged 로 표시 |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: 낡은 wiki 감지
- **Given**: wiki 가 반영하지 않은 ADR 이 있는 fixture
- **When**: `sdd doctor` 실행
- **Then**: wiki freshness 경고가 출력되고 `/hk-wiki-ingest` 가 안내된다. 최신 fixture 에서는 경고 없음
- **연관 SPEC**: spec-28-01

### 시나리오 2: 원본↔사본 불일치 감지
- **Given**: `sources/bin/sdd` 와 설치본이 다른 fixture
- **When**: `sdd doctor` 실행
- **Then**: drift 경고에 대상 파일이 표시된다. 일치 fixture 와 다운스트림(원본 부재)에서는 침묵
- **연관 SPEC**: spec-28-02

### 통합 테스트 실행
```bash
bash tests/run.sh
```

## 🔗 의존성

- **선행 phase**: phase-27 (docs-integrity — `cmd_doctor` 확장·`adr-index`·잔존 헬퍼)
- **외부 시스템**: 없음
- **연관 ADR**:
  - `docs/decisions/ADR-003-wiki-frontmatter-schema.md`
  - `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md`

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| freshness 휴리스틱 오탐 | 경고 피로 → 신호 무시 | 경고(exit 0)로 시작, 임계 보수적, 운영 데이터 후 조정 (hook 단계론) |
| drift 검사가 의도된 차이를 오탐 | 도그푸딩에서 상시 경고 | 제외 목록을 명시하고 테스트로 고정 |
| 다운스트림에서 의미 없는 검사 | 불필요한 소음 | 원본 저장소(도그푸딩) 판별 시에만 활성 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (base branch 모드: `phase-28-docs-freshness` → main)
- [ ] phase-FF 항목 완료
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
