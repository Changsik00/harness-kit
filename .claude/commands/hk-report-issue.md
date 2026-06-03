---
description: harness-kit 자체 버그를 kit GitHub 저장소에 이슈로 리포팅 (gh CLI 사용)
---

이 명령은 **harness-kit 키트 자체의 버그**(hook 오작동, `sdd` 명령 오류, 설치/업데이트 마찰 등)를 키트 원본 저장소에 GitHub 이슈로 보고합니다. 다운스트림 사용자가 발견한 키트 결함을 컨텍스트와 함께 메인테이너에게 환류하는 경로입니다.

> ⚠️ **다운스트림 자기 프로젝트의 버그는 대상이 아닙니다.** 명백히 harness-kit 의 기능 결함일 때만 사용하세요.

## 사전 조건 (사용자가 한 번만 준비)

1. `gh` CLI 설치: `brew install gh`
2. 인증: `gh auth login` (브라우저로 1회)

## 호출 절차 (에이전트가 수행)

### 1. 키트 이슈 판정 게이트 (필수)

보고하려는 증상이 **harness-kit 기능 결함**인지 먼저 판단한다. 다음에 해당하면 진행:
- `.harness-kit/` 의 스크립트(`sdd`, hook, install/update)·슬래시 커맨드·거버넌스 산출물이 의도와 다르게 동작
- 키트가 제공한 산출물(템플릿, doctor, state 관리)의 버그

다음이면 **중단하고 사용자에게 알린다** (키트 이슈 아님):
- 사용자 프로젝트 고유 코드/설정의 버그
- 사용자 환경(권한, 네트워크) 문제

판단이 불명확하면 사용자에게 "이게 키트 자체 버그가 맞나요?"를 확인한다.

### 2. 사전 점검 + 저장소 도출

```bash
gh auth status
```
미인증이면 §6 graceful 안내로 분기한다 (중단하되 차단 아님).

`installed.json` 에서 `kitOrigin` 을 읽어 `owner/repo` slug 을 도출한다 (hk-update 와 동일 패턴):

```bash
origin=$(jq -r '.kitOrigin // empty' .harness-kit/installed.json)
slug=$(echo "$origin" | sed 's|git@github.com:||; s|https://github.com/||; s|\.git$||')
```

`origin` 이 `github.com` 계열이 아니면(예: bitbucket) **§6 graceful 안내**로 분기한다 (타 호스트 이슈 API 미지원).

### 3. 진단 컨텍스트 수집

```bash
jq -r '.kitVersion' .harness-kit/installed.json   # 키트 버전
uname -sr                                          # OS
bash --version | head -1                           # bash
bash .harness-kit/bin/sdd doctor 2>&1 | tail -20   # doctor 발췌 (필요 시)
```

대화 맥락에서 **증상 / 재현 절차 / 기대 vs 실제**를 정리한다.

### 4. 중복 이슈 검색

게시 전 유사 이슈가 있는지 확인한다:

```bash
gh issue list --repo "$slug" --state all --search "<핵심 키워드>" --limit 10
```

유사 이슈가 있으면 사용자에게 제시하고 **신규 생성 대신 기존 이슈에 코멘트**할지 선택받는다.

### 5. 본문 초안 + 시크릿 점검 + 사용자 확인 (필수)

아래 템플릿으로 본문을 작성한다:

```markdown
## 증상
<무엇이 잘못 동작하는가>

## 재현 절차
1. ...
2. ...

## 기대 vs 실제
- 기대: ...
- 실제: ...

## 환경
- kit 버전: <kitVersion>
- OS: <uname>
- bash: <version>

## 추가 정보 (doctor 발췌 등)
```

게시 **전에** 본문을 점검한다:
- **시크릿/토큰**(API 키, PEM 헤더, 비밀번호)·다운스트림 고유 경로·사내 식별자가 섞이지 않았는지 검토하고, 있으면 제거하거나 마스킹한다.
- 키트 저장소는 **PUBLIC** 이므로 게시 내용은 영구 공개·인덱싱된다.

그 다음 **본문 전체를 사용자에게 보여주고** 확인을 받는다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📮 이슈 게시 확인 (PUBLIC: <slug>)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  제목   <issue title>
  본문   <전체 본문 표시>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

게시할까요? [Y/n]
```

긍정/거부 규칙 → constitution §5.7. **확인 전 게시 절대 금지** (외부 공개 행위).

### 6. 이슈 생성 / Graceful Degradation

확인(Y) 후:

```bash
gh issue create --repo "$slug" --title "$TITLE" --body "$BODY"
```

출력되는 이슈 URL 을 사용자에게 보고한다. 실패 시 stderr 를 그대로 보여주고 멈춘다 (임의 재시도 금지).

**Graceful degradation** (`gh` 미설치/미인증 또는 non-github origin):
- 차단(exit 1)하지 않는다. 대신 작성한 본문을 그대로 출력하고, 수동 작성 경로를 안내한다:

```
gh 가 없거나 인증되지 않았습니다. 아래 본문으로 직접 이슈를 생성하세요:
  https://github.com/<slug>/issues/new

<본문>
```

## 주의

- **자동 게시 금지** — 항상 사용자 `[Y/n]` 확인 후에만 생성.
- **PUBLIC 노출** — 다운스트림 코드/시크릿/사내 경로가 본문에 새지 않도록 게시 전 점검 필수.
- **키트 이슈만** — 사용자 프로젝트 버그는 대상 아님 (§1 판정 게이트).
- **non-github** origin 은 graceful skip — 수동 안내만.
