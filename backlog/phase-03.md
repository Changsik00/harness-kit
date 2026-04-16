# phase-03: macOS 네이티브 설치 모드

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-03-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-03` |
| **상태** | Planning |
| **시작일** | — |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

harness-kit은 모든 스크립트를 `#!/usr/bin/env bash`로 작성하고 있으나, macOS의 기본 셸은 zsh이며 Apple Silicon Mac에서 Homebrew bash는 추가 설치가 필요하다. 도그푸딩 회고에서 **macOS 전용 API 사용이 0건**임을 확인 — 실질적으로 크로스 플랫폼이지만 macOS에 최적화되어 있지 않다.

zsh는 bash 대비 내장 기능이 풍부하고(associative arrays, glob qualifiers, parameter expansion 등), macOS에서 추가 설치 없이 사용 가능하다는 장점이 있다.

### 목표 (Goal)

- macOS 사용자가 **Homebrew bash 없이** harness-kit을 설치/운영할 수 있는 모드 제공
- macOS 설치 가이드 문서화
- Linux 호환성 검증으로 크로스 플랫폼 선언

### 성공 기준 (Success Criteria) — 정량 우선

1. macOS에서 `bash` 미설치 상태로 `install.sh --shell=zsh` 실행 성공
2. 모든 hook/sdd 스크립트가 zsh 모드에서 정상 동작
3. GitHub Actions ubuntu-latest에서 bash 모드 테스트 통과

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-03-001 | zsh-native-scripts | P0 | Backlog | `specs/spec-03-001-zsh-native-scripts/` |
| spec-03-002 | macos-install-guide | P1 | Backlog | `specs/spec-03-002-macos-install-guide/` |
| spec-03-003 | linux-ci-validation | P1 | Backlog | `specs/spec-03-003-linux-ci-validation/` |
<!-- sdd:specs:end -->

### spec-03-001 — zsh 네이티브 스크립트 모드

- **요점**: hook/sdd 스크립트를 zsh로도 실행 가능하게 하는 듀얼 모드 구현
- **방향성**: 두 가지 접근 중 택 1: (A) POSIX sh 호환으로 다운그레이드 — 의존성 0, 하지만 기능 제한. (B) zsh 전용 스크립트 세트를 별도 유지 — macOS 최적화, 하지만 유지보수 2배. 권장은 **(C) 셸 추상화 레이어**: `lib/shell-compat.sh`에서 `bash`/`zsh` 분기하고, 스크립트 본문은 공통 함수 호출. install.sh가 `--shell=zsh|bash` 옵션으로 shebang을 선택
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §2
- **연관 모듈**: `sources/hooks/`, `sources/bin/`, `install.sh`

### spec-03-002 — macOS 설치 가이드

- **요점**: macOS 사용자를 위한 step-by-step 설치 가이드 작성
- **방향성**: (1) Homebrew 의존성 최소화 (jq만 필요, bash는 선택). (2) Apple Silicon / Intel 분기 안내. (3) Claude Code 설치 → harness-kit 설치 → doctor 검증까지 원스톱 가이드. (4) `docs/guides/macos-setup.md`에 배치
- **참조**: 없음
- **연관 모듈**: `docs/`, `install.sh`

### spec-03-003 — Linux CI 검증

- **요점**: GitHub Actions에 ubuntu-latest matrix를 추가하여 bash 모드 크로스 플랫폼 검증
- **방향성**: `.github/workflows/ci.yml` 생성. install.sh + doctor.sh + hook 스크립트를 fixture 프로젝트에 대해 실행. macOS-latest + ubuntu-latest 매트릭스
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §2.3 방안 A
- **연관 모듈**: `.github/workflows/`, `tests/`, `install.sh`, `doctor.sh`

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: macOS zsh 모드 설치
- **Given**: macOS, bash 미설치, zsh 기본 셸
- **When**: `./install.sh --shell=zsh /tmp/test-project`
- **Then**: 모든 스크립트 shebang이 `#!/bin/zsh`, sdd status 정상 출력
- **연관 SPEC**: spec-03-001, spec-03-002

### 시나리오 2: Linux bash 모드 설치
- **Given**: Ubuntu latest, bash 5.x
- **When**: `./install.sh /tmp/test-project`
- **Then**: install 성공, doctor.sh 전 항목 PASS
- **연관 SPEC**: spec-03-003

### 통합 테스트 실행
```bash
./tests/test-phase-03.sh
```

## 🔗 의존성

- **선행 phase**: phase-02 (거버넌스 경량화 후 스크립트 변경이 줄어듦)
- **외부 시스템**: GitHub Actions
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| zsh/bash 분기로 유지보수 부담 증가 | 버그 2배 가능성 | 셸 추상화 레이어로 공통 코드 극대화 |
| POSIX sh 다운그레이드 시 기능 손실 | jq 파이프 등 고급 기능 사용 불가 | 듀얼 모드(C안) 채택으로 회피 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
