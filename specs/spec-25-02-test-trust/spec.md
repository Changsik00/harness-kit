# spec-25-02: 사후 테스트 신뢰 — 칸0(commit-time 휴리스틱) + 칸2(위험비례 적대적 반증 골격)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-25-02` |
| **Phase** | `phase-25` |
| **Branch** | `spec-25-02-test-trust` |
| **Base 브랜치** | `phase-25-auto-reliability` (base 모드) |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-06-22 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

ADR-009 는 auto 의 안전이 *사후 검증*에 의존한다고 명시했고, `post-commit-verify` 가 커밋마다 테스트를 돌려 그 신호("테스트 통과")로 진행/revert 를 판단한다. spec-25-01 이 auto 의 "안 멈춤"을 기계적으로 보장하면서, 이제 **안 멈추고 직진할 때 그 결과를 믿을 수 있는가**가 유일하게 남은 load-bearing 지점이다 (GitHub #212).

### 문제점

`post-commit-verify` 는 "테스트가 통과했나"만 본다. **그 테스트가 거짓이면 안전망 전체가 거짓**이다 (#212). 에이전트 TDD 가 가짜 green 을 내는 메커니즘은 셋:
1. **동어반복** — 코드와 테스트가 같은 저자·같은 오해 → 틀려도 초록불
2. **가짜 red** — 올바른 이유로 먼저 실패하는 red 를 스킵
3. **방향 오류 무탐지** — 코드의 *동작*만 인코딩, *의도*는 안 함 → 회귀만 잡고 초반 방향 오류는 못 잡음

unattended(auto)는 이 가짜 green 의 폭발 반경을 키운다. 현재 키트엔 *테스트 자체의 신뢰도*를 보는 장치가 0건이다.

### 해결 방안

#212 비용 사다리를 **위험 비례**로 도입한다. 잡는 결이 다른 두 칸을 함께 둔다:
- **칸0 (상시·토큰 0)**: 커밋 시점 휴리스틱으로 *동어반복·over-mock* 류 가짜 green 을 싸게 적발 — "구현이 바뀌었는데 테스트는 안 바뀜" / "단언 없는 테스트". 경고.
- **칸2 (위험 비례·골격)**: 비가역/고위험 변경에서, **코드가 아니라 의도(spec)에 앵커**한 적대적 *반증* 패스를 권고·기동하는 골격(트리거 + 절차 + 커맨드). auto 가 못 잡는 *방향 오류*를 겨냥.

## 요구사항

1. **칸0 hook**: 커밋 시점(staged diff)에 (a) 구현 파일 변경 + 대응 테스트 변경 없음, 또는 (b) 추가/변경된 테스트에 단언(assert/expect/`[ ]` 등)이 없음 → 경고. 스택 무관·토큰 0·경고 모드.
2. **칸2 골격**: 고위험 신호(기존 `check-irreversible`/`check-scope` 위험 판정 재사용)일 때, "spec.md 의도에 앵커한 적대적 *반증* 패스를 ship 전 수행하라"는 경고 + 그 패스를 실행하는 커맨드(`hk-refute`) 골격 + agent.md 절차 1줄.
3. **위험 비례**: 칸0 은 항상, 칸2 는 고위험에서만. 라인 수가 아니라 위험으로 게이트.
4. 테스트가 칸0 경고 발동/미발동 경계와 칸2 트리거 조건을 고정.
5. 도그푸딩 미러 (sources ↔ .harness-kit ↔ .claude/settings.json).

## Out of Scope

- **칸1 (뮤테이션 테스트)** — 컴퓨트 비쌈·중요모듈 한정 → queue.md Icebox(phase-26).
- **칸2 의 완전 자동 LLM 실행** — 적대적 반증은 본질적으로 에이전트 구동(서브에이전트 디스패치)이라, 본 spec 은 *골격*(트리거+커맨드+절차)까지. 완전 통합은 운영 후.
- **차단(block) 모드** — 둘 다 경고로 시작 (hook 단계론).
- 칸0 의 스택별 정밀 over-mock 분석 (예: jest mock SUT 탐지) — 1차는 스택 무관 휴리스틱만.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **칸0 휴리스틱의 의미성**: "구현 변경 + 테스트 무변경"은 스택 무관·싸지만 *coarse*(리팩터·문서성 변경에 오탐 가능). 경고 모드라 영향은 제한적이나, 신호가 노이즈 대비 가치 있는지 검토 필요. (안전 경로 화이트리스트로 오탐 억제 예정)
> - [ ] **칸0 ↔ 칸2 구조 차이 (분할 결정)**: 칸0 은 결정론적 bash hook, 칸2 는 *에이전트 구동 절차*(커맨드+거버넌스)다. 성격이 달라 한 spec 이 커질 수 있음. **권장: critique 로 먼저 검증** 후, 과대하면 칸2 를 `spec-25-05` 로 분리. (phase-25.md 분할 출구 기등록)

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **칸0** | commit-time hook (`check-scope` 의 `HARNESS_GIT_HOOK_MODE` 패턴 재사용), staged diff 휴리스틱, 경고 | 토큰 0·스택 무관·상시. "revert 하면 빨개지나"의 정적 프록시 = "구현 변경에 테스트 동반했나" |
| **칸0 오탐 억제** | 안전 경로 화이트리스트(docs/·*.md·backlog/ 등) + 단언 패턴은 스택별 집합 | 리팩터/문서 커밋 오탐 최소화 |
| **칸2 트리거** | 기존 `check-irreversible`/`check-scope` 위험 신호 재사용 → 경고 프롬프트 | "라인 수 아닌 위험" — 신호 중복 구현 회피 |
| **칸2 절차** | `hk-refute` 커맨드 골격: spec.md 의도에 앵커한 *반증* 서브에이전트 디스패치 (hk-spec-critique 형제, 프레이밍은 refute) | 칸2 는 LLM 구동 — bash hook 불가. 의도 앵커가 동어반복을 끊음 |
| **독립성 원천** | "다른 모델"이 아니라 "구현 멘탈 상태 미공유"(fresh 컨텍스트) | #212 — 중위험은 fresh 컨텍스트로 충분 |

## Proposed Changes

#### [NEW] `sources/hooks/check-test-trust.sh`
칸0 — commit-time(`HARNESS_GIT_HOOK_MODE=1`) staged diff 검사. 구현 변경 ∧ 테스트 무변경, 또는 단언 없는 테스트 추가 → `hook_violation`(경고). 안전 경로 화이트리스트. mode 무관(blast-radius 가드처럼 항상).

#### [NEW] `sources/commands/hk-refute.md`
칸2 골격 — 현재 spec 의 고위험 diff 를 `spec.md` 의도에 앵커해 *반증*하는 서브에이전트 디스패치 절차. "이 테스트 다 통과해도 합의된 의도가 깨지는 경우를 찾아라". `hk-spec-critique` 형제이되 입력이 코드가 아닌 intent.

#### [MODIFY] `sources/governance/agent.md` (§6.7 Review orchestration, 최소)
위험 비례 refute 렌즈 1줄 — 고위험 변경 시 `hk-refute` 권고(칸2, spec-25-02). 단어 예산 ≤8000.

#### [MODIFY] git pre-commit 등록 + 도그푸딩 미러
`check-test-trust.sh` 를 commit-time hook 으로 등록(`check-scope` commit-mode 와 동일 경로). `.harness-kit/hooks/` + `.claude/` + `sources/commands` → `.claude/commands` 미러.

#### [NEW] `tests/test-test-trust.sh`
칸0: 구현+테스트 무변경 → 경고 / 구현+테스트 동반 → 무경고 / 단언 없는 테스트 → 경고 / 안전 경로(docs·md) → 무경고. (칸2 트리거 조건은 골격 — 커맨드 존재 + 위험신호 분기 smoke.)

## 검증 계획

```bash
bash tests/test-test-trust.sh
bash tests/run.sh
```

수동 검증:
1. 구현만 바꾼 staged 커밋 시도 → 칸0 경고 확인.
2. 고위험 변경(check-irreversible 신호) 상황에서 `hk-refute` 권고 노출 확인.

## 롤백 계획

- `git revert` — hook/커맨드/테스트 코드만. state·마이그레이션 영향 없음.
- pre-commit 등록 제거 시 칸0 미발동 — 기존 동작 복귀.

## ADR 후보

- [x] 가치 있는 결정 가능 → 후보: "테스트 신뢰를 위험 비례로 — 칸0 정적 + 칸2 의도앵커" (type: tradeoff). 단 ADR-009 Addendum 2 가 방향을 담음 — walkthrough 로 충분할 수 있음. Ship 시 판단.
- [ ] 없음

## ✅ Definition of Done

- [ ] `tests/test-test-trust.sh` PASS + 전체 회귀 PASS
- [ ] 칸0 경고 경계 고정 + 칸2 골격(커맨드+트리거+절차) 존재
- [ ] sources ↔ 설치본 미러 동일
- [ ] `walkthrough.md` / `pr_description.md` ship commit
- [ ] `spec-25-02-test-trust` 브랜치 push
