# phase-19: 문서 지식 그래프 (Doc Knowledge Graph)

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-19-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-19` |
| **상태** | In Progress |
| **시작일** | 2026-05-27 |
| **목표 종료일** | 2026-06-17 |
| **소유자** | dennis |
| **Base Branch** | `phase-19-doc-knowledge-graph` |

## 🎯 배경 및 목표

### 현재 상황

harness-kit 은 17개 phase, 111개+ spec, ADR 2개, RCA 1개를 생산했다. 이 문서들은 탐색 불가능한 상태로 쌓여 있고, 각 세션마다 과거 결정 맥락을 재발굴해야 한다.

**구체적 문제:**
- **raw layer 과부하**: 111개 spec.md/walkthrough.md 는 너무 많아서 실전에서 참조 불가
- **wiki layer 부재**: 결정 맥락이 증류(distill)된 곳이 없음. "archive strategy 관련 결정이 뭐였지?"에 즉답 불가
- **문서 간 연결 없음**: ADR/RCA 가 어떤 spec에서 비롯되었는지, 어떤 패턴이 반복되었는지 추적 불가
- **CLAUDE.md 비대화**: 저빈도 내용이 포함되어 항상-온 컨텍스트 토큰 낭비
- **governance 누적**: constitution.md 6,418w (상한 6,000w 초과), stale rule 제거 메커니즘 없음

**Karpathy의 LLM Wiki 패턴 (핵심 인사이트):**
```
Raw Sources      →  Wiki Layer (LLM 유지)   →  Query
spec/walkthrough     docs/wiki/               LLM이 wiki 읽고 즉답
ADR, RCA             decisions.md             (raw 111개 재탐색 안 함)
                     patterns.md
