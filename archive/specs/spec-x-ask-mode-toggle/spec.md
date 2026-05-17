# spec-x-ask-mode-toggle: uxMode 토글 액션 + `/hk-ask-mode` 슬래시 커맨드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-ask-mode-toggle` |
| **Phase** | `phase-x` (Solo Spec) |
| **Branch** | `spec-x-ask-mode-toggle` |
| **상태** | Planning |
| **타입** | Feature (small) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- `uxMode` 는 `AskUserQuestion` 사용 여부를 결정하는 영구 설정 (agent.md §8.4).
- 변경 수단은 CLI 한 줄: `sdd config ux-mode [interactive|text]`.
- 슬래시 커맨드는 없음 — 사용자는 매번 명시적으로 `interactive` 또는 `text` 를 타이핑해야 함.

### 문제점

1. **명시 값 강제**: 모드를 바꾸려면 *현재 값이 무엇인지* 먼저 확인하고, *반대 값* 을 외워서 입력해야 함. UX 마찰.
2. **발견성 낮음**: 슬래시 커맨드 없음 → `/` 자동완성 목록에 노출 안 됨. `sdd config` 라는 CLI 경로를 알아야만 변경 가능.
3. **빈도 ≠ 0**: 자주 바꾸는 설정은 아니지만, 사용자가 모드를 *시험* 하거나 *전환* 해보고 싶을 때 진입 장벽이 있음.

### 해결 방안 (요약)

(a) `sdd config ux-mode toggle` 액션을 추가해 현재값을 자동 반전 (`interactive` ↔ `text`) 시키고, (b) 이를 호출하는 단일 슬래시 커맨드 `/hk-ask-mode` 를 신설한다. 사용자는 한 번의 호출로 모드를 뒤집고 새 값을 통보받는다.

## 📊 개념도

```
[ /hk-ask-mode ]  ─┐
                   ▼
       bash .harness-kit/bin/sdd config ux-mode toggle
                   │
                   ▼
       .harness-kit/installed.json  ◄── uxMode: interactive ⇄ text
                   │
                   ▼
       agent.md §8.4 가 다음 세션부터 새 값 적용
```

## 🎯 요구사항

### Functional Requirements

1. **CLI 토글 액션**: `sdd config ux-mode toggle` 입력 시
   - 현재값이 `interactive` 면 `text` 로 변경.
   - 현재값이 `text` 면 `interactive` 로 변경.
   - 변경 후 새 값을 stdout 으로 출력 (예: `uxMode = text`).
2. **CLI 도움말 갱신**: `sdd --help` 의 `config ux-mode [interactive|text]` 라인에 `toggle` 도 표시.
3. **CLI 에러 메시지 갱신**: 잘못된 값 입력 시 에러에 `toggle` 허용값 포함.
4. **슬래시 커맨드 `/hk-ask-mode`**: 호출 시 위 CLI 를 실행하고 결과를 사용자에게 보고.
5. **install 자동 반영**: `sources/commands/hk-ask-mode.md` 가 `install.sh` 의 `installedCommands` 자동 수집 로직(`install.sh:497-507`)에 의해 신규 설치 / `update.sh` 실행 시 자동 등록.
6. **도그푸딩 동기화**: 본 저장소(`.harness-kit/installed.json` / `.claude/commands/`) 에도 새 커맨드가 반영됨.
7. **거버넌스 문서 동기화**: `sources/governance/agent.md` §8.4 의 변경 방법 안내에 `toggle` 액션과 `/hk-ask-mode` 슬래시를 명시. `.harness-kit/agent/agent.md` 도 같이 갱신.

### Non-Functional Requirements

1. **Backward compatibility**: 기존 `sdd config ux-mode interactive|text` 동작 유지.
2. **테스트 일관성**: `tests/test-sdd-config.sh` 의 기존 4개 시나리오 무회귀 + `toggle` 시나리오 추가.
3. **단일 명령 원칙**: 슬래시 커맨드 본문은 한 줄 bash 호출 (agent.md §6.4).

## 🚫 Out of Scope

- `uxMode` 외 다른 설정값에 대한 토글 일반화 (현재 토글 가치 있는 설정은 `uxMode` 뿐).
- `/hk-doctor` 출력에 `uxMode` 노출 (별건 — 필요 시 별도 spec).
- 세션 내 임시 토글 (값을 `installed.json` 에 저장하지 않는 ephemeral mode).

## 📑 ADR 후보

- [x] 없음 — 기존 `uxMode` 결정의 UX 부가 기능. 새 아키텍처 결정 없음.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-sdd-config.sh` 통과 + `toggle` 시나리오 추가)
- [ ] `walkthrough.md` / `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-ask-mode-toggle` 브랜치 push 완료
- [ ] PR 생성 + URL 보고

## 📎 부수 발견 (참고)

`sdd specx new` 가 생성한 spec.md 스캐폴드에서 Branch 필드 값이 `spec-x-ask-mode-toggle-ask-mode-toggle` (slug 중복) 으로 잘못 입력됨 — `specx new` 의 변수 치환 버그 의심. 본 spec 에서는 올바른 값으로 덮어쓰되, 별도 정리 대상으로 `backlog/queue.md` Icebox 에 기록.
