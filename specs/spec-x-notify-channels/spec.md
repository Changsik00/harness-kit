# spec-x-notify-channels: telegram/discord 알림 채널 — 루트 런처 + env 템플릿 설치

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-notify-channels` |
| **Phase** | 없음 (SDD-x) |
| **Branch** | `spec-x-notify-channels` |
| **상태** | Planning |
| **타입** | Feature (소규모, 기존 미머지 spec-x 에 bundle) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-28 |
| **소유자** | Leo |

## 📋 배경 및 문제 정의

### 현재 상황

직전 커밋 `be98c42` 가 알림 dispatcher 측을 추가했습니다.

- `sources/bin/notify.sh` — `NM_NOTIFY_CHANNEL` 값으로 telegram/discord 헬퍼 분기
- `sources/bin/notify-telegram.sh` / `notify-discord.sh` — 채널별 발송 헬퍼 (`.env.{telegram,discord}` 없으면 silent skip)
- `sources/hooks/notify-on-input-wait.sh` — 입력 대기 시 자동 알림 hook

이 dispatcher 는 `install.sh` 가 `sources/bin`·`sources/hooks` 를 글롭 복사하므로 대상 프로젝트의 `.harness-kit/bin`·`.harness-kit/hooks` 로 자동 설치됩니다.

### 문제점

dispatcher 는 두 입력에 의존하는데, **둘 다 현재 설치되지 않습니다.**

1. **채널 선택 (`NM_NOTIFY_CHANNEL`)** — `notify.sh` 는 이 환경변수로 채널을 정합니다. 이를 export 하는 주체는 **런처 스크립트** (`telegram.sh` / `discord.sh`) 입니다. 런처가 없으면 항상 telegram 기본값으로만 동작.
2. **토큰 (`.env.telegram` / `.env.discord`)** — 헬퍼는 이 파일에서 토큰을 읽습니다. 파일이 없으면 silent skip → 알림이 영영 안 옴.

즉 dispatcher 만 설치된 현재 상태로는 **알림 기능이 휴면 상태**입니다. 사용자가 `nextmarket-api` 에서 수동으로 만들어 둔 `telegram.sh` / `discord.sh` / `.env.*` 를 매 프로젝트마다 손으로 복제해야 합니다.

또한 키트에는 **대상 프로젝트 루트에 파일을 설치하는 메커니즘 자체가 없습니다.** install.sh 는 모든 산출물을 `.harness-kit/` · `.claude/` 하위로만 복사합니다.

### 해결 방안 (요약)

키트에 `sources/root/` 디렉토리를 신설하여 **프로젝트 루트에 설치될 파일**을 담고, install.sh 에 루트 복사 스텝을 추가합니다. 런처(`telegram.sh`/`discord.sh`)는 프로젝트-비종속 일반판으로, 토큰 파일은 placeholder `.example` 템플릿으로 제공합니다.

## 🎯 요구사항

### Functional Requirements

1. 키트에 `sources/root/` 디렉토리를 추가하고, 다음 4개 파일을 포함한다.
   - `telegram.sh` — 일반판 런처 (`NM_NOTIFY_CHANNEL=telegram` export 후 `claude --channels plugin:telegram@...` 실행)
   - `discord.sh` — 일반판 런처 (`NM_NOTIFY_CHANNEL=discord`)
   - `.env.telegram.example` — placeholder (`TELEGRAM_BOT_TOKEN=` / `TELEGRAM_CHAT_ID=`)
   - `.env.discord.example` — placeholder (`DISCORD_BOT_TOKEN=` / `DISCORD_CHANNEL_ID=`)
2. `install.sh` 가 `sources/root/*.sh` 를 대상 프로젝트 루트에 복사하고 실행권한(`chmod +x`)을 부여한다.
3. `install.sh` 가 `sources/root/.env.*.example` 를 대상 루트에 복사한다.
4. `uninstall.sh` 가 런처 + `.example` 를 제거하되, **실제 `.env.telegram` / `.env.discord` 는 보존**한다.
5. 대상 `.gitignore` 에 `.env.telegram` / `.env.discord` 가 (없으면) 추가되어 토큰 커밋을 방지한다.
6. (Critique #1, 대안 C) `uninstall.sh` 의 gitignore 정리 로직이 install 이 추가한 `.env.telegram`/`.env.discord` 라인도 함께 제거한다 — `update = uninstall + install` 사이클에서 라인 중복 누적이 없어야 한다.
7. (Critique #5) `install.sh` 의 "설치 계획 출력"(§4) 에 루트 파일 4개가 표시되어 dry-run 시 사용자가 인지할 수 있다.

### Non-Functional Requirements

1. **시크릿 안전 불변식 (최우선)**: 키트는 실제 토큰을 절대 보유·배포·덮어쓰지 않는다. `sources/` 에는 placeholder `.example` 만 존재. install 은 실제 `.env.*` 를 건드리지 않고, uninstall(따라서 update)도 지우지 않는다.
2. **멱등성**: 재설치/업데이트 시 런처는 동일 내용으로 재생성되어도 무방하고, 실제 토큰 파일은 영향받지 않으며, gitignore 라인도 중복되지 않는다 (FR6).
3. **bash 3.2 호환** + 모든 신규 스크립트 `set -euo pipefail` / `bash -n` 통과.
4. **dry-run 존중**: `install.sh --dry-run` 은 루트 복사를 실제 수행하지 않고 의도만 출력한다.
5. **(Critique #2) 줄바꿈**: `sources/root/*.sh` 는 LF 로 커밋되어야 한다 (macOS/Linux 에서 `bash\r` shebang 오류 방지). `.gitattributes` 에 `*.sh text eol=lf` 가 보장되는지 확인.
6. **(Critique #3) 키 동기화**: `.env.*.example` 의 변수명은 헬퍼(`notify-telegram.sh`/`notify-discord.sh`)가 실제 읽는 변수명과 일치해야 한다.

## 🚫 Out of Scope

- 런처가 호출하는 `plugin:telegram@claude-plugins-official` / `plugin:discord@...` 플러그인 자체의 설치·인증 (Claude Code 플러그인 영역).
- Slack 등 telegram/discord 외 신규 채널 추가.
- dispatcher / 헬퍼 / hook 로직 변경 (직전 커밋 `be98c42` 범위 — 본 spec 은 그 위에 설치 절반만 추가).
- 사용자의 기존 `.env.*` 토큰 자동 마이그레이션.

## 📑 ADR 후보

- [x] ADR 가치 있는 결정 있음 → 후보 한 줄 요약: `kit-root-install-secret-safety` (type: `invariant` — "키트는 실제 시크릿을 보유·배포·덮어쓰지 않는다; `.example` 만 관리"). 단발 spec-x 규모라 ADR 승격은 ship 시점 재판단 (비강제).
- [ ] 없음

## ✅ Definition of Done

- [ ] 신규 스크립트 `bash -n` PASS + bash 3.2 호환
- [ ] `install.sh --dry-run` 이 루트 복사 의도를 출력 (§4 설치 계획에 4파일 표시), 실제 install 이 루트에 4파일 배치 (jq 미설치 환경 한계는 walkthrough 에 기록)
- [ ] uninstall 이 실제 `.env.*` 를 보존함을 검증
- [ ] (FR6) `uninstall → install` 2회 반복 후 `.gitignore` 에 `.env.*` 라인이 중복되지 않음을 검증
- [ ] (NFR5) `sources/root/*.sh` 가 LF 로 커밋됨 (`.gitattributes` 확인/보강)
- [ ] (NFR6) `.env.*.example` 키가 헬퍼가 읽는 변수명과 일치
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-notify-channels` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
