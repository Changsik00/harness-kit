---
description: 현재 SPEC 의 plan.md 를 명시적으로 승인 — Strict Loop 모드 진입
---

사용자가 plan.md 를 승인했음을 시스템에 명시적으로 기록합니다. **이 명령은 신중하게 사용하세요** — 이후로는 Strict Loop 로 코드 편집이 시작됩니다.

> 허용 응답 목록 및 목록 외 응답 처리 규칙 → constitution §5.2 참조

## 1. 사전 검증

현재 활성 SPEC 이 있는지, plan.md 가 작성되어 있는지 확인:

```bash
./.harness-kit/bin/sdd status --json
```

다음 조건 모두 만족해야 합니다:
- `phase` ≠ null
- `spec` ≠ null
- `<spec-dir>/plan.md` 존재 + 비어있지 않음
- `<spec-dir>/task.md` 존재 + 비어있지 않음

하나라도 빠지면 사용자에게 무엇이 부족한지 보고하고 멈춥니다.

## 2. Plan Accept 플래그 설정

```bash
./.harness-kit/bin/sdd plan accept
```

이 명령은 `.claude/state/current.json` 의 `planAccepted` 를 `true` 로 설정합니다. 이후 hook (check-plan-accept.sh) 이 Edit/Write 도구를 통과시킵니다.

## 3. 사용자에게 보고

```
✅ Plan Accepted: spec-{phaseN}-{seq}-{slug}

이제 Strict Loop 모드로 진입합니다 (→ agent.md §6.1).
```

## 4. 첫 Task 시작

`task.md` 의 첫 미완 task 부터 Strict Loop 로 진행합니다.

> ⚠️ 첫 task 가 보통 **브랜치 생성** 입니다. main 브랜치라면 `git checkout -b spec-{phaseN}-{seq}-{slug}` 부터 시작하세요 (브랜치 = spec 디렉토리 이름, `feature/` prefix 없음). main 에서 commit 시도 시 hook 가 차단합니다.
