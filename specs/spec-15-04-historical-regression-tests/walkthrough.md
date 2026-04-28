# Walkthrough: spec-15-04 (historical-regression-tests)

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 시나리오 3 (customized fragment) 처리 | A) 본 spec 에서 작성 (XFAIL) / B) skip + spec-15-06 으로 위임 | **B** | 현재 install.sh 정책상 fragment OVERWRITE → 사용자 추가분 손실. "보존 vs 명시적 conflict" 정책 결정이 선행되어야 검증 작성 가능. spec-15-06 (user-hook-preserve) 의 산출물로 묶음 |
| 시나리오 분할 | A) 5개 별 파일 / B) 1 파일에 5 시나리오 | **B** | spec-15-02 의 fixture lib 한 사용처에서 시작. 시나리오 추가 비용 낮음. 파일 폭발 회피 |
| `set -e` 정책 | A) 켜기 / B) `set -uo pipefail` 만 | **B** | 한 시나리오 fail 이 다른 시나리오 차단 안 하도록. spec-15-02 의 단위 테스트와 동일 패턴 |
| md5 명령 | A) macOS `md5 -q` 만 / B) Linux `md5sum` fallback 추가 | **B** | best-effort Linux 호환. `_md5()` 헬퍼로 분기 |
| 멀티 install 시나리오의 .gitignore 검증 | A) 헤더 1 라인만 / B) hk 관련 4 라인 모두 | **B** | spec-14-03 의 라인별 멱등 fix 가 4 라인 모두 적용. 4 라인 각각 1 회 검증이 더 정확한 회귀 잠금 |

## 💬 사용자 협의

- **주제**: phase-15 의 핵심 가치 — stateful 회귀 테스트
  - **사용자 의견**: spec-15-03 (P0 fix) 이후 본 spec 으로 5 통합 시나리오 자동화
  - **합의**: 시나리오 3 은 spec-15-06 으로 위임. 본 spec 은 4 시나리오 (1, 2, 4, 5) 로 13 checks PASS.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (`tests/test-update-stateful.sh`)
- **결과**: ✅ Passed (13 / 13, 시나리오 3 skip)
- **시나리오별**:
  - **Scenario 1** — in-flight phase 보존 (#82, 4 PASS): 6 state 필드 / kitVersion 갱신 / phase.md 보존 / spec 디렉토리 보존
  - **Scenario 2** — pre-defined phases (#84, 2 PASS): 3개 phase.md md5 일치 / `sdd phase activate` 정상
  - **Scenario 3** — customized fragment: SKIP (spec-15-06 후보)
  - **Scenario 4** — dirty queue (Pattern B, 2 PASS): 사용자 Icebox 메모 보존 / sdd 마커 4 영역 보존
  - **Scenario 5** — multi-install (#78, #83, 5 PASS): 8 템플릿 모두 / .gitignore 의 hk 라인 4개 각각 1 회

#### 회귀 — `tests/test-version-bump.sh`
- **결과**: ✅ Passed (6 / 6 + 전체 스위트 FAIL=0)

### 2. 수동 검증

```bash
F=$(mktemp -d)
source tests/lib/fixture.sh
F=$(make_fixture)
with_in_flight_phase "$F" "phase-08" "spec-08-03-test"
bash update.sh --yes "$F"
jq -c '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}' "$F/.claude/state/current.json"
# → 6 필드 모두 input 값 보존, kitVersion 만 갱신
```

✅ spec-15-03 (uninstall-cmd-list-stale) fix 도 시나리오 5 에서 간접 검증 — multi-install 후 hk-* 12개 슬래시 커맨드 정확히 존재.

## 🔍 발견 사항

### 시나리오 5 가 spec-14-03 + spec-15-03 둘 다 잠금

multi-install 시나리오는 원래 #78 (gitignore dup) + #83 (phase-ship 누락) 만 잠그도록 설계되었지만, 멀티 install 후 `.harness-kit/installed.json.installedCommands` 도 정상 갱신됨 — spec-15-03 fix 의 간접 검증 효과. 향후 spec-15-03 회귀 시점에 본 시나리오가 같이 fail.

### `make_fixture()` 의 `git init` 이 시나리오 1 의 기대치와 잠재 충돌

spec-15-02 의 `make_fixture` 가 fixture 안에서 `git init` 함. update.sh 가 `cleanup.sh` 를 호출하면서 일부 동작이 git-aware 일 수 있음. 본 spec 의 시나리오 1 PASS 가 정상이지만, 향후 update.sh 동작 변경 시 본 가정이 깨질 수 있다는 점 인지.

### 시나리오 3 의 정책 결정이 phase-15 의 미해결 항목

phase-15.md §통합 테스트 시나리오 3 의 "보존 또는 명시적 conflict" 정책이 아직 미결정. spec-15-06 의 첫 작업이 정책 결정 → 그에 맞는 시나리오 3 작성. 본 spec 의 skip 메시지가 그 신호.

## 🚧 이월 항목

- **시나리오 3 (customized fragment)** → spec-15-06 (user-hook-preserve) 의 산출물로 합류.
- **시나리오 5 의 .gitignore 라인 4개** — 본 spec 이 검증하는 4 라인 외에 `cleanup.sh` 가 추가하는 라인이 더 있을 수 있음 (현재 확인 안 됨). 향후 `.gitignore` 에 키트가 관리하는 라인 카탈로그 명문화 후보.
- update.sh 의 동작 시간 — 5 시나리오 직렬 실행 ≈ 7 초 (실측). 향후 시나리오 추가 시 병렬화 검토.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-28 |
| **최종 commit** | `160fd42` (ship 직전 기준) |
