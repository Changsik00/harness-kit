# Implementation Plan: spec-14-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-14-02-doctor-bash-version` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main` (PR #76 머지 직후)
- 첫 task 가 브랜치 생성을 수행
- 첫 commit 에 다음 변경분도 포함 (main 의 working tree / specs):
  - `backlog/queue.md` — `sdd spec new` 결과로 생긴 active 갱신
  - `backlog/phase-14.md` — sdd:specs 마커 수동 보정 (spec-14-01 Merged + spec-14-02 In Progress 행 — sdd ship 이 sync 못한 잔재 정리. 자세한 진단은 spec-14-04 marker_append guard 에서)
  - `docs/harness-kit-bug-02-doctor-bash-version-false-positive.md` — 본 spec 의 근거 자료
  - `specs/spec-14-02-doctor-bash-version/` — spec.md, plan.md, task.md

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **bash 정책 변경** (`CLAUDE.md`) 확정 — "bash 4.0+ 전용" → "bash 3.2+ (4+ 전용 기능 미사용)". 이는 도그푸딩 관점에서 정책-코드 일치를 회복하는 변화이지 코드 동작 자체 변화는 아님.
> - [ ] 향후 정말 bash 4+ 가 필요해지면 별도 spec 으로 정책 재변경 + shebang/설치 가이드 갱신 등 동반 작업 — 알겠다는 동의.

> [!WARNING]
> - [ ] phase-14.md 의 sdd:specs 마커 수동 보정은 본 spec 의 *부수적 정리* 임. 근본 원인(sdd 가 spec 행을 sync 못한 별건 이슈) 의 진단/수정은 spec-14-04 (marker_append guard) 에서 다룸.

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
[현재] doctor 첫 화면 — macOS bash 3.2 환경
  필수 도구
    ❌ bash 3.2 (>= 4.0 필요)   ← false positive
    ✅ jq 1.7.1
    ✅ git 2.50.1

[변경 후]
  필수 도구
    ✅ bash 3.2.57              ← 정상 인식 (3.2 이상)
    ✅ jq 1.7.1
    ✅ git 2.50.1
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **doctor bash 체크** | min_ver 를 `"4.0"` → `"3.2"` 로 완화 | 코드는 3.2 호환. 정책-코드 일치 |
| **doctor 힌트 문구** | "권장 — 일부 환경에서 더 일관된 동작" 톤 | 사용자에게 "지금은 OK 지만 권장은 더 높음" 신호 |
| **CLAUDE.md** | "필수 도구" 행을 "bash 3.2+" 로 + 부연 설명 1 줄 | 정책 표현이 코드 실태와 일치 |
| **회귀 테스트** | `tests/test-doctor-bash-version.sh` 신규 | 향후 무심코 4.0 복귀 시 즉시 감지 |
| **shebang** | `#!/usr/bin/env bash` 유지 | bash 4+ 강제하지 않음 |

## 📂 Proposed Changes

### sdd doctor 완화

#### [MODIFY] `sources/bin/sdd:1427`

```diff
- _check_tool "bash" "4.0" "required" "brew install bash (macOS) 또는 apt-get install bash"
+ _check_tool "bash" "3.2" "required" "macOS 기본 bash 로도 동작 — 4+ 권장 (일부 환경 일관성)"
```

> **참고**: `_check_tool` 의 버전 비교 로직 (`sdd:1382-1390`) 은 major 버전 정수 비교 (`-lt`). `"3.2"` 의 major 는 `3`, 시스템 bash 3.2 의 major 도 `3` → `3 -lt 3` false → PASS. 4+ 환경도 `4 -lt 3` false → PASS. 의도대로 동작.

### 도그푸딩 동기화

#### [MODIFY] `.harness-kit/bin/sdd:1427`

`sources/bin/sdd:1427` 와 동일 변경 (install.sh 가 sources → .harness-kit 로 복사하는 구조이므로 둘이 동일해야 함). 이는 본 프로젝트 자체에서 즉시 doctor 출력을 PASS 로 만들기 위해 필요.

