# Implementation Plan: spec-x-notify-channels

## 📋 Branch Strategy

- 브랜치: `spec-x-notify-channels` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- **이미 존재함** — 직전 커밋 `be98c42` (dispatcher) 가 이 브랜치에 있음. 새로 만들지 않고 그대로 이어서 작업.
- 시작 지점: 현재 브랜치 HEAD.

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **시크릿 처리 방식**: 키트는 placeholder `.env.*.example` 만 보유·설치한다. 실제 토큰이 든 `.env.telegram` / `.env.discord` 는 install 이 생성·덮어쓰지 않으며 사용자가 직접 채운다. (대안: install 이 빈 `.env.*` 자동 생성 → 채택 안 함, 시크릿 파일 자동 생성은 혼동·실수 위험)
> - [ ] **런처 덮어쓰기**: `telegram.sh` / `discord.sh` 는 키트 관리 파일로 재설치/업데이트 시 덮어쓴다 (commands/hooks 와 동일 정책). 사용자가 nextmarket-api 에서 손본 프로젝트별 주석은 일반판으로 대체됨.

> [!WARNING]
> - [ ] **이미 노출된 토큰**: 현 세션에서 실제 봇 토큰이 출력됨. 유출 우려 시 BotFather / Discord 에서 재발급 권장 (본 spec 범위 밖, 사용자 조치).
> - [ ] **update = uninstall + install**: uninstall 이 실제 `.env.*` 를 지우면 업데이트마다 토큰 소실. → uninstall 은 런처 + `.example` 만 제거하고 실제 `.env.*` 는 보존하도록 구현 (Task 4).

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **키트 원본 위치** | 신규 `sources/root/` 디렉토리 | 기존 `bin`/`hooks` 처럼 글롭 복사 대상. "루트로 가는 파일" 의미를 디렉토리명으로 표현 |
| **런처 (`*.sh`)** | 일반판으로 정규화 후 루트 복사 + `chmod +x` | 프로젝트-비종속(BASH_SOURCE 기반). 키트 관리 파일이므로 덮어쓰기 OK |
| **토큰 (`.env.*`)** | `.example` placeholder 만 설치, 실제 파일 불간섭 | 시크릿 안전 불변식. 사용자가 `.example` 복사 후 토큰 입력 |
| **uninstall** | 런처 + `.example` 제거, 실제 `.env.*` 보존 + **gitignore 라인 동반 제거** | update 시 토큰 소실 방지 + gitignore 중복 누적 방지 (Critique #1, 대안 C) |
| **gitignore** | `.env.telegram`/`.env.discord` 멱등 추가 (대안 C 확정 — 대안 B 미채택) | 토큰 실수 커밋 능동 방어 |
| **uninstall 매니페스트** | 루트 4파일은 **하드코딩 파일명**으로 제거 (installed.json 명단 기록 비채택) | 4개 고정이라 명단 관리 ROI 낮음 (Critique #6). `sources/root/` 파일 증감 시 uninstall 동반 수정 필요 — 결정으로 명시 |

### 📑 ADR 후보

- [x] ADR 가치 있는 결정 있음 → 후보: `kit-root-install-secret-safety` (type: `invariant`). ship 시점 승격 재판단 (비강제).

## 📂 Proposed Changes

### sources/root/ (신규 디렉토리)

#### [NEW] `sources/root/telegram.sh`
nextmarket-api 의 `telegram.sh` 를 프로젝트-비종속 일반판으로 정규화. **정규화 규칙 (Critique #4)**:
- 제거: 프로젝트명 주석("Project: nextmarket-api"), 프로젝트 고유 경로 가정.
- 유지: `BASH_SOURCE` 기반 PROJECT_PATH 결정(이미 비종속), `.env.telegram` 로드, 토큰 검증, `NM_NOTIFY_CHANNEL=telegram` export.
- 플러그인 핀(`@claude-plugins-official`): 원본 그대로 유지 (현 동작 보존, 변경은 별도 spec 사안).
- 한국어 파일 헤더 주석 1줄.

#### [NEW] `sources/root/discord.sh`
위와 동일하게 discord 일반판.

#### (변경) env `.example` 는 키트 파일 아님 — install 이 heredoc 생성
세션 권한 가드가 키트 저장소의 `.env*` 파일 생성을 막고, 시크릿 안전 불변식상 키트에 `.env*` 를 안 싣는 게 더 깔끔하므로 `sources/root/.env.*.example` 파일을 두지 않는다. 대신 install.sh 가 대상 루트에 생성:
```text
# .env.telegram.example
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
# .env.discord.example
DISCORD_BOT_TOKEN=
DISCORD_CHANNEL_ID=
```

### install.sh

#### [MODIFY] `install.sh` — 루트 파일 설치 스텝 추가
bin 복사 스텝(§12) 인근에 새 스텝 추가. `sources/root/` 존재 시:
- `sources/root/*.sh` → `$TARGET/` 복사 (`do_cp`) + `chmod +x` (`do_run "chmod +x ..."` 로 dry-run 존중)
- `.env.telegram.example` / `.env.discord.example` 를 `$TARGET/` 에 **heredoc 생성** (DRY_RUN 시 의도만 출력)
- 실제 `.env.telegram` / `.env.discord` 는 **절대 생성·덮어쓰지 않음**

#### [MODIFY] `install.sh` — gitignore 에 `.env.telegram`/`.env.discord` 추가
기존 harness-kit gitignore 블록 작성 로직에 두 항목 멱등 추가 (구현 시 정확한 위치 확인).

#### [MODIFY] `install.sh` — §4 설치 계획 출력에 루트 파일 표시 (Critique #5)
dry-run "설치 계획/생성할 파일" 요약(§4)에 루트 4파일을 한 줄 추가하여 사용자가 dry-run 으로 인지 가능하게 함.

### uninstall.sh

#### [MODIFY] `uninstall.sh` — 루트 런처 + `.example` 제거
`.harness-kit/` 제거 인근에 추가: `telegram.sh`, `discord.sh`, `.env.telegram.example`, `.env.discord.example` 제거. **실제 `.env.telegram` / `.env.discord` 는 보존** (주석으로 명시).

#### [MODIFY] `uninstall.sh` — §7 gitignore 정리 awk 보강 (Critique #1, 대안 C)
현재 `skip=2` 하드코딩이 `.claude/state/`·`.harness-backup-*/` 두 줄만 소비 → install 이 추가한 `.env.telegram`/`.env.discord` 라인을 제거 못 함. update(=uninstall→install) 시 중복 누적. awk 를 두 `.env.*` 라인도 제거하도록 보강 (정확한 라인 카운트/패턴은 구현 시 install 블록과 짝맞춤).

### .gitattributes (Critique #2)

#### [MODIFY|NEW] `.gitattributes` — `*.sh text eol=lf` 보장
키트 저장소에 `*.sh text eol=lf` 항목이 있는지 확인하고 없으면 추가. Windows 작업 환경에서 `sources/root/*.sh` 가 CRLF 로 커밋되어 macOS/Linux `bash\r` shebang 오류 나는 것 방지.

### 문서 (선택, 경량)

#### [MODIFY] `sources/CLAUDE.md`
하위 디렉토리 표에 `root/` → `$TARGET/` (프로젝트 루트) 행 1줄 추가.

## 🧪 검증 계획 (Verification Plan)

### 단위/스모크 테스트 (필수)
```bash
# 신규 스크립트 구문 검사
bash -n sources/root/telegram.sh
bash -n sources/root/discord.sh
# install/uninstall 구문 검사
bash -n install.sh
bash -n uninstall.sh
```

### 수동 검증 시나리오
1. `install.sh --dry-run <fixture>` → 출력에 루트 4파일 복사 의도 + §4 계획 표시 — 기대: telegram.sh/discord.sh/.env.*.example 언급.
2. (jq 가용 시) `install.sh <fixture>` 실제 실행 → fixture 루트에 4파일 존재 + `.sh` 실행권한 — 기대: 4파일 존재, 실제 `.env.*` 미생성.
3. fixture 에 더미 `.env.telegram` (가짜 토큰) 둔 뒤 `uninstall.sh --yes` → 더미 `.env.telegram` 보존, `.example`·런처 제거 — 기대: 토큰 파일 생존.
4. (FR6) `install → uninstall → install` 2회 사이클 후 fixture `.gitignore` 에 `.env.telegram`/`.env.discord` 라인이 각 1개 — 기대: 중복 없음.
5. (NFR6) `.env.telegram.example` 의 키 = `notify-telegram.sh` 가 source 후 참조하는 변수명 / `.env.discord.example` ↔ `notify-discord.sh` — 기대: 일치.
6. (NFR5) `git check-attr eol -- sources/root/telegram.sh` → `eol: lf` — 기대: LF 강제됨.

> jq 미설치(현 Windows 로컬) 환경에서는 시나리오 2/3 의 full install 이 settings.json jq 머지에서 실패할 수 있음. 그 경우 dry-run + 루트 복사 스텝 단독 검증 + bash -n 으로 대체하고 walkthrough 에 한계 기록.

## 🔁 Rollback Plan

- 전부 신규 파일 + 가역적 install.sh/uninstall.sh 추가. 문제 시 해당 커밋 revert 로 즉시 원복. 대상 프로젝트엔 런처/`.example` 만 추가될 뿐 기존 파일 변경 없음.

## 📦 Deliverables 체크

- [x] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
