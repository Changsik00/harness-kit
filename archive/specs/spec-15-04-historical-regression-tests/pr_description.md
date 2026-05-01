# test(spec-15-04): historical regression tests — 5 stateful upgrade 시나리오 (4 활성 + 1 위임)

## 📋 Summary

### 배경 및 목적

phase-15.md §통합 테스트 시나리오 5개 — "사용 중인 사용자 환경에서 update 했을 때 무엇이 깨지면 안 되는가" — 를 자동화된 회귀 테스트로 잠금. 4건 과거 버그 (#82, #84, #78, #83) 가 같은 자리에서 같은 패턴으로 재발하면 즉시 빨간 신호.

spec-15-02 의 `tests/lib/fixture.sh` 첫 실 사용처 — fixture lib 의 5 mixin 이 시나리오 1, 2, 4 에서 그대로 활용됨.

### 주요 변경 사항

- [x] `tests/test-update-stateful.sh` 신규 — 5 시나리오 (시나리오 3 은 정책 결정 필요로 skip)
- [x] **13 checks PASS**:
  - **S1** (4) — in-flight phase: 6 state 필드 / kitVersion / phase.md / spec 디렉토리 → #82 잠금
  - **S2** (2) — pre-defined phases: 3개 md5 / sdd phase activate → #84 잠금
  - **S4** (2) — dirty queue: 사용자 Icebox 메모 / sdd 마커 4 영역 → Pattern B
  - **S5** (5) — multi-install: 8 템플릿 / .gitignore hk 라인 4개 각 1 회 → #78 + #83 잠금
- [x] **시나리오 3 skip** — customized fragment 정책 ("보존 vs 명시적 conflict") 결정 필요. spec-15-06 (user-hook-preserve) 의 산출물로 위임.

### Phase 컨텍스트

- **Phase**: `phase-15` (upgrade-safety, base: `phase-15-upgrade-safety`)
- **본 SPEC 의 역할**: phase 의 핵심 가치 — 통합 테스트 시나리오의 *실행 가능한* 구현. phase 성공 기준 #2 (4개 버그 stateful 회귀) 충족.

## 🎯 Key Review Points

1. **시나리오 3 위임 결정** — `tests/test-update-stateful.sh:46-49` skip 메시지. 정책 결정이 검증 작성에 선행. spec-15-06 진입 시 시나리오 3 추가.
2. **md5 분기** (`tests/test-update-stateful.sh:23-31`) — macOS `md5 -q` / Linux `md5sum` 자동 분기. best-effort Linux 호환.
3. **시나리오 5 의 4 라인 검증** — spec-14-03 의 라인별 멱등 fix 가 4 라인 모두 적용되어야 정확히 1 회씩 존재. 헤더만 검증하면 약함.
4. **fixture lib 첫 실 사용** — `with_in_flight_phase`, `with_pre_defined_phases`, `with_dirty_queue_icebox` 가 시나리오 1, 2, 4 에서 그대로 호출. 헬퍼 설계의 *실 검증*.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-update-stateful.sh   # 13/13 PASS (S3 skip)
bash tests/test-version-bump.sh      # 전체 스위트 FAIL=0
```

### 수동 검증
- 5 시나리오 직렬 실행 ≈ 7 초 (update.sh 의 uninstall+install 비용)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-update-stateful.sh` (140줄) — 5 시나리오 stateful 회귀 테스트
- `specs/spec-15-04-historical-regression-tests/{spec,plan,task,walkthrough,pr_description}.md`

### 🛠 Modified Files
- (없음 — 본 spec 은 *추가만*)

## ✅ Definition of Done

- [x] 5 시나리오 모두 작성 (S3 placeholder skip 메시지)
- [x] 13/13 checks PASS
- [x] 회귀 스위트 FAIL=0
- [x] phase-15 성공 기준 #2 충족 (4개 버그 #82, #84, #78, #83 stateful 회귀)
- [x] walkthrough.md / pr_description.md 작성

## 🔗 관련 자료

- Phase: `backlog/phase-15.md`
- 의존: spec-15-02 (`tests/lib/fixture.sh`)
- 후속: spec-15-06 (시나리오 3 정책 결정 + 작성)
