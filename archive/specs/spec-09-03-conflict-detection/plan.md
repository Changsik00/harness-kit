# Implementation Plan: spec-09-03

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-03-conflict-detection`
- 시작 지점: `phase-09-install-conflict-defense`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **UX 흐름 확정**: install 시 prefix 입력 프롬프트를 표시할 위치 — 설치 계획 출력 직후, 실제 파일 복사 전.
> - [ ] **기본값 미생성 정책**: prefix 미입력(기본값) 시 `harness.config.json`을 생성하지 않는다 → config 없으면 기본값이므로 파일 불필요.

> [!WARNING]
> - [ ] **`common.sh` `SDD_AGENT`/`SDD_TEMPLATES` 경로 수정**: `.harness-kit/agent/`로 변경 시 이미 설치된 v0.4.0 프로젝트는 `update.sh` 실행으로 자동 반영.

## 🎯 핵심 전략 (Core Strategy)

### UX 흐름

```
[install.sh 설치 계획 출력 후]

  backlog/, specs/ 기본 경로를 사용합니다.
  변경하려면 prefix 를 입력하세요 (예: hk- → hk-backlog/, hk-specs/)
  [Enter 로 기본값 유지]:

  → Enter: 그냥 진행, harness.config.json 미생성
  → "hk-": hk-backlog/, hk-specs/ 생성, harness.config.json 생성
  → --yes 플래그: 질문 없이 기본값
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **config 위치** | `.harness-kit/harness.config.json` | `.harness-kit/` 하위 통일 |
| **기본값 시 미생성** | config 파일 없음 = 기본값 | 불필요한 파일 최소화 |
| **jq 폴백** | jq 없으면 grep으로 파싱 | jq 없는 환경 호환 |
| **common.sh 경로** | `SDD_AGENT` → `.harness-kit/agent/` | spec-09-01 누락 수정 |

## 📂 Proposed Changes

### [install.sh]

#### [MODIFY] `install.sh` — prefix UX + config 생성

설치 계획 출력(Section 4) 직후, 실제 파일 복사 전에 삽입:

```bash
# prefix UX (--yes 시 스킵)
PREFIX=""
if [ $ASSUME_YES -eq 0 ]; then
  printf "  backlog/, specs/ 기본 경로 사용합니다.\n"
  printf "  변경하려면 prefix 입력 (예: hk-) [Enter = 기본값]: "
  read -r PREFIX < /dev/tty 2>/dev/null || PREFIX=""
fi

if [ -n "$PREFIX" ]; then
  BACKLOG_DIR="${PREFIX}backlog"
  SPECS_DIR="${PREFIX}specs"
  # harness.config.json 생성
  printf '{"backlogDir":"%s","specsDir":"%s"}\n' "$BACKLOG_DIR" "$SPECS_DIR" \
    > "$TARGET/.harness-kit/harness.config.json"
else
  BACKLOG_DIR="backlog"
  SPECS_DIR="specs"
fi
```

backlog/specs 디렉토리 생성 및 초기 파일 생성 시 `$BACKLOG_DIR`/`$SPECS_DIR` 변수 사용.

### [sources/bin/lib/common.sh]

#### [MODIFY] `common.sh`

1. `sdd_find_root`: `.harness-kit/installed.json` 감지 조건 추가 (루트 찾기 개선)
2. `SDD_AGENT` → `$SDD_ROOT/.harness-kit/agent`
3. `SDD_TEMPLATES` → `$SDD_ROOT/.harness-kit/agent/templates`
4. `harness.config.json` 읽기:

```bash
_CONFIG="$SDD_ROOT/.harness-kit/harness.config.json"
if [ -f "$_CONFIG" ]; then
  if command -v jq >/dev/null 2>&1; then
    _bd=$(jq -r '.backlogDir // "backlog"' "$_CONFIG")
    _sd=$(jq -r '.specsDir // "specs"' "$_CONFIG")
  else
    _bd=$(grep -o '"backlogDir":"[^"]*"' "$_CONFIG" | cut -d'"' -f4)
    _sd=$(grep -o '"specsDir":"[^"]*"' "$_CONFIG" | cut -d'"' -f4)
    _bd="${_bd:-backlog}"; _sd="${_sd:-specs}"
  fi
  SDD_BACKLOG="$SDD_ROOT/$_bd"
  SDD_SPECS="$SDD_ROOT/$_sd"
fi
```

### [doctor.sh]

#### [MODIFY] `doctor.sh` Section 5 — config 확인 추가

```bash
if [ -f "$TARGET/.harness-kit/harness.config.json" ]; then
  check_pass ".harness-kit/harness.config.json 존재"
  # 설정 경로 출력
fi
```

Section 2 디렉토리 체크: config 경로로 backlog/specs 체크.

### [tests/]

#### [NEW] `tests/test-path-config.sh`

- 기본값(Enter) → config 미생성, `backlog/` 생성 확인
- prefix `hk-` 입력 → `harness.config.json` 생성, `hk-backlog/` 생성 확인
- config 있는 상태에서 `sdd status` → 오류 없이 실행

## 🧪 검증 계획

### 단위 테스트
```bash
bash tests/test-path-config.sh
```

### 수동 검증
1. `install.sh` 실행 → prefix 프롬프트 확인
2. `hk-` 입력 → `hk-backlog/`, `.harness-kit/harness.config.json` 생성 확인
3. `bash .harness-kit/bin/sdd status` → 정상 출력 확인

## 🔁 Rollback Plan

- config 파일 삭제 → 기본값(`backlog/`, `specs/`)으로 복귀

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
