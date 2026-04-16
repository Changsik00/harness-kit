# spec-09-006: .harness-kit/ gitignore 자동 추가 옵션

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-09-006` |
| **Phase** | `phase-09` |
| **Branch** | `spec-09-006-gitignore-config` |
| **상태** | Plan Accepted |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-15 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh`는 `.harness-kit/`가 `.gitignore`의 `.*` 패턴에 걸려 추적되지 않는 문제를 방지하기 위해 `.gitignore`에 `!.harness-kit/` (un-ignore)를 추가한다.

### 문제점

- 사용자가 `.harness-kit/`를 git에서 숨기고 싶은 경우(하네스 설정을 공개하지 않으려는 팀)가 있다.
- 반대로 un-ignore 강제 추가가 의도치 않게 팀의 `.gitignore` 규칙을 override할 수 있다.
- 현재는 사용자 선택권이 없다.

### 해결 방안 (요약)

`install.sh`에서 `.harness-kit/`를 `.gitignore`에 추가할지 여부를 사용자에게 질문한다 (기본 Y). 선택 결과를 `harness.config.json`의 `"gitignore"` 필드에 저장하며, `update.sh`는 이 설정을 유지한다.

## 🎯 요구사항

### Functional Requirements

1. `install.sh` 실행 시 `.harness-kit/`를 `.gitignore`에 추가할지 묻는다. 기본값 Y (Enter = Y).
2. `--yes` 플래그 사용 시 기본값(Y)으로 자동 처리한다.
3. Y 선택 시: `.gitignore`에 `.harness-kit/` 항목 추가. 이미 있으면 skip.
4. N 선택 시: `.gitignore`에 `!.harness-kit/` un-ignore 항목 추가. 이미 있으면 skip.
5. `harness.config.json`에 `"gitignore": true|false` 필드 저장.
6. 기존 `!.harness-kit/` un-ignore 무조건 추가 로직을 제거하고 위 조건부 로직으로 대체.
7. `update.sh`는 uninstall+install 구조이므로 prefix와 동일하게 `harness.config.json`에서 `gitignore` 값을 읽어 `install.sh`에 전달한다 (`--gitignore` / `--no-gitignore` 플래그).

### Non-Functional Requirements

1. 멱등성: 동일 설정으로 재설치 시 `.gitignore` 중복 항목 없음.
2. `--yes` 플래그와 완전 호환.

## 🚫 Out of Scope

- `.gitignore` 파일 자체를 생성하는 것 (없으면 안내만).
- `harness.config.json`의 다른 필드 변경.
- gitignore 패턴 세부 커스터마이징.

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-09-006-gitignore-config` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
