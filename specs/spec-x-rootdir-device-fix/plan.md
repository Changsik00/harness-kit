# Implementation Plan: spec-x-rootdir-device-fix

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-rootdir-device-fix`
- 시작 지점: `main`
- 첫 task에서 브랜치 생성

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [x] `rootDir`를 `harness.config.json`에서 제거 — 기존 설치본에 `rootDir`가 남아 있어도 `sdd`가 무시하므로 하위 호환 유지됨

> [!WARNING]
> - [x] `tests/test-path-config.sh`의 `rootDir` 검증 로직 변경 필요 — 기존 테스트가 `rootDir` 존재를 assert하므로 동작 변경에 맞게 수정

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
현재 (문제):
  sdd_find_root() → harness.config.json 발견 → rootDir 읽기 → 절대경로로 루트 확정
                                                                ↑ 타 디바이스에서 깨짐

변경 후 (파일시스템 앵커링):
  sdd_find_root() → .harness-kit/ 를 포함하는 디렉토리 자체를 루트로 확정
                    (rootDir 필드 무시, harness.config.json 위치 = 루트)
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **`sdd_find_root()`** | `rootDir` 읽기 로직 제거, `.harness-kit/` 위치 기반 앵커링으로 교체 | 절대경로 의존 제거 |
| **`install.sh`** | `harness.config.json` 출력에서 `rootDir` 필드 제거 | 문제의 근본 차단 |
| **기존 `rootDir` 필드** | 무시(ignore) — 제거 강제 안 함 | 기존 설치본 하위 호환 |

### 📑 ADR 후보

- [x] ADR 가치 있는 결정 있음 → `sdd-root-detection-anchor` (type: decision) — 파일시스템 앵커링 전략 채택 이유

## 📂 Proposed Changes

### Task 1: `sdd_find_root()` 수정 (TDD)

#### [NEW] `tests/test-sdd-root-detection.sh`
다중 디바이스 시나리오 검증 테스트:
- 잘못된 `rootDir`가 기록된 `harness.config.json`이 있어도 올바른 루트를 반환하는지
- `rootDir` 없이도 루트 탐지가 정상 동작하는지

#### [MODIFY] `sources/bin/lib/common.sh`
`sdd_find_root()` 내 `rootDir` 분기 제거:

```bash
# 변경 전
if [ -f "$d/.harness-kit/harness.config.json" ]; then
  root=$(jq -r '.rootDir // empty' ...)
  if [ -n "$root" ] && [ -d "$root" ]; then
    echo "$root"; return 0
  fi
fi
if [ -f "$d/.harness-kit/installed.json" ] || ...; then
  echo "$d"; return 0
fi

# 변경 후
if [ -f "$d/.harness-kit/harness.config.json" ] || \
   [ -f "$d/.harness-kit/installed.json" ] || \
   [ -f "$d/.claude/state/current.json" ]; then
  echo "$d"; return 0
fi
```

#### [MODIFY] `.harness-kit/bin/lib/common.sh`
도그푸딩 반영 — 동일 변경

### Task 2: `install.sh` `rootDir` 기록 제거 + 테스트 수정

#### [MODIFY] `install.sh`
`harness.config.json` 출력 두 곳에서 `rootDir` 필드 제거:

```bash
# 변경 전 (backlogDir/specsDir 있는 경우)
printf '{"rootDir":"%s","backlogDir":"%s","specsDir":"%s","gitignore":%s}\n' \
  "$TARGET" "$BACKLOG_DIR" "$SPECS_DIR" "$_gi_bool" > "$HK_CONFIG"

# 변경 후
printf '{"backlogDir":"%s","specsDir":"%s","gitignore":%s}\n' \
  "$BACKLOG_DIR" "$SPECS_DIR" "$_gi_bool" > "$HK_CONFIG"

# 변경 전 (기본 경로인 경우)
printf '{"rootDir":"%s","gitignore":%s}\n' "$TARGET" "$_gi_bool" > "$HK_CONFIG"

# 변경 후
printf '{"gitignore":%s}\n' "$_gi_bool" > "$HK_CONFIG"
```

#### [MODIFY] `tests/test-path-config.sh`
`rootDir` 존재 및 값 검증 → `rootDir` 부재 검증으로 변경

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-root-detection.sh
bash tests/test-path-config.sh
```

### 수동 검증 시나리오

1. 잘못된 `rootDir` 주입 후 `sdd status` 실행 → 올바른 루트 출력 확인
2. `rootDir` 없는 fresh install 후 `sdd status` 실행 → 정상 동작 확인

## 🔁 Rollback Plan

- `sources/bin/lib/common.sh`의 `sdd_find_root()` 원복
- `install.sh` `printf` 구문 원복
- 단순 git revert로 완전 복구 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
