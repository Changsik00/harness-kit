# Walkthrough: spec-x-notify-channels

> 본 문서는 작업 기록입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 작업 모드 | 새 spec-x / 현재 브랜치 bundle / FF | 현재 `spec-x-notify-channels` 에 bundle | 직전 커밋(dispatcher)과 동일 테마. 런처가 dispatcher 의 직접 의존 대상이라 한 PR 로 마무리 (bundle 패턴) |
| gitignore 자동 관리 (critique #1) | 대안 B(제거+주석) / 대안 C(유지+uninstall 대칭) | 대안 C | 루트 런처 UX + 능동 커밋 방어 유지. uninstall §7 awk 동반 수정으로 update 중복 누적 차단 |
| `.env.*.example` 설치 방식 | 파일 복사 / install heredoc 생성 | install heredoc 생성 | 세션 권한 가드가 키트의 `.env*` 파일 생성을 막음 + 시크릿 안전상 키트에 `.env*` 미적재가 더 깔끔. 결과 동일 |
| uninstall gitignore 정리 | skip=N 카운터 보강 / 블록-범위 명시 매칭 교체 | 명시 매칭 교체 | 기존 카운터가 `.harness-kit/` 조차 안 지우던 잠재 버그 실증. 순서/개수 무관 견고 + 블록 범위라 사용자 라인 보존 |

### ADR 승격 가이드

- [x] ADR 승격 대상 있음 → 후보: `kit-root-install-secret-safety` (type: `invariant`). 단발 spec-x 규모로 본 PR 에서는 미작성, 후속 채널 추가 시 승격 재판단 (비강제, spec.md ADR 후보에 기록).
- [ ] 없음

## 💬 사용자 협의

- **주제**: 작업 모드 — 사용자가 AskUserQuestion 에서 "현재 spec-x 에 bundle" 선택.
- **주제**: critique 반영 — 대안 C + 보강 #2~#7 전부 반영 선택.
- **주제**: `.env.*.example` 방식 — 처음 "inline 생성" 선택 → "install.sh 수정되는 거네, 다시" 로 재검토 요청 → 트레이드오프 재제시 후 다시 "inline 생성(A)" 확정. (두 방식 모두 install.sh 의 런처 복사 스텝은 동일, env 처리만 차이임을 명확화)

## 🧪 검증 결과

### 1. 자동화 테스트

#### 스모크 (bash -n)
- **명령**: `bash -n` × `sources/root/telegram.sh`, `discord.sh`, `install.sh`, `uninstall.sh`, `update.sh`
- **결과**: ✅ 모두 통과

#### 기존 회귀 테스트 (내 변경 영향권)
- ✅ `tests/test-gitignore-idempotent.sh` — 22/22 PASS (install 의 `.env.*` gitignore 추가가 멱등성 유지)
- ✅ `tests/test-install-layout.sh` — 15/15 PASS (루트 파일 추가가 레이아웃 점검 비파괴)
- ⚠ `tests/test-uninstall-cmd-list.sh` — PASS=8 / FAIL=1. **pre-existing FAIL** (Scenario 2 `hk-*` glob 불일치, queue.md icebox 기록). Task 6 이전 `uninstall.sh`(commit `1443fcc`)로도 동일하게 PASS=8/FAIL=1 재현 → 본 변경과 무관함을 확인.

### 2. 수동 검증 (fixture)

1. **Action**: `install.sh --dry-run /d/tmp/hk-fixture-test`
   - **Result**: §4 계획에 루트 4파일 표시 + `cp/chmod` dry-run 출력 + `.env.*.example 생성` 의도 출력 확인.
2. **Action**: `install.sh --yes /d/tmp/hk-real-test` (실제, jq 가용)
   - **Result**: `telegram.sh`/`discord.sh` mode 755, `.env.*.example` 키가 헬퍼 변수명과 일치, **실제 `.env.telegram`/`.env.discord` 미생성**, `.gitignore` 에 `.env.telegram`/`.env.discord` 추가.
3. **Action**: install → 더미 `.env.telegram`(가짜 토큰) 생성 → uninstall
   - **Result**: 더미 `.env.telegram` **보존**, 런처/`.example` 제거, `.gitignore` 완전 정리(빈 파일).
4. **Action**: 위 직후 재install (update 사이클 모사)
   - **Result**: `.gitignore` harness 블록 **정확히 1개** (중복 없음 — FR6), 더미 `.env.telegram` 미덮어씀.

## 🔍 발견 사항

- **기존 잠재 버그 해결**: uninstall §7 의 `skip=2` 카운터는 `.harness-kit/` 라인을 한 번도 제거하지 못했음 (실증). 블록-범위 매칭 교체로 동반 해결.
- **jq 가용**: 이 Git Bash 환경엔 `/mingw64/bin/jq` 존재 — 과거 메모리("Windows jq 미설치")와 상충. 실제 install/uninstall full 사이클 검증 가능했음.
- **런처 무동작 주의** (critique #7): 런처는 설치되어도 `claude --channels plugin:telegram@claude-plugins-official` 플러그인이 미설치면 알림이 동작하지 않음. 플러그인 설치/인증은 본 spec 범위 밖 (Claude Code 플러그인 영역).

## 🚧 이월 항목

- 없음. (런처가 의존하는 Claude Code telegram/discord 플러그인 설치 안내는 별도 사안.)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Leo |
| **작성 기간** | 2026-05-28 |
| **최종 commit** | ship 직전 `0bad93d` (ship commit 으로 갱신 예정) |
