# feat(spec-17-03): Internal reliability infrastructure (cache 분리 + integration test + doctor)

> ★ **PR Target**: `phase-17-coherence-fix` (main 직 PR 아님 — phase base branch 모드)

## 📋 Summary

### 배경 및 목적

phase-17 (운영 성숙도) 의 *내부 신뢰성* 묶음 — phase-16 회고에서 식별된 3 종 부채를 한 spec 으로 처리:
- **C3 — installed.json 캐시 필드** 가 tracked 파일이라 매 SessionStart drift 발생
- **W2 — phase-level integration test** 자동화 부재 (매번 수동 grep)
- **W6 — doctor.sh** 가 phase-16 신규 산출물 (rca/decisions) 점검 누락

### 주요 변경 사항

- [x] **Cache 분리** — `installed.json` 의 `lastVersionCheck` / `latestKnownVersion` → `.harness-kit/cache.json` (gitignored). hook + sdd 모두 자동 migration (기존 사용자 액션 0).
- [x] **`.gitignore`** — `.harness-kit/cache.json` 추가
- [x] **`tests/test-phase16-integration.sh`** 신규 — phase-16.md 시나리오 3 개 (type closure / stale ADR detection / reliability layer slogan) 한 명령 자동 검증. `phase-NN-integration.sh` 명명 규약 신설.
- [x] **`doctor.sh` 확장** — templates checklist 에 `rca.md` / `adr.md` 추가, dir checklist 에 `docs/rca` / `docs/decisions` optional 추가 (부재 시 silent skip)
- [x] **install 미러 sync** — `.harness-kit/hooks/check-kit-version.sh`, `.harness-kit/bin/sdd` 동기화

### Phase 컨텍스트

- **Phase**: `phase-17` — 운영 성숙도 (Operational Maturity)
- **Base branch**: `phase-17-coherence-fix`
- **본 SPEC 의 역할**: phase-17 의 *내부 신뢰성* 묶음 (4 spec 중 1). spec-17-01 (sdd marker bugs) + spec-17-02 (외부 접근성) 다음 — *워킹트리 cleanliness* + *phase 자동화 진입점* + *doctor 확장* 으로 내부 운영 인프라 완성.

## 🎯 Key Review Points

1. **Migration 안전성** — hook + sdd 양쪽에 동일 migration 로직. 1 회만 실행 (`jq has(...)` 체크). silent — 사용자 노출 0. 본 저장소의 installed.json 도 이미 migration 됨 (commit `e172921`) — *도그푸딩 실증*.
2. **`docs/rca` / `docs/decisions` 부재 시 silent skip** — 기존 사용자 false negative 0. phase-16 산출물 install 안 받은 환경에서도 doctor 가 잘못된 FAIL 안 함.
3. **Fixture 격리** — `ADR-999-phase16-integration-fixture` (spec-16-03 의 `ADR-999-fixture` 와 다른 slug). 동시 실행 race 회피.
4. **워킹트리 cleanliness 실증** — 본 PR 머지 후 `git status --porcelain` 빈 출력 유지. C3 해소.

## 🧪 Verification

### 단위 + 통합 + 회귀
```bash
# Migration 확인
jq 'has("lastVersionCheck") or has("latestKnownVersion")' .harness-kit/installed.json   # → false
jq -e '.lastVersionCheck and .latestKnownVersion' .harness-kit/cache.json                # → true
git check-ignore .harness-kit/cache.json                                                 # exit 0 (ignored)

# 워킹트리 cleanliness
git status --porcelain                                                                    # 빈 출력

# Integration self-test
bash tests/test-phase16-integration.sh                                                    # 3/3 PASS

# 회귀
bash tests/test-sdd-marker-idempotent.sh                                                  # 3/3 PASS
bash tests/test-drift-stale-adr.sh                                                        # 3/3 PASS

# Doctor 확장
bash doctor.sh | grep -E "rca.md|adr.md|docs/rca|docs/decisions"                          # 4 hits
```

**결과 요약**:
- ✅ Migration 정상 (installed.json 정리 + cache.json 생성)
- ✅ 워킹트리 cleanliness (C3 해소)
- ✅ phase-16 integration 3/3 PASS (W2 해소)
- ✅ doctor 확장 4 항목 hit (W6 해소)
- ✅ 회귀 0 (spec-17-01 + spec-16-03 단위 테스트 통과)

### 통합 테스트 (phase-17.md 시나리오 2)
- **워킹트리 cleanliness**: SessionStart hook 실행 후 `git status --porcelain` 빈 출력 ✓
- **Phase-16 integration self-test**: 3/3 PASS ✓

## 📦 Files Changed

### 🆕 New Files
- `tests/test-phase16-integration.sh` (66 줄)
- `specs/spec-17-03-internal-reliability-infra/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md`

### 🛠 Modified Files
- `.gitignore` (+3) — cache.json 추가
- `sources/hooks/check-kit-version.sh` (+22, -7) — cache.json 사용 + migration
- `.harness-kit/hooks/check-kit-version.sh` — install 미러
- `sources/bin/sdd` (+24, -8) — _drift_kit_version cache.json 사용 + migration
- `.harness-kit/bin/sdd` — install 미러
- `doctor.sh` (+5, -1) — templates + dir checklist 확장
- `.harness-kit/installed.json` — 캐시 필드 제거 (migration 결과)

**Total**: 12 files changed (6 new + 6 modified)

## ✅ Definition of Done

- [x] Cache 분리 (installed.json → cache.json + gitignored + migration)
- [x] phase16-integration 스크립트 (3 시나리오 PASS)
- [x] doctor.sh 확장 (4 항목)
- [x] install 미러 sync (hook + sdd)
- [x] 회귀 0 + 워킹트리 cleanliness
- [x] walkthrough.md / pr_description.md ship commit

## 🔗 관련 자료

- Phase: `backlog/phase-17.md` (운영 성숙도)
- Walkthrough: `specs/spec-17-03-internal-reliability-infra/walkthrough.md`
- 회고 ref: phase-16 회고 C3 (cache drift) / W2 (integration test) / W6 (doctor 확장)
- 선행 spec: spec-17-01 (sdd marker bugs) / spec-17-02 (accessibility)

## ⏭ 다음 단계

본 PR 머지 → phase-17 의 마지막 spec **spec-17-04 (governance-test-coherence)** 진입. W1/W3/W4/W7 잡탕 cleanup (3-5 commit).