### 정책 갱신

#### [MODIFY] `CLAUDE.md` (line 9)

```diff
 ## 대상 환경 (고정)

 | | |
 |---|---|
 | **OS** | macOS (1차 타깃) — Sonoma+, Apple Silicon / Intel |
 | **AI 호스트** | Claude Code 전용 |
 | **Shell** | 모든 스크립트는 `bash` shebang (이식성 우선) |
- | **필수 도구** | `bash 4.0+`, `jq`, `git` (모두 Homebrew 로 설치) |
+ | **필수 도구** | `bash 3.2+`, `jq`, `git` — bash 는 macOS 기본 (3.2.57) 으로도 동작. jq/git 은 Homebrew 권장. |
```

다음 문단 (작업 원칙) 의 line 36 도 갱신:
```diff
- 3. **bash 4.0+ 전용**: 모든 스크립트는 `#!/usr/bin/env bash` 로 작성 (단, `set -euo pipefail` 필수)
+ 3. **bash 3.2+ 호환**: 모든 스크립트는 `#!/usr/bin/env bash` (이식성 우선) + `set -euo pipefail` 필수. bash 4+ 전용 기능 (`declare -A`, `mapfile`, globstar, `${var,,}` 등) 사용 금지.
```

### 회귀 테스트

#### [NEW] `tests/test-doctor-bash-version.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
# spec-14-02: doctor bash 버전 false positive 회귀 테스트
#
# 검증 1: sources/bin/sdd 의 bash 체크 라인이 "4.0" 을 요구하지 않음 (lint-style grep)
# 검증 2: 현재 환경에서 sdd doctor 실행 시 출력에 "❌ bash" 패턴이 없음
# 검증 3: doctor 출력에 "bash" 라인이 ✅ 또는 ⚠️ 로 표시됨

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 검증 1: source 코드에 bash "4.0" required 가 부재
if grep -E '_check_tool "bash" "4\.0" "required"' "$ROOT/sources/bin/sdd"; then
  echo "❌ sdd 에 bash 4.0 required 체크 잔존"
  exit 1
fi

# 검증 2,3: 실행 결과
output=$(bash "$ROOT/sources/bin/sdd" doctor 2>&1 || true)
if echo "$output" | grep -E "^\s*❌\s*bash"; then
  echo "❌ doctor 출력에 bash FAIL 잔존"
  exit 1
fi
echo "✅ spec-14-02 회귀 테스트 PASS"
```

> 자세한 검증 로직은 task.md 에서 확정 (test-hk-doctor.sh 의 픽스처 패턴 참고).

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-doctor-bash-version.sh
```

기존 테스트 회귀 점검:
```bash
bash tests/test-hk-doctor.sh
bash tests/test-sdd-queued-marker-removed.sh
```

### 통합 테스트

본 spec 의 `Integration Test Required = no` — 별도 통합 테스트 없음.

### 수동 검증 시나리오

1. **doctor 출력 확인**: `bash .harness-kit/bin/sdd doctor` → 출력에 `❌ bash` 없음, `✅ bash 3.2.57` 표시.
2. **CLAUDE.md 정책 grep**: `grep -E "bash 4\.0\+? 전용|bash 4\.0\+ \(맥OS|기본 bash 4\.0" CLAUDE.md` → 0 매치.
3. **homebrew bash 환경 회귀**: bash 4+ 가 PATH 상 first 인 환경에서 doctor 가 여전히 PASS (수동 환경에서만 검증 — 본 프로젝트 CI 없음).

## 🔁 Rollback Plan

- 본 spec 은 `_check_tool` 한 줄 + `CLAUDE.md` 표현 + 신규 테스트만. `git revert <merge-commit>` 즉시 복원 가능.
- 정책 변화는 표현 차원이고 실제 코드 동작 변화는 0 — 사용자 환경에 영향 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
