# spec-09-003: 경로 config 시스템

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-09-003` |
| **Phase** | `phase-09` |
| **Branch** | `spec-09-003-conflict-detection` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-14 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`는 `backlog/`와 `specs/` 경로를 하드코딩한다. 경로를 바꿀 방법이 없다.

### 문제점

harness-kit 파일은 고유한 네이밍 컨벤션(`phase-N.md`, `spec-N-NNN-slug/` 등)을 가지므로 기존 디렉토리와 실제 파일 충돌이 발생하지는 않는다. 그러나 기존 프로젝트에 `backlog/`나 `specs/`가 다른 용도로 이미 있다면 디렉토리가 뒤섞여 관리가 어려워진다. 사용자가 경로를 바꾸고 싶어도 방법이 없다.

### 해결 방안 (요약)

install 시 경로를 바꾸고 싶은지 묻고, prefix를 지정하면 자동으로 `{prefix}backlog/`, `{prefix}specs/`로 설정한다. `harness.config.json`으로 저장하며 `sdd` 바이너리도 반영한다.

## 📊 개념도

```
install.sh 실행
  ↓
[경로 설정 UX]
  "backlog/, specs/ 기본 경로 사용합니다."
  "변경하려면 prefix 입력 (예: hk- → hk-backlog/, hk-specs/):"
  "[Enter = 기본값 / prefix 입력]"
  ↓
[prefix 입력한 경우]
  .harness-kit/harness.config.json 생성:
  { "backlogDir": "hk-backlog", "specsDir": "hk-specs" }
  ↓
설치 진행 (config 경로로 디렉토리 생성)

--yes 플래그: 기본값(backlog/, specs/)으로 질문 없이 진행

sdd 모든 서브커맨드: harness.config.json 읽어 경로 반영
```

## 🎯 요구사항

### Functional Requirements

1. **install UX**: install 시 경로 변경 여부를 묻는다. prefix 입력 시 `{prefix}backlog/`, `{prefix}specs/`로 설정한다.
2. **`--yes` 플래그**: 질문 없이 기본값(`backlog/`, `specs/`)으로 진행한다.
3. **`harness.config.json`**: prefix 지정 시 `.harness-kit/harness.config.json` 생성. 기본값이면 파일 미생성(불필요).
4. **`harness.config.json` 스키마**: `{ "backlogDir": "hk-backlog", "specsDir": "hk-specs" }`.
5. **`sdd` 반영**: 모든 서브커맨드가 `harness.config.json` 읽어 `SDD_BACKLOG`/`SDD_SPECS` 경로 사용.
6. **`update.sh`**: 기존 `harness.config.json` 보존 (override 금지).
7. **`doctor.sh`**: config 파일 존재 시 설정된 경로로 디렉토리 확인.
8. **`common.sh` 경로 수정**: `SDD_AGENT`/`SDD_TEMPLATES`를 `.harness-kit/agent/`로 수정 (spec-09-001에서 누락).

### Non-Functional Requirements

1. **하위 호환**: config 없으면 `backlog/`, `specs/` 기본값 사용.
2. **jq 없어도 동작**: config 읽기 실패 시 기본값으로 폴백.

## 🚫 Out of Scope

- 충돌 감지 (harness-kit 네이밍 컨벤션으로 실제 충돌 없음)
- `backlog/`/`specs/` 외 다른 경로 설정
- config 동적 변경 (수동 편집으로 충분)

## ✅ Definition of Done

- [ ] `install.sh`: prefix UX + `harness.config.json` 생성
- [ ] `sources/bin/lib/common.sh`: config 읽기 + `.harness-kit/agent/` 경로 수정
- [ ] `update.sh`: config 보존
- [ ] `doctor.sh`: config 경로 반영
- [ ] `tests/test-path-config.sh` 통과
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-09-003-conflict-detection` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
