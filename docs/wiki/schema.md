---
kind: catalog
sources: []
linked:
  - "[[wiki/index]]"
updated: 2026-10-23
---

# docs/wiki/ — 스키마 (에이전트·사람 공용 운영 규약)

> "human curates, LLM maintains" — Karpathy LLM Wiki 패턴

## 이 디렉토리의 역할

`docs/wiki/`는 harness-kit의 **지식 레이어**입니다. 문서를 분류해 놓은 색인이 아니라, 세 가지 질문에 답하는 것이 목적입니다.

1. **지금 입장이 무엇인가** — 이 프로젝트는 X 를 지금 어떻게 하기로 했고, 실제로 그렇게 되어 있나
2. **어떻게 바뀌어 왔나** — 무엇이 번복·대체됐고 왜
3. **무엇이 반복·미결인가** — 같은 문제가 되풀이되거나, 결정을 미루고 있는 것

- **raw layer** (`archive/specs/`, ADR, RCA, 코드): 원본 — 상세하지만 주제별로 모이지 않음. 사실의 최종 출처.
- **wiki layer** (이 디렉토리): raw 에서 *현재 입장과 그 변천*만 증류. 코드와 어긋나면 wiki 가 틀린 것이다.

## 3층 구조

| 층 | 파일 | 답하는 질문 |
|---|---|---|
| **방향** | `direction.md` | 무엇을 하려는 프로젝트이고, 의도대로 가고 있나 (원칙 대비 현황 · 연혁 · 반복되는 방향 이슈 · 열린 질문) |
| **구현** | `components/<name>.md` | 이 컴포넌트가 *지금* 어떻게 되어 있나 (책임 · 현재 설계 · 변경 이력 · 반복·미결 · 기술 부채 · 관련 결정) |
| **이슈 스레드** | `threads.md` | 번복·반복·미결이 어디에 걸쳐 있나 — 여러 컴포넌트에 걸친 스레드의 레지스트리 (스레드마다: 상태 · 경과 · 관련 페이지) |

운영 파일: `schema.md`(이 문서), `index.md`(인벤토리), `log.md`(인제스트 이력).
**출처별 로그(격하)**: `decisions.md`, `patterns.md` — 결정·패턴을 출처 단위로 쌓은 기록. 삭제하지 않으며 "왜 그때 그렇게 정했나" 의 상세 근거로 쓰지만, **현재 입장은 여기가 아니라 direction/components 에서 읽는다.**

컴포넌트 페이지 양식: `.harness-kit/agent/templates/wiki-component.md` (원본 `sources/templates/wiki-component.md`).

## Frontmatter 스키마

### wiki 페이지 (`docs/wiki/**/*.md`)

```yaml
---
kind: catalog | synthesis    # catalog: 운영 파일 / synthesis: 증류 지식
sources:                     # 이 페이지를 합성하는 데 사용한 원본 문서
  - docs/decisions/ADR-001-knowledge-types.md
  - specs/spec-XX-XX-slug/walkthrough.md
covers:                      # (components/ 전용) 이 컴포넌트가 다루는 저장소 경로 접두
  - sources/hooks/
linked:                      # 관련 wiki/ADR/RCA wikilinks
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
updated: YYYY-MM-DD          # 마지막 갱신일
---
```

`covers:` 는 인제스트가 spec 의 `Proposed Changes` 경로를 컴포넌트에 **기계적으로** 매핑하는 키다. 한 경로가 여러 컴포넌트에 걸릴 수 있다.

### 기존 ADR/RCA (backfill 필드)

기존 `type:`, `date:`, `status:` 필드는 그대로 유지. 아래 3개 필드만 추가:

```yaml
sources:                     # 이 문서를 만든 원인 spec
  - specs/spec-XX-XX-slug/walkthrough.md
linked:                      # 관련 wiki/ADR/RCA
  - "[[wiki/decisions]]"
  - "[[ADR-002]]"
updated: YYYY-MM-DD
```

> ADR-001의 `type:` 5어휘 vocabulary와 wiki의 `kind:` 는 별도 네임스페이스입니다.
> `type:` → ADR/RCA 전용 (decision/invariant/failure-pattern/convention/tradeoff)
> `kind:` → wiki 페이지 전용 (catalog/synthesis)

## wikilinks 컨벤션

| 참조 대상 | 형식 | 예시 |
|---|---|---|
| wiki 페이지 | `[[wiki/page-name]]` | `[[wiki/decisions]]`, `[[wiki/components/hooks]]` |
| ADR | `[[ADR-NNN]]` | `[[ADR-001]]` |
| RCA | `[[RCA-NNN]]` | `[[RCA-001]]` |
| spec | `[[spec-NN-NN]]` | `[[spec-16-01]]` |

Obsidian에서 `docs/` 를 vault root로 열면 자동 탐색됩니다.

## 페이지 작성 규약

### 1. 제자리 갱신 + 이력 보존 (append-only 아님)

- 현재 서술은 **제자리에서 고친다.** 낡은 문장 옆에 새 문장을 덧붙여 모순을 쌓지 않는다.
- 주장이 바뀌면 덮어쓰기 *전에* `## 변경 이력` 에 한 줄을 남긴다: 날짜 · 이전 입장 → 현재 입장 · 이유 · 출처. **지우지 않는 것은 현재 서술이 아니라 이력이다.**
- 같은 내용이 이미 있으면 추가하지 않고 출처만 보강한다.

