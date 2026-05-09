---
description: GitHub PR 생성 — pr_description.md 기반으로 origin 에 PR 요청 (gh CLI 사용)
---

이 명령은 현재 브랜치에 대한 GitHub Pull Request 를 `gh` CLI 로 생성합니다.
원격 GitHub UI 에 접속해 수동으로 PR 을 만들 필요 없이, CLI 한 번으로 끝납니다.

## 사전 조건 (사용자가 한 번만 준비)

1. `gh` CLI 설치: `brew install gh`
2. 인증: `gh auth login` (브라우저로 1회만)
3. 인증 확인: `gh auth status` 가 `Logged in to github.com` 표시하는지

## 호출 절차 (에이전트가 수행)

### 1. 사전 점검

- `gh auth status` 로 인증 상태 확인. 미인증이면 사용자에게 `gh auth login` 안내하고 멈춤.
- `git remote get-url origin` 이 `github.com` 을 포함하는지 확인. 아니면 멈추고 사용자에게 보고.
- `git status` 로 워킹 트리가 깨끗한지 확인
- `git rev-parse --abbrev-ref HEAD` 로 현재 브랜치가 main/master 가 아닌지 확인
- 본문 파일 위치 결정:
  - SDD 흐름이면 → `specs/spec-{phaseN}-{seq}-{slug}/pr_description.md`
  - 일반 흐름이면 → 저장소 루트의 `./pr_description.md`
- 본문 파일이 존재하고 placeholder 만 있는 게 아닌지 확인. 없으면 멈추고 사용자에게 보고.

### 2. 원격 push 확인

`git log --oneline @{u}..HEAD 2>/dev/null` 로 push 안 된 커밋이 있는지 확인.
upstream 이 없으면 처음 push 임. 사용자에게 확인 후:

```bash
git push -u origin <current-branch>
```

### 3. 제목/본문 추출

본문 파일의 첫 비어있지 않은 줄을 PR 제목으로, 나머지를 본문으로 사용합니다. `gh` 가 직접 파일 분리를 지원하지 않으므로 에이전트가 분리해서 인자로 전달:

```bash
PR_FILE="specs/spec-{phaseN}-{seq}-{slug}/pr_description.md"  # 또는 ./pr_description.md
TITLE="$(awk 'NF { sub(/^#+ +/,""); print; exit }' "$PR_FILE")"
BODY="$(awk 'BEGIN{found=0} found{print;next} NF{found=1;next}' "$PR_FILE")"
```

### 4. PR 확인 (사용자 승인)

`--no-confirm` 옵션이 없는 경우, 다음 블록을 표시하고 응답 대기:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 PR 생성 확인
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  브랜치    <head>  ▶  🎯 <base>
  제목      <PR title>
  커밋 수   <N>개
  변경 파일 <M>개
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

생성할까요? [Y/n]
```

긍정/거부 규칙 → constitution §5.7 참조
- **`--no-confirm`**: 확인 블록 생략하고 바로 PR 생성 (hk-ship 경유 시 자동 적용)

### 5. PR 생성

타깃 브랜치는 위 확인 블록에서 이미 표시됨. 승인 후:

```bash
gh pr create \
  --title "$TITLE" \
  --body  "$BODY" \
  --base  "<target-branch>" \
  --head  "<current-branch>"
```

자주 쓰는 추가 옵션:
- `--draft`             draft PR
- `--reviewer USER`     리뷰어 지정 (쉼표 구분 다중 가능)
- `--label LABEL`       라벨 지정
- `--assignee @me`      본인 자동 할당

`gh` 는 자체 확인 프롬프트가 없으므로 **에이전트가 사용자에게 명시적으로 확인을 받은 뒤** 호출해야 합니다.

### 6. 결과 보고

`gh pr create` 가 출력하는 PR URL 을 그대로 사용자에게 전달합니다.
실패 시 stderr 메시지를 그대로 보여주고 멈춥니다 (임의 재시도 금지).

## 주의

- **인증 미설정** 시 `gh` 가 에러를 뱉습니다. 그대로 사용자에게 전달하고 `gh auth login` 안내.
- **타깃 브랜치 자동 사용 금지** — 항상 사용자 확인. main 보호의 일환.
- **upstream 자동 설정** (`-u`) 은 첫 push 일 때만 사용. 이후는 그냥 `git push`.
- **fork 시나리오**: `gh pr create` 가 자동으로 fork 감지. 추가 처리 불필요.
- github.com 이 아닌 GitHub Enterprise 인 경우 `gh` 가 `GH_HOST` 환경변수 또는 `gh auth login --hostname` 으로 사전 설정되어 있어야 함.
