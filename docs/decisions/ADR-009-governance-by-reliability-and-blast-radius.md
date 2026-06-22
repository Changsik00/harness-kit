---
id: ADR-009
type: decision
date: 2026-06-19
status: accepted
---

# ADR-009: 거버넌스를 신뢰도·blast-radius 기준으로 재배분 + 자율(auto) 모드

> **Note — 경로 표기와 stale ADR 검사 대상**: 본 ADR 의 inline backtick 경로는 `sdd status` 의 stale ADR 검사 대상입니다.
> 검사 패턴은 *inline backtick + 슬래시 + 확장자* 만. code fence 안 경로, 슬래시 없는 토큰, URL 은 무시됩니다.

## 📚 Context

harness-kit 은 *안정성(safety) 위주*로 설계됐다. 그러나 (2026-06 기준) agent(모델) 자체가 이전보다 안정적으로 향상되어, 키트가 사람-ceremony 로 떠안던 안정성의 일부를 모델이 직접 감당하게 됐다. 동시에 "키트가 너무 느리다(ceremony 과다)"는 지적이 누적됐고, 그 대응으로 `turbo` 모드와 외부 LSP 확장(→ ADR-007/008)이 도입됐다.

핵심 관찰: 거버넌스는 한 덩어리가 아니라 두 종류가 섞여 있다.
- **(A) "agent 가 못 미덥다"는 가정의 사전 ceremony** — Plan Accept 게이트, 작은 변경에도 spec/task 강제, PLANNING 잠금, 태스크 사이 확인, 결정 시 차단형 질문. 모델이 좋아질수록 *순수 세금*.
- **(B) 결정론적 blast-radius 가드** — git 브랜치·PR 리뷰, diff-size·secret·branch·commit-msg 훅, post-commit-verify, 테스트. 모델 품질과 *무관하게* 사고(force push, secret 유출, 대량 삭제)를 막음.

속도 불만은 거의 전부 (A)에 대한 것이고, 안전 가치는 (B)에 있다. 둘은 충돌하지 않는다 — 지금은 (A)가 (B)에 업혀 한 덩어리로 굴러갈 뿐이다.

또한 더 좋은 agent = "코딩을 잘함"이지 "자기가 틀린 걸 잘 앎"이 아니다. 실패 양상이 *적지만 더 그럴듯하고 자신감 있는* 오류로 이동한다. 이런 오류는 *사전 질문*으로 잡히지 않고 *사후 검증*(테스트·diff·리뷰)으로 잡힌다.

## 🎯 Decision

**원칙**: 거버넌스는 **agent 신뢰도에 반비례, blast-radius 에 비례**해서 적용한다.
- 싸고 + 가역적 + agent 가 판단 가능 → ceremony 0
- 비싸고 + 비가역 + 넓은 blast → 게이트 유지하되 *결정론적(훅/테스트)* 으로. 차단형 프롬프트에 의존하지 않는다.
- agent 신뢰도가 오를수록 예산을 **사전 게이트(A) → 사후 검증(B)** 으로 이동한다.

**적용**: 작업 모드를 3단계로 정의한다.

| 모드 | 사람 | ceremony | 안전 근거 |
|---|---|---|---|
| `governed` | 붙어 있음 | 풀 (기존 기본) | (A)+(B) |
| `turbo` | 붙어 있음 | (A) 제거, (B) 유지 | (B) + 실시간 사람 |
| **`auto` (신규)** | **없음(unattended)** | (A) 제거, (B) 강화 | **(B) 단독 + 정지규칙** |

**`auto` 모드 규약** (사용자 결정 2026-06-19):
1. **입도 = phase 전체 fire-and-forget**. phase 안 모든 spec 을 자율 수행하고, **`phase-ship` PR 에서만** 사람이 일괄 검토한다. spec 단위로 멈추지 않는다.
2. **결정은 기본값+로그, 논블로킹**. 결정이 필요한 순간(통상 `AskUserQuestion`) 합리적 기본값으로 진행하고 그 결정·근거를 결정 로그(walkthrough)에 기록한다. 사람을 기다리며 멈추지 않는다.
3. **정지규칙(hard stop) — auto 의 유일한 사전 안전판**. 다음에서만 멈추고 사람을 기다린다:
   - ① 방향이 바뀌는 진짜 모호함 (기본값을 고를 수 없는 갈림)
   - ② 비가역/파괴 행동 (force push, 대량 삭제, 외부 발행/배포, secret 노출 위험)
   - ③ 스스로 못 푸는 반복 테스트 실패 (N회 시도 후)
4. **사후 검증이 안전망이 된다**. spec 사이 테스트 게이트 + `post-commit-verify` 가 항상 작동하고, 결정 로그가 `phase-ship` 에서 사람에게 일괄 노출된다.

## 📊 Consequences

