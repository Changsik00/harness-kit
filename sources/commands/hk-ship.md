---
description: 현재 SPEC 작업 종료 — walkthrough/pr_description 검증 후 push 준비
---

현재 SPEC 의 모든 작업 task 가 완료되었을 때 이 명령으로 hand-off 절차를 시작합니다.

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

`sdd archive` 가 walkthrough.md / pr_description.md 를 한 commit 으로 묶어줍니다:

```bash
./scripts/harness/bin/sdd archive
# 위 명령은 내부에서:
#   git add specs/spec-{phaseN}-{seq}-{slug}/walkthrough.md
#   git add specs/spec-{phaseN}-{seq}-{slug}/pr_description.md
#   git commit -m "docs(spec-{phaseN}-{seq}): archive walkthrough and pr description"
```

## 4. Push 확인 (사용자 승인 필요)

`git log --oneline origin/<branch>..HEAD 2>/dev/null` 로 커밋 수를, `git remote get-url origin` 의 기본 브랜치로 타깃을 확인한 후 다음 블록을 표시:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Push 확인
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  브랜치    <head>  ▶  🎯 <base>
  제목      <pr_description.md 첫 줄>
  커밋 수   <N>개
  변경 파일 <M>개
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

push 할까요? [Y/n]
```

긍정/거부 규칙 → constitution §4.2 참조
- **`--no-confirm`**: 확인 블록 생략하고 바로 push

승인 시 (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음):

```bash
git push -u origin spec-{phaseN}-{seq}-{slug}
```

## 5. PR 생성

`git remote get-url origin` 의 호스트로 분기:

### 5-A. github.com → `gh` CLI

(사전: `gh auth status` 로 인증 확인. 미인증이면 사용자에게 `gh auth login` 안내 후 멈춤)

`/hk-pr-gh` 슬래시 커맨드의 절차를 따릅니다.

### 5-B. bitbucket.org → `bb-pr`

(사전: `~/.config/bitbucket/token` 준비)

`/hk-pr-bb` 슬래시 커맨드의 절차를 따릅니다.

### 5-C. 그 외 (GitLab, GitHub Enterprise, 사내 Bitbucket Server 등)

기존대로 hosted git UI 에서 수동 생성하도록 안내:

```
✅ Push 완료: spec-{phaseN}-{seq}-{slug}

다음 단계 (사용자):
1. <hosted git URL>/pull-requests/new?source=spec-{phaseN}-{seq}-{slug}
2. PR 본문에 specs/spec-{phaseN}-{seq}-{slug}/pr_description.md 내용 복사
3. 리뷰어 지정
4. 머지 후 backlog/phase-{phaseN}/phase.md 의 SPEC 표 갱신 (Status: Merged)
```

성공 시 어느 경로든 출력되는 PR URL/번호를 그대로 사용자에게 보고합니다.

## 6. State 업데이트

```bash
./scripts/harness/bin/sdd plan reset
```

planAccepted 플래그를 false 로 되돌려 다음 SPEC 을 위해 깨끗한 상태로 만듭니다.
