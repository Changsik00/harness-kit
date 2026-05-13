# spec-x-kit-update-hook: SessionStart에서 kit 새 버전 알림 노출

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-kit-update-hook` |
| **Phase** | `phase-x` (Solo) |
| **Branch** | `spec-x-kit-update-hook` |
| **상태** | Planning |
| **타입** | Feature (UX) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-13 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
- `sources/bin/sdd:285-341` `_drift_kit_version()` 함수가 GitHub raw `version.json`을 조회해 새 버전을 감지하고 24h 캐시(`installed.json.lastVersionCheck` / `latestKnownVersion`)에 기록한다.
- 알림은 `sdd status` 의 🔄 동기화 상태 섹션 안에 한 줄로 출력된다: `kit: X.X.X 사용 가능 (현재 Y.Y.Y) — /hk-update`.
- 트리거 진입점은 사용자가 `sdd status` / `/hk-align` 을 *수동으로 호출할 때* 뿐이다.
- `sources/claude-fragments/settings.json.fragment:194-207` 의 SessionStart hook 은 `sdd status --brief` 만 호출하는데, `--brief`는 `no_drift=1`(`sources/bin/sdd:515`)로 drift 검사 자체를 건너뛴다.

### 문제점
- 사용자가 다른 프로젝트에서 작업을 시작할 때 새 kit 버전이 있어도 알림을 만날 일이 거의 없다.
- 결과: "새 버전이 있습니다, 업데이트 할까요?" 같은 흐름을 한 번도 본 적이 없다는 보고. 의도된 동작은 존재하지만 *도달 빈도가 0에 가까움*.
- 본 프로젝트는 도그푸딩이라 늘 최신이라 알림이 안 나오는 게 자연스러우나, 키트를 install한 다른 프로젝트에서는 알림이 노출돼야 함.

### 해결 방안 (요약)
SessionStart 시점에 **전용 hook 스크립트**(`check-kit-version.sh`)를 실행해 새 버전이 있으면 stderr 1줄로 알린다. `_drift_kit_version` 과 동일한 24h 캐시·차단 정책을 그대로 따른다 (cost = curl 1회 / 24h, 캐시 valid 시 0).

알림 예:
```
🆕 harness-kit 0.10.0 사용 가능 (현재 0.9.0) — /hk-update 로 갱신
```

> **자동 실행 금지**: hook은 안내만 한다. `/hk-update` 슬래시 커맨드는 기존대로 사용자가 직접 입력해야 한다 (constitution §5.7 + `hk-update.md` 안전 문구 유지).

## 🎯 요구사항

### Functional Requirements
1. `sources/hooks/check-kit-version.sh` 신규 hook 스크립트:
   - `installed.json` 의 `kitOrigin` 이 github.com 일 때만 동작
   - 24h 캐시 검사: 유효하면 `latestKnownVersion` 사용, 아니면 `curl` 로 갱신
   - `latest > installed` 인 경우만 stderr 한 줄 출력
   - exit 0 (절대 차단 안 함), HARNESS_HOOK_MODE=off 또는 HARNESS_DRIFT_FETCH=0 시 즉시 통과
2. `sources/claude-fragments/settings.json.fragment` SessionStart 배열에 hook entry 추가:
   ```json
   { "type": "command", "command": ".harness-kit/hooks/check-kit-version.sh 2>&1 || true" }
   ```
3. install.sh의 기존 hook 복사 로직(`install.sh:289-297`)이 새 hook 을 자동으로 `.harness-kit/hooks/` 로 복사·chmod 처리한다 (코드 변경 불필요).

### Non-Functional Requirements
1. **차단 금지**: hook 은 어떤 상황에서도 exit 0 (`hook_violation` 사용 안 함). 네트워크 실패 / jq 부재 / origin 비-GitHub → 모두 silent skip.
2. **bash 3.2+ 호환**: `_drift_kit_version` 패턴 그대로 활용 (이미 호환됨).
3. **캐시 일관성**: `_drift_kit_version` 과 같은 `installed.json` 캐시 필드를 사용 → hook 과 status 가 서로 충돌하지 않음.
4. **per-hook off**: `HARNESS_HOOK_MODE_KIT_VERSION=off` 로 개별 비활성 가능.

## 🚫 Out of Scope

- 알림 발견 시 자동 `[Y/n]` prompt → `/hk-update` 자동 실행 (파괴적 작업 보호 원칙 유지)
- `sdd status` brief 모드에서 drift 활성화 (brief의 의미가 무너짐)
- doctor.sh 가 새 hook 의 권한/존재를 별도 점검 (필요 시 별도 spec)
- 비-GitHub origin 지원 확장

## ✅ Definition of Done

- [ ] `sources/hooks/check-kit-version.sh` 신규 작성 (`bash -n` PASS)
- [ ] `sources/claude-fragments/settings.json.fragment` SessionStart 에 hook entry 추가
- [ ] 수동 검증: fake `installed.json` 으로 `kitVersion=0.0.1` 설정 후 hook 직접 실행 시 stderr 알림 출력
- [ ] `walkthrough.md`, `pr_description.md` 작성 + ship commit
- [ ] `spec-x-kit-update-hook` 브랜치 push + PR 생성
