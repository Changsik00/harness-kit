# Implementation Plan: spec-15-06

## 📋 Branch Strategy

- 신규 브랜치: `spec-15-06-user-hook-preserve`
- 시작 지점: `phase-15-upgrade-safety` (phase base branch)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **머지 방향 결정**: 키트가 관리하는 hook event type(`PreToolUse`, `SessionStart`) 안에 사용자가 직접 항목을 추가한 경우는 본 spec에서 보존하지 않는다. 이 제한에 동의하는지 확인 필요.

> [!WARNING]
> - [ ] **기존 동작 변경 없음 확인**: 키트 hook(`PreToolUse`, `SessionStart`)은 기존과 동일하게 fragment로 갱신됨. 이 동작은 그대로임.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **hooks 머지 단위** | event type key 단위 보존 | `.command` 경로 기반 항목-레벨 머지보다 단순하고 실패 위험 낮음 |
| **테스트** | 신규 테스트 파일 + Scenario 3 활성화 | `with_user_hook` fixture가 이미 준비되어 있어 연결만 필요 |

### 핵심 jq 변경

**현재 (`install.sh:352`)**:
```jq
| .hooks = ($kit.hooks // $user.hooks)
```

**변경 후**:
```jq
| ($kit.hooks // {}) as $kh
| ($user.hooks // {}) as $uh
| .hooks = ($kh + ($uh | with_entries(select(.key as $k | ($kh | has($k)) | not))))
```

- `$kit.hooks`의 모든 key → 그대로 사용 (fragment 최신 버전)
- `$user.hooks`의 key 중 `$kit.hooks`에 없는 것 → 보존
- `$user.hooks`의 key 중 `$kit.hooks`에 있는 것 → kit 버전으로 갱신 (기존 동작)

## 📂 Proposed Changes

### [install.sh — settings.json 머지 로직]

#### [MODIFY] `install.sh`

`install.sh`의 jq `-s` 인라인 표현에서 `.hooks` 처리 부분을 변경한다.

변경 전 (line ~352):
```text
| .hooks = ($kit.hooks // $user.hooks)
```

변경 후:
```text
| ($kit.hooks // {}) as $kh
| ($user.hooks // {}) as $uh
| .hooks = ($kh + ($uh | with_entries(select(.key as $k | ($kh | has($k)) | not))))
```

### [테스트 — 신규 단위 테스트]

#### [NEW] `tests/test-install-settings-hook.sh`

install 후 hook 보존 동작을 검증하는 독립 테스트 파일.

| 시나리오 | 검증 내용 |
|---|---|
| 키트 hook 갱신 | install 후 `PreToolUse`·`SessionStart`가 fragment 버전으로 갱신됨 |
| 사용자 hook 보존 | install 후 사용자가 추가한 `UserAddedHook` event type이 보존됨 |
| 멱등성 | 재설치 후 사용자 hook 중복 없음 |
| 사용자 hook 없음 | 사용자가 hook 미추가 시 kit hook만 존재 (기존 동작 유지) |

### [sdd `spec_new()` — archive 스캔 버그 수정]

#### [MODIFY] `sources/bin/sdd` + `.harness-kit/bin/sdd`

**배경**: `phase_new()`는 commit `ab271db`에서 `archive/backlog/`도 함께 스캔하도록 수정됐으나, `spec_new()`는 `archive/specs/`를 포함하지 않았다. Phase-15 spec들이 아카이브된 후 `sdd spec new`를 호출하면 seq 번호가 01부터 재사용될 수 있다.

`sources/bin/sdd:831` 변경:
```text
# 현재
last=$(find "$SDD_SPECS" -maxdepth 1 -type d -name "spec-${phase_n}-*" ...

# 수정 후
last=$(find "$SDD_SPECS" "$SDD_ROOT/archive/specs" -maxdepth 1 -type d -name "spec-${phase_n}-*" ...
```

두 파일(`sources/bin/sdd`, `.harness-kit/bin/sdd`) 모두 동일하게 수정.

### [테스트 — Scenario 3 활성화]

#### [MODIFY] `tests/test-update-stateful.sh`

Scenario 3의 `skip "정책 결정 후 spec-15-06..."` 라인을 실제 검증 로직으로 교체.
`with_user_hook` fixture를 사용하여 update 후 사용자 hook 보존을 검증한다.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-install-settings-hook.sh
```

### 통합 테스트 (Integration Test Required = yes)
```bash
bash tests/test-update-stateful.sh
```

### 수동 검증 시나리오
1. `settings.json`에 `PostToolUse` hook 추가 → `install.sh` 재실행 → `PostToolUse` 잔존 확인
2. `install.sh` 두 번 실행 → 사용자 hook 중복 없음 확인

## 🔁 Rollback Plan

- `install.sh`의 jq 표현 한 줄 변경이므로 git revert로 즉시 복구 가능
- 기존 사용자 환경에 영향 없음 (키트 hook 동작 동일, 추가 보존만)

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
