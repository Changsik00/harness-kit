# spec-15-06: 사용자 커스텀 hook 보존

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-15-06` |
| **Phase** | `phase-15` |
| **Branch** | `spec-15-06-user-hook-preserve` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`의 `settings.json` 머지 로직(`install.sh:352`)은 다음 jq 표현으로 hooks를 처리한다:

```jq
| .hooks = ($kit.hooks // $user.hooks)
```

이는 키트 hooks가 존재하면 사용자 hooks를 *통째로* 교체한다. 현재 키트 fragment는 항상 `PreToolUse`와 `SessionStart`를 포함하므로, 사용자가 `settings.json`에 추가한 모든 커스텀 hook event type이 install/update 시 영구 소실된다.

### 문제점

- **Pattern B (User Content Blindness)**: 사용자가 `settings.json`에 추가한 hook event type(예: `PostToolUse`, `UserAddedHook`)이 install/update 실행 때마다 삭제됨
- 사용자는 키트를 재설치하지 않는 한 커스텀 hook을 복구할 수 없음
- `spec-15-01` audit에서 `settings.json` hook 처리를 "B (중간 — 사용자 hook 손실)"로 분류하고 본 spec으로 위임
- `tests/test-update-stateful.sh` Scenario 3이 "정책 결정 후 spec-15-06에서 추가"로 skip 처리 중

### 해결 방안 (요약)

**Kit-key 우선 + 사용자-전용 key 보존 전략**:

키트 hooks(`PreToolUse`, `SessionStart`)는 fragment 버전으로 항상 최신화하되, 키트에 없는 사용자 정의 hook event type은 덮어쓰지 않고 보존한다. jq 머지 로직에서 `+` 연산자와 `with_entries(select(...))` 조합으로 구현한다.

## 🎯 요구사항

### Functional Requirements

1. install 실행 후, 사용자가 `settings.json`에 추가한 **키트에 없는** hook event type이 그대로 보존된다.
2. install 실행 후, 키트가 관리하는 `PreToolUse`·`SessionStart`는 fragment 최신 버전으로 갱신된다 (기존 동작 유지).
3. install을 여러 번 실행해도 보존된 사용자 hook이 중복 추가되지 않는다 (멱등성).
4. update.sh 실행 시에도 동일한 보존 동작이 적용된다 (update.sh → install.sh 재실행 경로 포함).

### Non-Functional Requirements

1. bash 3.2+ 호환 — jq 표현 내에서만 처리하므로 bash 버전 무관.
2. `jq`가 없는 환경에서는 기존 fallback(`cp "$FRAGMENT" "$SETTINGS"`) 그대로 동작.

## 🚫 Out of Scope

- **기존 kit event type 내부 hook 항목 병합**: 사용자가 `PreToolUse` 배열에 직접 추가한 항목 보존. 이는 `.command` 경로 기반 intra-event 머지가 필요한 더 복잡한 케이스로 후속 spec에 위임.
- `harness.config.json` OVERWRITE 정책 변경 (spec-15-07 후보 / Icebox).
- settings.json 외 파일(`CLAUDE.fragment.md` 등)의 커스텀 내용 보존.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`bash tests/test-install-settings-hook.sh`)
- [ ] `tests/test-update-stateful.sh` Scenario 3 PASS (skip 해제 후 실제 검증)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-15-06-user-hook-preserve` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
