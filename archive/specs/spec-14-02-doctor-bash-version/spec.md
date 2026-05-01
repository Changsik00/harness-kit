# spec-14-02: doctor bash 버전 요구사항 완화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-14-02` |
| **Phase** | `phase-14` |
| **Branch** | `spec-14-02-doctor-bash-version` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-25 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sources/bin/sdd:1427` 의 doctor 체크:

```bash
_check_tool "bash" "4.0" "required" "brew install bash (macOS) 또는 apt-get install bash"
```

→ macOS 기본 bash 3.2 환경에서 onboarding 첫 화면이 ❌ FAIL:

```
필수 도구
  ❌ bash 3.2 (>= 4.0 필요)
     → brew install bash (macOS) 또는 apt-get install bash
```

`CLAUDE.md` 의 정책 표현 (line 9):

> | **필수 도구** | `bash 4.0+`, `jq`, `git` (모두 Homebrew 로 설치) |

### 문제점

`docs/harness-kit-bug-02-doctor-bash-version-false-positive.md` 의 분석:

1. **코드 실태**: sdd, common.sh, state.sh, bb-pr 4 개 파일 전체에 bash 4+ 전용 기능 0건:
   ```bash
   $ grep -En "declare -A|mapfile|readarray" .harness-kit/bin/sdd .harness-kit/bin/lib/common.sh .harness-kit/bin/lib/state.sh .harness-kit/bin/bb-pr
   (0 matches)
   ```
   - `declare -A` (associative arrays): 0건
   - `mapfile` / `readarray`: 0건
   - `**` globstar / `${var,,}` lowercase 확장 / `coproc`: 모두 미사용
2. **실 동작**: macOS bash 3.2.57 환경에서 `sdd phase done`, `sdd status`, `sdd phase show`, `sdd ship`, `sdd spec new` 등 주요 명령이 모두 정상 동작.
3. **결과**: doctor 가 false positive FAIL 을 출력 → 사용자 onboarding UX 첫 화면이 잘못된 경보로 시작. 실제로는 homebrew bash 설치 없이도 동작.
4. **부수 효과**: 프로젝트 전체 FAIL 카운트가 허위로 올라가 진짜 구성 문제를 가릴 수 있음.

### 해결 방안 (요약)

**Option A (권장 — bug-02 보고서 동의)**: doctor 의 bash 최소 버전을 `3.2` 로 완화 + `CLAUDE.md` 의 정책 표현을 실제 코드 호환 범위에 맞춰 정확하게 갱신.

#### 옵션 비교

| 기준 | A. min "3.2" | B. min "" (버전 무관) | C. optional + min "4.0" (WARN) |
|---|---|---|---|
| FAIL 제거 | ✅ | ✅ | ✅ (WARN 으로) |
| 버전 표시 | ✅ ver 출력 유지 | ⚠ 설치 여부만 | ✅ |
| 향후 4+ 강제 시 단순성 | ✅ "3.2"→"4.0" 한 줄 | ⚠ 다시 필드 채워야 | ✅ optional → required |
| 정책-코드 일치 | ✅ 명시적 (3.2+) | ⚠ 명시 없음 | ⚠ "권장만 4+" 의 모호함 |

**A 채택 사유**:
- 현재 코드는 정확히 "3.2 이상" 호환. 정책에 그대로 반영하는 게 가장 명확.
- 향후 정말 4+ 전용 기능 도입 시 `"3.2"` → `"4.0"` 한 줄 수정 + shebang 정책 변경. 큰 부담 아님.
- C 의 WARN 다운그레이드는 "여전히 4+ 가 권장이지만 안 깔아도 됨" 이라는 모호한 메시지를 남김 — 코드는 분명 3.2 호환이므로 모호함이 불필요.

### 정책 충돌 처리

`CLAUDE.md` 는 "bash 4.0+ 전용" 으로 명시됨. 이는 현재 코드 실태와 모순. 본 spec 에서 정책을 *재평가* 하여 **"bash 3.2+ 동작 (4+ 전용 기능 미사용)"** 으로 갱신.

장기적으로 4+ 가 정말 필요해지면 별도 spec 으로 정책 재변경 + shebang `#!/opt/homebrew/bin/bash` 명시 + 설치 가이드 갱신 등 동반 작업 수행.

## 🎯 요구사항

### Functional Requirements

1. `sources/bin/sdd:1427` 의 `_check_tool "bash" "4.0" "required" ...` 를 `"3.2"` 로 변경. 힌트 문구도 "권장 — 일부 환경에서 더 일관된 동작" 톤으로 완화.
2. `CLAUDE.md` 의 "필수 도구" 표 행에서 "bash 4.0+" → "bash 3.2+" 로 수정. 추가 설명 (현재 코드 4+ 전용 기능 미사용) 한 줄 명시.
3. `.harness-kit/bin/sdd` 도그푸딩 동기화 (sources 와 동일).
4. 회귀 테스트 추가 — `tests/test-doctor-bash-version.sh`:
   - macOS 기본 bash (3.x) 로 doctor 실행 시 출력의 bash 라인이 ❌ 가 아님 (✅ 또는 WARN).
   - sdd 의 bash 체크 코드에 `"4.0"` 이 다시 들어가지 않았는지 (lint-style grep).

### Non-Functional Requirements

1. **하위 호환**: 사용자가 이미 homebrew bash (4+) 를 설치한 환경에서도 PASS — 버전 체크는 `>=` 비교라 영향 없음.
2. **회귀 방지**: 향후 누군가 무심코 `"4.0"` 으로 되돌리면 회귀 테스트가 즉시 잡아냄.
3. **bug-02 보고서의 다른 권장사항 (`#!/opt/homebrew/bin/bash` shebang 변경 등)** 은 본 spec 범위 아님 — 정말 4+ 가 필요해질 때만 수행.

## 🚫 Out of Scope

- shebang 변경 (`#!/usr/bin/env bash` 유지).
- bash 4+ 전용 기능 도입 (associative arrays, mapfile 등).
- doctor 출력 양식 자체 변경 (FAIL/WARN/PASS 분류 로직, bullet 스타일 등).
- 다른 도구 (jq, git) 의 버전 요구사항 재평가 — 본 spec 은 bash 만.
- update.sh 가 기존 사용자 환경의 sdd 를 자동 업데이트하는지 여부 (이미 update.sh 의 별도 역할).

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = no 이므로 해당 사항 없음)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-14-02-doctor-bash-version` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
