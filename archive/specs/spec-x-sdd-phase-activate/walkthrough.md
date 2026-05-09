# Walkthrough: spec-x-sdd-phase-activate

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 사전 정의 phase 활성화 경로 | A) `phase new` 자동 흡수 / B) 별도 `phase activate` 명령 신설 | **B** | A는 `phase new` 시멘틱이 두 갈래(생성/활성화)로 모호해짐. B는 의도가 명시적 + `phase new` 가드 메시지에서 한 줄 안내 가능 |
| `--base` 시 baseBranch 결정 | A) 사용자가 phase.md 메타 미리 채움 / B) slug 인자로 받아 `phase-NN-<slug>` 자동 조립 | **A (단일 경로)** | 사전 정의 phase 는 사용자가 메타까지 직접 관리하는 워크플로우. slug 자동 조립은 첫 줄 한국어 제목과 충돌 위험. 메타 비어있으면 die 로 명확한 안내 |
| `phase new` 가드 우회 | A) 항상 die / B) `--force` 플래그로 우회 | **B** | 사전 정의 phase 가 있어도 의도적으로 새 phase 를 추가하고 싶은 경우(예: 긴급 phase) 가능해야 함. 명시적 의도(`--force`)는 사일런트 잘못된 생성과 다름 |
| queue.md "대기 Phase" 섹션에서 phase 행 자동 제거 | A) 자동 제거 / B) 사용자 수동 정리 | **B (계획 단순화)** | "대기 Phase" 섹션은 자유 메모 영역(자동 마커 없음)이라 sdd 가 손대지 않는 정책. activate 시에도 동일하게 사용자 영역 유지 |

## 💬 사용자 협의

- **주제**: `sdd phase new` 가 사전 정의 phase 를 무시하고 max+1 로 새 phase 생성하는 버그
  - **사용자 의견**: "매번 새로 생성한다고 하는데 .. 이전 작업을 보고 판단해야 하지 않을까 함"
  - **합의**: SDD-x 로 진행. `phase activate` 명령 신설 + `phase new` 가드 강화 + 0.6.2 bump

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-phase-activate.sh`
- **결과**: ✅ Passed (13 / 13)
- **로그 요약**:
```text
Check 1: sdd phase activate phase-03 → state/queue 갱신, 본문 미변경  ✅✅✅
Check 2: sdd phase activate phase-99 (파일 없음) → die  ✅
Check 3: 다른 active phase 존재 시 활성화 거부  ✅
Check 4: 동일 id 재활성화 (idempotent)  ✅
Check 5: --base + meta 채워진 케이스 → 메타값 사용  ✅
Check 6: --base + meta 비어있음 → die  ✅
Check 7: 사전 정의 phase 존재 시 sdd phase new → die + activate 안내  ✅✅✅
Check 8: sdd phase new --force → 가드 우회  ✅
Check 9: 사전 정의 phase 없음 → phase new 정상 (회귀)  ✅
결과: PASS=13  FAIL=0
```

#### 회귀 테스트
- **명령**: `bash tests/test-version-bump.sh` (전체 스위트 자동 호출 포함)
- **결과**: ✅ Passed (6 / 6 + 전체 스위트 FAIL=0)

### 2. 수동 검증

1. **Action**: `bash .harness-kit/bin/sdd help` — 도움말에 `phase activate` / `phase new --force` 항목 노출 확인
   - **Result**: ✅ 두 항목 모두 표시

2. **Action**: `bash .harness-kit/bin/sdd version`
   - **Result**: ✅ `harness-kit 0.6.2`

## 🔍 발견 사항

- **TDD Red 단계에서 bash 3.2 corner case 발견**: `local id="$2" base_branch="${4:-...${id}...}"` 형태로 한 줄에 묶으면 `set -u` + 미정의 `$4` 조합에서 `id: unbound variable` 오류. `local`이 동일 라인 좌→우 순으로 변수를 등록하더라도 default expression 의 `${id}` 참조 시점은 미세하게 어긋남. 분리 선언 후 `[ -z "$base_branch" ] && ...` 패턴으로 회피.
- **기존 `phase_new` 의 sed placeholder mismatch**: 템플릿 17번째 줄은 `없음 / \`phase-{N}\` (opt-in)` 인데, `phase_new --base` 분기는 `없음 / phase-{N}-{slug} (opt-in)` 패턴으로 치환 시도 → 매치 안 됨 (사일런트 무동작). 본 spec 범위는 아니므로 그대로 두되, 추후 spec-x 후보로 메모.
- **queue.md "대기 Phase" 섹션은 자유 메모**: 자동 마커가 없는 사용자 영역이라 `phase activate` 가 임의로 정리하지 않는 것이 거버넌스 일관성에 맞음.

## 🚧 이월 항목

- **`phase_new --base` 의 phase.md 메타 sed mismatch**: placeholder 가 실제 템플릿 내용과 어긋나 base branch 가 phase.md 메타에 반영되지 않는 잠재 버그. 별도 spec-x 후보 (Icebox 등록 권장).

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-28 |
| **최종 commit** | `29ad739` (ship commit 직전 기준) |
