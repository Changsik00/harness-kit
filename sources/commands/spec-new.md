---
description: 현재 phase 안에 새 SPEC 디렉토리와 템플릿 4종 생성
argument-hint: <slug>
---

새 SPEC 을 생성합니다. 인자로 받은 slug: **$1**

## 1. 사전 점검

현재 active phase 가 있는지 확인합니다:

```bash
./scripts/harness/bin/sdd status --json | jq -r '.phase'
```

값이 `null` 이라면 phase 가 없는 것이므로 사용자에게 알립니다:

> "active phase 가 없습니다. 먼저 `bin/sdd phase new <slug>` 로 phase 를 만들거나, 임시 phase (`PHASE-0-misc`) 사용 여부를 결정해 주세요."

그리고 멈춥니다.

## 2. SPEC 생성

active phase 가 있다면 다음 명령으로 SPEC 디렉토리와 템플릿 4종 (spec.md / plan.md / task.md / walkthrough.md / pr_description.md) 을 생성합니다:

```bash
./scripts/harness/bin/sdd spec new "$1"
```

명령은 자동으로:
- 다음 SPEC 번호 (현재 phase 기준 N+1)
- `backlog/phases/PHASE-{N}-{slug}/specs/SPEC-{N}-{NNN}-{$1}/` 디렉토리
- 5종 템플릿 복사
- state 의 active spec 갱신

## 3. 작성 시작

생성된 `spec.md` 를 열어 사용자와 함께 §1 배경 및 문제 정의부터 작성을 시작합니다.

> ⚠️ **이 시점부터 PLANNING 모드입니다.** constitution §4.3 에 따라 코드 편집 금지. 오직 spec/plan/task 문서 작성만 허용됩니다.

## 4. 다음 단계 안내

spec.md → plan.md → task.md 순으로 작성한 후 사용자에게 검토를 요청하고, `/plan-accept` 호출을 기다립니다.
