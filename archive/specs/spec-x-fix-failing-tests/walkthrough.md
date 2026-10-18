# Walkthrough: spec-x-fix-failing-tests

> 사전 실패 테스트 4건 정리. 각 항목의 *진짜* 원인과 fix 위치를 남긴다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| #1 version-bump (Check 4) | README 에 버전 하드코딩 / 테스트 수정 | 테스트 수정 | README 는 `version.json` dynamic badge 사용 — 하드코딩은 수동 sync 부채 재도입 |
| #1 version-bump (Check 6) | 메타-러너 set-e 수선 / 제거 | 제거 | 전체 스위트 재실행은 run.sh 책임. 메타-러너는 재귀·취약·중복 — 단일 책임 위반 |
| #5 phase17 4c | CLAUDE.md 룰 복원 / 테스트 경로 수정 | 테스트 경로 수정 | 룰은 #135 슬림화로 `docs/release-strategy.md` 로 *이동*됨. 테스트만 옛 위치를 보고 있었음 |
| #3 wiki sources | stale 경로 직접 수정 / 검사 archive-aware | archive-aware | walkthrough 는 삭제가 아니라 archive 로 *이동* — fallback 이 정확하고 재발 방지 |
| #4 pr-merge-detect | sdd guard 추가 / 테스트 수정 | 테스트 수정 | guard 는 이미 존재(sdd:2514). 테스트의 no-gh 시뮬레이션이 깨져 있었음 |

## 💬 사용자 협의

- **주제**: `run.sh --fast` 사전 실패 4건을 한 번에 정리
  - **합의**: 묶음 spec-x `fix`, #3 은 archive-aware 방식. #1 은 (조사 후 정정) README 하드코딩이 아닌 테스트 수정.

## 🧪 검증 결과

### 자동화 테스트
- `tests/test-version-bump.sh` — README dynamic badge 검증 PASS
- `tests/test-update-stateful.sh` — S5 7템플릿 PASS=17/FAIL=0
- `tests/test-wiki-structure.sh` — 70/70 PASS (archived sources 인식)
- `tests/test-pr-merge-detect.sh` — 5/5 PASS
- `tests/run.sh --fast` — 전체 회귀 확인 (Ship 게이트)
- `diff -q .harness-kit/bin/sdd sources/bin/sdd` — 동일

## 🔍 발견 사항

- **#4 는 코드 버그가 아니라 테스트 버그였다.** spec 단계에선 "guard 누락"으로 추정했으나, 구현 직전 코드를 보니 `command -v gh` guard(sdd:2514)가 이미 정상 존재. 진짜 원인은 테스트의 no-gh 시뮬레이션이 `$BASH_DIR`(homebrew `/opt/homebrew/bin`, gh 와 동일 디렉토리)를 PATH 에 포함해 gh 가 계속 노출된 것. → 도구별 심볼릭(gh 만 제외)으로 hermetic 하게 교정. sdd 변경 불필요.
- **#2 `plan` 폐기 잔재의 출처 확인**: `sdd specx new` 의 scaffold 루프(sdd:2035)가 `plan` 을 포함해, 템플릿이 없으니 빈 plan.md 를 생성하고 있었다(이번 spec scaffold 도 그랬음). 루프에서 제거해 근본 차단. `sdd spec show` 표시 루프(2482 부근)는 `[ -f ]` 가드라 무해해 Out of Scope.
- **#3 archive-aware 는 systemic 처방**: 이 fallback 으로 향후 어떤 spec 이 archive 돼도 wiki/ADR `sources:` 검사가 깨지지 않는다. 더 큰 docs integrity 도구군은 Icebox #167/#168 유지.
- **version-bump 이 메타-러너였다 (Check 6)**: 표면 실패(README 리터럴)는 Check 4 였지만, 그걸 고치자 진짜 원인이 드러남 — Check 6 가 전체 스위트를 full 로 재실행하며 `set -e` 로 첫 nested 실패에서 침묵 종료. 이게 **5번째 숨은 실패(phase17 4c)** 까지 끌어와 표면화시킴. 메타-러너 제거로 test 단일 책임 회복 + 5번째 항목도 같이 close. "표면 fix 가 더 깊은 구조 문제를 드러낸" 사례.
- **#5 도 '이동' 패턴**: #3 와 동일하게, 4c 실패는 룰 *삭제*가 아니라 *이동*(CLAUDE.md → docs/release-strategy.md, #135) 인데 테스트가 옛 경로를 봤던 것. 데이터가 아니라 검사 위치를 고치는 게 정답.

## 🚧 이월 항목

- 없음. (docs integrity 도구군은 기존 Icebox #167/#168)
