---
id: RCA-001
type: failure-pattern
date: 2026-05-15
severity: medium
status: active
sources:
  - specs/spec-x-readme-refresh/walkthrough.md
  - specs/spec-x-phase-16-define/walkthrough.md
linked:
  - "[[wiki/decisions]]"
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
updated: 2026-05-27
---

# RCA-001: sdd ship 이 spec/plan/task 산출물을 git add 하지 않음

## 🔍 Symptom

`sdd ship` 실행 후 spec.md / plan.md / task.md 가 ship commit 에 포함되지 않아 working tree 에 untracked 로 남는다. 사용자가 push 전 사후 `git add` + commit 을 별도로 수행해야 한다. 두 번 연속 (spec-x-readme-refresh, spec-x-phase-16-define) 확인된 운영 이슈.

## 🔁 Reproduction

새 spec-x 디렉토리에서 spec/plan/task 를 한 번에 작성한 뒤 Plan Accept → Strict Loop 진입, walkthrough.md / pr_description.md 까지 작성한 상태에서:

```bash
bash .harness-kit/bin/sdd ship
git status
```

기대: working tree 깔끔. 실제: `specs/<spec-dir>/{spec,plan,task}.md` 가 untracked 로 남음.

## 🎯 Root Cause

`sdd ship` 의 git add 매트릭스가 *walkthrough.md / pr_description.md* 만 포함한다. spec/plan/task 산출물은 *Pre-flight 단계에서 별도 commit* 되었을 거라는 암묵적 전제. 그러나 실제 spec-x 운영은 spec/plan/task 를 *한 번에* 작성 후 Plan Accept 로 넘어가는 흐름이라, *Pre-flight commit* 단계 자체가 없다. ship 시점에 산출물이 first-touch 인 경우가 일반적이다.

## 🛡 Invariant Violated

본 RCA 작성 전까지 명시되지 않았던 불변식을 *지금* 명시한다:

> `sdd ship` 실행 후 working tree 에 *해당 spec 디렉토리 내* 신규 산출물 untracked 가 남으면 안 된다.

ship 의 의미는 "spec 산출물 일괄 인도" 이고, 누락된 add 는 인도 불완전.

## 🚧 Prevention

별도 spec-x 후보 (본 RCA 의 *직접 fix* 는 본 spec scope 밖):

- `sdd ship` 의 git add 매트릭스 확장 — 활성 SPEC 디렉토리의 `spec.md`, `plan.md`, `task.md` 도 ship 시점에 자동 staging.
- 매트릭스 확장 후 검증: 같은 시나리오 재현 → ship 후 `git status` 깔끔해야 한다.
- 부가: ship 단계에서 untracked 산출물 발견 시 *경고 stderr* 출력 (즉시 차단 X — 단계론 따라 1 주 운영 후 차단 승격).

## 🔗 Related

- 발견 spec: `spec-x-readme-refresh`, `spec-x-phase-16-define`
- 본 RCA 자체는 phase-16 의 첫 사용자 RCA — spec-16-01 (RCA + Knowledge Types) 의 도그푸딩 검증 대상
- 정규 vocabulary: constitution §6.4 `failure-pattern`
