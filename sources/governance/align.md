# Alignment Bootstrap

> 이 문서는 `/align` 슬래시 커맨드 또는 새 세션 시작 시 에이전트가 자동으로 따라야 하는 부트스트랩 프로토콜입니다.

새 세션을 시작했거나 컨텍스트를 재정렬해야 한다면, 어떤 행동을 취하기 전에 반드시 다음을 수행한다.

## 1. 규약 로딩 (Read Rules)
- `agent/constitution.md` 와 `agent/agent.md` 를 읽고 거버넌스를 인지한다.
- 본 프로젝트의 `CLAUDE.md` 에 import 되어 있다면 자동 로딩되었을 수 있으나, 안전을 위해 명시적으로 다시 확인한다.

## 2. 컨텍스트 점검 (Context Check)
- `bin/sdd status` (있다면) 실행하여 현재 PHASE / SPEC / 브랜치 / plan-accept 플래그 / 마지막 테스트 결과를 확인한다.
- 없다면 폴백:
  - `git branch --show-current`
  - `git log -3 --oneline`
  - `ls backlog/` 와 `ls specs/` (있는 경우)
  - `cat backlog/queue.md` (있는 경우)

## 3. 행동 모드 잠금 (Behavior Lock)

### 언어 규칙
- 채팅, Phase, Spec, Plan, Task, Walkthrough, PR Description: **한국어**
- 코드, 파일 경로, 표준 기술 용어: 영어 허용
- 거버넌스 문서 (constitution, agent.md 등): 영어 (내부 시스템 문서)

### 절차 규칙
- **SDD Process**: Phase → Spec → Plan → Task → Walkthrough → Hand-off
- **TDD**: Test 작성 → Fail 확인 → Implement → Pass → Commit
- **Strict Loop**: 한 task 완료 시마다 task.md 업데이트 + 사용자에게 보고 + 대기
- **Plan Accept Gate**: 사용자가 "Plan Accept" 또는 `/plan-accept` 호출하기 전까지는 PLANNING 모드. 코드 편집 금지

## 4. 상태 요약 보고 (State Summary)

위 점검 결과를 다음 형식으로 사용자에게 한 번에 보고한다:

```
📊 현재 상태
- Active Phase: PHASE-{N}-{slug} (또는 없음)
- Active Spec: SPEC-{N}-{seq}-{slug} (또는 없음)
- Branch: <current branch>
- Plan Accepted: yes / no
- Last Test: <timestamp> (PASS / FAIL / 없음)
- Pending Tasks: <count>

📝 최근 활동 (git log -3)
- ...
- ...
- ...
```

## 5. 단 하나의 질문 (One Question)

상태 보고 후, **단 하나의 질문**만 사용자에게 던진다:

> **"어떤 컨텍스트로 진행할까요?"**

여러 옵션을 짧게 제시할 수 있으나, 사용자의 명시적 선택 전에 어떤 행동도 취하지 않는다.
