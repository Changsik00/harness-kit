# Walkthrough: spec-x-kit-update-hook

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| SessionStart 알림 방식 | (A) 새 hook 스크립트 / (B) `sdd status --brief` 출력에 알림 한 줄 끼워넣기 / (C) `--brief --check-version` 같은 새 플래그 | (A) | brief 의 본래 의미(state 한 줄)를 침범하지 않고, 단일 책임으로 분리. hook 비활성도 per-hook env 로 가능. |
| 알림 발견 시 자동 prompt? | (A) stderr 1줄 알림에 그침 / (B) 즉시 `[Y/n]` 으로 `/hk-update` 자동 진입 | (A) | `/hk-update` 는 uninstall→install 재실행이라는 파괴적 작업. constitution §5.7 + hk-update.md 안전 문구 (사용자 명시 입력 필요) 유지. |
| 캐시 정책 | (A) `_drift_kit_version` 과 동일 필드 공유 / (B) hook 전용 캐시 신설 | (A) | 동일 조회 결과를 두 진입점(sdd status, SessionStart hook) 이 재사용 → 비용 절감 + 동작 일관. |
| 메시지 형식 | sdd status 와 동일 / 더 명시적 | 더 명시적 | `🆕` 이모지 + "/hk-update 로 갱신" 행동 지시. SessionStart 의 첫 출력군에 묻히지 않도록. |

## 💬 사용자 협의

- **주제**: `/hk-update` 의 자동 체크 기능이 실제로 동작하나? "새 버전 있습니다" 안내를 본 적이 없다는 의문 제기
  - **사용자 의견**: 새 세션 시작 시 자동으로 알림이 보였으면 좋겠다
  - **합의**: SessionStart hook 으로 stderr 1줄 알림. 자동 실행은 하지 않고, `/hk-update` 슬래시 커맨드를 사용자가 직접 입력해야 하는 정책은 유지.

## 🧪 검증 결과

### 1. 자동화 테스트

스크립트 + 설정 JSON 변경이라 단위 테스트 대신 정적 검증 + 수동 4종.

- **명령**: `bash -n sources/hooks/check-kit-version.sh` → ✅ PASS (syntax)
- **명령**: `jq '.hooks.SessionStart[0].hooks | length' sources/claude-fragments/settings.json.fragment` → ✅ `3`
- **명령**: `jq '.hooks.SessionStart[0].hooks[1].command' ...fragment` → ✅ `.harness-kit/hooks/check-kit-version.sh 2>&1 || true`

### 2. 수동 검증

1. **Action**: `installed.json.kitVersion` 을 임시로 `0.0.1` 로 교체 → `bash sources/hooks/check-kit-version.sh`
   - **Result**: ✅ `🆕 harness-kit 0.8.0 사용 가능 (현재 0.0.1) — /hk-update 로 갱신` 출력, exit 0
   - latest 가 0.8.0 인 이유: `installed.json` 의 `latestKnownVersion` 캐시가 0.8.0 시절(2026-05-12) 값이고 24h 캐시가 valid 했기 때문. **의도된 동작** (sdd status 와 캐시 공유).
2. **Action**: `HARNESS_HOOK_MODE_KIT_VERSION=off bash sources/hooks/check-kit-version.sh`
   - **Result**: ✅ 출력 없음, exit 0
3. **Action**: `HARNESS_DRIFT_FETCH=0 bash sources/hooks/check-kit-version.sh`
   - **Result**: ✅ 출력 없음, exit 0
4. **Action**: 본 프로젝트(`kitVersion=0.9.0`, 원격=0.9.0) 에서 그대로 실행
   - **Result**: ✅ 출력 없음, exit 0 (`latest == installed` 에서 silent skip)

## 🔍 발견 사항

- `installed.json` 의 `latestKnownVersion` 캐시 갱신 시점에 미묘한 갭이 있다. 0.8.0 시절 캐시가 24h 안에는 *0.8.0이 최신* 이라고 계속 보고함. 본 프로젝트는 도그푸딩이라 install 이 잦아 큰 문제 아니나, **외부 프로젝트 입장에서는 첫 24h 내에는 캐시가 stale 한 시기가 있을 수 있음**. 이는 본 spec 범위 밖 — `_drift_kit_version` 이 이미 같은 동작을 했고, hook 은 그 동작을 공유할 뿐.
- `install.sh:289-297` 이 `sources/hooks/*.sh` 를 일괄 복사·chmod 처리하므로 새 hook 도 자동 배포된다. install 코드 변경 없이 끝났다.
- `install.sh` 의 hooks 머지 정책(line 383-384) 은 *kit fragment 가 권위* 이므로 update.sh 호출 시에도 기존 사용자의 SessionStart 배열이 새 entry 로 자동 갱신된다 — 기존 사용자에게 별도 안내 없이 다음 update 부터 알림이 켜진다.

## 🚧 이월 항목

- 없음 (캐시 stale 이슈는 본 spec 범위 밖).

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-13 |
| **최종 commit** | ship 후 갱신 |
