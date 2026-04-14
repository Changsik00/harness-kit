# Implementation Plan: spec-9-003

## 📋 Branch Strategy

- 신규 브랜치: `spec-9-003-conflict-detection`
- 시작 지점: `phase-9-install-conflict-defense`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **충돌 판정 기준**: `backlog/`나 `specs/`가 존재할 때 "harness-kit 소유"를 어떻게 판별할지 — `.harness-kit/installed.json` 존재로 판단(신규 설치 아님 = 기존 설치이거나 충돌 없음).
> - [ ] **`--yes` 시 자동 채택 경로**: `hk-backlog/`, `hk-specs/` 고정 vs 사용자 설정 가능 — `hk-` prefix 고정으로 단순화.

> [!WARNING]
> - [ ] **`common.sh` 경로 수정 사이드이펙트**: `SDD_AGENT`/`SDD_TEMPLATES`가 아직 `agent/`를 가리킴 → `.harness-kit/agent/`로 교체. 이미 설치된 프로젝트(v0.4.0)에서는 `update.sh` 실행 시 자동 반영됨.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **충돌 판정** | `installed.json` 부재 + 디렉토리 비어있지 않음 | 단순하고 오탐 없음 |
| **config 위치** | `.harness-kit/harness.config.json` | `.harness-kit/` 하위로 통일 |
| **sdd 경로 반영** | `common.sh`에서 config 읽기 | 모든 서브커맨드 자동 반영 |
| **common.sh 경로 정리** | `SDD_AGENT`/`SDD_TEMPLATES` → `.harness-kit/agent/` | spec-9-001 도그푸딩 후 누락된 수정 |

### config 파일 형식

```json
{ "backlogDir": "hk-backlog", "specsDir": "hk-specs" }
```

위치: `.harness-kit/harness.config.json`

## 📂 Proposed Changes

### [install.sh]

#### [MODIFY] `install.sh` — 충돌 감지 + config 생성 섹션 추가

install.sh 초반(디렉토리 생성 전)에 삽입:
```bash
# 충돌 감지 함수
_check_dir_conflict() {
  local dir="$1" name="$2"
  # installed.json 없고 디렉토리가 존재하면서 비어있지 않으면 충돌
  if [ ! -f "$TARGET/.harness-kit/installed.json" ] && \
     [ -d "$TARGET/$dir" ] && \
     [ -n "$(ls -A "$TARGET/$dir" 2>/dev/null)" ]; then
    echo "$name"
  fi
}
```

충돌 시 UX:
```
⚠ 충돌 감지:
  backlog/ — 기존 내용이 있습니다
제안: hk-backlog/ 로 변경
계속할까요? [y/N]
```

`harness.config.json` 생성:
```bash
echo '{"backlogDir":"hk-backlog","specsDir":"specs"}' > "$TARGET/.harness-kit/harness.config.json"
```

#### [MODIFY] `install.sh` — backlog/specs 생성 시 config 경로 사용

### [sources/bin/lib/common.sh]

#### [MODIFY] `common.sh` — config 읽기 + 경로 수정

1. `sdd_find_root` 루트 감지 조건에 `.harness-kit/installed.json` 추가
2. `SDD_AGENT`/`SDD_TEMPLATES` → `.harness-kit/agent/` 경로 수정
3. config 읽기: `harness.config.json` 존재 시 `SDD_BACKLOG`/`SDD_SPECS` override

```bash
# config 읽기 (jq 없으면 기본값 사용)
_CONFIG="$SDD_ROOT/.harness-kit/harness.config.json"
if [ -f "$_CONFIG" ] && command -v jq >/dev/null 2>&1; then
  _backlog=$(jq -r '.backlogDir // "backlog"' "$_CONFIG")
  _specs=$(jq -r '.specsDir // "specs"' "$_CONFIG")
  SDD_BACKLOG="$SDD_ROOT/$_backlog"
  SDD_SPECS="$SDD_ROOT/$_specs"
fi
```

### [doctor.sh]

#### [MODIFY] `doctor.sh` — config 경로 반영 + config 파일 확인

### [tests/]

#### [NEW] `tests/test-conflict-detection.sh`

TDD Red 단계:
- 충돌 없는 신규 repo → install 정상 진행
- `backlog/` 기존 내용 있는 repo → 충돌 감지, `harness.config.json` 생성, `hk-backlog/` 사용
- `--yes` 플래그 → 자동 채택
- config 읽기: sdd status 실행 시 `hk-backlog/` 경로 반영

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트
```bash
bash tests/test-conflict-detection.sh
```

### 통합 테스트
```bash
# 충돌 있는 프로젝트에 install → config 생성, hk-backlog/ 사용 확인
# config 있는 프로젝트에서 sdd status → hk-backlog/ 읽기 확인
```

### 수동 검증 시나리오
1. 기존 `backlog/` 있는 프로젝트에 `install.sh --yes` → `hk-backlog/` 생성, `harness.config.json` 확인
2. config 있는 상태에서 `bash .harness-kit/bin/sdd status` → 정상 출력
3. config 없는 프로젝트에서 `sdd status` → 기존대로 `backlog/` 사용

## 🔁 Rollback Plan

- `install.sh`는 `.harness-backup-{TS}/` 백업을 먼저 생성하므로 복원 가능
- config 파일만 삭제하면 기본 경로(`backlog/`, `specs/`)로 복귀

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
