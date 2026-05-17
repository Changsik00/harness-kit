# docs(spec-17-04): Governance + Test Coherence (W1/W3/W4/W7 cleanup)

> ★ **PR Target**: `phase-17-coherence-fix` (main 직 PR 아님 — phase base branch 모드)

## 📋 Summary

### 배경 및 목적

phase-16 회고에서 식별된 *Warning 4 건* 의 잡탕 cleanup. 각각 단발 fix 라 spec-x 분리 시 PR 4 개 누적 — 한 spec 묶음으로 review 1 회.

- **W1** — `sources/governance/constitution.md` §6.4 closure 표 표현 모호: "Used in" 열이 `failure-pattern` = RCA 전용임을 시사하나, Rules 1 항 "RCA and ADR; both adopt the closure" 가 ADR 도 모든 어휘 가능하다고 읽힘. 인간 작성자 silent 혼선.
- **W3** — `tests/test-drift-stale-adr.sh` Step 3 (회귀 마커) 가 ADR-001 본문에 종속: ADR-001 정상 갱신이 false positive 가능. 회귀 마커가 *외부 데이터에 결합*.
- **W4** — ADR 작성자에게 *어떤 경로 표기가 stale 검사 대상인지* 안내 부재: 도구가 *일하는 척만* 함 (code fence / 슬래시 없는 경로는 silent 우회).
- **W7** — CLAUDE.md "릴리스 전략" 섹션에 *phase ship 시 CHANGELOG draft* 룰 부재: 다음 release 시 phase-16/17 catch-up 부담 누적.

### 주요 변경 사항

- [x] **W1** — `sources/governance/constitution.md` §6.4 "Used in" 열에 *전용/공유* 마크 명시 (`ADR only` / `RCA only` / `+ ... (shared)`). Rules 1 항 부연 — closure 어휘 자체는 공유, 각 type 의 적합 산출물은 "Used in" 열을 따름. install 미러 sync.
- [x] **W3** — `tests/test-drift-stale-adr.sh` Step 3 을 `ADR-998-valid-paths-fixture` (모든 경로 valid) 기반으로 전환. 회귀 마커가 ADR-001 본문 변경에 둔감.
- [x] **W4** — `sources/templates/adr.md` 본문 시작부 (헤더 직후, Context 앞) 에 Note 블록 3 줄 추가 — *inline backtick + 슬래시 + 확장자* 만 stale 검사 대상 명시. install 미러 sync.
- [x] **W7** — CLAUDE.md "릴리스 전략 → 룰" 하위에 `Phase ship 시 CHANGELOG draft 갱신` bullet 추가 — `## [Unreleased]` 섹션 패턴 명시.

### Phase 컨텍스트

- **Phase**: `phase-17` — 운영 성숙도 (Operational Maturity)
- **Base branch**: `phase-17-coherence-fix`
- **본 SPEC 의 역할**: phase-17 의 *문서·테스트 정합성* 묶음 (4 spec 중 마지막). spec-17-01 (sdd marker bugs) + spec-17-02 (외부 접근성) + spec-17-03 (내부 신뢰성 인프라) 다음 — phase-17 *운영 성숙도* 마무리. 본 PR 머지 후 phase-17 phase-ship 진입.

## 🎯 Key Review Points

1. **W1 — closure 어휘 자체 변경 없음** — 표 표현 명확화 + Rules 1 항 부연만. ADR 승격 불필요 (closure 5 어휘는 안정). 변경은 *표현 모호성 해소* 만.
2. **W3 — 회귀 마커 self-contained** — Step 3 의 assertion 이 더 이상 ADR-001 의 *valid 상태* 에 종속 안 함. ADR-001 본문 정상 갱신 (valid path 추가) 시 영향 0. *stale 검사 자체는 전역* 이라 절대적 격리는 아니나 (Icebox), 의도된 assertion 의 종속성 해소.
3. **W4 — 검사 로직 확장 아님** — spec-16-03 의 *의도된 한계* 유지. Note 블록은 *작성자에게 한계 노출* 만. code fence 안 경로 검사 확대는 별 spec (Icebox).
4. **W7 — 룰 텍스트만 추가** — 본 spec 에서 CHANGELOG.md backfill 안 함. `## [Unreleased]` 섹션 신설 + 첫 draft entry 작성은 phase-17 phase-ship 시점.
5. **install 미러 sync 일관** — constitution.md / adr.md 양쪽 동기화. mirror diff 0 검증.

## 🧪 Verification

### 단위 + 회귀

```bash
# W1: 거버넌스 표 변경
grep -Ec "ADR only|RCA only|\(shared\)" sources/governance/constitution.md .harness-kit/agent/constitution.md
# → 각 5 hits

# W4: ADR 템플릿 가이드
grep -c "stale ADR 검사 대상" sources/templates/adr.md .harness-kit/agent/templates/adr.md
# → 각 1 hit

# W7: 릴리스 룰
grep -c "Phase ship 시 CHANGELOG draft" CLAUDE.md
# → 1 hit

# install 미러 sync
diff sources/governance/constitution.md .harness-kit/agent/constitution.md   # → 0 diff
diff sources/templates/adr.md .harness-kit/agent/templates/adr.md             # → 0 diff

# 회귀 0
bash tests/test-sdd-marker-idempotent.sh   # 3/3 PASS
bash tests/test-drift-stale-adr.sh          # 3/3 PASS (W3 변경 후)
bash tests/test-phase16-integration.sh      # 3/3 PASS
bash .harness-kit/bin/sdd status            # drift 0 / 워킹트리 깔끔
```

### 워킹트리 cleanliness
- 본 PR 머지 후 `git status --porcelain` 빈 출력 유지 — spec-17-03 의 cache 분리 성과 손상 없음.

## 📦 Files

### sources/
- `sources/governance/constitution.md` — §6.4 표 + Rules 1 항 (W1)
- `sources/templates/adr.md` — Note 블록 (W4)

### .harness-kit/ (install mirrors)
- `.harness-kit/agent/constitution.md` (sync W1)
- `.harness-kit/agent/templates/adr.md` (sync W4)

### tests/
- `tests/test-drift-stale-adr.sh` — Step 3 fixture-based (W3)

### root
- `CLAUDE.md` — "릴리스 전략 → 룰" bullet (W7)

### specs/
- `specs/spec-17-04-governance-test-coherence/{spec,plan,task,walkthrough,pr_description}.md`

## 🔁 Rollback

본 PR revert. 4 항목 모두 *문서 변경 / 테스트 fixture 추가* — 코드 동작 변경 없음. W3 의 fixture (ADR-998) 는 trap cleanup 으로 테스트 종료 시 자동 삭제 — revert 후 잔재 0.

## 🔗 Related

- Phase: `backlog/phase-17.md`
- Spec: `specs/spec-17-04-governance-test-coherence/spec.md`
- Walkthrough: `specs/spec-17-04-governance-test-coherence/walkthrough.md`
- 선행 spec: `spec-17-01` (#122) / `spec-17-02` (#123) / `spec-17-03` (#124 가설)
- 출처: phase-16 회고의 Warning 4 건
