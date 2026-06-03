# Walkthrough: spec-x-harness-footguns

> 현장 제보 3건(update 미커밋 drift / 시크릿 가드 오탐 / phase activate --base 마찰)을 하나의 spec-x 로 묶어 수정.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 시크릿 오탐 완화 방식 | 단일 regex 부정형 / 다단계 grep -v 파이프 | 다단계 grep -v | bash 3.2·BSD grep 에서 안전하고 가독성 높음. 값 바로 뒤([=:] 직후)만 앵커링해 "실제 시크릿 + 부수적 변수" 라인은 계속 탐지 |
| update 산물 처리 | 자동 커밋 / 안내만 | 안내만 | dirty repo 자동 커밋은 위험. 종료 메시지 + hk-update.md 안내로 유도 |
| base 마찰 해소 방식 | 신규 `phase base` 서브커맨드 / 기존 `activate --base` 수정 | 기존 수정 | spec-x 범위 유지(feature 추가 회피). `--base=<branch>` 인자 + 메타 자동기입 + 같은 phase 재활성화 시 spec 보존 |
| phase activate slug 출처 | 제목에서 kebab 파생 / `--base=<branch>` 명시 | 명시 인자 우선 | activate 의 slug 는 한글 제목이라 kebab 파생 불안정. 명시 인자 > phase.md 메타 fallback |

### ADR 승격 가이드
- [ ] ADR 승격 대상 있음
- [x] 없음 (3건 모두 국소 fix, cross-spec 의존·장기 결정 아님)

## 💬 사용자 협의

- **주제**: 현장 제보 3건 처리 방식
  - **사용자 의견**: "하나로 묶어 spec-x" 선택 (AskUserQuestion)
  - **합의**: bundle-before-spec-x 패턴 적용 — 같은 테마(하네스 footgun) 3건을 단일 PR 로

## 🧪 검증 결과

### 1. 자동화 테스트 (단위)

shell 단위 테스트, 각 독립 실행 (`bash tests/test-*.sh`, rc=0 = PASS). 중앙 러너 없음.

| 테스트 | 결과 |
|---|---|
| `test-check-secrets-dual-mode.sh` | ✅ 14/14 (신규 Test 12·13·14) |
| `test-sdd-phase-activate.sh` | ✅ 17/17 (신규 Check 10·11) |
| `test-sdd-spec-new-drift-warn.sh` (신규) | ✅ 4/4 |
| `test-sdd-base-branch.sh` | ✅ 4/4 (회귀) |
| `test-update.sh` | ✅ 11/11 (회귀) |
| `test-sdd-spec-new-seq.sh` | ✅ 5/5 (회귀) |
| `test-sdd-drift.sh` | ✅ (회귀) |

```text
check-secrets: PASS 14 FAIL 0
phase-activate: PASS=17 FAIL=0
drift-warn: PASS 4 FAIL 0
update: ALL PASS (11/11)
```

### 2. 수동 검증

1. **Action**: dirty `.harness-kit/hooks/` 상태에서 `sdd specx new foo`
   - **Result**: `⚠ 미커밋 install 변경 N건 감지` 경고 출력 + rc=0 + 정상 생성
2. **Action**: Task 1-2 의 시크릿 수정 커밋을 warn 우회 없이 시도
   - **Result**: 통과 — 수정된 가드가 실제 저장소에서도 오탐하지 않음을 도그푸딩으로 검증

## 🔍 발견 사항

- **live dogfood**: 작업 초반 spec/plan 커밋이 *우리가 고치려는 그 시크릿 가드*에 막혔다. spec/plan 문서가 예시로 담은 `password=...`, `${POSTGRES_PASSWORD:-default}`, `password: changeme` 가 그대로 오탐 대상이었다. 즉 footgun #2 가 자기 자신을 막은 셈 — 수정 후 같은 문서를 warn 우회 없이 커밋 가능해진 것이 가장 직접적인 회귀 증거다.
- **테스트 self-trigger 컨벤션**: 기존 테스트는 시크릿 리터럴을 변수로 쪼개(`_AKIA_PFX="AKIA"; echo "${_AKIA_PFX}..."`) 테스트 스크립트 자체가 가드에 걸리지 않게 한다. Test 14 의 진짜 시크릿 fixture 도 같은 방식(`_PW_KEY` 분리)으로 작성해야 했다.
- **제보 #3 의 실제 동작은 제보보다 미묘**: `phase activate --base` 는 active spec 을 "silent reset" 한다기보다, phase.md 메타가 `phase-NN-slug` 형식으로 미리 채워져 있지 않으면 **die** 하고(미정 상태에선 명령 자체가 막힘), 활성 spec 가드에도 걸린다. 그래서 surgery 로 갈 수밖에 없었다. 수정은 두 갈래(메타 자동기입 + 같은 phase 재활성화 시 spec 보존)로 해소.
- **감지는 있는데 행동이 끊긴 패턴**: install drift 는 `sdd status`(`_drift_install`/`_drift_worktree`)가 이미 감지하지만 *보고만* 했다. update 후 커밋 유도(update.sh) + 브랜치 직전 경고(spec/specx new)로 "감지→행동" 연결을 보강.

## 🚧 이월 항목

- 별개 잔재 `specs/spec-x-queue-derived/` (untracked) 는 본 작업과 무관하게 유지 — 머지 후 정리 여부 별도 결정.
- 시크릿 가드 완화가 과하다고 판단되면 placeholder allowlist 만 좁히는 후속 패치로 조정 가능 (warn 모드라 위험 낮음).

## 🔗 관련 문서 (Related)

- 관련 spec: [[spec-x-check-secrets-dual-mode]], [[spec-x-hk-align-drift-detect]]
- 관련 wiki: `docs/wiki/patterns.md`

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-30 |
| **최종 commit** | (ship 시 갱신) |
