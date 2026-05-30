fix(spec-x-harness-footguns): 하네스 운영 footgun 3종 수정

## 📋 Summary

### 배경 및 목적

도그푸딩 대상 프로젝트의 한 세션에서 올라온 현장 제보 3건을 묶어 수정한다. 세 건 모두 키트 원본(`sources/`, `update.sh`)의 실제 결함으로 소스 확인을 마쳤다.

1. **`/hk-update` 미커밋 산물이 spec 브랜치를 오염** — `update.sh` 가 `.harness-kit/*`·`.claude/*` 를 덮어쓰고 커밋하지 않아, 이후 새 브랜치를 따면 따라붙어 PR scope 를 오염.
2. **시크릿 가드 오탐** — `check-secrets.sh` 의 정규식이 `${POSTGRES_PASSWORD:-default}` 같은 env 보간을 시크릿으로 오탐. placeholder(`changeme` 등)도 동일.
3. **`phase activate --base` 마찰** — phase.md `Base Branch` 메타가 미리 채워져 있지 않으면 die, 같은 phase 재활성화 시 active spec silent reset. 결국 state surgery 강요.

### 주요 변경 사항

- [x] **시크릿 가드**: 값이 shell 변수 보간(`${..}`/`$(..)`/`$VAR`)·placeholder 면 오탐에서 제외. 실제 하드코딩 시크릿은 계속 차단.
- [x] **update 가드**: `update.sh` 종료 시 미커밋 install 산물 감지 → 명시적 커밋 안내. `hk-update.md` 동일 안내.
- [x] **branch 경고**: `sdd spec new`/`specx new` 시 미커밋 install drift 감지 → 비차단 경고(`_warn_install_drift`).
- [x] **phase activate --base**: `--base=<branch>` 인자 지원 + phase.md 메타 자동 기입 + 같은 phase 재활성화 시 active spec 보존.

### Phase 컨텍스트
- **Phase**: 없음 (spec-x, 독립)
- **본 SPEC 의 역할**: 운영 중 드러난 footgun 의 systemic 수정 (감지→행동 연결 보강 포함)

## 🎯 Key Review Points

1. **시크릿 정규식 앵커링** (`check-secrets.sh`): 변수/placeholder 제외 필터를 값 바로 뒤(`[=:]` 직후)에만 앵커링. "실제 시크릿 + 부수적 변수"가 같은 줄에 있어도 계속 탐지되는지 확인.
2. **phase activate 재활성화 시맨틱** (`sdd`): `cur_phase == id` 일 때 spec/planAccepted 리셋과 active-spec 가드를 건너뛴다 — 미세한 행동 변경. 기존 Check 5·6(메타 fallback / die) 회귀 보존 확인.
3. **warn 모드 유지**: 모든 신규 경고는 비차단(rc 유지). Hook 단계론에 따라 차단 승격 없음.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-check-secrets-dual-mode.sh   # 14/14
bash tests/test-sdd-phase-activate.sh        # 17/17
bash tests/test-sdd-spec-new-drift-warn.sh   # 4/4 (신규)
bash tests/test-sdd-base-branch.sh           # 4/4 (회귀)
bash tests/test-update.sh                    # 11/11 (회귀)
bash tests/test-sdd-spec-new-seq.sh          # 5/5 (회귀)
```

**결과 요약**: ✅ 전 스위트 PASS (rc=0)

### 수동 검증 시나리오
1. dirty `.harness-kit/` 상태 → `sdd specx new foo` → 경고 출력 + rc=0 + 정상 생성
2. 시크릿 수정 커밋을 warn 우회 없이 시도 → 통과 (live dogfood 회귀 증거)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-spec-new-drift-warn.sh`: install drift 경고 단위 테스트

### 🛠 Modified Files
- `sources/hooks/check-secrets.sh` / `.harness-kit/hooks/check-secrets.sh`: env 보간·placeholder 예외
- `update.sh`: 미커밋 산물 커밋 안내
- `sources/commands/hk-update.md` / `.claude/commands/hk-update.md`: 업데이트 후 커밋 단계
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: `_warn_install_drift` + `phase activate --base` 개선
- `tests/test-check-secrets-dual-mode.sh`: Test 12·13·14
- `tests/test-sdd-phase-activate.sh`: Check 10·11

**Total**: 10 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] `bash -n` 문법 점검 통과 (shellcheck 미설치 — skip)
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-harness-footguns/walkthrough.md`
- 관련 spec: `spec-x-check-secrets-dual-mode`, `spec-x-hk-align-drift-detect`
