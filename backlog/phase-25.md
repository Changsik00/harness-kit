# phase-25: auto-reliability (auto 신뢰성)

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-25-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.
> (draft — phase-24 merge 후 `sdd phase activate phase-25` 로 활성화. 진행 중 §11.3 재검증으로 조정 가능.)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-25` |
| **상태** | In Progress |
| **시작일** | 2026-06-22 |
| **목표 종료일** | TBD |
| **소유자** | dennis |
| **Base Branch** | phase-25-auto-reliability |

## 🎯 배경 및 목표

### 현재 상황

phase-24 가 auto 모드의 **배관**(모드 전환·논블로킹 resolver·정지규칙 엔진·결정 로그·phase-ship rollup)을 완성했다. 그러나 phase-review(2026-06-22)에서 auto 가 *실제로 안전하게 자율*하려면 필요한 두 기둥이 미구현임이 드러났다 (→ ADR-009 Addendum):

1. **논블로킹의 기계적 백스톱 부재.** auto 의 "안 멈춤"이 agent.md §8.4 산문 한 줄에만 의존한다. Claude Code 시스템 프롬프트는 결정 지점에서 `AskUserQuestion` 을 *권장*하므로, auto 는 모델 기본 행동과 산문으로 싸우는 약한 구조다. spec-24-04 는 "hook 으로 못 막는다"고 닫았으나, `PreToolUse` matcher 는 도구명 임의 매칭이라 `AskUserQuestion` 호출을 가로챌 수 있다(전제 정정).

2. **사후 테스트의 신뢰 미보강.** ADR-009 가 "안전이 사후 테스트 품질에 전적으로 의존"이라 명시했으나, 테스트 *자체의 신뢰도*(GitHub #212 칸0)는 0건. unattended 는 가짜 green 의 폭발 반경을 키운다.

이 둘이 없는 auto 도그푸딩은 *검증되지 않은 자율*이다.

### 목표 (Goal)

auto 모드를 **"걸어두고 딴 일"이 실제로 안전한 수준**으로 끌어올린다 — 논블로킹을 기계적으로 보장하고(routine 은 안 멈춤, ①은 단일 채널로 멈춤), 사후 검증의 신뢰를 최소 1차 방어선까지 올리고, "산문만으로 충분한가"를 e2e 로 *측정*한다. 이 phase 종료 후 auto 첫 도그푸딩이 정당화된다.

### 성공 기준 (Success Criteria) — 정량 우선
1. auto 모드에서 `AskUserQuestion` 호출이 `PreToolUse` hook 으로 가로채져 기본값+`sdd decision add` 로 리다이렉트됨을 테스트로 증명. governed/turbo 에서는 hook 무간섭(회귀 테스트).
2. GitHub #212 칸0(revert/over-mock 경고 hook) 존재 + "구현을 의도적으로 훼손하면 테스트가 빨개지는가"를 검증하는 메타 테스트 1건 이상.
3. `test-e2e-auto-mode.sh` 신규 — auto 한 사이클에서 "routine 결정에서 안 멈춤 + 정지규칙에서 멈춤"을 *실제 실행*으로 증명(phase-24 carry-over C1).
4. `check-irreversible` 차단 모드(exit 2) 승격 + settings `deny` 와의 층위 불일치(deny 는 완전 차단, ②는 "멈추고 대기") 해소.
5. 전체 테스트 PASS + 거버넌스 단어 예산(≤8000) 준수.

## 🧩 작업 단위 (SPEC + phase-FF)

> 본 절은 phase 의 *작업 지도* 입니다. 실질적/불확실 → **SPEC**, 작고 가역적인 1–2 commit → **phase-FF**.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-25-01` | askquestion-redirect-hook | P? | Merged | `specs/spec-25-01-askquestion-redirect-hook/` |
| `spec-25-02` | test-trust-revert-check | P1 | Backlog | `specs/spec-25-02-test-trust-revert-check/` |
| `spec-25-03` | auto-e2e | P1 | Backlog | `specs/spec-25-03-auto-e2e/` |
| `spec-25-04` | irreversible-block-promotion | P2 | Backlog | `specs/spec-25-04-irreversible-block-promotion/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-25-01 — AskUserQuestion 리다이렉트 hook (auto 논블로킹 기계적 백스톱)

- **요점**: auto 모드에서 `AskUserQuestion` 호출을 `PreToolUse` hook 으로 가로채 exit 2 + stderr 리다이렉트 — routine 은 기본값+`decision add` 후 진행, ①은 `decision add "미해결" + 턴 종료` 단일 채널로 유도. 24-04 의 "hook 불가" 전제를 뒤집는다.
- **방향성**: `.claude/settings.json` 에 `PreToolUse` matcher `"AskUserQuestion"` 추가 + 신규 hook `check-askquestion-auto.sh`. mode != auto → exit 0. mode == auto → exit 2 + 안내. hook 단계론과 무관(차단이 목적). `AskUserQuestion` 도구가 정말 PreToolUse 대상인지 1개 프로토타입으로 선검증.
- **참조**: ADR-009 Addendum 1, GitHub #181(논블로킹), spec-24-04 walkthrough(정정 대상)
- **연관 모듈**: `sources/hooks/`, `.claude/settings.json`, `sources/governance/agent.md` §8.4

### spec-25-02 — 사후 테스트 신뢰 칸0 (revert/over-mock 체크)

- **요점**: "구현을 망가뜨리면 테스트가 빨개지나?"를 검증하는 가장 싼(토큰 0) 1차 방어선. 가짜 green(동어반복·over-mock)을 잡는다.
- **방향성**: GitHub #212 비용 사다리의 칸0. 경고 모드로 시작. auto 의 post-commit-verify 가 "테스트 통과"를 신호로 쓰는데 그 테스트가 거짓이면 안전망 전체가 거짓 — 이 갭을 1차로 막는다. 구현 형태(스크립트/메타 테스트)는 spec 에서 결정.
- **참조**: ADR-009 Addendum 2, GitHub #212(칸0)
- **연관 모듈**: `sources/hooks/post-commit-verify.sh`, `tests/`

### spec-25-03 — auto e2e (측정)

- **요점**: `test-e2e-auto-mode.sh` 신규. auto 한 사이클을 실제로 돌려 "routine 결정에서 안 멈춤 + 정지규칙에서 멈춤"을 증명. "산문만으로 충분한가 vs hook 이 꼭 필요한가"의 *측정기*.
- **방향성**: phase-24 carry-over(C1). spec-25-01 의 hook 효과를 e2e 로 확인. decision log 가 실제로 쌓이는지(현재 0건) 검증.
- **참조**: phase-24 시나리오 1·2, spec-24-05 이월 항목
- **연관 모듈**: `tests/test-e2e-auto-mode.sh`(신규)

### spec-25-04 — 정지규칙 ② 차단 승격 + deny 층위 정합

- **요점**: `check-irreversible` 를 경고(exit 0) → 차단(exit 2) 승격. settings `deny`(완전 차단)와 ②("멈추고 대기")의 층위 불일치 해소 — auto 가 정당한 복구로 deny 명령을 만나면 프롬프트 없이 데드락되는 문제(phase-review W3) 정리.
- **방향성**: 경고 모드 1주 운영 경과 확인 후 승격(hook 단계론). deny 와 hook 의 역할 경계를 ADR 또는 hook 주석으로 명문화.
- **참조**: ADR-009 규약 3·②, phase-review W3, check-irreversible 이월(3개 spec)
- **연관 모듈**: `sources/hooks/check-irreversible.sh`, `.claude/settings.json`

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 phase base 브랜치에 직접 커밋(phase-FF, → ADR-004).

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| `autoFailCount` ship 리셋 | `sdd ship` 이 spec 전환 시 정지규칙③ 카운터를 리셋하지 않아 이전 spec 실패가 이월(phase-review W1) | 1 |
| post-commit-verify 600s 윈도우 분기 | auto 가 한 커밋에 10분+ 쓰면 검증·revert·카운터가 통째로 스킵(phase-review C3) — auto 에서 윈도우 만료 시 스킵하지 않도록 분기 | 1 |

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| (착수 시 기록) | | | |

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: auto routine 결정 — 안 멈춤
- **Given**: `sdd mode auto` + agent 가 결정 지점에서 `AskUserQuestion` 호출 시도
- **When**: `PreToolUse` hook(spec-25-01)이 가로챔
- **Then**: exit 2 + 안내로 기본값 채택 + `sdd decision add` 후 진행, *멈추지 않음*. decision log 에 항목 누적
- **연관 SPEC**: spec-25-01, spec-25-03

### 시나리오 2: 정지규칙 ② — 실제 hard stop
- **Given**: auto 모드 실행 중 비가역 행동 시도
- **When**: `check-irreversible`(차단 승격, spec-25-04)
- **Then**: exit 2 로 멈추고 사람 대기(notify 발송)
- **연관 SPEC**: spec-25-04, spec-25-03

### 시나리오 3: 가짜 green 1차 방어
- **Given**: 구현을 의도적으로 훼손(revert/over-mock)
- **When**: 칸0 체크(spec-25-02)
- **Then**: 경고(또는 차단)로 적발
- **연관 SPEC**: spec-25-02

### 통합 테스트 실행
```bash
bash tests/test-e2e-auto-mode.sh
```

## 🔗 의존성

- **선행 phase**: phase-24 (auto 토대) — merge 선행 필수
- **외부 시스템**: 없음 (bash 3.2 + git + gh + Claude Code hook 런타임)
- **연관 ADR**:
  - `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md` (+Addendum, 거버닝)
- **연관 이슈**: GitHub #212(테스트 신뢰 비용 사다리), #181(하네스 격차 3건)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| `AskUserQuestion` 이 `PreToolUse` 대상이 아닐 가능성 | spec-25-01 의 기계적 백스톱 불성립 | spec 착수 전 1개 프로토타입으로 hook 가로채기 선검증. 불가 시 대안(Notification hook 기반 감시) 재설계 |
| hook 이 정당한 ① 정지까지 막음 | auto 가 멈춰야 할 때 못 멈춤 | `AskUserQuestion` 은 auto 에서 전면 비활성, ①은 `decision add + 턴 종료` 단일 채널로 분리(ADR-009 Addendum) |
| 칸0 false positive | 자율성 저하 | 경고 모드 시작, 차단 승격은 운영 후 |
| 거버넌스 단어수 한계 | auto 규칙 추가 시 8000 초과 | 상세는 ADR-009 Addendum 으로 위임, agent.md 엔 포인터만 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (base 모드: `phase-25` → main / 일반: 각 spec → main)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
