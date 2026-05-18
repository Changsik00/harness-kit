# spec-x-kit-update-notify: kit 업데이트 알림 및 실행 UX 개선

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-kit-update-notify` |
| **Phase** | `phase-x` |
| **Branch** | `spec-x-kit-update-notify` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-05-18 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`check-kit-version.sh` 훅이 SessionStart마다 실행되어 GitHub에서 최신 버전을 조회한다. 새 버전이 있으면 `🆕 harness-kit X.Y.Z 사용 가능` 메시지를 출력한다. `/hk-update` 슬래시 커맨드는 버전 비교 후 업데이트 명령어를 텍스트로 출력한다.

### 문제점

1. **알림 미도달**: Claude Code의 `SessionStart:compact hook success: ...` 포맷은 첫 번째 훅(`sdd status --brief`) 출력만 포함한다. `check-kit-version.sh`는 두 번째 훅으로 실행되므로 출력이 compact 포맷에 들어오지 않아 에이전트가 볼 수 없다 → 사용자는 알림을 한 번도 받지 못함.
2. **업데이트 실행 불가**: `/hk-update` 가 명령어 텍스트만 출력하고 실행하지 않는다. 사용자가 "업데이트해줘"라고 말해도 에이전트는 복사-붙여넣기를 요구한다.
3. **비로컬 설치 후 업데이트 경로 불명확**: `bash <(curl .../get.sh)` 로 설치한 경우 로컬 클론이 없어서 `update.sh` 직접 실행이 불가능하다. 올바른 경로(`get.sh --update`)가 충분히 안내되지 않는다.

### 해결 방안 (요약)

`sdd status --brief` 자체가 `cache.json`을 읽어 업데이트 가능 여부를 compact 한 줄에 포함시킨다(`→UPDATE:X.Y.Z` 접미사). SessionStart IMPORTANT 지시를 갱신해 에이전트가 이 패턴을 감지하면 즉시 사용자에게 보고하도록 한다. `/hk-update` step 5를 변경해 사용자가 step 4에서 승인하면 에이전트가 Bash 툴로 직접 실행한다(임시 동의 기반).

## 🎯 요구사항

### Functional Requirements

1. `sdd status --brief` 출력이 업데이트 가능 시 `harness-kit 0.12.0 →UPDATE:0.13.0 | ...` 형식을 포함한다. 네트워크 호출 없이 `cache.json` 파일 읽기만 사용한다.
2. SessionStart IMPORTANT 지시에 `→UPDATE:` 패턴 감지 → 사용자 즉시 보고 규칙이 추가된다.
3. `/hk-update` step 5: 사용자가 step 4 확인(`[Y/n]`)에서 승인하면 에이전트가 `bash <(curl -fsSL .../get.sh) --update` 를 Bash 툴로 직접 실행한다. 거절 시 기존 텍스트 출력 유지.
4. 비로컬 설치 시나리오(`get.sh` 경유 설치, 로컬 클론 없음)에서 `get.sh --update`가 올바른 유일한 경로임을 명확히 안내한다.

### Non-Functional Requirements

1. `sdd status --brief`의 cache 읽기는 `jq`와 cache.json 없는 환경에서 graceful skip (기존 brief 출력 유지).
2. bash 3.2+ 호환 유지 — 새 코드에 bash 4+ 전용 기능 사용 금지.

## 🚫 Out of Scope

- `check-kit-version.sh` 훅 자체 제거 또는 재설계 (현재 훅은 cache 갱신 역할도 하므로 유지)
- 자동 업데이트 (사용자 확인 없는 자동 실행)
- 비 GitHub 저장소 지원

## 📑 ADR 후보 (Architecture Decision Records)

- [x] 없음 — 특정 slash command 실행 정책 변경, cross-spec 장기 결정 아님

## ✅ Definition of Done

- [ ] `sdd status --brief` 가 cache.json에 업데이트 버전 있을 때 `→UPDATE:X.Y.Z` 포함 출력
- [ ] SessionStart IMPORTANT 에코 메시지에 `→UPDATE:` 감지 지시 포함
- [ ] `/hk-update` step 5 실행 로직 적용 (sources + installed 모두)
- [ ] 기존 테스트 PASS (`bash tests/test-install-claude-import.sh` 등)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-kit-update-notify` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
