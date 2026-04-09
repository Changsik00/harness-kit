---
description: 현재 SPEC 작업 종료 — walkthrough/pr_description 검증 후 push 준비
---

현재 SPEC 의 모든 작업 task 가 완료되었다고 판단되면 본 명령으로 hand-off 절차를 시작합니다.

## 1. 사전 검증

```bash
./scripts/harness/bin/sdd archive --check
```

확인 항목:
- task.md 의 모든 작업 task 가 `[x]` 또는 `[-]` 인지
- walkthrough.md 가 작성되어 있는지 (placeholder 만 있으면 안 됨)
- pr_description.md 가 작성되어 있는지

부족한 부분이 있으면 사용자에게 정확히 무엇이 부족한지 보고하고 멈춥니다.

## 2. 품질 게이트

스택 어댑터의 명령으로 lint + 전체 테스트:

```bash
source ./scripts/harness/lib/stack.sh
$HARNESS_LINT_CMD || { echo "lint 실패"; exit 1; }
$HARNESS_TEST_CMD || { echo "test 실패"; exit 1; }
```

(Integration Test Required = yes 인 경우)
```bash
$HARNESS_TEST_INTEGRATION_CMD || { echo "integration test 실패"; exit 1; }
```

실패 시 멈추고 사용자에게 보고. 에이전트가 임의로 fix 시도 금지 — 사용자 결정 대기.

## 3. Archive Commit

walkthrough.md 와 pr_description.md 를 한 commit 으로 archive:

```bash
git add backlog/phases/PHASE-{N}-*/specs/SPEC-{N}-{NNN}-*/walkthrough.md
git add backlog/phases/PHASE-{N}-*/specs/SPEC-{N}-{NNN}-*/pr_description.md
git commit -m "docs(SPEC-{N}-{NNN}): archive walkthrough and pr description"
```

## 4. Push 확인 (사용자 승인 필요)

`git status` + `git log --oneline origin/main..HEAD` 를 보여주고 사용자에게 묻습니다:

> "다음 커밋들을 origin 으로 push 할까요?"

사용자가 명시적으로 승인하면:

```bash
git push -u origin feature/SPEC-{N}-{NNN}-{slug}
```

## 5. PR 생성 안내

push 후 사용자에게 hosted git UI 에서 PR 을 생성하라고 안내합니다. PR 본문은 방금 archive 한 `pr_description.md` 를 그대로 복사하면 됩니다.

```
✅ Push 완료: feature/SPEC-{N}-{NNN}-{slug}

다음 단계 (사용자):
1. <hosted git URL>/pull-requests/new?source=feature/SPEC-{N}-{NNN}-{slug}
2. PR 본문에 backlog/phases/.../specs/SPEC-{N}-{NNN}-*/pr_description.md 내용 복사
3. 리뷰어 지정
4. 머지 후 phase.md 의 SPEC 표 갱신 (Status: Merged)
```

## 6. State 업데이트

```bash
./scripts/harness/bin/sdd plan reset
```

planAccepted 플래그를 false 로 되돌려 다음 SPEC 을 위해 깨끗한 상태로 만듭니다.
