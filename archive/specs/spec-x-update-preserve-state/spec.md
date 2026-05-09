# spec-x-update-preserve-state: update.sh 의 state 손실 버그 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-update-preserve-state` |
| **Phase** | `phase-x` (Solo Spec) |
| **Branch** | `spec-x-update-preserve-state` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no (단위 테스트 + 도그푸딩으로 충분) |
| **작성일** | 2026-04-27 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`update.sh` 는 두 단계로 동작한다:

1. `uninstall.sh --keep-state` 로 기존 설치 제거 (state 보존 옵션)
2. state 에서 4개 필드 (`phase`, `spec`, `planAccepted`, `lastTestPass`) 만 jq 로 백업
3. `install.sh` 재실행 — `install.sh` 는 **항상** `state.json` 을 새 템플릿으로 덮어씀
4. 백업한 4개 필드를 새 state 위에 다시 jq 로 머지 (복원)

`install.sh` 의 state 템플릿 (install.sh:481-491):

```json
{
  "kitVersion": "$KIT_VERSION",
  "phase": null,
  "spec": null,
  "branch": null,
  "planAccepted": false,
  "lastTestPass": null,
  "installedAt": "..."
}
```

### 문제점

1. **`baseBranch` 필드 누락** — `sdd phase new --base` 모드에서 사용하는 `baseBranch` 가 install 템플릿에 없음. 신규 설치 직후엔 필드 자체가 존재하지 않다가, `sdd phase new --base` 가 실행될 때 비로소 추가됨. `update.sh` 도 백업하지 않으므로 update 후 영구 소실.
2. **`branch` 필드 손실** — `update.sh` 가 백업/복원 대상에서 누락. 현재는 항상 `null` 로 리셋됨.
3. **`state.json` 의 `kitVersion` 정합성 부재** — `installed.json` 과 `state.json` 이 두 곳에서 같은 정보(`kitVersion`)를 갖는데 동기화 보장이 약함. `sdd status` 는 `state.json` 의 `kitVersion` 을 출력하므로 stale 하면 사용자가 잘못된 버전을 본다.
4. **`/hk-align` 의 부정확한 진단** — 위 셋이 모두 stale 하면 `sdd status` 가 잘못된 컨텍스트를 보고하고, 에이전트는 잘못된 NEXT 추천을 한다 (실제로 본 사례에서 `kitVersion=0.5.0`, `branch=null` 잔재 발견).

증거 (spec 작성 시점 본 프로젝트 상태):
- `installed.json.kitVersion = 0.6.0`
- `state.json.kitVersion = 0.5.0` (stale)
- `state.json.branch = null` (실제 main)

### 해결 방안 (요약)

1. `update.sh` 의 state 백업 대상을 모든 보존 가능 필드로 확장 (`phase`, `spec`, `branch`, `baseBranch`, `planAccepted`, `lastTestPass`).
2. `install.sh` 의 `state.json` 템플릿에 `baseBranch` 필드 추가.
3. 보존 로직을 명시적 화이트리스트 기반으로 단순화하여 향후 새 필드 추가 시 누락을 잡을 수 있는 단위 테스트 추가.
4. `VERSION` 0.6.0 → 0.6.1, `CHANGELOG.md` 항목 추가, 본 프로젝트에 도그푸딩.

## 🎯 요구사항

### Functional Requirements

1. **F1.** `update.sh` 실행 후 `state.json` 의 다음 필드는 update 직전 값을 그대로 유지해야 한다: `phase`, `spec`, `branch`, `baseBranch`, `planAccepted`, `lastTestPass`.
2. **F2.** `install.sh` 가 신규로 작성하는 `state.json` 템플릿에 `baseBranch: null` 필드가 포함되어야 한다.
3. **F3.** `update.sh` 실행 후 `state.json.kitVersion` 은 `VERSION` 의 새 버전을 반영해야 한다 (이건 기존에도 동작 — 회귀 테스트로 명시화).
4. **F4.** `update.sh` 실행 후 `installed.json.kitVersion` 과 `state.json.kitVersion` 은 동일해야 한다.
5. **F5.** 본 변경 후 자기 자신(harness-kit 저장소)에 `update.sh` 를 적용하면 `state.json` 의 `kitVersion` 이 `0.6.1` 로 갱신되어야 한다.

### Non-Functional Requirements

1. **NF1.** 기존 `tests/test-update.sh` 의 모든 케이스가 계속 PASS 해야 한다 (backward compatible).
2. **NF2.** bash 3.2+ 호환 (CLAUDE.md 의 호환 정책).
3. **NF3.** `state.json` 의 키 추가는 jq fallback 없이 동작해야 한다 — 단, `update.sh` 의 보존 로직은 `jq` 가 있을 때만 실행되는 기존 가드를 유지한다 (jq 미설치 시 graceful degrade).

## 🚫 Out of Scope

- `update.sh` 를 진정한 in-place 업그레이드로 리팩토링하는 것 (현재의 uninstall+install 모델을 유지)
- `installed.json` 의 스키마 변경
- `state.json` 의 신규 필드 추가 (예: `lastUpdateAt`)
- 기존 hook 동작 변경
- 다른 OS 지원 변경

## ✅ Definition of Done

- [ ] F1~F5 모두 충족하는 단위 테스트 추가 (`tests/test-update.sh` 확장 또는 신규 테스트)
- [ ] `update.sh` / `install.sh` / `VERSION` / `CHANGELOG.md` 수정 완료
- [ ] `tests/test-update.sh` PASS
- [ ] `tests/test-version-bump.sh` PASS (버전 인식 마이그레이션 시스템 회귀 방지)
- [ ] 본 프로젝트 도그푸딩 — `bash update.sh` 실행 후 `sdd status` 가 0.6.1 로 표시
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-update-preserve-state` 브랜치 push 완료
- [ ] PR 생성 + 사용자 검토 요청 알림
