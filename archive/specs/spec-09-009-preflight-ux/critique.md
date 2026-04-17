# Spec Critique: spec-09-009

## 1. 유사 기법 조사

### 발견된 패턴/도구

- **Homebrew preflight checks**: `brew install` 실행 전 의존성 충돌, 기존 파일 존재 여부를 검사하고 경고를 출력한다. 사용자에게 `--force`로 무시할 수 있는 선택지를 제공. — 현재 spec과의 비교: 거의 동일한 패턴. Homebrew는 "경고 후 확인"이 아니라 "경고 후 자동 중단 + force 옵션"인 점이 다름.

- **Terraform plan**: 인프라 변경 전 `terraform plan`으로 현재 상태와 원하는 상태의 diff를 보여주고, `apply`에서 실행한다. — 현재 spec과의 비교: preflight가 "무엇이 바뀔 것인가"가 아니라 "무엇이 문제인가"에 초점을 맞추는 점이 다름. Terraform의 plan-then-apply 2단계 모델은 `--dry-run` + 실제 실행과 유사.

- **Docker Compose config validation**: `docker compose config`가 실행 전 YAML 문법과 서비스 구성을 검증한다. — 현재 spec과의 비교: 사전 검증이라는 점은 같으나, Docker는 구문(syntax) 검증이고 이 spec은 환경 상태(state) 검증.

- **Preflight Check 패턴 (Kubernetes)**: Kubernetes의 `kubeadm init --preflight-checks`는 노드 상태, 포트 충돌, 필수 바이너리 존재 등을 체계적으로 검사한다. 각 체크에 PASS/WARN/FAIL 레벨을 부여하고, `--ignore-preflight-errors`로 특정 체크를 무시할 수 있다. — 현재 spec과의 비교: 가장 유사한 패턴. 다만 kubeadm은 FAIL 시 차단하는 반면, 이 spec은 경고만 하고 차단하지 않음.

- **Git pre-commit hooks**: 커밋 전 코드 품질 검사를 수행하고 실패 시 차단. `--no-verify`로 우회 가능. — 현재 spec과의 비교: "사전 검증 + 우회 옵션" 구조는 동일하나, pre-commit은 차단이 기본이고 이 spec은 비차단이 기본.

### 시사점

1. **레벨 체계**: kubeadm처럼 INFO/WARN/ERROR 3단계를 명확히 구분하는 것이 업계 표준이다. 현재 spec은 ✅과 ⚠만 사용하는데, "반드시 막아야 하는 상황"(예: 완전히 깨진 state 파일)에 대한 ERROR 레벨이 없다.

2. **개별 체크 무시 기능**: kubeadm의 `--ignore-preflight-errors=<check-name>` 패턴은 유용하다. 현재 spec은 "경고가 있으면 한꺼번에 y/N"인데, 특정 경고만 무시하고 싶은 사용자 케이스를 다루지 않는다. 다만 이 프로젝트의 규모에서는 YAGNI일 수 있다.

3. **doctor.sh와의 중복**: 대부분의 도구(Homebrew, kubeadm 등)는 preflight와 post-check을 별도 도구로 분리하지 않고 하나의 검증 프레임워크에서 "언제 실행하느냐"만 다르게 한다. 현재 spec은 doctor.sh와 preflight.sh를 완전 분리하는데, 검증 로직의 중복 가능성이 있다.

## 2. 요구사항 비판

### 누락

- **ERROR 레벨 부재**: 현재 spec은 "preflight 실패가 설치를 차단하지 않음"이라 명시했지만, `installed.json`이 손상되어 파싱 불가능한 경우처럼 진행하면 확실히 실패하는 상황에서도 경고만 하고 넘어가는 것은 문제가 될 수 있다. 최소한 "hard error" 케이스(파싱 불가, 필수 의존성 없음)와 "soft warning"(기존 파일 존재, 다운그레이드)을 구분해야 한다. 다만 필수 의존성 검사는 이미 install.sh 3번 섹션에서 하고 있으므로, preflight에서는 state 파일 손상 정도만 해당된다.

