# phase-29: doctor-accuracy

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-29-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-29` |
| **상태** | In Progress |
| **시작일** | 2026-10-21 |
| **목표 종료일** | - |
| **소유자** | changsik |
| **Base Branch** | `phase-29-doctor-accuracy` |

## 🎯 배경 및 목표

### 현재 상황

phase-27(docs-integrity)이 ADR 인덱스·무결성 검사를 도입했고, phase-28(docs-freshness)이 wiki 낡음·원본↔사본 drift 검사와 wikilink 오탐 교정을 더했다. 그러나 phase-27 회고에서 나온 `sdd doctor` 검사기의 정확도 구멍 4건이 Icebox 에 남아 있다. 모두 작고 같은 영역(`sources/bin/sdd` 의 ADR 검사)이며 회귀 테스트가 없다.

2026-10-21 착수 점검에서, 같은 Icebox 에 있던 phase-25/26 후속 3건(fail-open 일관성·우회 변형 테스트·settings 미러 잔재)은 0.21.0(phase-26)에서 이미 해소돼 있음을 확인했다(`test-stop-rules.sh` W1/W2, spec-26-01). 본 phase 에서 Icebox 정리만 한다.

### 목표 (Goal)

`sdd doctor` 의 ADR 검사가 frontmatter 경계·`type:` 값·경로 오탐 패턴을 정확히 판정하게 하고, 각각 회귀 테스트로 고정한다.

### 성공 기준 (Success Criteria) — 정량 우선
1. frontmatter 없는 ADR 본문의 우연한 `id:` 줄이 인덱스/중복 판정에 쓰이지 않는다 (회귀 테스트).
2. `type:` 이 폐쇄 어휘(decision/invariant/convention/tradeoff) 밖이면 doctor 가 경고한다. 템플릿 인라인 주석이 남아 있어도 값은 주석을 제외하고 판정한다.
3. 모노레포 path alias(`@app/foo/bar.ts`)는 stale 검사에서 제외되지 않고, npm 스코프 패키지(`@scope/pkg@1.0`)는 계속 제외된다 (회귀 테스트).
4. 전체 테스트 회귀 0.

## 🧩 작업 단위 (SPEC + phase-FF)

> 모든 항목이 작고 같은 영역이라 SPEC 없이 phase-FF 로 처리한다 (ADR-004, right-size).

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 phase base 브랜치에 직접 커밋(phase-FF, → ADR-004). 착수 시 §11.3 재검증으로 크기를 재확인하고, 커질 경우 SPEC 으로 승격합니다. (draft — 진행 중 조정 가능)

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| adr-field-frontmatter-bound | `_adr_field` 가 `---`~`---` 블록 안에서만 필드를 읽는다. 회귀 테스트 | 2 |
| adr-type-closure-check | doctor 가 ADR `type:` 값이 폐쇄 어휘 안인지 검증(주석 제거 후 판정). 템플릿 인라인 주석 footgun 은 힌트를 줄 밖으로 이동 | 2 |
| stale-adr-alias-pattern | `_drift_stale_adr` 의 `^@` 를 npm 스코프(`@scope/pkg`) 에 한정. alias 경로는 제외하지 않음. 회귀 테스트 | 2 |
| icebox-cleanup-29 | 해소 확인된 phase-25/26 후속 3건과 본 phase 처리 항목을 Icebox 에서 정리 | 1 |

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 작업 구성 | spec 1개 묶음 / 항목별 phase-FF | **phase-FF 4건** | 모두 1–2 commit, 같은 영역, 가역적 (ADR-004) |
| phase-25/26 후속 3건 | phase 에 포함 / 해소 확인 후 정리 | **정리** | 0.21.0 에서 해소, 테스트로 고정돼 있음 (착수 점검 2026-10-21) |
| Stop-hook 검증 게이트 (#181 제안 2) | 본 phase / 별도 | **별도 phase** | auto 정지규칙과 정합 설계 필요 — 큰 설계 건 |
| wiki 개편 (phase 주제 외) | 살린다 / 줄인다 | **살린다 — phase-FF 2커밋** | 에이전트가 wiki 를 읽는 경로가 없어 증류 비용이 낭비됨. `purpose.md` → `schema.md`(Ingest/Query/Lint 규칙) |
| wiki 질의 규칙 위치 | agent.md / CLAUDE.fragment | **CLAUDE.fragment** | governance 가 이미 7000w 상한 초과(7902w), fragment 는 항상 로드됨 |
| fragment 150w 상한 | 상한 완화 / 패턴 요약 축약 | **패턴 요약 축약** | `test-two-tier-loading` 상한 유지, 질의 규칙 우선 |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: ADR 검사기 정확도
- **Given**: frontmatter 없는 ADR(본문에 `id:` 줄), `type:` 어휘 밖 ADR, alias 경로를 인용한 ADR 이 있는 fixture
- **When**: `sdd doctor` / `sdd status` 실행
- **Then**: 첫째는 frontmatter 누락으로 판정되고 오염된 인덱스 행이 없다, 둘째는 type 경고, 셋째는 stale 로 검출된다. 정상 ADR 은 침묵
- **연관**: phase-FF 3건

### 통합 테스트 실행
```bash
bash tests/run.sh
```

## 🔗 의존성

- **선행 phase**: phase-27 (docs-integrity), phase-28 (docs-freshness)
- **외부 시스템**: 없음
- **연관 ADR**: `docs/decisions/ADR-003-wiki-frontmatter-schema.md`

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| type 검증이 기존 ADR 을 경고로 오판 | doctor 소음 | 기존 ADR-001~009 전수 통과를 테스트로 확인 후 경고 단계로 시작 |
| alias 제외 해제로 다운스트림 stale 오탐 증가 | status 소음 | 경고 수준 유지, npm 스코프·IAM 제외는 보존 |

## 🏁 Phase Done 조건

- [x] phase-FF 4건 완료 (+ 주제 외 wiki 개편 1건)
- [x] 통합 테스트 시나리오 PASS
- [x] 성공 기준 측정 결과 기록
- [x] 사용자 최종 승인 (2026-10-22)

## 📊 검증 결과 (phase 완료 시 작성)

| # | 기준 | 결과 | 증거 |
|:---:|---|:---:|---|
| 1 | frontmatter 밖 `id:` 무시 | ✅ PASS | `tests/test-adr-accuracy.sh` 케이스 1 |
| 2 | `type:` 폐쇄 어휘 경고, 주석 제외 | ✅ PASS | 케이스 2, 3, 4 |
| 3 | alias 경로 비제외, npm 스코프 제외 | ✅ PASS | 케이스 5, 6 |
| 4 | 전체 테스트 회귀 0 | ✅ PASS | `tests/run.sh` 85/85 (`HARNESS_DRIFT_FETCH=0`) |

- 통합 시나리오 1(ADR 검사기 정확도): `test-adr-accuracy` 6/6 PASS.
- 알려진 이슈: `test-sdd-status-cross-check` 가 원격 fetch 대기로 멈출 수 있음 (`HARNESS_DRIFT_FETCH=0` 으로 통과).
