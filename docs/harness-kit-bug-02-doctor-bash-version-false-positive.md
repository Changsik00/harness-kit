# [Bug] `sdd doctor` 가 bash 4.0+ 를 required 로 체크하지만 실제로는 bash 3.2 로 정상 동작 — false positive FAIL

## 요약

`sdd doctor` 는 bash 를 **required** 로 분류하고 **최소 버전 4.0** 을 요구한다. 그러나 sdd 코드 전체를 검사한 결과 bash 4+ 전용 기능이 **전혀 사용되지 않으며**, 실제 macOS 기본 bash 3.2 환경에서 `sdd phase done`, `sdd status`, `sdd spec new` 등 주요 명령이 모두 정상 동작한다.

결과적으로 macOS 사용자는 설치 직후 `doctor` 에서 첫 번째 체크가 FAIL 로 표시되어 **허위 경보 (false positive)** 를 받게 된다.

## 환경

- harness-kit: **0.6.0**
- macOS: Darwin 25.4.0
- bash: `/bin/bash` = 3.2.57 (macOS 기본, Apple 이 GPLv3 라이선스 이슈로 업그레이드 중단)

## 재현 절차

1. 기본 macOS 에서 `bash .harness-kit/bin/sdd doctor` 실행.
2. 출력:
   ```
   필수 도구
     ❌ bash 3.2 (>= 4.0 필요)
        → brew install bash (macOS) 또는 apt-get install bash
   ...
   결과: ❌ FAIL 1건 / WARN 1건
   ```
3. 그럼에도 `sdd phase done phase-4`, `sdd status`, `sdd phase show` 등은 **정상 동작** 한다.

## 근본 원인 (코드 근거)

### 1. doctor 의 bash 요구사항 선언 (`.harness-kit/bin/sdd:1427`)

```bash
_check_tool "bash" "4.0" "required" "brew install bash (macOS) 또는 apt-get install bash"
```

`required` 플래그 + `4.0` min_ver 는 `_check_tool` 내부에서 major 버전 비교 후 미달 시 `_doc_fail` 로 귀결된다 (sdd:1382-1390).

### 2. bash 4+ 전용 기능이 실제로 사용되지 않음

`sdd`, `sdd/lib/common.sh`, `sdd/lib/state.sh`, `bb-pr` 네 파일 전체에 대해 grep:

```bash
$ grep -En "declare -A|mapfile|readarray" .harness-kit/bin/sdd .harness-kit/bin/lib/common.sh .harness-kit/bin/lib/state.sh .harness-kit/bin/bb-pr
(0 matches)
```

확인된 bash 4+ 전용 기능:
- `declare -A` (associative arrays) → 0건
- `mapfile` / `readarray` → 0건
- `**` globstar → 미사용 (find 로 대체)
- `${var,,}` / `${var^^}` lowercase/uppercase expansion → 미사용 (tr 로 대체)
- coproc → 0건

사용 중인 셸 기능은 모두 bash 3.2 호환 범위 (local, set -uo pipefail, arithmetic, `[ ]` / `[[ ]]` 혼용, sed/awk/grep 보조).

### 3. 실제 동작 증거

본 repository (Design) 에서 bash 3.2.57 로 `sdd phase done phase-4` 를 실행했고, `active` + `done` marker 가 정상 갱신되었다 (문제는 별건 — Bug #01 `queued` marker 미구현).

## 실제 피해

- macOS 사용자 설치 직후 첫 경험이 "환경이 잘못되었습니다" 로 시작되어 onboarding UX 에 불필요한 마찰.
- 실제로는 homebrew bash 설치 없이도 동작하므로, 사용자가 쓰지 않아도 되는 추가 설치를 유도.
- 프로젝트 전체 FAIL 카운트를 허위로 올려, 진짜 구성 문제를 가릴 수 있음.

## 제안 수정

### Option A — bash 요구사항을 `optional` + 3.2 허용 으로 완화 (권장)

```bash
_check_tool "bash" "3.2" "required" "brew install bash (권장, 일부 고급 기능 대비)"
```
혹은 단순히 버전 체크를 제거:
```bash
_check_tool "bash" "" "required" ""
```

### Option B — 향후 bash 4+ 기능 도입 예정이라면 예정을 문서화

정책으로 bash 4+ 를 필요로 할 계획이라면 현재 시점에선 `warn` 으로 분류:
```bash
_check_tool "bash" "4.0" "optional" "향후 버전에서 bash 4+ 기능 도입 예정 — 미리 설치 권장"
```
→ 체크 결과가 FAIL → WARN 으로 완화.

### Option C — `_check_tool` 로직 보강

현재 `_check_tool` 은 `required` 이고 min_ver 미달일 때 `_doc_fail` 을 반환. 만약 Option A 의 "3.2 허용" 시 체크 로직이 버전 범위 (min-inclusive) 를 올바로 다루는지 확인 필요. `sdd:1386` 의 major 비교 `-lt` 는 정수 비교이므로 3 >= 3 → 통과, 문제 없음.

## 관찰 메모

- macOS 가 기본 bash 를 3.2 로 고정한 것은 잘 알려진 사실 (GPLv3 회피). `#!/usr/bin/env bash` 가 PATH 상 첫 bash 를 쓰므로, homebrew bash 가 있어도 설치 위치/PATH 설정에 따라 3.2 가 먼저 잡힐 수 있다.
- doctor 결과와 sdd 실제 실행 가능 여부 사이의 괴리가 FAIL/WARN 분류를 의심하게 만든다. 이는 향후 다른 체크 항목에도 같은 패턴이 있을 수 있음을 시사.
- 정말로 bash 4+ 가 필요한 경우가 도입되면 그때 shebang 을 `#!/usr/bin/env bash` 에서 `#!/opt/homebrew/bin/bash` 등으로 바꿔야 하고, macOS 설치 스크립트에서 homebrew bash 를 prerequisite 로 명시해야 한다.
