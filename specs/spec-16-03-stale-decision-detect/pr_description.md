# feat(spec-16-03): _drift_stale_adr — ADR missing-path 탐지

> ★ **PR Target**: `phase-16-reliability-layer` (main 직 PR 아님 — phase base branch 모드)

## 📋 Summary

### 배경 및 목적

spec-16-02 머지로 ADR 경로가 활성화됐지만, ADR 본문이 *지운 모듈* 을 참조해도 키트가 감지 못함. `docs/decisions/` 가 누적될수록 stale 검토 비용이 증가하며, phase-16 통합 테스트 시나리오 2 (지운 경로 참조 fixture → drift 라인) 의 *전제 기능* 이 부재.

본 PR 은 `sources/bin/sdd` 에 `_drift_stale_adr()` 함수를 추가하여 ADR 본문의 backtick-wrapped 경로를 grep 추출 → 존재 검사 → 1 줄 drift 출력. TTL/contradiction/auto-fix 는 명시적 Out of Scope.

### 주요 변경 사항

- [x] **신규 함수** `_drift_stale_adr()` — `sources/bin/sdd` (`_drift_kit_version` 직후 위치), `_status_drift` 체인에 wire
- [x] **install 미러 동기화** — `.harness-kit/bin/sdd` 동일 (도그푸딩)
- [x] **단위 테스트** — `tests/test-drift-stale-adr.sh` 3 단계 (clean / fixture / 회귀) 모두 PASS
- [x] **통합 테스트** (phase-16 시나리오 2) PASS — fixture 1 개 → "stale ADR: 1 (missing-path)" 라인 출력

### Phase 컨텍스트

- **Phase**: `phase-16` — Reliability Layer 강화
- **Base branch**: `phase-16-reliability-layer` (2026-05-16 mid-phase 전환)
- **본 SPEC 의 역할**: phase-16 의 5 영역 중 **Stale 탐지** 담당. spec-16-01 (type 어휘) + spec-16-02 (ADR 활성화) 이 누적한 자산을 *경로 정합성* 으로 감시. 성공 기준 #3 충족.

## 🎯 Key Review Points

1. **경로 추출 휴리스틱 (좁게)** — backtick + 슬래시 + URL 제외 + 확장자/끝슬래시. ADR-001 본문에 `obj.method` 같은 인라인 코드가 잘못 매칭되지 않도록. false positive 최소화 우선.
2. **출력 형식 일관성** — drift 섹션의 다른 라인 (`원격: behind N / ahead M` 등) 과 동일 패턴. 1 줄 요약 + list (최대 3 개 + "…").
3. **silent on no-ADR** — `docs/decisions/` 없거나 ADR 0 개 → drift 출력 없음. 기존 `sdd status` 사용자에게 회귀 없음.
4. **`HARNESS_DRIFT_FETCH=0` 사용 권장 (테스트/CI)** — `_drift_remote` 의 git fetch noise 회피. 테스트 스크립트는 환경변수 적용.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-drift-stale-adr.sh
```

**결과 요약**:
- ✅ clean state: no stale ADR line
- ✅ fixture ADR (1 missing path) → stale ADR: 1 detected
- ✅ regression: ADR-001 paths all valid

### 통합 테스트 (phase-16 시나리오 2)
```bash
cat > docs/decisions/ADR-999-stale-integration.md <<'EOF'
---
type: decision
status: accepted
---
Reference: `src/removed-module.ts`
EOF

HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status | grep "stale ADR"
# → stale ADR: 1 (missing-path) — docs/decisions/ADR-999-stale-integration.md

rm docs/decisions/ADR-999-stale-integration.md
```

**결과**: ✅ Passed (fixture → 1 stale 출력 / cleanup 후 stale 라인 사라짐)

### 수동 검증 시나리오
1. **정상 상태** — `sdd status` drift 섹션에 "stale ADR" 라인 없음 ✓
2. **fixture 주입** — 부재 경로 참조 ADR 추가 → 1 줄 출력 ✓
3. **install 미러 동등성** — `diff sources/bin/sdd .harness-kit/bin/sdd` 차이 없음 ✓

## 📦 Files Changed

### 🆕 New Files
- `tests/test-drift-stale-adr.sh` — 단위 테스트 스크립트 (70 줄)
- `specs/spec-16-03-stale-decision-detect/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md` — 본 spec 산출물

### 🛠 Modified Files
- `sources/bin/sdd` (+58, -0) — `_drift_stale_adr()` 함수 + `_status_drift` wire
- `.harness-kit/bin/sdd` (+58, -0) — install 미러 동기화
- `backlog/phase-16.md` / `backlog/queue.md` — `sdd spec new` 자동 갱신 + dedupe

**Total**: 9 files changed (6 new + 3 modified)

## ✅ Definition of Done

- [x] 모든 단위 테스트 PASS (3/3)
- [x] 통합 테스트 PASS — phase-16 시나리오 2 검증
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check — bash 키트, shellcheck pre-commit 통과
- [x] 사용자 검토 요청 알림 완료 (PR 머지 대기)

## 🔗 관련 자료

- Phase: `backlog/phase-16.md` (Reliability Layer 강화, base branch 모드)
- Walkthrough: `specs/spec-16-03-stale-decision-detect/walkthrough.md`
- 선행 spec: `specs/spec-16-02-adr-activation-trigger/` (ADR 활성화)
- 외부 진단: https://velog.io/@typo/80-problem-in-agentic-coding (#6 Spec Drift)
