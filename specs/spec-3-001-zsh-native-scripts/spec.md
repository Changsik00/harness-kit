# spec-3-001: zsh 네이티브 스크립트 모드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-3-001` |
| **Phase** | `phase-3` |
| **Branch** | `spec-3-001-zsh-native-scripts` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

harness-kit의 모든 스크립트가 `#!/usr/bin/env bash`로 작성되어 있다. macOS의 기본 bash는 3.2(GPLv2)로 기능이 제한적이며, 최신 bash(4.0+)는 Homebrew를 통해 별도 설치해야 한다. 반면 macOS에는 zsh가 기본 셸로 탑재되어 있다.

### 문제점

1. **Homebrew bash 의존**: macOS 사용자가 `brew install bash`를 반드시 수행해야 설치 가능
2. **bash 전용 구문 사용**: `${BASH_SOURCE[0]}`, `local -a`, 0-based 배열 인덱싱 등 bash 전용 기능이 산재
3. **doctor.sh에서 bash 4.0+ 경고**: macOS 기본 bash(3.2)로는 정상 동작 불가

### 해결 방안 (요약)

셸 호환 레이어(`_shell_compat` 함수)를 `_lib.sh`에 통합하여 bash/zsh 양쪽에서 동작하도록 한다. `${BASH_SOURCE[0]}` → 호환 함수, 배열 → 순차 변수 패턴으로 전환. install.sh에 `--shell=zsh` 옵션을 추가하여 shebang을 자동 교체한다.

## 📊 개념도

```
install.sh --shell=zsh
    │
    ▼
복사 시 shebang 교체: #!/usr/bin/env bash → #!/usr/bin/env zsh
    │
    ▼
_lib.sh: _script_dir() 함수가 $BASH_SOURCE / $0 자동 분기
    │
    ▼
sdd, hooks: 배열 대신 순차 변수 또는 POSIX 호환 패턴
```

## 🎯 요구사항

### Functional Requirements

1. `_lib.sh`에 `_script_dir` 함수 추가 — bash에서는 `${BASH_SOURCE[0]}`, zsh에서는 `${(%):-%x}` 사용
2. `sdd` hooks 서브커맨드의 배열 사용을 POSIX 호환 패턴으로 교체 (`local -a` 제거, 0-based 인덱싱 제거)
3. 각 hook 스크립트의 `${BASH_SOURCE[0]}` 호출을 `_script_dir` 함수로 교체
4. `install.sh`에 `--shell=zsh|bash` 옵션 추가 — 복사 시 shebang 교체
5. `doctor.sh`에 zsh 모드 감지 추가 — zsh일 때 bash 버전 체크 스킵

### Non-Functional Requirements

1. 기존 bash 모드(기본값)의 동작이 100% 유지되어야 함 (backward compatibility)
2. zsh 모드에서 모든 hook과 sdd 서브커맨드가 정상 동작

## 🚫 Out of Scope

- zsh 전용 고급 기능 활용 (glob qualifiers, associative arrays 등) — 호환성만 확보
- Linux zsh 지원 — macOS zsh만 1차 타깃
- bb-pr의 `read -r` 시맨틱 차이 — bb-pr은 별도 spec에서 다룸
- POSIX sh 다운그레이드 — 최소 bash 4.0 / zsh 5.0 기준

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-3-001-zsh-native-scripts` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
