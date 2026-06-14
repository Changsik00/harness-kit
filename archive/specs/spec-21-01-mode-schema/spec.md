# spec-21-01: 모드 스키마 및 CLI

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-21-01` |
| **Phase** | `phase-21` |
| **Branch** | `spec-21-01-mode-schema` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-06-12 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`.claude/state/current.json` 에는 `phase`, `spec`, `planAccepted`, `lastTestPass` 등의 필드가 있다. 훅 시스템은 `_lib.sh` 의 `hook_state` 함수로 이 파일의 임의 키를 읽는다. `sdd` CLI 에는 `phase`, `spec`, `plan`, `config` 등의 서브커맨드가 있지만 실행 모드를 전환하는 커맨드는 없다.

### 문제점

Turbo 모드를 추가하려면 훅과 CLI 모두 현재 활성 모드를 알아야 한다. 현재 상태 파일에 모드 개념이 없어서 훅이 모드를 읽을 수 없고, 사용자가 모드를 전환할 CLI 진입점도 없다.

### 해결 방안 (요약)

`current.json` 에 `mode` 필드(기본값: `"governed"`)를 도입하고, `sdd mode [turbo|governed|status]` 서브커맨드를 추가한다. `hook_state mode` 가 이미 임의 키를 읽으므로 `_lib.sh` 변경 없이 훅에서 즉시 활용 가능하다. 필드 부재 시 `governed` 로 간주하여 기존 설치에 영향 없다.

## 🎯 요구사항

### Functional Requirements

1. `sdd mode turbo` 실행 시 `current.json` 의 `mode` 필드를 `"turbo"` 로 설정하고 확인 메시지 출력
2. `sdd mode governed` 실행 시 `mode` 를 `"governed"` 로 설정하고 확인 메시지 출력
3. `sdd mode status` (또는 인수 없이 `sdd mode`) 실행 시 현재 모드 출력. 필드 없으면 `"governed"` 출력
4. `sdd status` 출력에 `Active Mode` 항목으로 현재 모드 표시
5. `hook_state mode` 호출로 훅에서 mode 읽기 가능 — `_lib.sh` 변경 없음

### Non-Functional Requirements

1. `mode` 필드 부재 (기존 설치) 시 `"governed"` 로 fallback — 기존 거버넌스 유지
2. `sources/bin/sdd` 에도 동일 변경 미러링 — install/update 경로 반영
3. bash 3.2+ 호환

## 🚫 Out of Scope

- 훅 분기 로직 (`check-plan-accept.sh` 변경) — spec-21-02
- `post-commit-verify.sh` 신규 생성 — spec-21-02
- `intent.yaml` 및 `sdd intent` 커맨드 — spec-21-03
- `constitution.md` / `/hk-mode` 슬래시 커맨드 — spec-21-04

## 📑 ADR 후보 (Architecture Decision Records)

- [ ] 없음 (모드 개념 자체는 phase-21 ADR-007 에서 상위 결정으로 다룸)

## 🔗 관련 문서 (Related)

- 관련 ADR: ADR-007 (spec-21-04에서 작성 예정)
- 관련 phase: `backlog/phase-21.md`

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-mode-schema.sh`)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-21-01-mode-schema` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
