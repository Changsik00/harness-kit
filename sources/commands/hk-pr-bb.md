---
description: Bitbucket Cloud PR 생성 — pr_description.md 기반으로 origin 에 PR 요청
---

이 명령은 현재 브랜치에 대한 Bitbucket Cloud Pull Request 를 생성합니다.
원격 git UI 에 접속해 수동으로 PR 을 만들 필요 없이, CLI 한 번으로 끝납니다.

## 사전 조건 (사용자가 한 번만 준비)

1. Bitbucket Cloud API 토큰 발급 (또는 App Password — `pullrequest:write` 스코프 필요)
2. 토큰을 파일로 저장:
   ```bash
   mkdir -p ~/.config/bitbucket
   echo '<TOKEN>' > ~/.config/bitbucket/token       # 또는 'user:app_password'
   chmod 600 ~/.config/bitbucket/token
   ```
   - 다른 경로를 쓰려면 `BITBUCKET_TOKEN_FILE` 환경변수로 지정

## 호출 절차 (에이전트가 수행)

### 1. 사전 점검

- `git status` 로 워킹 트리가 깨끗한지 확인
- `git rev-parse --abbrev-ref HEAD` 로 현재 브랜치가 main/master 가 아닌지 확인
- 본문 파일 위치 결정:
  - SDD 흐름이면 → `specs/spec-{phaseN}-{seq}-{slug}/pr_description.md`
  - 일반 흐름이면 → 저장소 루트의 `./pr_description.md`
- 본문 파일이 존재하고 placeholder 만 있는 게 아닌지 확인. 없으면 멈추고 사용자에게 보고.

### 2. 원격 push 확인

`git log --oneline @{u}..HEAD 2>/dev/null` 로 push 안 된 커밋이 있는지 확인.
있으면 사용자에게 push 여부를 물어본 뒤 승인 시:
```bash
git push -u origin <current-branch>
```

### 3. PR 확인 (사용자 승인)

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
- **`--no-confirm`**: 확인 블록 생략 (`bb-pr -y` 플래그와 동일 효과, hk-ship 경유 시 자동 적용)

### 4. PR 생성

```bash
./scripts/harness/bin/bb-pr -f <본문 파일 경로>
```

기본 동작:
- origin URL 에서 workspace/repo 자동 추출
- 소스 브랜치 = 현재 체크아웃 브랜치
- 타깃 브랜치 = repo 기본 브랜치 (대화형 입력으로 변경 가능)
- 본문 파일의 첫 비어있지 않은 줄 → PR 제목 (선두 `# ` 제거)
- 나머지 → PR 본문

자주 쓰는 옵션:
- `-t <branch>`  타깃 브랜치 명시 (예: `develop`)
- `-d`           draft PR
- `-y`           모든 확인 생략 (CI 등 비대화형)
- `-n`           dry-run (페이로드만 출력)

### 5. 결과 보고

bb-pr 이 출력하는 PR URL 과 PR 번호를 그대로 사용자에게 전달합니다.
실패 시 stderr 의 응답 body 를 그대로 보여주고 멈춥니다 (임의 재시도 금지).

## 주의

- bb-pr 은 자체 확인 프롬프트가 있습니다. 에이전트는 `-y` 를 임의로 붙이지 마세요 — 사용자가 명시적으로 요청한 경우에만 사용.
- 토큰 파일이 없거나 권한이 600 이 아니면 bb-pr 이 경고/에러를 냅니다. 그대로 사용자에게 전달하세요.
- bitbucket.org 가 아닌 origin (GitHub, GitLab, 사내 Bitbucket Server) 이면 bb-pr 이 거부합니다.
