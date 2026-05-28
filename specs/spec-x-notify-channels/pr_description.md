# feat(spec-x-notify-channels): telegram/discord 알림 채널 — dispatcher + 루트 런처/env 설치

## 📋 Summary

### 배경 및 목적

harness-kit 에 telegram/discord 알림 채널을 완성합니다. 이미 추가돼 있던 알림 **dispatcher**(`notify.sh`/`notify-telegram.sh`/`notify-discord.sh` + 입력 대기 hook)는 두 입력에 의존하는데 둘 다 설치되지 않아 휴면 상태였습니다.

1. **채널 선택** (`NM_NOTIFY_CHANNEL`) — 이를 export 하는 **런처** (`telegram.sh`/`discord.sh`) 가 없었음.
2. **토큰** (`.env.telegram`/`.env.discord`) — 헬퍼가 읽을 파일이 없었음 (없으면 silent skip).

본 PR 은 그 빠진 절반 — 런처와 env 템플릿을 대상 프로젝트 **루트**에 설치하는 메커니즘 — 을 추가합니다. 키트엔 루트 설치 메커니즘 자체가 없었으므로 `sources/root/` 디렉토리 + install 스텝을 신설합니다.

### 주요 변경 사항
- [x] `sources/root/` 신설 — 프로젝트-비종속 일반판 런처 `telegram.sh`/`discord.sh`
- [x] `install.sh` — 런처를 대상 루트에 복사(+chmod), `.env.*.example` 를 heredoc 생성, `.gitignore` 에 `.env.telegram`/`.env.discord` 멱등 추가, §4 계획 출력 갱신
- [x] `uninstall.sh` — 런처/`.example` 제거하되 **실제 `.env.*` 토큰은 보존**, `.gitignore` 정리를 블록-범위 명시 매칭으로 교체(update 중복 누적 차단 + 기존 `.harness-kit/` 누락 버그 해결)
- [x] `.gitattributes` — `*.sh text eol=lf` (Windows CRLF → macOS/Linux `bash\r` 오류 방지)
- [x] (참고) 본 브랜치는 dispatcher 커밋 `be98c42` 위에 쌓여 알림 채널 기능 전체를 한 PR 로 묶음

### 컨텍스트
- **모드**: SDD-x (Phase 비소속, 단발). PR 타깃: `main`.
- **시크릿 안전 불변식**: 키트는 실제 토큰을 보유·배포·덮어쓰지 않음. `.env*` 파일을 저장소에 아예 두지 않고 install 이 placeholder 만 생성.

## 🎯 Key Review Points

1. **시크릿 안전** (`install.sh` §12b, `uninstall.sh` §2·§7): install 은 실제 `.env.*` 를 절대 건드리지 않고, uninstall(=update 의 일부)도 지우지 않음. fixture 사이클로 검증.
2. **gitignore 대칭성** (`uninstall.sh` §7): install 이 추가한 라인을 uninstall 이 정확히 제거해야 update 시 중복이 안 쌓임. skip=N 카운터 → 블록-범위 명시 매칭으로 교체.
3. **런처 정규화** (`sources/root/*.sh`): nextmarket-api 원본에서 프로젝트 고유 요소 제거, kit 컨벤션(`set -euo pipefail` + `${VAR:-}` 가드) 적용, 플러그인 핀은 현 동작 보존 위해 유지.

## 🧪 Verification

### 스모크 / 회귀
```bash
bash -n sources/root/telegram.sh sources/root/discord.sh install.sh uninstall.sh update.sh
bash tests/test-gitignore-idempotent.sh   # 22/22 PASS
bash tests/test-install-layout.sh         # 15/15 PASS
bash tests/test-uninstall-cmd-list.sh     # PASS=8/FAIL=1 (pre-existing, 본 변경 무관 — 확인됨)
```

### 수동 검증 시나리오 (fixture)
1. **dry-run** → §4 계획 + 런처 복사 + `.env.*.example` 생성 의도 출력.
2. **실제 install** → 런처 755, `.example` 키가 헬퍼와 일치, **실제 `.env.*` 미생성**, gitignore 추가.
3. **install → 더미 `.env.telegram` → uninstall** → 더미 토큰 **보존**, 런처/`.example` 제거, gitignore 정리.
4. **재install (update 모사)** → gitignore harness 블록 정확히 1개 (중복 없음), 더미 토큰 미덮어씀.

## 📦 Files Changed

### 🆕 New Files
- `sources/root/telegram.sh`, `sources/root/discord.sh`: 알림 채널 런처 (루트 설치용)
- `.gitattributes`: `*.sh` LF 강제
- (dispatcher 측: `sources/bin/notify*.sh`, `sources/hooks/notify-on-input-wait.sh` — `be98c42`)

### 🛠 Modified Files
- `install.sh` (+44): 루트 설치 스텝 + gitignore + 계획 출력
- `uninstall.sh` (+30/-8): 루트 정리(시크릿 보존) + gitignore 대칭 정리
- `sources/CLAUDE.md` (+1): `root/` 행

**Total**: 13 files changed (spec 산출물 제외), +1009 insertions

## ✅ Definition of Done

- [x] 신규 스크립트 `bash -n` 통과 + bash 3.2 호환
- [x] 실제 install/uninstall fixture 검증 (시크릿 보존 + gitignore 비중복)
- [x] 영향권 회귀 테스트 통과 (pre-existing FAIL 1건은 무관 확인)
- [x] `walkthrough.md` / `pr_description.md` ship commit
- [ ] 사용자 검토 요청 알림 (push 후)

## 🔗 관련 자료
- Spec: `specs/spec-x-notify-channels/spec.md`
- Walkthrough: `specs/spec-x-notify-channels/walkthrough.md`
- Critique: `specs/spec-x-notify-channels/critique.md`
- ADR 후보: `kit-root-install-secret-safety` (type: invariant, 미작성 — 후속 재판단)
