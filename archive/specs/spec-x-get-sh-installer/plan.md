# Implementation Plan: spec-x-get-sh-installer

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-get-sh-installer`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 버전 미지정 시 `main` 브랜치 zip 을 내려받음 (최신 = 불안정 가능). 수용 가능한가?
> - [ ] `--version` 은 git tag 기준 (`v0.6.3` 형식). 태그 미존재 시 404 로 실패함.

## 🎯 핵심 전략

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **소스 다운로드** | GitHub zip (main 또는 tag) | git clone 불필요, curl+unzip 만으로 충분 |
| **버전 기본값** | main 브랜치 최신 | 릴리즈 생성 없이 동작. tag 지정 시 안정 버전 사용 |
| **update 구현** | update.sh 재활용 | 로직 중복 없음. get.sh 는 진입점만 담당 |

### get.sh 흐름

```
인자 파싱 (--version / --update / --yes / target_dir)
    ↓
TMP_DIR 생성 + trap EXIT (cleanup)
    ↓
GitHub zip URL 결정
  버전 지정: .../archive/refs/tags/v{VERSION}.zip
  미지정:    .../archive/refs/heads/main.zip
    ↓
curl 다운로드 → unzip → KIT_DIR 탐색
    ↓
--update 이면 bash $KIT_DIR/update.sh $TARGET [--yes]
그 외 이면    bash $KIT_DIR/install.sh $TARGET [--yes]
```

## 📂 Proposed Changes

### [NEW] `get.sh`

원격 인스톨러 진입점. 사용법:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Changsik00/harness-kit/main/get.sh)
bash <(curl -fsSL ...) /path/to/project
bash <(curl -fsSL ...) --version 0.6.3
bash <(curl -fsSL ...) --update
bash <(curl -fsSL ...) --yes
```

### [MODIFY] `README.md`

설치 섹션을 `get.sh` 기반 curl 한 줄 명령으로 교체. 기존 clone 방식은 "개발자용" 섹션으로 이동.

### [NEW] `tests/test-get-sh.sh`

- get.sh 존재 + 실행 권한 확인
- `--help` 출력 확인
- `--version` 플래그 파싱 확인 (실제 다운로드 없이 dry-run 방식)
- 인자 없이 실행 시 TARGET_DIR = `$(pwd)` 기본값 확인

## 🧪 검증 계획

### 단위 테스트
```bash
bash tests/test-get-sh.sh
```

### 수동 검증 시나리오
1. `bash <(curl -fsSL .../get.sh) /tmp/test-project` 실행 → harness-kit 설치 확인
2. `bash <(curl -fsSL .../get.sh) --update /tmp/test-project` 실행 → update 동작 확인
3. `bash <(curl -fsSL .../get.sh) --version 0.6.3 /tmp/test-project` 실행 → 태그 버전 설치 확인

## 🔁 Rollback Plan

- `get.sh` 추가이므로 기존 기능에 영향 없음
- 문제 시 `git revert` 로 제거

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