### 2. 충돌은 사용자 확인 후 반영

새 근거가 기존 "현재 설계"의 주장과 **모순**되면 LLM 은 임의로 덮어쓰지 않는다.

1. 사용자에게 (기존 주장 / 새 근거 / 제안하는 갱신)을 나란히 보여 주고 확인받는다.
2. 확인 전에는 해당 페이지 `## 반복·미결` 에 `⚠ 충돌 대기: <한 줄>` 로만 기록한다.
3. 확인되면 제자리 갱신 + 변경 이력(규약 1)으로 반영하고 대기 표시를 지운다.

근거: 시범 페이지 작성 중 LLM 이 사실 주장을 두 번 틀렸다(commit-msg 오탐, phase-03~06 실행 기록). 조용한 덮어쓰기는 틀린 주장을 영속화한다.

### 3. 출처 필수

모든 사실 주장은 출처(파일 경로 또는 spec/ADR)를 단다. 출처를 확인하지 못한 주장은 쓰지 않거나 `(미확인)` 으로 표시한다. 판단·해석에는 "판단" 표시를 붙여 사실과 구분한다.

### 4. 검증 가능 주장 마커

코드에서 기계적으로 확인할 수 있는 표·목록(예: hook 기본 모드 표, 서브커맨드 목록)은 **바로 위 줄**에 마커를 둔다.

```markdown
<!-- verify: hooks-defaults -->
| hook | 걸리는 곳 | 기본 | 비고 |
```

`<키>` 별 검증 방법은 지식 lint(spec-30-02)가 정의한다. 마커가 있는 표는 코드와 어긋나면 경고 대상이다.

### 5. 크기 상한

| 페이지 | 상한 |
|---|---|
| `components/<name>.md` | 200줄 |
| `direction.md` | 150줄 |
| `threads.md` | 300줄 |

초과하면 가장 오래된 `변경 이력` 행들을 한 줄 요약으로 압축하고 원문 출처 링크를 유지한다. 지식을 버리는 것이 아니라 상세를 출처로 내리는 것이다.

## Ingest — 무엇을 쓰고 무엇을 버리나

실행: `/hk-wiki-ingest` (archive 후, 또는 `sdd doctor` 가 wiki 낡음 경고를 낼 때). 단위는 **walkthrough 가 아니라 영향받은 컴포넌트 페이지**다.

1. 대상 spec 의 `Proposed Changes` 경로를 각 컴포넌트 페이지의 `covers:` 와 매칭해 영향 컴포넌트를 정한다.
2. 영향 컴포넌트 페이지만 읽고 규약 1~3 에 따라 갱신한다.
3. 어느 `covers:` 에도 맞지 않는 항목은 사용자에게 "새 컴포넌트 / direction / 버림" 을 묻는다.
4. 번복·반복·미결은 `threads.md` 에도 반영한다.
5. `log.md` 에 이벤트를 기록한다.

- **쓴다**: 이후 작업의 판단을 바꾸는 것 — 현재 설계의 변화, 번복과 그 이유, 재발한 함정, 보류된 결정.
- **버린다**: 일회성 수정, 문구 정리, 이미 ADR/코드에 있는 사실의 복제. 모든 spec 을 링크하지 않는다.
- 새 항목은 *한 줄 결론 + 출처* 로 시작한다.

## Query — 에이전트가 wiki 를 읽는 시점

에이전트는 아래 상황에서 raw(`archive/specs/`) 를 뒤지기 *전에* wiki 를 먼저 본다 (CLAUDE.fragment 에 같은 규칙).

| 상황 | 먼저 읽을 곳 |
|---|---|
| "이 프로젝트가 지금 X 를 어떻게 하나 / 잘 가고 있나" | `direction.md` |
| 특정 컴포넌트를 건드리기 전 — 현재 설계·부채·미결 | `components/<name>.md` |
| "이게 왜 자꾸 바뀌나 / 아직 안 정해진 게 뭔가" | `threads.md` |
| "그때 왜 그렇게 정했나" 의 상세 근거, 유사 작업 이력 | `decisions.md` · `patterns.md` (출처별 로그) |
| ADR/RCA 전체 목록 | `index.md` |
| wiki 에 답이 없을 때 | 그제서야 `archive/specs/*/walkthrough.md` 를 검색 |

wiki 와 raw 가 충돌하면 raw(ADR·코드) 가 우선이며, 충돌을 발견하면 wiki 를 고치거나(규약 2) `/hk-wiki-ingest` 대상으로 보고한다.

## Lint — 건강 상태 점검

`sdd doctor` 의 `wiki layer` 섹션이 구조를 점검한다: 고아 `[[wikilink]]`, stale ADR/RCA(90일+), 신선도(wiki 에 없는 ADR, 마지막 인제스트 이후 archive 누적). 경고는 차단하지 않고 `/hk-wiki-ingest` 를 안내한다.

신선도는 "인제스트했는가" 만 재며 지식이 *맞는가* 는 재지 못한다. `verify` 마커 사실 검증과 의미 lint(모순·대체됐는데 현재형인 주장·장기 보류)는 spec-30-02 에서 추가된다.