- **긍정**: "걸어두고 딴 일" 이 가능해짐 — phase 전체 자율 수행. 속도 불만의 근원(A)을 제거하면서 (B)는 강화. 사람 검토는 phase 당 1회(phase-ship)로 압축.
- **긍정**: 거버넌스 의사결정에 일관된 잣대(신뢰도·blast-radius)가 생겨, 향후 규칙 추가/삭제를 원칙으로 판정 가능.
- **부정**: unattended 이므로 잘못된 기본값으로 *멀리* 진행할 위험. 정지규칙 ①②③·결정 로그·사후 테스트의 품질에 안전이 전적으로 의존 → 이들이 부실하면 사고가 phase-ship 까지 안 잡힌다.
- **부정**: MCP 경유 편집(예: Serena 쓰기)은 `Edit|Write` 훅 매처를 우회 → auto 모드 전에 blast-radius 가드를 *편집 시점이 아닌 커밋 시점* 으로 정렬해야 도구 무관하게 유효 (관련 작업으로 분리).
- **중립**: `turbo` 는 그대로 "attended 빠른 모드" 로 유지. auto 는 그 위 단계로 추가될 뿐 turbo 를 대체하지 않음.

## 🔀 Alternatives

- **spec 단위 일시정지**: 매 spec 의 PR 에서 사람이 승인해야 다음 spec 진행 — 비채택: 더 안전하나 "걸어두고 딴 일" 이라는 목적을 못 살림(자주 끊김). 사용자가 phase 전체 입도를 선택.
- **결정을 큐에 모아 체크포인트에서 일괄 응답**: 진행을 막지 않되 일부 작업을 보류 — 비채택: 보류가 누적되면 자율성이 반감. 기본값+로그가 더 단순하고 흐름이 끊기지 않음.
- **turbo 에 unattended 플래그만 추가**: 별도 모드 없이 turbo 확장 — 비채택: "사람이 붙어 있나" 는 안전 근거가 질적으로 다른 축이라 별도 모드로 명시하는 게 오인 위험이 적음.

## 📌 Status

Accepted (2026-06-19, phase-24 착수). phase-24 (자율 모드 구현) 의 거버닝 ADR. 첫 적용 대상: harness-kit 자기 자신(도그푸딩).

## 📎 Addendum — phase-24 phase-review (2026-06-22)

phase-24 가 본 ADR 의 auto 규약을 구현한 뒤 phase-review 에서 두 가지가 드러났다. 원래 Decision 은 유지하되, 구현 전제 하나를 정정하고 후속을 명시한다.

1. **규약 2(논블로킹)의 전제 정정.** spec-24-04 는 "결정 지점에서 멈추지 않음"을 *agent 행동 규약(§8.4)+resolver* 로만 규율하며, 그 근거로 "`AskUserQuestion` 호출 여부는 agent 행동이라 hook 으로 못 막는다"고 했다. 이는 **절반만 맞다** — hook 은 *호출 안 함*을 선제할 수 없으나, `PreToolUse` matcher 는 도구명 임의 매칭이라 `AskUserQuestion` 이 *호출되는 순간* 가로채 exit 2 로 리다이렉트할 수 있다. 따라서 논블로킹은 산문 규약 외에 **기계적 백스톱이 가능**하다. 현재 auto 의 "안 멈춤"이 산문 한 줄에만 의존하는 것은 약한 지렛대다(Claude Code 시스템 프롬프트가 결정 지점에서 `AskUserQuestion` 을 *권장*하므로 모델 기본 행동과 충돌). → phase-25 에서 재검토.

2. **규약 4(사후 검증)의 load-bearing 가정 미보강.** Consequences 가 "안전이 정지규칙·결정 로그·**사후 테스트의 품질에 전적으로 의존**"이라 명시했으나, phase-24 는 그 *발판*(post-commit-verify·정지규칙 엔진)만 깔고 *테스트 자체의 신뢰도*(GitHub #212 칸0 revert/over-mock·뮤테이션·적대적 2차 검토)는 손대지 않았다. unattended 는 가짜 green 의 폭발 반경을 키우므로, 도그푸딩 전에 최소 칸0 1건이 선행돼야 한다.

**멈춤의 두 종류 구분(설계 보강)**: auto 에서 `AskUserQuestion` 은 전면 비활성으로 두고 — routine 결정(work mode·plan-accept·PR 확인·idea capture)은 기본값+`sdd decision add` 후 진행, 정지규칙 ①(기본값 정당화 불가) 은 `AskUserQuestion` 이 아니라 `decision add "미해결" + 턴 종료` 단일 채널로 보낸다(Stop 훅 → `notify-on-input-wait` 가 사용자에 핑). 이로써 "routine 에서 멈춤(버그)"과 "①에서 멈춤(기능)"이 분리된다.

**후속 (phase-25 — auto 신뢰성)**: ① `AskUserQuestion` 리다이렉트 hook(auto 한정, 본 Addendum 1), ② #212 칸0 사후 검증(본 Addendum 2), ③ auto e2e `test-e2e-auto-mode.sh`(산문만으로 충분한지 *측정*), ④ check-irreversible 차단 승격 + settings deny 층위 정합. 이 넷 이전의 auto 도그푸딩은 *검증되지 않은 자율*이다.

## 🔗 Related

- ADR-002 (planning-economy — ceremony 고정비·우편향): 본 ADR 은 그 원칙을 신뢰도 축까지 일반화.
- ADR-004 (phase-FF first-class), ADR-006 (director-mode), ADR-008 (extension 우선 사용).
- 후속 phase-24: auto 모드 상태/CLI · 정지규칙 엔진 · 결정 로그 · phase-ship 체크포인트 · blast-radius 가드 커밋시점 정렬.
- 후속 phase-25 (auto 신뢰성): 본 Addendum 의 ①~④. GitHub #181(행동 기반 평가·bounded 수정 루프·가정 레지스트리), #212(테스트 신뢰 — 비용 사다리).
