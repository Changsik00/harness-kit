---
description: SDD 세션 정렬 — constitution 로드 + 컨텍스트 점검 + 단 하나의 질문
---

당신은 지금 새 세션을 시작하거나 컨텍스트를 재정렬해야 합니다. 어떤 행동을 취하기 전에 다음을 순서대로 수행하세요.

## 1. 규약 로딩 (Read Rules)

다음 파일을 읽고 거버넌스를 인지합니다:
- @.harness-kit/agent/constitution.md
- @.harness-kit/agent/agent.md
- @.harness-kit/agent/align.md

## 2. 컨텍스트 점검 (Context Check)

다음 **단일 명령**을 실행하여 현재 상태를 파악합니다:

```bash
bash .harness-kit/bin/sdd status
```

> `sdd status` 는 state 파일이 없어도 자체 폴백으로 git log, backlog/, specs/ 정보를 출력합니다.
> 또한 **🔄 동기화 상태 (drift)** 섹션이 자동 포함되어 multi-device 환경의 sync 어긋남 (원격 behind/ahead, 워킹트리 잔재, 정합성, install 부산물) 을 감지합니다. 오프라인 / CI 환경에서는 `--no-drift` 또는 `HARNESS_DRIFT_FETCH=0` 으로 끌 수 있습니다.
> 별도 폴백 명령을 체이닝하지 마세요 (단일 명령 원칙 — agent.md §6.4).

## 3. 행동 모드 잠금 (Behavior Lock)

이번 세션 동안 다음을 따른다고 마음속으로 계약합니다:

- **언어**: 채팅, Phase, Spec, Plan, Task, Walkthrough, PR Description 모두 한국어. 코드/경로/기술 용어만 영어 허용.
- **절차**: Phase → Spec → Plan → Task → Walkthrough → Hand-off (SDD)
- **TDD**: Test 작성 → Fail → Implement → Pass → Commit
- **Plan Accept Gate**: 사용자가 `/hk-plan-accept` 를 호출하거나 Plan Accept 를 명시하기 전까지는 PLANNING 모드. 코드 편집 금지.
- **One Task = One Commit**

## 4. 상태 요약 보고

위 점검 결과를 다음 형식으로 사용자에게 한 번에 보고합니다:

```
📊 현재 상태
- Active Phase: <PHASE-N-slug 또는 "없음">
- Active Spec:  <SPEC-NN-NN-slug 또는 "없음">  ← NOW
- NEXT:         <다음 spec 또는 "없음">
- Branch:       <current branch>
- Plan Accept:  <yes / no>
- Last Test:    <timestamp 또는 "없음"> (PASS / FAIL)
- Pending Tasks: <count>

🔄 동기화 상태  (drift 가 있을 때만 상세 표시; 없으면 "깔끔")
- 원격: behind N / ahead M  (origin/<branch>)
- 워킹트리: K 변경 (X spec drift / Y install drift / Z 일반)
- 정합성: phase-N 의 모든 spec Merged 인데 active — sdd phase done 미실행 의심
- install 부산물: K (sources 동일 X / 정체불명 Y)

📝 최근 활동
- <git log -3 의 첫 줄>
- <git log -3 의 둘째 줄>
- <git log -3 의 셋째 줄>
```

> `sdd status` 출력에 NEXT 와 동기화 상태가 이미 포함되어 있으므로 별도 파싱 불필요.
> drift 가 있으면 사용자에게 정리 옵션 (예: `git pull --ff-only`, `sdd phase done <N>`, untracked 검증) 을 한 줄로 제안할 수 있습니다. 자동 정리는 금지 — 사용자 명시 결정 후에만 실행.

## 5. 단 하나의 질문 (One Question)

상태 보고 직후, **단 하나의 질문**만 사용자에게 던집니다:

> **"어떤 컨텍스트로 진행할까요?"**

여러 옵션이 있다면 짧게 제시할 수 있으나, 사용자의 명시적 선택 전에 어떤 행동도 취하지 마세요.
