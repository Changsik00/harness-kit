# Task List: spec-x-notify-channels

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성 (+ critique 반영)
- [x] plan.md 작성 (+ critique 반영)
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — spec-x 는 phase.md 불필요. queue.md specx 등록은 state 부재로 ship 시 수동 처리.
- [x] Critique 수행 (critique.md) + 반영 결정 (대안 C + #2~#7 전부)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 확인

### 1-1. 브랜치 검증
- [x] 현재 브랜치가 `spec-x-notify-channels` 이고 `main` 이 아님을 확인 (이미 존재 — 신규 생성 불필요)
- [x] Commit: 없음 (확인만)

---

## Task 2: .gitattributes — `*.sh` LF 보장 (Critique #2)

### 2-1. eol=lf 정책 확인/보강
- [x] `.gitattributes` 에 `*.sh text eol=lf` 추가 (없었음 — 신규 생성). autocrlf=true 라 기존 .sh 는 이미 LF 저장, renormalize 노이즈 없음
- [x] 검증: `git check-attr eol -- sources/root/telegram.sh` → `eol: lf` 확인
- [x] Commit: `chore(spec-x-notify-channels): enforce LF for *.sh via .gitattributes`

---

## Task 3: sources/root/ 런처 스크립트 추가

### 3-1. telegram.sh / discord.sh 일반판 작성
- [x] `sources/root/telegram.sh` — 일반판 (한국어 헤더, `#!/usr/bin/env bash` + `set -euo pipefail`, `${VAR:-}` 가드, `NM_NOTIFY_CHANNEL=telegram` export, 플러그인 핀 유지)
- [x] `sources/root/discord.sh` — discord 일반판 (`NM_NOTIFY_CHANNEL=discord`)
- [x] 검증: `bash -n` 양쪽 PASS
- [x] Commit: `feat(spec-x-notify-channels): add generic telegram/discord launchers under sources/root`

---

## Task 4: env 템플릿 — Task 5(install.sh)로 병합

- [-] 사용자 결정: 키트에 `.env*` 파일을 두지 않고 install.sh 가 heredoc 으로 생성. → 별도 파일/커밋 없음, Task 5 에 흡수. (헬퍼 키 확인 완료: TELEGRAM_BOT_TOKEN/TELEGRAM_CHAT_ID, DISCORD_BOT_TOKEN/DISCORD_CHANNEL_ID)

---

## Task 5: install.sh 루트 복사 + gitignore + §4 출력

### 5-1. 루트 설치 스텝 + gitignore 추가 + 계획 출력
- [x] `install.sh` §12b: `sources/root/*.sh` → `$TARGET/` 복사 (+`do_run "chmod +x"` dry-run 존중)
- [x] `.env.telegram.example`/`.env.discord.example` 를 `$TARGET/` 에 heredoc 생성 (헬퍼 키 일치, 실제 `.env.*` 불간섭, DRY_RUN 존중)
- [x] `.env.telegram`/`.env.discord` 를 §16 gitignore 에 멱등 추가
- [x] §4 설치 계획 출력에 루트 4파일 표시 (Critique #5)
- [x] 검증: `bash -n install.sh` PASS + dry-run 출력 확인 + 실제 install fixture 에 런처(755)/`.example`(키 일치)/gitignore 확인, 실제 `.env.*` 미생성 확인
- [ ] Commit: `feat(spec-x-notify-channels): install root launchers + generate env templates at target root`

---

## Task 6: uninstall.sh 루트 정리 + gitignore awk 보강 (시크릿 보존)

### 6-1. 런처/.example 제거, 실제 .env.* 보존, gitignore 라인 동반 제거
- [x] `uninstall.sh` 에 런처 + `.example` 제거 추가 (+백업 루프 포함), 실제 `.env.telegram`/`.env.discord` 보존 (주석 명시)
- [x] §7 gitignore awk 를 블록-범위 명시 매칭으로 교체 — 헤더+5라인+leading blank 제거. 기존 `.harness-kit/` 누락 버그도 해결 (FR6)
- [x] 검증: `bash -n uninstall.sh` PASS + 더미 `.env.telegram` 보존 확인 + `install→uninstall→install` 사이클 후 gitignore 정확히 1블록(비중복) 확인
- [ ] Commit: `feat(spec-x-notify-channels): preserve real .env on uninstall + symmetric gitignore cleanup`

---

## Task 7: 문서 갱신 (경량)

### 7-1. sources/CLAUDE.md 디렉토리 표
- [ ] `sources/CLAUDE.md` 하위 디렉토리 표에 `root/` 행 1줄 추가
- [ ] Commit: `docs(spec-x-notify-channels): document sources/root in sources/CLAUDE.md`

---

## Task 8: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 스모크 테스트 (`bash -n` 4종 + dry-run + 가능 시 update 사이클 gitignore 검증) → PASS
- [ ] **walkthrough.md 작성** (증거 로그 + jq 미설치 한계 + 런처 무동작(플러그인 미설치) 명기 — Critique #7)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-notify-channels): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-notify-channels`
- [ ] **PR 생성**: `/hk-pr-gh` (사용자 승인 후)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 (브랜치 확인 포함) |
| **예상 commit 수** | 5~6 (Task 2 조건부 + 3·4·5·6·7) + ship 1 |
| **현재 단계** | Planning (Critique 반영 완료) |
| **마지막 업데이트** | 2026-05-28 |
