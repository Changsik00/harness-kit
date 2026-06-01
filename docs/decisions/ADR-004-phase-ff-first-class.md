---
id: ADR-004
type: decision
date: 2026-06-01
status: accepted
---

# ADR-004: phase-FF 를 phase 내 1급 작업 모드로

## 📚 Context

SDD ceremony 는 작업 크기와 무관하게 고정비(spec/plan/task/walkthrough/pr_description + Plan Accept + PR + 리뷰, 약 6,000–8,000 토큰)를 가진다. 그런데 phase 안의 작업은 **암묵적으로 전부 spec** 으로 처리돼 왔다 — 3줄짜리 코드 변경에도 5개 md 산출물이 붙어, 토큰의 대부분이 코드가 아니라 문서 반복 서술에 소모됐다 (실측: spec-15-05 = templates.ts 3줄 + 테스트 1개에 spec/plan/task/walkthrough/pr_description 전부 생성). "관련된 것끼리 묶자"는 bundle 본능도 작은 항목을 spec 으로 승격시키는 압력으로 작동했다.

phase base 브랜치는 main 이 아니므로, 그 안의 직접 커밋은 main 보호 불변식을 깨지 않는다 — 즉 ceremony 의 안전 근거(main 오염 방지 + 리뷰 가능 PR)가 phase 브랜치 안에서는 거의 사라진다.

## 🎯 Decision

phase 내 작업은 **항목별로 크기에 맞는 모드를 선택**한다. 실질적/불확실한 작업은 full Spec, 작고 명확하고 가역적인 1–2 commit 항목은 **phase-FF** — phase base 브랜치에 spec 산출물 없이 직접 커밋. phase-FF 는 재조정 fallback 이 아니라 **착수 시점의 1급 선택지**이며, 승인된 phase plan 이 이미 항목 실행을 위임하므로 항목마다 재승인이 필요 없다. "phase 안이면 무조건 spec" 편향과 "FF 회피용 bundle" 을 금지한다.

## 📊 Consequences

- **긍정**: 작은 작업의 ceremony 고정비 제거 — 토큰·사용자 검토 피로 대폭 감소. phase 가 "작업 묶음"의 자연스러운 단위가 됨.
- **긍정**: 리뷰는 phase-ship PR 한 곳으로 모임 (per-spec PR 리뷰가 과한 솔로/도그푸딩 맥락에 적합).
- **부정**: per-spec 리뷰 입자도 상실 — phase 가 크면 phase-ship PR 이 큰 덩어리가 됨. 완화: 결정 로그를 phase.md 의 "결정 기록" 섹션에 누적.
- **부정**: phase-FF 는 base 브랜치 모드를 전제 (커밋할 non-main 위치 필요) — base 모드를 더 적극 채택해야 함.
- **중립**: phase-FF 는 FF (Mode C) 와 구별 — phase PR 에 실리고 state.json 의 active spec 을 바꾸지 않음.

## 🔀 Alternatives

- **ceremony 단위를 spec→phase 로 재설계**: phase 전체를 무거운 경계로, 내부는 전부 경량화. — 비채택 이유: 과설계. 기존 spec/FF 모드를 유지한 채 "phase 내 강제 spec" 규칙만 푸는 게 더 단순.
- **산출물 통합(5 md → 1 work.md)**: spec 자체를 가볍게. — 비채택 아님(보류): 직교하는 별도 레버로, 후속 검토.
- **현상 유지 + 사용자가 매번 FF 승인**: — 비채택 이유: 매 항목 재승인 마찰이 결국 phase-FF 를 안 쓰게 만든 원인.

## 📌 Status

Accepted (2026-06-01). 규약 반영: constitution §3.1 (In-Phase Work Sizing), agent.md §11.4 (In-Phase Work Sizing & Re-Adjustment), CLAUDE.fragment 패턴.

## 🔗 Related

- ADR-002 (Planning Economy) — phase plan 은 contract 아닌 draft, 재검증 의무.
