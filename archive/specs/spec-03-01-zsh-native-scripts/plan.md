# Implementation Plan: spec-03-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-03-01-zsh-native-scripts`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 셸 호환 전략: `_lib.sh`에 호환 함수 통합 vs 별도 `shell-compat.sh` 파일 분리 — 본 Plan은 `_lib.sh` 통합 방식 채택
> - [ ] 배열 제거 전략: sdd의 bash 배열을 문자열 기반 순차 처리로 교체

> [!WARNING]
> - [ ] shebang 교체는 install.sh가 복사 시점에 수행 — 이미 설치된 프로젝트에는 `update.sh` 재실행 필요

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **호환 레이어** | `_lib.sh`에 `_script_dir` 함수 추가 | 별도 파일 불필요 — 이미 모든 hook이 `_lib.sh`를 source |
| **배열 제거** | 문자열 + `for` 루프 패턴 | `local -a`와 0-based 인덱싱 제거, bash/zsh 모두 동일 동작 |
| **shebang 교체** | install.sh `--shell` 옵션 | 복사 시점에 `sed`로 교체, 원본(`sources/`)은 bash shebang 유지 |
| **doctor.sh** | zsh 모드 감지 + bash 체크 조건부 스킵 | `$ZSH_VERSION` 존재 여부로 판별 |

## 📂 Proposed Changes

### _lib.sh (셸 호환 함수)

#### [MODIFY] `sources/hooks/_lib.sh`

`_script_dir` 함수 추가. bash에서는 `${BASH_SOURCE[0]}`, zsh에서는 `${(%):-%x}` 사용.

```bash
_script_dir() {
  local src
  if [ -n "${BASH_SOURCE[0]:-}" ]; then
    src="${BASH_SOURCE[0]}"
  elif [ -n "${ZSH_VERSION:-}" ]; then
    src="${(%):-%x}"
  else
    src="$0"
  fi
  cd "$(dirname "$src")" && pwd
}
```

### Hook 스크립트 (BASH_SOURCE 교체)

#### [MODIFY] `sources/hooks/check-branch.sh`
`${BASH_SOURCE[0]}` → `_script_dir` 함수 호출

#### [MODIFY] `sources/hooks/check-plan-accept.sh`
동일 교체

#### [MODIFY] `sources/hooks/check-test-passed.sh`
동일 교체

### sdd (배열 제거)

#### [MODIFY] `sources/bin/sdd`
- `local -a HOOK_NAMES=(...)` → 문자열 리스트 + `for` 루프
- 0-based 배열 인덱싱 → 순차 변수 패턴
- `${BASH_SOURCE[0]}` → `_script_dir` 호환 함수 (또는 인라인 분기)

### install.sh (--shell 옵션)

#### [MODIFY] `install.sh`
- `--shell=zsh|bash` CLI 옵션 파싱 추가 (기본값: `bash`)
- 파일 복사 시 shebang 교체: `sed "1s|#!/usr/bin/env bash|#!/usr/bin/env zsh|"`
- `${BASH_SOURCE[0]}` 자체도 호환 처리

### doctor.sh (zsh 감지)

#### [MODIFY] `doctor.sh`
- `$ZSH_VERSION` 존재 시 bash 버전 체크 스킵
- zsh 버전 출력 추가

### 테스트

#### [NEW] `tests/test-zsh-compat.sh`
- `_script_dir` 함수 정상 동작 검증
- sdd hooks 배열 제거 후 동작 검증
- install.sh `--shell=zsh` shebang 교체 검증

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-zsh-compat.sh
```

### 수동 검증 시나리오
1. `bash tests/test-zsh-compat.sh` 실행 → 모든 체크 PASS
2. `zsh sources/hooks/_lib.sh` 에서 `_script_dir` 함수가 올바른 경로 반환
3. `./install.sh --shell=zsh /tmp/test-zsh` → shebang이 `#!/usr/bin/env zsh`로 교체 확인

## 🔁 Rollback Plan

- `sources/` 원본은 bash shebang을 유지하므로, `--shell=zsh` 옵션 없이 재설치하면 원래 bash 모드로 복원
- 호환 함수(`_script_dir`)는 기존 bash 동작에 영향 없음 — bash에서 `${BASH_SOURCE[0]}`를 동일하게 사용

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