```
문제는 검색(index/search)이 아니라 **지식 누적**이다. 매번 raw를 재검색하면 인사이트가 쌓이지 않는다. wiki layer가 이를 해결한다.

**lat.md의 보완:**  
`[[wikilinks]]` + YAML frontmatter + `sources[]` 역참조로 raw↔wiki 연결을 유지한다.

### 목표 (Goal)

1. **`docs/wiki/`** 지식 증류 레이어 신설 — raw spec 없이도 결정 맥락을 즉시 파악 가능
2. **`/hk-wiki-ingest`** 슬래시 커맨드 — archive 후 Claude가 wiki 페이지를 갱신하는 표준 워크플로
3. **`sdd doctor`** 확장 — wiki 고아 링크, stale ADR/RCA, governance 비대화 자동 감지
4. **root CLAUDE.md 슬림화** — 항상-온 컨텍스트 토큰 절감

### 성공 기준 (Success Criteria) — 정량 우선

1. `docs/wiki/` 에 `index.md`, `log.md`, `decisions.md`, `patterns.md` 존재 + 기존 ADR/RCA 내용 증류 포함
2. `[[wikilinks]]` 가 spec.md / walkthrough.md / ADR / RCA 템플릿에 "관련 문서" 섹션으로 반영
3. `/hk-wiki-ingest` 실행 시 `docs/wiki/log.md` 갱신 + 대상 wiki 페이지 업데이트
4. `sdd doctor` 가 ① stale ADR/RCA (90일+) ② governance 단어 수 초과 ③ wiki 고아 링크를 각각 경고
5. root `CLAUDE.md` 크기 현재 대비 30% 이상 절감

## 🧩 작업 단위 (SPECs)

> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

### spec-19-01 — 문서 위키 레이어 설계 & 부트스트랩

- **요점**: `docs/wiki/` 구조 정의 + YAML frontmatter 스키마 + 기존 ADR/RCA/walkthrough 에서 초기 wiki 페이지 합성
- **방향성**:
  - 핵심 파일: `docs/wiki/index.md` (카탈로그), `docs/wiki/log.md` (인제스트 이력), `docs/wiki/purpose.md` (wiki 목적/스키마)
  - 증류 페이지: `docs/wiki/decisions.md` (ADR-001/002, 주요 walkthrough 결정 합성), `docs/wiki/patterns.md` (반복 패턴 + anti-pattern)
  - YAML frontmatter 스키마: `type:`, `sources:[]`, `updated:`, `linked:[]`
  - `[[wikilinks]]` 컨벤션: `[[spec-id]]`, `[[ADR-NNN]]`, `[[wiki/page-name]]`
  - 기존 `docs/decisions/ADR-*.md`, `docs/rca/RCA-*.md` 에 frontmatter 추가
- **참조**: Karpathy LLM Wiki 패턴, lat.md `[[wikilinks]]`
- **연관 모듈**: `docs/wiki/` (신규), `docs/decisions/`, `docs/rca/`, `sources/governance/constitution.md` (ADR type vocabulary §6.4)

### spec-19-02 — hk-wiki-ingest 슬래시 커맨드 & 템플릿 연동

- **요점**: archive 후 Claude가 wiki를 갱신하는 표준 워크플로(`/hk-wiki-ingest`) + 모든 artifact 템플릿에 `[[wikilinks]]` "관련 문서" 섹션 추가
- **방향성**:
  - `sources/commands/hk-wiki-ingest.md` 신규 슬래시 커맨드:
    1. 최근 archived spec들의 walkthrough.md 읽기
    2. `docs/wiki/decisions.md`, `docs/wiki/patterns.md` 갱신 (Claude가 직접)
    3. `docs/wiki/log.md` 에 인제스트 이벤트 기록
    4. `docs/wiki/index.md` 카탈로그 갱신
  - `sources/templates/` 에 "관련 문서 (Related)" 섹션 추가: spec.md, walkthrough.md, adr.md, rca.md
  - `sdd archive` 에 후처리 힌트 출력: `→ /hk-wiki-ingest 로 wiki 갱신 권장`
- **참조**: `sources/commands/` 내 기존 슬래시 커맨드 패턴, `sources/templates/`
- **연관 모듈**: `sources/commands/hk-wiki-ingest.md` (신규), `sources/templates/{spec,walkthrough,adr,rca}.md`, `sources/bin/sdd` (archive 후처리 출력)

### spec-19-03 — sdd doctor 확장 & CLAUDE.md 슬림화

- **요점**: `sdd doctor` 에 wiki 상태 점검 3종 추가 + root CLAUDE.md 비대 콘텐츠 분리 + governance prune 기준 도입
- **방향성**:
  - `sdd doctor` 신규 점검:
    1. `docs/wiki/` 존재 여부 (`⚠ wiki layer 없음 — /hk-wiki-ingest 실행 권장`)
    2. wiki `[[wikilinks]]` 고아 링크 감지 (참조 대상 파일 없음)
    3. `docs/decisions/`, `docs/rca/` 파일 중 90일+ 미참조 경고
    4. governance 단어 수 상한 경고 (상한 재설정: 7,000w)
  - root `CLAUDE.md` 슬림화: 릴리스 전략 등 저빈도 섹션 → `docs/` 하위 분리, root는 포인터만
  - `sources/governance/constitution.md` / `agent.md` 에 "rule prune 권고 기준" 섹션 추가: 작성일 6개월+ AND 모델 2세대 경과 시 검토 권장
- **참조**: Icebox "root CLAUDE.md 슬림화", Icebox "분기별 governance prune protocol"
- **연관 모듈**: `sources/bin/sdd` (doctor 서브커맨드), `CLAUDE.md`, `sources/governance/`

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| lat.md 도입 방식 | 전면 도입 vs 개념 차용 | 개념 차용 | Node.js 22+ 의존성 회피, bash 우선 원칙, Obsidian 호환으로 충분 |
| wiki layer 방식 | 정적 INDEX vs LLM Wiki 패턴 | LLM Wiki 패턴 | Karpathy 인사이트: 문제는 검색이 아닌 지식 누적. wiki layer가 raw 재탐색 비용 제거 |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: 신규 세션에서 wiki만으로 결정 맥락 파악

- **Given**: `docs/wiki/decisions.md`, `docs/wiki/patterns.md` 존재
- **When**: 새 Claude 세션에서 "archive strategy 결정이 뭐였지?" 질문
- **Then**: `docs/wiki/` 만 읽고 ADR-001, spec-11 관련 결정을 즉시 참조 가능 (raw 111개 탐색 불필요)
- **연관 SPEC**: spec-19-01, spec-19-02

### 시나리오 2: /hk-wiki-ingest → wiki 갱신 확인

- **Given**: `sdd archive` 후 신규 archived spec 존재
- **When**: `/hk-wiki-ingest` 실행
- **Then**: `docs/wiki/log.md` 에 타임스탬프 + 인제스트 대상 기록. `docs/wiki/index.md` 카탈로그 갱신.
- **연관 SPEC**: spec-19-02

### 시나리오 3: sdd doctor → wiki 상태 점검

- **Given**: `docs/wiki/` 에 고아 링크 1개 이상 존재
- **When**: `sdd doctor` 실행
- **Then**: `⚠ 고아 wiki 링크 N개` 경고 출력. stale ADR 있으면 별도 경고.
- **연관 SPEC**: spec-19-03

### 통합 테스트 실행
```bash
bash tests/test-doctor.sh
bash tests/test-wiki.sh
```

## 🔗 의존성

- **선행 phase**: 없음 (독립 실행 가능)
- **외부 시스템**: 없음
- **연관 ADR**: `docs/decisions/ADR-001-knowledge-types.md`, `docs/decisions/ADR-002-planning-economy.md`

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| wiki 페이지 내용이 raw 와 drift (부정확) | 잘못된 결정 참조 | `sources[]` 역참조 필수화 + lint로 확인. 수동 수정 허용 (human curates) |
| `/hk-wiki-ingest` 가 hallucinate | 잘못된 wiki 기록 | walkthrough.md 원문 인용 원칙. 합성 시 "출처: spec-XX-XX walkthrough §결정" 명시 |
| CLAUDE.md 슬림화 중 필수 컨텍스트 제거 | 에이전트 동작 오류 | 제거 전 현재 토큰 수 측정 → 제거 항목 목록 walkthrough 기록 → 테스트 실행 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 으로 merge
- [ ] 통합 테스트: `test-doctor.sh`, `test-wiki.sh` 전 시나리오 PASS
- [ ] 성공 기준 1~5 정량 측정 결과 기록
- [ ] `docs/wiki/` 가 실제로 "결정 즉시 참조" 가능한 수준인지 수동 검증
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
