# phase-30: wiki-as-knowledge

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-30-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-30` |
| **상태** | In Progress |
| **시작일** | 2026-10-22 |
| **목표 종료일** | - |
| **소유자** | changsik |
| **Base Branch** | `phase-30-wiki-as-knowledge` |

## 🎯 배경 및 목표

### 현재 상황

phase-27~29 는 문서 계층을 *도구로 정리·검사*했다(ADR 인덱스, 무결성, 신선도, 검사기 정확도). 그러나 2026-10-22 에 다음 지적이 나왔다: wiki 는 LLM wiki 가 아니라 *요약 색인*에 머물러 있다.

- `decisions.md` 는 ADR/spec 하나당 "결정·이유·출처" 를 쌓은 출처 단위 로그다. 주제별 "지금 입장" 이 없다.
- 인제스트 규칙이 append-only("기존 내용을 삭제·교체하지 않는다")라 번복·대체를 담을 수 없다. ADR 9개가 전부 `accepted`, 번복 이력이 wiki 어디에도 없다.
- 충돌·반복·미결(보류)은 wiki 밖(`queue.md` Icebox)에 있다.
- lint 는 구조(고아 링크·90일 미참조·신선도)만 본다. 지식이 *맞는가·모순되는가* 는 보지 않는다. phase-28 의 신선도 검사도 "인제스트했는가" 만 잰다.

시범(브랜치 `wiki-pilot-3layer`)으로 `direction.md` + `components/hooks.md` 를 3층 구조로 써 보니, 기존 방식으로는 안 보이던 불일치·반복·미결이 8건 드러났다(아래 triage).

### 목표 (Goal)

wiki 를 "무엇이 정리됐나" 가 아니라 **"지금 입장이 무엇이고, 어떻게 바뀌었고, 무엇이 반복·미결인가"** 에 답하는 3층(방향 / 구현 / 이슈 스레드) 지식 계층으로 바꾸고, 그 내용이 코드와 어긋나면 감지한다.

### 성공 기준 (Success Criteria) — 정량 우선
1. `direction.md`, 컴포넌트 페이지 5~6개, `threads.md` 가 존재하고 모든 사실 주장에 출처가 있다.
2. 사실 검증 lint 가 의도적으로 틀린 fixture(예: hook 기본값 변경)를 감지하고, 본 저장소에서는 불일치 0건이다.
3. 시범에서 나온 발견 8건 전부에 처분 기록(코드 수정 / 문서 수정 / 수용 / 보류)이 있다.
4. 인제스트가 기존 주장을 바꿀 때 이력을 보존하고, 충돌이면 사용자에게 먼저 묻는다 (fixture 테스트).
5. 전체 테스트 회귀 0.

## 🧩 작업 단위 (SPEC + phase-FF)

> 실질적/불확실 → **SPEC**, 작고 가역적인 1–2 commit → **phase-FF** (→ ADR-004).

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-30-01` | wiki-three-layer-schema | P? | Merged | `specs/spec-30-01-wiki-three-layer-schema/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-30-01 — wiki 3층 구조와 인제스트 규약 개정

- **요점**: 방향 / 구현(컴포넌트) / 이슈 스레드 3층 구조와, 그에 맞는 인제스트·조회 규약을 정한다.
- **방향성**: `schema.md` 에서 append-only 폐지. 페이지 템플릿(현재 입장 / 변경 이력 / 반복·미결 / 부채), 페이지 크기 상한(초과 시 오래된 이력 압축), 충돌 시 사용자 확인, 출처 필수. `/hk-wiki-ingest` 를 "바뀐 컴포넌트 페이지만 갱신" 으로 개정. 기존 `decisions.md`/`patterns.md` 는 삭제하지 않고 "출처별 로그" 로 격하. ADR `supersedes`/`superseded_by` frontmatter 도입 검토.
- **참조**: 시범 페이지(`docs/wiki/direction.md`, `docs/wiki/components/hooks.md`), `docs/wiki/schema.md`, ADR-003, `sources/commands/hk-wiki-ingest.md`
- **연관 모듈**: `docs/wiki/`, `sources/commands/`, `sources/templates/`

### spec-30-02 — 지식 lint (사실 검증 + 의미 lint)

- **요점**: wiki 가 코드와 어긋나거나 스스로 모순되면 감지한다.
- **방향성**: (a) 사실 검증 — 페이지의 기계 검증 가능한 주장(hook 기본값 표, 서브커맨드 목록 등)을 코드에서 뽑아 대조(결정론적). (b) 의미 lint(`/hk-wiki-lint`, LLM) — 모순, 대체됐는데 현재형인 주장, 장기 보류 항목. 기존 신선도 검사는 보조 신호로 격하. 경고(exit 0)로 시작(hook 단계론).
- **참조**: spec-28-01 walkthrough (신선도 검사의 한계), `_wiki_freshness_report`
- **연관 모듈**: `sources/bin/sdd`, `sources/commands/`, `tests/`

### spec-30-03 — 컴포넌트·스레드 페이지 확장

- **요점**: 시범 2페이지 이후 남은 구현 층 페이지와 이슈 스레드 레지스트리를 채운다.
- **방향성**: sdd CLI, 거버넌스·커맨드, 설치·업데이트·원본↔사본, 상태·설정(SSOT), 문서·wiki 계층 페이지 + `threads.md`(번복·반복·미결 레지스트리). task 하나당 컴포넌트 하나. spec↔컴포넌트 연결은 spec 의 `Proposed Changes` 파일 경로 매핑을 기계적으로 활용. 30-02 의 사실 검증으로 각 페이지의 기계 검증 가능 주장을 고정.
- **의존**: spec-30-01(구조), spec-30-02 의 사실 검증(도구 선행 권장)
- **연관 모듈**: `docs/wiki/components/`, `docs/wiki/threads.md`

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 phase base 브랜치에 직접 커밋(phase-FF, → ADR-004). 착수 시 §11.3 재검증으로 크기를 재확인하고, 커질 경우 SPEC 으로 승격합니다. (draft — 진행 중 조정 가능)

| 항목 | 요점 | 종류 | 예상 commit |
|---|---|---|:---:|
| pilot-pages-merge | 시범 페이지(`direction.md`, `components/hooks.md`, index 행)를 phase 브랜치로 반영 | 문서 | 1 |
| hook-claims-doc-fix (F1·F2) | README/헌법의 "테스트 미실행 커밋 물리적 차단" 을 실제(경고 + 사후 신뢰 검사)에 맞게 정정. hook 별 분류표(의도적 warn / 다른 층이 block / 승격 후보)를 CLAUDE.md #5 에 문서화. 일괄 block 승격은 하지 않음 | 문서 | 1–2 |
| plan-accept-shared-fn (F3) | Plan Accept 판정(whitelist)을 `_lib.sh` 공유 함수로 통합. `pre-commit.sh` 와 `check-plan-accept.sh` 불일치 재발 방지 테스트 | 코드 | 2 |
| sdd-hooks-all (F4) | `sdd hooks` 가 모드를 가진 hook 전부를 표시 | 코드 | 1–2 |
| phase-03-06-disposition (F5) | phase-03~06 archive 파일의 상태를 실제(구현/철회/리서치 완료)로 정정하고 direction.md 에 셸 정책 번복·No-Go 결정을 기록 | 문서 | 1 |
| wikilink-spec-ref (F6) | 고아 링크 검사기가 `[[spec-NN-NN]]` 을 `archive/specs/spec-NN-NN-*` 로 해소. `index.md` 의 `[[wiki/purpose]]` 정정. 회귀 테스트 | 코드+문서 | 2 |

## 🔎 발견 사항 triage (시범 결과, 코드 vs 문서)

| # | 발견 | 근거 | 처분 | 처리 위치 |
|---|---|---|---|---|
| F1 | README "테스트 미실행 커밋 물리적 차단" 인데 `check-test-passed` 기본 warn | hook 은 `lastTestPass` 시각(30분 창)만 봄. 기록은 `sdd run-test`/수동. 헌법의 TDD red 커밋과 구조적 충돌, 시각 기록으로는 "이 변경이 테스트됐다" 보장 불가 | **문서 수정** (block 승격 안 함) | hook-claims-doc-fix |
| F2 | warn→block 승격이 7개 hook 에서 미이행 | 승격 결정 기록 없음. `check-commit-msg` 는 heredoc 메시지에서 오탐 *없음*을 직접 확인(정정: 초안의 "오탐 가능" 추정은 틀렸음). 단 `grep` 줄 단위라 어느 줄이든 형식에 맞으면 통과(느슨함) | **문서화** (분류표), 일괄 승격 안 함. commit-msg 는 엄격화 후 승격 후보 | hook-claims-doc-fix |
| F3 | Plan Accept 판정 이중 구현 | `pre-commit.sh`·`check-plan-accept.sh` 각자 whitelist. 정책 불일치 3회 반복 | **코드 수정** (완료) | plan-accept-shared-fn |
| F4 | `sdd hooks` 11개 중 4개만 표시 | 출력 직접 확인 | **코드 수정** (완료) | sdd-hooks-all |
| F5 | phase-03~06 Planning 채 archive | **정정**: 초안의 "실행 기록 없음" 판단은 틀렸음 — spec 6개가 실행돼 walkthrough 존재. 실제 문제는 phase 파일 상태가 갱신되지 않은 것. 03-01 zsh 는 #59 에서 철회(bash 4.0+) → #77 에서 3.2+ 로 수렴, 05-01 은 멀티 에이전트 No-Go | **문서 수정** (상태 정정 완료 — 사용자 확인 불필요, 이월 판단 없음) | phase-03-06-disposition (완료) |
| F6 | 고아 wikilink 30건 + `[[wiki/purpose]]` | 대부분 archive spec 참조, ADR 접두 문제와 같은 원인 | **검사기 수정 + 문서 수정** | wikilink-spec-ref |
| F7 | 거버넌스 7,902w (soft 7,000w 초과) | 상한 상향이 되풀이됨 | **보류** (rule prune 은 큰 결정 — Icebox 유지, 페이지에 "미결" 기록) | threads.md (spec-30-03) |
| F8 | 외부 검증(nextmarket-api) 근거가 저장소 밖 | 이 저장소로 확인 불가 | **사용자 입력 대기** — 확인되면 `direction.md` 반영 | pilot-pages-merge 이후 |

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| wiki 구조 | 출처 단위 로그 유지 / 주제 중심 3층 | **3층 (방향·구현·이슈 스레드)** | 출처 단위는 "지금 입장·번복·미결" 에 답하지 못함 (2026-10-22 사용자 지적) |
| 시작 방식 | 도구 먼저 / 시범 페이지 먼저 | **시범 페이지 먼저** | phase-28 의 신선도 검사처럼 형식 검증 전에 도구를 만들면 같은 실수 반복 |
| F2 승격 정책 | 일괄 승격 / 분류표 문서화 | **분류표 문서화** | 휴리스틱·파싱 취약 hook 의 일괄 block 은 오탐 비용 > 이득 (CLAUDE.md #5) |
| spec-30-02/03 순서 | 내용 먼저 / 도구 먼저 | **도구(사실 검증) 먼저** | 페이지가 코드와 어긋나 거짓이 되는 것이 최대 위험 |
| 기존 decisions.md/patterns.md | 삭제 / 격하 보존 | **격하 보존** | 출처 로그로서 가치 유지, 이력 삭제 금지 |
| 신선도 검사(spec-28-01) | 유지 / 제거 | **보조 신호로 격하** | "인제스트했는가" 만 재며 지식의 정확성을 재지 못함 |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: 코드와 어긋난 wiki 감지
- **Given**: hook 기본 모드를 바꾼 fixture (wiki 의 hook 표는 그대로)
- **When**: 지식 lint 실행
- **Then**: 불일치가 표시된다. 일치 fixture 와 본 저장소에서는 침묵
- **연관 SPEC**: spec-30-02, spec-30-03

### 시나리오 2: 번복이 이력과 함께 반영
- **Given**: 기존 주장을 뒤집는 새 결정이 있는 fixture
- **When**: 인제스트 규약대로 페이지 갱신
- **Then**: 현재 입장이 바뀌고 변경 이력에 이전 입장이 남는다. 충돌은 사용자 확인 대상으로 표시
- **연관 SPEC**: spec-30-01

### 통합 테스트 실행
```bash
bash tests/run.sh
```

## 🔗 의존성

- **선행 phase**: phase-27/28/29 (문서 도구군), 시범 브랜치 `wiki-pilot-3layer`
- **외부 시스템**: 없음
- **연관 ADR**: `docs/decisions/ADR-003-wiki-frontmatter-schema.md`, ADR-009 (hook 단계론 · 모드 차등)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| wiki 페이지가 코드와 어긋나 거짓 정보가 됨 | 에이전트가 거짓 맥락으로 작업 | spec-30-02 사실 검증을 spec-30-03 보다 먼저, 기계 검증 가능한 주장은 코드에서 뽑아 대조 |
| 범위 과대 (spec 3 + FF 6) | phase 장기화 | spec-30-03 은 컴포넌트 단위로 쪼개 진행, 막히면 다음 phase 로 이월 |
| "정리 도구" 로 회귀 | 같은 문제 반복 | 성공 기준 3·4 (처분 기록·이력 보존·충돌 확인)가 방지 장치 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (`phase-30-wiki-as-knowledge` → main)
- [ ] phase-FF 6건 완료, F1~F8 처분 기록
- [ ] 통합 테스트 시나리오 PASS
- [ ] 성공 기준 측정 결과 기록
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)