- **update.sh에서 semver 비교 방법 미명시**: "PREV_VER > NEW_VER → 경고"라고 했지만, 버전 비교 알고리즘(semver 파싱 vs 단순 문자열 비교)이 명시되지 않았다. `0.9.0` vs `0.10.0` 같은 케이스에서 문자열 비교는 잘못된 결과를 줄 수 있다.

- **preflight 결과의 기계 판독 가능성**: `--dry-run`과 조합하여 CI에서 preflight만 실행하고 결과를 파싱하고 싶을 수 있다. 현재는 사람이 읽는 ANSI 출력만 정의되어 있다. 다만 현재 사용 규모에서는 YAGNI일 가능성이 높다.

### 모순

- **update.sh의 이중 확인 문제**: spec FR 2에서 "스캔 결과를 동일한 요약 블록 형식으로 출력"이라 했고, plan에서 "기존 확인 프롬프트와 합쳐서 한번만 묻기"라고 했다. 그런데 현재 update.sh는 버전 표시 후 바로 `[y/N]`을 묻고, 이후 uninstall → install 순서로 진행한다. preflight를 확인 프롬프트 "전에" 넣으면 현재 코드의 흐름(버전 표시 → 확인 → uninstall → install)을 상당히 바꿔야 한다. 반면 spec은 이를 가벼운 수정처럼 서술하고 있다.

### 과잉 설계

- **`.claude/state/current.json` 파싱 검증 (update preflight)**: update.sh는 이미 uninstall → install 순서로 동작하며, state 파일은 install 과정에서 새로 생성된다. state 파일이 깨져 있어도 update 과정에서 자연스럽게 재생성되므로, update preflight에서 state 파일 유효성을 검사하는 것은 실익이 적다. 단, update.sh 4단계에서 기존 state를 복원하는 로직이 있으므로 파싱 실패 시 복원이 안 되는 문제는 있다 — 이 경우 preflight에서 경고하는 것보다 복원 로직 자체에서 graceful fallback 하는 것이 더 적절하다.

### 모호함

- **"v0.3 구 레이아웃" 감지 조건의 범위**: `agent/constitution.md` 또는 `scripts/harness/` 존재를 v0.3 잔재로 판단하는데, 사용자 프로젝트에 우연히 `agent/` 디렉토리가 있는 경우(예: AI agent 관련 프로젝트)를 오탐할 수 있다. 감지 조건을 `agent/constitution.md` (단순 `agent/`가 아닌 특정 파일)로 한정한 것은 좋지만, `scripts/harness/`도 사용자가 독립적으로 만들었을 가능성이 있다. 오탐 시 사용자 혼란이 발생할 수 있다.

- **"hooks 충돌 가능성 안내"의 구체적 의미**: FR 1에서 `.claude/settings.json` 존재 시 "기존 hooks 충돌 가능성 안내"라고 했지만, 실제로 충돌이 발생하는 조건(사용자가 이미 hooks를 설정한 경우)과 단순히 파일이 존재하는 경우를 구분하지 않았다. settings.json이 있지만 hooks 키가 없는 경우는 충돌 가능성이 없으므로, 경고 조건을 `.hooks` 키 존재 여부로 좁혀야 한다.

## 3. 대안 제안

### 대안 A: doctor.sh 재사용 — `doctor.sh --preflight` 모드

- **아이디어**: preflight.sh를 별도로 만들지 않고, doctor.sh에 `--preflight` 플래그를 추가한다. doctor.sh의 기존 7단계 검증 중 설치 전에도 의미 있는 검사(디렉토리 존재, state 파일, 구 레이아웃)를 공유하고, install/update 컨텍스트에서만 추가 체크(다운그레이드, 이미 설치됨 등)를 수행한다.
- **장점**: 검증 로직 단일 소스(Single Source of Truth). doctor.sh와 preflight 사이의 검사 항목 불일치 방지. 유지보수 포인트가 하나.
- **단점**: doctor.sh가 복잡해진다. 사전/사후 검증의 관심사가 다르므로 하나의 스크립트에 넣으면 조건 분기가 많아진다. doctor.sh는 `set -e`를 의도적으로 비활성화하는 등 다른 실행 특성을 가지고 있어 합치기 어려울 수 있다.

