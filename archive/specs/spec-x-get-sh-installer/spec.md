# spec-x-get-sh-installer: curl 한 줄 원격 인스톨러

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-get-sh-installer` |
| **Phase** | 없음 (Solo Spec) |
| **Branch** | `spec-x-get-sh-installer` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-05-09 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

harness-kit 설치는 두 단계가 필요하다:
1. `git clone` 또는 zip 다운로드로 로컬에 키트 확보
2. `bash install.sh /path/to/project` 실행

### 문제점

- 사용자가 먼저 레포를 clone/download 해야 한다는 진입 장벽이 있음
- clone 후 키트 디렉토리 관리(어디 뒀더라, 지워도 되나) 등 인지 부하 발생
- 다른 bash 툴킷처럼 curl 한 줄로 설치하는 경험을 제공하지 못함

### 해결 방안 (요약)

`get.sh` 를 추가한다. GitHub에서 harness-kit 소스를 임시 디렉토리에 내려받아 `install.sh` 를 실행하고 정리한다. 업데이트도 같은 방식으로 지원한다.

## 🎯 요구사항

### Functional Requirements

1. `bash <(curl -fsSL .../get.sh)` — 현재 디렉토리에 harness-kit 설치
2. `bash <(curl -fsSL .../get.sh) /path/to/project` — 지정 디렉토리에 설치
3. `bash <(curl -fsSL .../get.sh) --version 0.6.3` — 특정 버전 설치 (git tag 기준)
4. `bash <(curl -fsSL .../get.sh) --update [dir]` — 기존 설치 업데이트 (update.sh 호출)
5. `--yes` 플래그 전달 지원 (install.sh / update.sh 프롬프트 자동 수락)
6. 다운로드 실패 시 명확한 에러 메시지 출력 후 종료
7. 임시 디렉토리 항상 정리 (trap EXIT)

### Non-Functional Requirements

1. bash 3.2+ 호환 (macOS 기본 bash)
2. 추가 의존성 없음 — curl, unzip, bash, jq, git 만 사용 (jq/git 은 install.sh 가 검증)
3. `set -euo pipefail` 필수

## 🚫 Out of Scope

- uninstall 원격 지원 (`bash path/to/uninstall.sh` 로 충분)
- Homebrew formula
- npm/npx 배포
- Windows 지원

## ✅ Definition of Done

- [ ] `get.sh` 작성 및 동작 검증
- [ ] `tests/test-get-sh.sh` 작성 및 PASS
- [ ] `README.md` 설치 섹션 업데이트
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-get-sh-installer` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
