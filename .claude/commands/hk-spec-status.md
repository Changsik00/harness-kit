---
description: 현재 SPEC 의 task 진행률, 변경 파일, 테스트 상태 출력
---

현재 SPEC 의 진행 상태를 자세하게 보고합니다. **읽기 전용 명령** — 어떤 변경도 가하지 않습니다.

## 1. 상태 수집

```bash
./scripts/harness/bin/sdd status --verbose
```

이 명령은 다음을 출력합니다:
- 키트 버전, 스택, OS
- Active phase / spec / branch / plan-accepted
- task.md 진행률 (`[x]` / `[ ]` / `[-]` 카운트)
- `git status -s` 변경 파일 목록
- `git log --oneline -5` 최근 커밋
- 마지막 테스트 통과 시각

## 2. 다음 task 미리보기

`task.md` 에서 첫 번째 미완 (`[ ]`) task 를 찾아 사용자에게 보여줍니다:

```
다음 task: <task title>
  - 단계 1
  - 단계 2
  - ...
```

> ⚠️ 다음 task 를 *실행하지는 마세요*. 사용자가 명시적으로 진행을 지시할 때까지 대기합니다.

## 3. 이상 징후 점검

다음과 같은 경우 사용자에게 주의 환기:
- main 브랜치 위에 있음 → "⚠️ 현재 main 입니다. feature 브랜치로 이동 필요"
- plan-accepted 인데 변경 파일이 없음 → "⚠️ Strict Loop 시작 전인 것 같습니다"
- 변경 파일이 많은데 아직 커밋이 없음 → "⚠️ 변경이 누적되어 있습니다. 한 task 단위로 분할 commit 권장"
- task.md 의 모든 항목이 `[x]` 인데 push 안 됨 → "다음 단계: `/handoff` 실행"
