# spec-30-01: wiki 3층 구조와 인제스트·조회 규약 개정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-30-01` |
| **Phase** | `phase-30` |
| **Branch** | `spec-30-01-wiki-three-layer-schema` |
| **Base 브랜치** | `phase-30-wiki-as-knowledge` |
| **상태** | Planning |
| **타입** | Feature (문서·커맨드 규약, 코드 변경 없음) |
| **작성일** | 2026-10-23 |
| **소유자** | changsik |

## 배경 및 문제 정의

### 현재 상황
- `docs/wiki/schema.md` 는 wiki 를 "출처 단위 증류 로그"(`decisions.md`, `patterns.md`)로 정의하고, 인제스트 규칙은 **"기존 내용을 삭제하거나 교체하지 않는다 — 항상 증분 추가"**(append-only)다.
- `/hk-wiki-ingest` 는 walkthrough 의 결정 기록 → `decisions.md`, 발견 사항 → `patterns.md` 로 *추가*만 한다.
- 시범(`docs/wiki/direction.md`, `docs/wiki/components/hooks.md`)에서 주제 중심 3층(방향 / 구현 / 이슈 스레드) 페이지가 실제로 쓰였고, 기존 방식으로는 안 보이던 불일치·반복·미결 8건이 드러났다. 시범 페이지는 임시 규약(페이지 상단 안내문)으로 쓰였을 뿐 schema·ingest 에는 반영되지 않았다.

### 문제점
- append-only 규칙은 번복·대체를 담을 수 없다 → "지금 입장"이 wiki 어디에도 없다.
- 인제스트 단위가 "walkthrough 1개"라 주제(컴포넌트)별 지식이 흩어진다.
- 충돌(새 결정이 기존 주장을 뒤집음)을 어떻게 다룰지 규약이 없다. LLM 이 조용히 덮어쓰거나, 조용히 병기할 위험.
- 페이지가 무한히 자란다(`patterns.md` 343줄, `decisions.md` 320줄). 크기 상한이 없다.
- 후속 spec-30-02(사실 검증 lint)가 검사할 "기계 검증 가능한 주장"의 표기 규약이 없다.

### 해결 방안
schema.md 를 3층 구조 + 페이지 템플릿 + 갱신(in-place, 이력 보존, 충돌 확인) 규약으로 개정하고, `/hk-wiki-ingest` 를 "바뀐 컴포넌트 페이지만 갱신" 방식으로 바꾼다. 검증 가능 주장 표기(`verify` 마커)를 여기서 정해 spec-30-02 가 대상을 찾을 수 있게 한다. 기존 `decisions.md`/`patterns.md` 는 삭제하지 않고 "출처별 로그"로 격하한다.

## 요구사항

1. **3층 정의**: `direction.md`(방향: 의도 대비 현황·연혁·반복 방향 이슈) / `components/<name>.md`(구현: 책임·현재 설계·변경 이력·반복·미결·기술 부채) / `threads.md`(이슈 스레드 레지스트리: 번복·반복·미결). 각 층이 답하는 질문을 schema 에 명시.
2. **컴포넌트 페이지 템플릿** `sources/templates/wiki-component.md` (설치 시 `.harness-kit/agent/templates/` 로 자동 복사): frontmatter(`kind`, `sources`, `covers`, `linked`, `updated`) + 필수 섹션(책임 / 현재 설계 / 변경 이력 / 반복·미결 / 기술 부채 / 관련 결정). `covers:` 는 이 컴포넌트가 다루는 저장소 경로 접두 목록 — 인제스트가 spec 의 `Proposed Changes` 경로를 컴포넌트에 기계적으로 매핑하는 키.
3. **갱신 규약 (append-only 폐지)**: 주장을 *제자리에서* 갱신한다. 기존 주장이 바뀌면 이전 입장을 "변경 이력"(날짜·출처·이전→현재·이유)에 남긴다. 삭제 금지 대상은 *이력*이지 *현재 서술*이 아니다.
4. **충돌 규약**: 새 근거가 기존 "현재 설계"의 주장과 모순되면 LLM 은 임의로 덮어쓰지 않고 사용자에게 (기존 주장 / 새 근거 / 제안 갱신)을 보여 주고 확인받은 뒤 반영한다. 확인 전에는 페이지 "반복·미결"에 `⚠ 충돌 대기` 로만 기록.
5. **출처 필수·검증 가능 주장 표기**: 모든 사실 주장은 출처(파일 경로 또는 spec/ADR)를 단다. 코드에서 기계적으로 확인 가능한 표·목록은 바로 위 줄에 `<!-- verify: <키> -->` 마커를 둔다 (키 목록과 검증 방법은 spec-30-02 가 정의하며, 본 spec 은 마커 문법과 위치 규칙만 정한다).
6. **페이지 크기 상한**: 컴포넌트 페이지 200줄, direction 150줄, threads 300줄(초과 시 오래된 "변경 이력"을 요약 1줄로 압축하고 원문 출처 링크 유지). 상한 검사는 테스트에서 시범 페이지에 대해 확인(doctor 경고화는 spec-30-02).
7. **인제스트 개정**: `/hk-wiki-ingest` 의 흐름을 (1) 대상 walkthrough 수집 (2) 해당 spec 의 Proposed Changes 경로 → `covers:` 매칭으로 영향 컴포넌트 결정 (3) 영향 컴포넌트 페이지만 읽고 갱신(요구사항 3·4) (4) 매칭 안 된 항목은 사용자에게 "새 컴포넌트 / direction / 버림" 선택 요청 (5) 번복·반복·미결을 `threads.md` 에 반영 (6) `log.md` 기록으로 바꾼다. `decisions.md`/`patterns.md` 직접 편집 단계는 제거한다.
8. **조회 규약 개정**: Query 표를 "현재 입장은 direction/components → 번복·미결은 threads → 출처별 상세는 decisions/patterns(로그) → 마지막으로 archive" 순으로 바꾼다. `CLAUDE.fragment.md` 의 wiki 질의 문구도 같은 순서로 맞춘다.
9. **기존 페이지 정합**: `decisions.md`/`patterns.md` 상단에 "출처별 로그(격하) — 현재 입장은 direction/components 참조" 배너. `direction.md`/`components/hooks.md` 의 hook 기본값 표 위에 `verify` 마커 부착. `index.md` 에 3층 안내 행 보강.