### 대안 B: Inline preflight — 별도 함수/파일 없이 install.sh/update.sh 내부에 직접 작성

- **아이디어**: 공통 라이브러리 추출 없이, install.sh의 기존 "3. 사전 점검" 섹션을 확장하고, update.sh에도 유사한 섹션을 직접 작성한다.
- **장점**: 가장 단순. 새 파일 없음. 각 스크립트가 자기 맥락에 맞는 검사만 하므로 불필요한 추상화가 없다. install과 update의 preflight 체크 항목은 실제로 상당 부분 다르므로(이미 설치됨 vs 다운그레이드) 공통화 이득이 적다.
- **단점**: v0.3 잔재 감지 같은 공통 로직이 두 곳에 중복된다. 다만 중복되는 체크가 2-3개에 불과하면 추상화 비용 대비 이득이 미미하다.

### 대안 C: 현재 spec 유지 + 미비점 보완

- **아이디어**: 현재 spec의 `sources/bin/lib/preflight.sh` 접근법을 유지하되, 위 비판에서 지적한 사항을 반영한다. (1) semver 비교 방법 명시, (2) hooks 충돌 조건을 `.hooks` 키 존재로 구체화, (3) state 파일 검증은 update 복원 로직의 graceful fallback으로 대체.
- **장점**: 기존 설계 방향 유지로 재작업 최소. lib 패턴이 이미 `common.sh`, `state.sh`로 확립되어 있어 일관성 유지.
- **단점**: preflight.sh의 install/update 공통 함수가 실제로는 2-3개 체크밖에 공유하지 않아 추상화 이득이 기대보다 적을 수 있다.

## 권장안

**대안 B (Inline preflight)를 권장**한다. 이유:

1. **공통 로직이 생각보다 적다**: install preflight와 update preflight의 체크 항목을 나열하면, 실제 공통인 것은 "v0.3 잔재 감지"뿐이다. "이미 설치됨"은 install 전용, "다운그레이드"와 "state 파싱"은 update 전용이다. 2-3줄짜리 디렉토리 존재 확인을 공유하기 위해 새 파일을 만드는 것은 과잉.

2. **install.sh에 이미 "사전 점검" 섹션이 있다**: 섹션 3이 정확히 이 역할을 하고 있고, jq 확인, OS 확인, git 확인까지 이미 수행한다. 여기에 2-3개 체크를 추가하고 요약 블록을 출력하는 것이 자연스러운 확장이다.

3. **YAGNI**: `sources/bin/lib/preflight.sh`가 대상 프로젝트의 `.harness-kit/bin/lib/`에도 복사되지만, 대상 프로젝트에서 preflight를 독립 실행할 일은 없다(install/update는 항상 키트 원본에서 실행). 즉 공유 라이브러리로 추출할 소비자가 2개(install/update)뿐이고, 그 2개의 공통 부분이 미미하다.

4. **v0.3 잔재 감지 중복은 함수 하나로 해결**: 정말 필요하다면 install.sh 내부에 `_check_legacy_layout()` 헬퍼 함수를 정의하고, update.sh에서 동일 함수를 복사하면 된다. 혹은 update.sh는 uninstall → install 구조이므로 install.sh의 preflight가 자동으로 실행된다(단, `--yes` 모드에서).

만약 팀이 "라이브러리 추출이 향후 확장에 유리하다"고 판단한다면 대안 C도 합리적이지만, 현재 체크 항목의 수와 복잡도를 고려하면 inline이 더 실용적이다.
