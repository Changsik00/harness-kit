# spec-20-04: 모델 역할 config + review 패널 + 중재 패턴 (디렉터 모드 마무리)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-20-04` |
| **Phase** | `phase-20` |
| **Branch** | `spec-20-04-model-config-and-review` |
| **상태** | Planning |
| **타입** | Feature (번들 — 구 spec-20-04 + 20-05 + 20-06) |
| **Integration Test Required** | no |
| **작성일** | 2026-06-04 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

phase-20 의 앞 3 spec 으로 디렉터 모드의 *뼈대*가 섰다: 스위치(20-01) + 운영 프로토콜 §6.8(20-02) + SDD ceremony 분업 §6.1(20-03). 남은 3 조각은 모두 **개별로는 작은 변경**이라, 처음 계획대로 각각 full spec 으로 진행하면 형식 채우기가 실제 작업을 압도한다(D4). 따라서 한 ceremony 유닛으로 묶는다.

남은 3 조각:
1. **모델 역할 config**: `agent.md §6.6` 은 아직 `Opus(main) / Sonnet(sub) / Opus(review)` 식 **2-tier + 모델 이름 하드코딩** 표다. 모델 세대는 빠르게 churn 하는데(constitution §13) 이름이 거버넌스 본문에 박혀 있어, 세대 교체마다 거버넌스를 손대야 한다. 또 scout(검색·기계 작업용 저비용 티어)가 1급으로 정의돼 있지 않다.
2. **review 패널**: `hk-code-review` / `hk-spec-critique` / `hk-phase-review` 는 **단일 Opus 서브에이전트**로 단정돼 있다(§6.6 표 + 각 커맨드). 디렉터 모드의 핵심인 "페르소나 패널 → 디렉터 종합·중재"가 빠져 있다.
3. **중재 패턴(구 20-05)**: front↔back 도메인 에이전트 협상에 디렉터가 끼어 아키텍처·over-engineering 을 중재하는 패턴. 단, harness-kit 은 front/back 앱이 아니라 *실동작 POC 대상이 없다* — 따라서 *작동 실험*이 아니라 **재사용 가능한 패턴 기록**으로 남기는 게 현 단계의 올바른 산출이다.

### 문제점

- **모델 이름 하드코딩 → 거버넌스 부채**: 모델 교체마다 §6.6 수정. de-hardcode 안 하면 phase-20 의 "역할 기반" 목표(성공기준 4) 미달.
- **review 가 디렉터 모드와 단절**: 모드를 켜도 리뷰는 여전히 단일 에이전트 — 패널·중재 가치를 못 살림.
- **중재 패턴이 휘발**: 설계 대화에서 얻은 통찰(종료조건·증류)이 기록되지 않으면 다음에 재발견 비용.

### 해결 방안 (요약)

① §6.6 을 **director/worker/scout 역할 표**로 재작성하고 실제 모델은 `harness.config.json` 의 `models` 매핑으로 분리(이름 de-hardcode), `sdd config models` 로 조회. ② 3개 review 커맨드에 **페르소나 패널 옵션**을 추가(디렉터가 렌즈별 워커 병렬 → 종합·중재; 소규모 diff 는 단일 fallback), agent.md §6.7 에 1줄 참조. ③ 중재 패턴을 `docs/wiki/patterns.md` 의 good-pattern 1개로 기록. agent.md 에는 **새 절을 만들지 않고** §6.6 교체 + §6.7 1줄로 흡수(앞 spec 들이 같은 파일을 분절적으로 건드린 문제 회피 — §6.1/§6.6/§6.7/§6.8 일관성 점검 포함).

## 🎯 요구사항

### Functional Requirements

1. **역할 표 (§6.6 재작성)**: agent.md §6.6 을 director/worker/scout 3역할 + 각 역할 *책무*로 재작성. director=판단·아키텍처·게이트, worker=구현·문서작성·Strict Loop, scout=검색·grep sweep·로그 triage·기계적 편집. 모델 *이름*은 본문에서 제거하고 "→ `harness.config.json` `models`" 참조.
2. **config 매핑**: `harness.config.json` 에 `"models": {"director","worker","scout"}` (별칭값). 키 부재 시 기본값(director=opus, worker=sonnet, scout=haiku) fallback.
3. **`sdd config models`**: 현재 매핑을 조회 출력(set 은 범위 밖 — 조회로 충분). `sdd config ux-mode`/`director-mode` 와 대칭.
4. **review 패널 옵션**: `hk-code-review` / `hk-spec-critique` / `hk-phase-review` 각 커맨드에 "디렉터 모드 활성 시 페르소나 패널(correctness/security/perf/test-coverage 렌즈 워커 병렬 → 디렉터 종합·중재)" 절 추가. **소규모 diff 는 단일 리뷰어 fallback**(패널 over-kill 방지). agent.md §6.7 에 1줄 cross-ref.
5. **중재 패턴 기록**: `docs/wiki/patterns.md` 에 `mediated-design-dialogue` good-pattern — front↔back 협상 + 디렉터 중재, **종료조건**(무한 핑퐁 방지)과 **증류**(디렉터는 수렴 계약+자기 개입만 흡수) 포함.

### Non-Functional Requirements

1. **단어 예산 ≤ 8000w** (constitution §13). §6.6 은 *교체*라 중립 목표. 초과 시 멈추고 디렉터 보고(§13 prune 은 별도).
2. **모델 이름 하드코딩 0** (성공기준 4) — agent.md 본문 기준.
3. **이중 미러** parity: `sources/governance/agent.md`↔`.harness-kit/agent/agent.md`, `sources/commands/*`↔`.claude/commands/*`, `sources/bin/sdd`↔`.harness-kit/bin/sdd`.
4. bash 3.2 / BSD 호환. 거버넌스 영어, 산출물·patterns.md 한국어.
5. **회귀 안전**: review 패널은 *옵션* — 디렉터 모드 off 또는 소규모 diff 면 기존 단일 리뷰어 동작 유지.

## 🚫 Out of Scope

- 중재 패턴의 실동작 POC(`scripts/research/`) — harness-kit 에 front/back 앱 부재. patterns.md 문서화까지만.
- `sdd config models set`(매핑 변경) — 조회만. 변경은 파일 직접 편집(드문 작업).
- §13 governance prune — 단어 예산이 8000w 넘으면 별도 spec-x.
- README "모델 분배" 행 동기화 — phase-FF 항목으로 분리(phase.md).

## 📑 ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — ADR-005/006 의 운영 구체화. 역할 기반 config 는 §6.6 + harness.config.json 으로 충분, 신규 ADR 불필요.

## 🔗 관련 문서

- 관련 ADR: [[ADR-005]] (context-orchestration), [[ADR-006]] (director-mode)
- 관련 wiki: [[wiki/patterns]] (mediated-design-dialogue 추가 대상)
- 선행: spec-20-01/02/03 (스위치·프로토콜·분업) — 본 spec 이 모델 티어·리뷰·패턴으로 마감
- 참고 패턴: agent.md §6.7 judge panel / perspective-diverse verify

## ✅ Definition of Done

- [ ] `tests/test-director-mode.sh` 확장(역할표 grep + `sdd config models` + 미러 parity) 전체 PASS
- [ ] `test-governance-dedup.sh` PASS (단어 예산 ≤8000w)
- [ ] agent.md 본문 모델 이름 하드코딩 0 확인
- [ ] review 패널 옵션 3개 커맨드 반영 + 단일 fallback 명시
- [ ] `walkthrough.md` / `pr_description.md` ship + base PR
