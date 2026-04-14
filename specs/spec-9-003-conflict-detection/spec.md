# spec-9-003: 충돌 감지 + config 시스템

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-9-003` |
| **Phase** | `phase-9` |
| **Branch** | `spec-9-003-conflict-detection` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-14 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`는 `backlog/`와 `specs/` 디렉토리를 무조건 생성한다. 설치 전 해당 디렉토리에 기존 내용이 있는지 확인하지 않는다.

### 문제점

- 기존 프로젝트에 이미 `backlog/`, `specs/` 디렉토리가 있으면 harness-kit이 그 안에 파일을 생성하면서 기존 내용과 뒤섞인다.
- 사용자가 설치 후에야 충돌 사실을 알게 된다.
- 경로를 바꿀 방법이 없어 충돌 시 harness-kit을 포기하거나 기존 디렉토리를 리네임해야 한다.

### 해결 방안 (요약)

설치 전 충돌을 감지하고, 충돌 시 대체 경로를 제안한다. `harness.config.json`으로 경로를 override할 수 있으며, `sdd` 바이너리도 이 config를 읽어 반영한다.

## 📊 개념도

```
install.sh 실행
  ↓
[충돌 스캔]
  backlog/ 존재 + harness-kit 소유 아님 → 충돌
  specs/ 존재 + harness-kit 소유 아님 → 충돌
  ↓ (충돌 없으면 그냥 진행)
[충돌 있으면]
  충돌 내역 출력
  제안: hk-backlog/, hk-specs/ (또는 사용자 직접 입력)
  사용자 확인 (y/N)
  harness.config.json 자동 생성
  ↓
설치 진행 (config 경로 사용)

harness.config.json:
  { "backlogDir": "hk-backlog", "specsDir": "hk-specs" }

sdd status / archive 등 모든 명령이 config를 읽어 경로 반영
```

## 🎯 요구사항

### Functional Requirements

1. **충돌 감지**: `install.sh` 실행 시 `backlog/`, `specs/` 디렉토리가 존재하고 harness-kit 소유(`installed.json`에 의해 만들어진 것)가 아니면 "외부 콘텐츠 충돌"로 판정한다.
2. **충돌 UX**: 충돌 시 충돌 내역 출력 → 대체 경로 제안(`hk-backlog/`, `hk-specs/`) → 사용자 확인 (y/N) → `harness.config.json` 생성.
3. **`harness.config.json` 스키마**: `{ "backlogDir": "backlog", "specsDir": "specs" }` (기본값은 기존 경로 그대로).
4. **`--yes` 플래그**: 충돌 감지 시 자동으로 제안 경로(`hk-backlog/`, `hk-specs/`)를 채택하고 진행.
5. **`sdd` 반영**: 모든 `sdd` 서브커맨드(`status`, `archive`, `phase`, `spec` 등)가 `harness.config.json`의 경로를 읽어 사용.
6. **`update.sh` 반영**: update 시 기존 `harness.config.json`을 보존한다 (override하지 않음).
7. **`doctor.sh` 반영**: config 파일 존재 시 설정된 경로로 디렉토리 확인.

### Non-Functional Requirements

1. **harness.config.json 없으면 기본값**: config 파일이 없으면 `backlog/`, `specs/`를 그대로 사용 (하위 호환).
2. **충돌 감지는 `--yes` 시에도 리포트 출력**: 무조건 진행하더라도 사용자가 무슨 일이 일어났는지 알 수 있어야 함.

## 🚫 Out of Scope

- `backlog/`, `specs/` 외 다른 디렉토리 충돌 감지 (`.claude/`, `.harness-kit/`은 spec-9-001에서 처리됨)
- `harness.config.json` 값의 동적 변경 (설치 후 수동 편집으로 충분)
- config 스키마 확장 (추가 필드는 향후 spec에서)

## ✅ Definition of Done

- [ ] `install.sh`: 충돌 감지 + `harness.config.json` 생성 로직
- [ ] `sdd` 바이너리: `harness.config.json` 읽어 `SDD_BACKLOG`, `SDD_SPECS` 경로 반영
- [ ] `update.sh`: config 보존
- [ ] `doctor.sh`: config 경로 반영
- [ ] `tests/test-conflict-detection.sh` 통과
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-9-003-conflict-detection` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
