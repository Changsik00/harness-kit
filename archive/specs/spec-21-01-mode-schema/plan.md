# Implementation Plan: spec-21-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-21-01-mode-schema`
- 시작 지점: `main` (phase-21 첫 번째 spec — base branch `phase-21-turbo-mode` 는 첫 hk-ship 시 자동 생성)
- PR 대상: `phase-21-turbo-mode` (base branch 모드)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `mode` 필드 부재 시 `"governed"` fallback — 기존 설치 거버넌스 유지 여부 확인

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **mode 저장소** | `current.json` 기존 파일에 필드 추가 | 별도 파일 도입 없이 `hook_state` 재사용 |
| **기본값** | 필드 부재 = `"governed"` | 기존 설치 영향 없음 |
| **CLI 위치** | `sdd mode` 서브커맨드 | 기존 `sdd plan`, `sdd spec` 패턴 일관 |
| **훅 호환성** | `_lib.sh` 변경 없음 | `hook_state mode` 가 이미 임의 키 읽기 지원 |

### 📑 ADR 후보

- [ ] 없음

## 📂 Proposed Changes

### [sdd CLI]

#### [MODIFY] `.harness-kit/bin/sdd`

`cmd_mode()` 함수 추가 + `main()` dispatch에 `mode)` 케이스 추가.

```bash
cmd_mode() {
  local sub="${1:-status}"; shift || true
  case "$sub" in
    turbo)
      state_set mode "turbo"
      printf '✓ 모드 전환: governed → turbo\n'
      printf '  Plan Accept 없이 코드 편집 가능\n'
      printf '  커밋 후 post-commit-verify 자동 실행\n'
      ;;
    governed)
      state_set mode "governed"
      printf '✓ 모드 전환: turbo → governed\n'
      printf '  Plan Accept 필요 — 전체 SDD ceremony\n'
      ;;
    status|"")
      local current
      current="$(state_get mode)"
      [ -z "$current" ] || [ "$current" = "null" ] && current="governed"
      printf '현재 모드: %s\n' "$current"
      ;;
    *)
      die "알 수 없는 모드: $sub (허용: turbo | governed | status)" ;;
  esac
}
```

`sdd status` 의 `📊 현재 상태` 블록에 `Active Mode` 행 추가:
```
Active Mode:  turbo    (또는 governed)
```

#### [MODIFY] `sources/bin/sdd`

`.harness-kit/bin/sdd` 와 동일한 변경 미러링.

### [테스트]

#### [NEW] `tests/test-mode-schema.sh`

`sdd mode` CLI 동작 및 state 읽기 검증:
- 기본값 `governed` 확인
- `sdd mode turbo` → state 파일 `mode=turbo` 확인
- `sdd mode status` 출력 확인
- `sdd mode governed` → 복귀 확인
- `hook_state mode` 반환값 확인

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-mode-schema.sh
```

### 수동 검증 시나리오
1. `sdd mode status` 실행 → `현재 모드: governed` 출력 확인
2. `sdd mode turbo` 실행 → 확인 메시지 출력, `current.json` `mode: "turbo"` 확인
3. `sdd mode status` 실행 → `현재 모드: turbo` 출력 확인
4. `sdd mode governed` 실행 → `current.json` `mode: "governed"` 복귀 확인
5. `sdd status` 실행 → `Active Mode: governed` 행 존재 확인

## 🔁 Rollback Plan

- `sdd mode governed` 로 즉시 복귀
- 상태 파일 수동 편집: `jq '.mode = "governed"' current.json`

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
