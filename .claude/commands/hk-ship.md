---
description: 현재 SPEC 작업 종료 — walkthrough/pr_description 검증 후 push + PR 자동 진행
---

현재 SPEC 의 모든 작업 task 가 완료되었을 때 이 명령으로 ship 절차를 시작합니다.
**모든 검증이 통과하면 push + PR 생성까지 자동 진행합니다.** 실패 시에만 멈추고 보고합니다.

## 1. 사전 검증

```bash
./.harness-kit/bin/sdd ship --check
```

확인 항목:
- task.md 의 모든 작업 task 가 `[x]` 또는 `[-]` 인지
- walkthrough.md 가 작성되어 있는지 (placeholder 만 있으면 안 됨)
- pr_description.md 가 작성되어 있는지

부족한 부분이 있으면 사용자에게 정확히 무엇이 부족한지 보고하고 멈춥니다.

## 2. 품질 게이트

프로젝트의 설정 파일(`package.json`, `Makefile`, `pyproject.toml` 등)을 확인하여 적절한 lint/test 명령을 실행합니다:

1. **Lint / Type Check**: 프로젝트에 lint 또는 typecheck 스크립트가 있으면 실행
2. **단위 테스트**: 프로젝트의 테스트 명령 실행
3. **(Integration Test Required = yes 인 경우)** 통합 테스트 명령 실행

실패 시 멈추고 사용자에게 보고. 에이전트가 임의로 fix 시도 금지 — 사용자 결정 대기.

## 3. Ship Commit

`sdd ship` 가 walkthrough.md / pr_description.md 를 한 commit 으로 묶어줍니다:

```bash
./.harness-kit/bin/sdd ship
# 위 명령은 내부에서:
#   git add specs/spec-{phaseN}-{seq}-{slug}/walkthrough.md
#   git add specs/spec-{phaseN}-{seq}-{slug}/pr_description.md
#   git commit -m "docs(spec-{phaseN}-{seq}): ship walkthrough and pr description"
```

## 4. Push (자동 진행)

**[Phase base branch 감지]** Push 전, PR 타깃 결정:

```bash
base_branch=$(./.harness-kit/bin/sdd status --json | jq -r '.baseBranch // "null"')
if [ "$base_branch" != "null" ]; then
  # phase base branch 모드 — remote 존재 여부 확인
  if ! git ls-remote --exit-code origin "$base_branch" >/dev/null 2>&1; then
    echo "phase base branch 없음 — 생성: $base_branch"
    git checkout -b "$base_branch" main
    git push -u origin "$base_branch"
    git checkout -   # spec 브랜치로 복귀
  fi
  PR_BASE="$base_branch"
else
  PR_BASE="main"
fi
```

정보 블록을 표시한 후 **자동으로 push** 합니다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Push
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  브랜치    <head>  ▶  🎯 <PR_BASE>
  제목      <pr_description.md 첫 줄>
  커밋 수   <N>개
  변경 파일 <M>개
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

```bash
git push -u origin spec-{phaseN}-{seq}-{slug}
```

push 실패 시 멈추고 사용자에게 보고.

## 5. PR 생성 (자동 진행)

`git remote get-url origin` 의 호스트로 분기:

### 5-A. github.com → `gh` CLI

(사전: `gh auth status` 로 인증 확인. 미인증이면 사용자에게 `gh auth login` 안내 후 멈춤)

`/hk-pr-gh --no-confirm` 슬래시 커맨드의 절차를 따릅니다.
hk-ship 은 Plan Accept 이후 흐름이므로 PR 생성 확인을 생략합니다 (→ constitution §5.7).

> **Phase base branch 모드**: `PR_BASE` 가 `main` 이 아닌 경우 `gh pr create --base $PR_BASE` 를 사용합니다.

### 5-B. bitbucket.org → `bb-pr`

(사전: `~/.config/bitbucket/token` 준비)

`/hk-pr-bb` 슬래시 커맨드의 절차를 따릅니다.

### 5-C. 그 외 (GitLab, GitHub Enterprise, 사내 Bitbucket Server 등)

push 완료 후 수동 PR 생성을 안내:

```
✅ Push 완료: spec-{phaseN}-{seq}-{slug}

다음 단계 (사용자):
1. <hosted git URL>/pull-requests/new?source=spec-{phaseN}-{seq}-{slug}
2. PR 본문에 specs/spec-{phaseN}-{seq}-{slug}/pr_description.md 내용 복사
3. 리뷰어 지정
```

성공 시 PR URL/번호를 사용자에게 보고하고 **머지를 기다립니다**.

## 6. State 업데이트

`sdd ship` 가 이미 state.json 을 초기화합니다 (spec=null, planAccepted=false).
별도 `sdd plan reset` 호출은 불필요합니다.

> **[spec-x 한정] queue.md 완료 갱신**
>
> spec-x (`spec-x-{slug}`) 인 경우 queue.md 갱신:
> ```bash
> ./.harness-kit/bin/sdd specx done {slug}
> ```
> 이 명령은 specx 대기 섹션에서 해당 항목을 제거하고 완료 섹션으로 이동합니다.

> **[Phase base branch 모드] 다음 Spec 시작 전 주의사항**
>
> 현재 Spec PR 이 phase base branch 에 **merge된 후** 다음 Spec 브랜치를 생성해야 합니다.
> merge 전에 다음 Spec 을 시작하면 이전 Spec 의 변경사항이 누락된 base 에서 분기하게 됩니다.
>
> ```
> 올바른 순서:
>   1. PR merge 완료 (phase base branch ← spec 브랜치)
>   2. 다음 Spec 브랜치 생성 (phase base branch 최신 기준)
> ```
>
> (→ constitution §4.1 Phase base branch 분기 규칙)
