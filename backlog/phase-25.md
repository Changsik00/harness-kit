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
2. GitHub #212 비용 사다리 — **칸0**(revert/over-mock 경고 hook, 상시) 존재 + "구현을 의도적으로 훼손하면 테스트가 빨개지는가" 메타 테스트 1건 이상, **그리고 칸2 골격**(위험 비례 적대적 검토: 비가역/고위험 변경 시 *의도(spec)에 앵커*해 "테스트 다 통과해도 합의된 의도가 깨질 경우를 반증" — 기존 commit-scope/irreversible 신호를 트리거로 재사용) 도입.
3. `test-e2e-auto-mode.sh` 신규 — auto 한 사이클에서 "routine 결정에서 안 멈춤 + 정지규칙에서 멈춤"을 *실제 실행*으로 증명(phase-24 carry-over C1).
4. settings `deny`(never-justify, 완전 차단) ↔ `check-irreversible` ②(context-dependent, 멈추고 대기) **2층 모델 명문화** + 데드락(W3) 해소 설계 + 차단 승격 *준비*(테스트로 block 경로 고정). 실제 warn→block 플립과 deny→hook 이관은 **1주 운영(2026-06-26) 후 phase-FF** — hook 단계론(CLAUDE.md #5) 준수.
5. 전체 테스트 PASS + 거버넌스 단어 예산(≤8000) 준수.

## 🧩 작업 단위 (SPEC + phase-FF)

> 본 절은 phase 의 *작업 지도* 입니다. 실질적/불확실 → **SPEC**, 작고 가역적인 1–2 commit → **phase-FF**.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-25-01` | askquestion-redirect-hook | P? | Merged | `specs/spec-25-01-askquestion-redirect-hook/` |
| `spec-25-02` | test-trust | P? | Merged | `specs/spec-25-02-test-trust/` |
| `spec-25-03` | auto-e2e | P? | Merged | `specs/spec-25-03-auto-e2e/` |
| `spec-25-04` | stop-rule-layering | P? | Active | `specs/spec-25-04-stop-rule-layering/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-25-01 — AskUserQuestion 리다이렉트 hook (auto 논블로킹 기계적 백스톱)

- **요점**: auto 모드에서 `AskUserQuestion` 호출을 `PreToolUse` hook 으로 가로채 exit 2 + stderr 리다이렉트 — routine 은 기본값+`decision add` 후 진행, ①은 `decision add "미해결" + 턴 종료` 단일 채널로 유도. 24-04 의 "hook 불가" 전제를 뒤집는다.
- **방향성**: `.claude/settings.json` 에 `PreToolUse` matcher `"AskUserQuestion"` 추가 + 신규 hook `check-askquestion-auto.sh`. mode != auto → exit 0. mode == auto → exit 2 + 안내. hook 단계론과 무관(차단이 목적). `AskUserQuestion` 도구가 정말 PreToolUse 대상인지 1개 프로토타입으로 선검증.
- **참조**: ADR-009 Addendum 1, GitHub #181(논블로킹), spec-24-04 walkthrough(정정 대상)
- **연관 모듈**: `sources/hooks/`, `.claude/settings.json`, `sources/governance/agent.md` §8.4

### spec-25-02 — 사후 테스트 신뢰 (칸0 상시 + 칸2 위험 비례)

> #212 비용 사다리를 위험 비례로 도입. **칸0**(가짜 green 의 *동어반복·over-mock*)과 **칸2**(auto 의 핵심 약점인 *방향 오류*)는 잡는 결이 다르므로 한 spec 에 함께 둔다. **칸1**(뮤테이션)은 컴퓨트 비싸고 "중요 모듈" 한정이라 Icebox(→ phase-26).

- **요점(칸0)**: "구현을 망가뜨리면 테스트가 빨개지나?" — 토큰 0 의 상시 1차 방어선. 가짜 green(동어반복·over-mock)을 잡는다. 경고 모드 시작.
- **요점(칸2)**: 비가역/고위험 변경 시, **코드가 아니라 의도(spec)에 앵커**해 "이 테스트 다 통과해도 합의된 의도가 깨질 경우를 반증하라"는 적대적 2차 패스. auto 가 못 잡는 *방향 오류*를 겨냥. 프레이밍은 커버리지 추가가 아니라 **반증(refute)**.
- **방향성**: 게이트는 라인 수가 아니라 **위험** — 기존 commit-scope / check-irreversible 신호를 칸2 트리거로 재사용(5줄 결제 변경 > 500줄 로그 포매터). 칸0 은 항상, 칸2 는 고위험에서만. 독립성의 원천은 "다른 모델"이 아니라 "구현 멘탈 상태 미공유"(fresh 컨텍스트).
- **참조**: ADR-009 Addendum 2, GitHub #212(칸0·칸2 — 비용 사다리), #181(행동 기반 평가)
- **연관 모듈**: `sources/hooks/post-commit-verify.sh`, `sources/hooks/check-scope.sh`·`check-irreversible.sh`(트리거 재사용), `tests/`
- **분할 가능성**: spec 작성 시 칸0+칸2 가 한 PR 로 과대하면 칸2 를 spec-25-05 로 분리(§11.3 재검증).

### spec-25-03 — auto e2e (측정)

- **요점**: `test-e2e-auto-mode.sh` 신규. auto 한 사이클을 실제로 돌려 "routine 결정에서 안 멈춤 + 정지규칙에서 멈춤"을 증명. "산문만으로 충분한가 vs hook 이 꼭 필요한가"의 *측정기*.
- **방향성**: phase-24 carry-over(C1). spec-25-01 의 hook 효과를 e2e 로 확인. decision log 가 실제로 쌓이는지(현재 0건) 검증.
- **참조**: phase-24 시나리오 1·2, spec-24-05 이월 항목
- **연관 모듈**: `tests/test-e2e-auto-mode.sh`(신규)

### spec-25-04 — 정지규칙 ② 층위 정합 + 차단 승격 준비 (플립은 6/26 phase-FF)

> **타이밍 정정(§11.3, 2026-06-22)**: check-irreversible 는 phase-24(2026-06-19)에 추가돼 아직 3일째 — CLAUDE.md #5 "경고 1주 후 차단 승격" 미달. 따라서 본 spec 은 *지금 플립하지 않고*, 2층 모델 명문화 + 데드락 해소 설계 + 승격 준비(테스트)만. 실제 플립은 6/26 phase-FF.

- **요점**: deny(never-justify, 프롬프트 없는 완전 차단)와 check-irreversible ②(context-dependent, 멈추고 대기)의 **2층 모델**을 명문화하고, 둘이 겹쳐 auto 가 정당한 복구(`git reset --hard` 등)에서 프롬프트 없이 데드락되는 W3 를 해소한다.
- **방향성**: ① 명령 분류 결정(never-justify → deny / context-dependent → hook). ② 데드락 명령(`git reset --hard`·`git rebase --onto`)은 *플립 시점에* deny→hook 이관(지금 옮기면 warn 창에서 무방비 공백 → 이관은 6/26 과 묶음). ③ block 경로를 테스트로 고정(승격 준비). ④ 승격 적격일을 명시(잊힘 방지).
- **참조**: ADR-009 규약 3·②, phase-review W3, CLAUDE.md #5(hook 단계론)
- **연관 모듈**: `sources/hooks/check-irreversible.sh`(주석/문서), `tests/test-stop-rules.sh`, `.claude/settings.json`(deny — 플립 시 수정)

### phase-FF 예정 항목 (spec 미생성)

> 작고 가역적인 1–2 commit 항목. spec 산출물 없이 phase base 브랜치에 직접 커밋(phase-FF, → ADR-004).

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| `autoFailCount` ship 리셋 | `sdd ship` 이 spec 전환 시 정지규칙③ 카운터를 리셋하지 않아 이전 spec 실패가 이월(phase-review W1) | 1 |
| post-commit-verify 600s 윈도우 분기 | auto 가 한 커밋에 10분+ 쓰면 검증·revert·카운터가 통째로 스킵(phase-review C3) — auto 에서 윈도우 만료 시 스킵하지 않도록 분기 | 1 |
| **check-irreversible warn→block 플립 (2026-06-26~)** | 1주 운영 경과 후 기본값을 block(exit 2)으로 + deny 의 `git reset --hard`·`git rebase --onto` 를 hook 으로 이관(spec-25-04 가 준비). 적격일 전 실행 금지 | 1 |

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

### 시나리오 3: 가짜 green 1차 방어 (칸0)
- **Given**: 구현을 의도적으로 훼손(revert/over-mock)
- **When**: 칸0 체크(spec-25-02)
- **Then**: 경고(또는 차단)로 적발
- **연관 SPEC**: spec-25-02

### 시나리오 4: 방향 오류 반증 (칸2)
- **Given**: 비가역/고위험 변경 + 테스트는 전부 통과(green)
- **When**: 칸2 적대적 패스가 의도(spec)에 앵커해 반증 시도
- **Then**: "테스트는 통과하나 합의된 의도가 깨지는" 케이스를 적발(경고)
- **연관 SPEC**: spec-25-02

### 통합 테스트 실행
```bash
bash tests/test-e2e-auto-mode.sh
```

> **e2e 커버리지 메모 (spec-25-03)**: `test-e2e-auto-mode.sh` 가 시나리오 1·2 의 *기계적* 부분을 실제 install 에서 구동·증명한다 — mode=auto 설정·settings 패치 / askquestion 차단(auto)·통과(governed) / **결정 로그 누적**(decision add→list·list --phase, phase-24 의 0건이 *미사용*이었음 실증) / 칸0 경고 / 정지규칙 ② 감지 (8/8 PASS).
> **측정 한계 (정직)**: bash e2e 는 *기계적 보장*(차단·경고·누적)만 증명한다. **에이전트가 실제로 좋은 기본값을 고르는 행동**(routine 을 안 묻고 합리적으로 진행하는가)은 측정하지 못한다 — 그건 본질적으로 행동 기반 평가(#181) 영역이며, auto 도그푸딩 운영 데이터로만 확인 가능하다. "e2e 가 다 증명한다"는 가짜 안심을 경계한다(#212 정신).

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
| 칸2 비용(토큰)·오반증 | ceremony 비용 증가 / 잘못된 경고 | **위험 비례 트리거**(고위험만), 경고 모드 시작. 저위험엔 미발동 |
| 칸0+칸2 한 PR 과대 | spec 비대 | §11.3 재검증 — 과대 시 칸2 를 spec-25-05 분리 |
| 거버넌스 단어수 한계 | auto 규칙 추가 시 8000 초과 | 상세는 ADR-009 Addendum 으로 위임, agent.md 엔 포인터만 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 merge (base 모드: `phase-25` → main / 일반: 각 spec → main)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
