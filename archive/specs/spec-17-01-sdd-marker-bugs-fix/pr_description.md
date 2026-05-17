# fix(spec-17-01): sdd CLI marker 버그 3 종 fix — RCA-001 prevention 직접 구현

> ★ **PR Target**: `phase-17-coherence-fix` (main 직 PR 아님 — phase base branch 모드)

## 📋 Summary

### 배경 및 목적

phase-16 회고에서 RCA-001 invariant ("sdd ship 산출물 누락 금지") 가 *phase 내내 4 회 위반* 으로 식별. 매번 수동 dedupe / 보정 commit 필요한 productivity tax (W5/W10). 본 PR 은 RCA-001 prevention 의 *직접 구현* — sdd CLI 의 marker 처리 3 함수 fix.

3 버그 root cause:
1. **`cmd_spec_new` (line 1170)** — `sdd_marker_grep` 가 `` `${short_id}` `` (backtick) 만 매칭. 수동 작성 phase doc 의 plain Backlog 행 미인식 → append → 중복.
2. **`cmd_ship` (line 1434)** — `index($0, sid)` 가 full slug 매칭. Backlog 행 (short id 만) 미터치 → Active→Merged 후 Backlog 잔류.
3. **`queue_mark_done` (line 993)** — `sdd phase done 16` (prefix 없이) → 경로 잘못 → title 빈 → entry `**16** — ?`.

### 주요 변경 사항

- [x] **`cmd_spec_new`** — backtick OR plain `| short_id |` 둘 다 매칭 → in-place update
- [x] **`cmd_ship`** — Active/Merged 변경 시 동일 short_id 의 Backlog 행 삭제 (한 spec = 한 행 invariant)
- [x] **`queue_mark_done`** — function 진입부 case normalize (`16` → `phase-16`)
- [x] **install 미러 동기화** — `.harness-kit/bin/sdd` 동일 + chmod +x 보존
- [x] **단위 테스트** — `tests/test-sdd-marker-idempotent.sh` (3 시나리오) — 모두 PASS

### Phase 컨텍스트

- **Phase**: `phase-17` — 정합성 fix
- **Base branch**: `phase-17-coherence-fix`
- **본 SPEC 의 역할**: phase-17 의 *3 spec 중 P0* — RCA-001 prevention 의 직접 구현. 후속 spec-17-02 (cache 분리) / 17-03 (integration test+doctor) 의 *bookkeeping 신뢰성* 전제.

## 🎯 Key Review Points

1. **Backlog 행 매칭 패턴** — backtick `` `spec-17-01` `` vs plain `| spec-17-01 |`. 정규식이 길이가 다른 spec ID (예: `spec-17-01` vs `spec-17-001`) 부분 일치 위험 없는지 — 단위 테스트가 검증.
2. **ship 의 Backlog 행 삭제 분기** — `index($0, sid)` 매칭과 *동일 short_id Backlog 매칭* 의 순서. awk 의 next 사용으로 두 패턴이 동시 적용 안 되게 보장.
3. **normalize 위치 선택 (callee)** — `queue_mark_done` 진입부 vs `phase_done` caller. callee 가 다른 진입점 (state_get phase 등) 도 함께 보호.
4. **defensive coding 명시** — ship 의 Backlog 행 삭제 분기는 spec_new fix 이후엔 실제 trigger 안 됨 (이미 update 됨). 기존 phase 파일 backfill 안 된 환경의 cleanup 역할. walkthrough 에 명시.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-marker-idempotent.sh
bash tests/test-drift-stale-adr.sh    # 회귀 점검
```

**결과 요약**:
- ✅ Test 1 — spec new: in-place update of Backlog row (no append)
- ✅ Test 2 — spec new: row status = Active
- ✅ Test 3 — phase done: normalize 'phase done 99' → '**phase-99** — title'
- ✅ 회귀: stale ADR drift 3/3 PASS

### 통합 테스트
Integration Test Required = yes. phase-17.md 시나리오 1 (Marker 멱등성) 의 단위 구현. 본 PR 머지 후 spec-17-02 의 `sdd spec new` 가 plain Backlog 행을 *append 없이 update* 함이 첫 실증.

### 수동 검증 시나리오
1. **본 spec self-cleanup 시연** — fixture phase-99 + spec-99-01 (Backlog) → `sdd spec new marker-test` → 행 수 1 ✓
2. **phase done normalize** — `sdd phase done 99` → `**phase-99** — Marker Test Fixture` ✓
3. **install 미러 동등성** — `diff sources/bin/sdd .harness-kit/bin/sdd` 빈 출력 ✓
4. **phase-08~16 회귀** — 본문 변경 없음 (`git status`) ✓

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-marker-idempotent.sh` (105 줄) — 3 시나리오 단위 테스트
- `specs/spec-17-01-sdd-marker-bugs-fix/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md`

### 🛠 Modified Files
- `sources/bin/sdd` (+25, -7) — 3 함수 fix
- `.harness-kit/bin/sdd` (+25, -7) — install 미러
- `backlog/phase-17.md` — Pre-flight 시점 dedupe (spec-17-01 행 1 행만 Active)
- `backlog/queue.md` — sdd spec new 자동 갱신

**Total**: 9 files changed (6 new + 3 modified)

## ✅ Definition of Done

- [x] 3 함수 fix 완료
- [x] install 미러 동기화
- [x] 단위 테스트 3/3 PASS
- [x] 회귀 테스트 PASS (stale ADR 3/3)
- [x] phase-17.md self-cleanup 시연 (Pre-flight 수동 dedupe 후 fix 적용)
- [x] `walkthrough.md` / `pr_description.md` ship commit

## 🔗 관련 자료

- 선행 RCA: `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` (본 PR 이 prevention 의 직접 구현)
- 선행 phase 회고: phase-16 회고 결과 — `backlog/queue.md` Icebox W5/W10
- Phase: `backlog/phase-17.md` (정합성 fix)
- Walkthrough: `specs/spec-17-01-sdd-marker-bugs-fix/walkthrough.md`

## ⏭ 다음 단계

본 PR 머지 → phase-17 의 spec-17-02 (installed-cache-separation, P1) 진입. spec-17-02 의 `sdd spec new` 호출이 본 fix 의 첫 실증 — phase-17.md 의 spec-17-02 행이 plain Backlog 에서 backtick Active 로 *append 없이* in-place 전환되어야 함.