## Out of Scope

- 사실 검증 lint 구현, `verify` 키별 검증기, 크기 상한 doctor 경고 (→ spec-30-02)
- 남은 컴포넌트 페이지 5개와 `threads.md` 내용 작성 (→ spec-30-03). 본 spec 은 `threads.md` 의 *형식*만 schema 에 정의하고 빈 골격 파일은 만들지 않는다.
- ADR `supersedes`/`superseded_by` frontmatter 도입 — ADR 템플릿·doctor ADR 검사까지 건드려 문서 spec 의 성격을 벗어남. 번복은 우선 `threads.md` 와 변경 이력으로 추적하고, 필요성은 spec-30-03 에서 판단 (열린 질문)
- 기존 `decisions.md`/`patterns.md` 내용 재작성·삭제

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **append-only 폐지**: 기존 규칙을 정면으로 뒤집는다. 이력 보존 의무가 그 자리를 대신한다 (요구사항 3). 동의 여부 확인.
> - [ ] **충돌 시 사용자 확인 의무** (요구사항 4): 인제스트가 완전 자동이 아니게 된다. 사용자 합의(2026-10-22)에 따른 것.

> [!WARNING]
> - [ ] `/hk-wiki-ingest` 흐름이 바뀌어 다운스트림 프로젝트의 wiki 운용에 영향(`update.sh` 로 전파). `decisions.md`/`patterns.md` 를 이미 쓰는 프로젝트는 계속 읽을 수 있다 (삭제 없음).
> - [ ] 크기 상한 수치(200/150/300)는 시범 페이지(hooks 114줄, direction 69줄) 기준의 초기값이며 조정 가능.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **3층 정의** | 질문 중심 (방향=지금 잘 가나 / 구현=지금 어떻게 돼 있나 / 스레드=무엇이 반복·미결인가) | 출처 단위는 이 3개 질문에 답하지 못함 |
| **갱신 단위** | 컴포넌트 페이지 (walkthrough 아님) | 지식은 주제별로 모여야 "현재 입장"이 보임 |
| **spec↔컴포넌트 매핑** | 페이지 `covers:` ↔ spec `Proposed Changes` 경로 (기계적) | LLM 판단에 맡기면 매핑이 흔들림 |
| **충돌 처리** | 덮어쓰기 금지, 사용자 확인 후 반영 | 시범에서 LLM 이 사실을 두 번 틀렸음 (commit-msg, phase-03~06) |
| **검증** | 문서 계약 테스트(정적) + 인제스트 실사용 검증(수동) | 인제스트는 LLM 절차라 결정론 테스트 불가. 계약(필수 섹션·문구·마커·크기)은 정적으로 고정 |

## Proposed Changes

#### [NEW] `sources/templates/wiki-component.md` (+ 사본 `.harness-kit/agent/templates/wiki-component.md`)
컴포넌트 페이지 템플릿 (요구사항 2). `install.sh` 의 templates glob 으로 자동 설치됨.

#### [MODIFY] `doctor.sh`
필수 템플릿 목록(`for f in queue.md ...`)에 `wiki-component.md` 추가. `tests/test-doctor-templates.sh` 가 목록↔실제 템플릿 일치를 강제하므로 템플릿 추가의 필연적 결과 (Task 4 에서 발견, 계획 외 1줄 보정).

#### [MODIFY] `docs/wiki/schema.md`
3층 정의, 페이지 종류별 frontmatter(`covers`), 갱신·충돌·출처·verify 마커·크기 상한 규약, Ingest/Query/Lint 절 개정. "운영 규칙 1~5" 중 append-only 문구 제거.

#### [MODIFY] `sources/commands/hk-wiki-ingest.md` (+ 사본 `.claude/commands/hk-wiki-ingest.md`)
요구사항 7 흐름으로 재작성. "삭제하거나 교체하지 않는다" 문구 제거, 이력 보존·충돌 확인 단계 추가.

#### [MODIFY] `sources/claude-fragments/CLAUDE.fragment.md` (+ 사본 `.harness-kit/CLAUDE.fragment.md`)
wiki 질의 문구를 조회 순서(요구사항 8)에 맞춤.

#### [MODIFY] `docs/wiki/decisions.md`, `docs/wiki/patterns.md`, `docs/wiki/index.md`, `docs/wiki/direction.md`, `docs/wiki/components/hooks.md`
요구사항 9. 배너·마커·안내 행만 추가. 본문 내용 불변.

#### [NEW] `tests/test-wiki-schema-v2.sh`
계약 테스트 (검증 계획 참조). `tests/run.sh` 는 glob 으로 자동 포함되는지 Task 1 에서 확인.

## 검증 계획

```bash
bash tests/test-wiki-schema-v2.sh
bash tests/test-wiki-ingest.sh
bash tests/test-wiki-structure.sh
bash tests/test-doctor-wiki.sh
bash tests/run.sh
```

`test-wiki-schema-v2.sh` 케이스:
1. 템플릿 존재 + 필수 섹션 6개 + frontmatter 필드 (`sources/` 와 사본 동일)
2. schema.md: 3층 정의·충돌 규약·`verify` 마커·크기 상한 문구 존재, "삭제하거나 교체하지 않는다" 부재
3. hk-wiki-ingest.md: `covers` 매핑·충돌 사용자 확인·이력 보존 문구 존재, `decisions.md` 직접 편집 단계 부재 (원본·사본 동일)
4. 시범 페이지(direction, hooks)가 템플릿 필수 섹션을 갖고 크기 상한 이내
5. 시범 hooks.md 의 hook 표 위에 `verify` 마커 존재
6. decisions.md/patterns.md 에 격하 배너 존재, 본문 줄 수는 불감소(삭제 없음)
7. fragment 의 조회 순서 문구가 direction/components 를 먼저 가리킴

수동 검증 시나리오:
1. 인제스트 실사용 — phase-28·29 archive 후 `/hk-wiki-ingest` 를 새 규약으로 실행해 (a) 영향 컴포넌트만 갱신 (b) 매핑 불가 항목에서 사용자에게 질문 (c) 기존 주장 변경 시 이력 보존 (d) 충돌 시 확인 요청이 나오는지 확인. 결과를 walkthrough 에 기록 (성공 기준 4 의 행동 검증; 정적 계약 테스트는 문구만 고정함을 명시).

## 롤백 계획

- 문서·템플릿·커맨드 변경뿐이므로 `git revert`. state·마이그레이션·외부 부수효과 없음.
- `decisions.md`/`patterns.md` 는 내용을 지우지 않으므로 롤백 시 손실 없음.

## ADR 후보

- [x] ADR 가치 있는 결정 있음 → 후보: `wiki-update-in-place-with-history` (type: convention) — "wiki 는 append-only 가 아니라 제자리 갱신 + 이력 보존 + 충돌 시 사용자 확인". ADR-003(wiki frontmatter schema) 규약을 개정하므로 spec-30-01 ship 시 작성 여부를 사용자와 확인
- [ ] 없음

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (`tests/test-wiki-schema-v2.sh` 포함, 전체 회귀 0)
- [ ] 수동 검증 시나리오 1 결과 walkthrough 기록 (또는 phase 종료 시 인제스트로 이월 명시)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-30-01-wiki-three-layer-schema` 브랜치 push 완료
