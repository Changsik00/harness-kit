# feat(spec-16-02): ADR 활성화 트리거 + 첫 ADR-001 도입

## 📋 Summary

### 배경 및 목적

`constitution.md` §6.3 에 ADR 경로는 *정의* 되어 있었으나 **작성 트리거가 살아있지 않았다** — 템플릿 부재, 산출물 어디에도 "이게 ADR 가치 있는 결정?" 을 자문하는 접점 없음, `docs/decisions/` 디렉토리도 없음. 그 결과 spec-16-01 의 *Knowledge Type Vocabulary 도입* 같은 long-lived architectural decision 이 walkthrough 결정 표에만 남고 ADR 로 박히지 않은 채 머지됐다.

본 PR 은 ADR 작성 경로를 *비강제* 로 활성화하고, 첫 ADR (`ADR-001-knowledge-types`) 을 작성하여 트리거가 *실증* 됨을 확인한다.

### 주요 변경 사항
- [x] **ADR 템플릿 신설** (`sources/templates/adr.md` + install 미러) — RCA 와 대칭 구조 (frontmatter 4 필드 + 본문 5 섹션)
- [x] **3 산출물 템플릿에 트리거 박음** — `spec.md` / `plan.md` 에 "📑 ADR 후보" 본문 체크박스 섹션, `walkthrough.md` 에 "ADR 승격 가이드" + 체크박스
- [x] **`/hk-spec-critique` 보강** — sub-agent prompt 의 검토 관점 3 → 4 확장, 출력 형식에 "ADR 후보 추출" 섹션
- [x] **constitution 갱신** — §6.3 ADR 정의에 *템플릿 경로* + *type 의무* 명시. §6.4 Rules 첫 항목을 "RCA and ADR; both adopt the closure" 로 수정 (deferred 표현 제거)
- [x] **첫 ADR 작성** — `docs/decisions/ADR-001-knowledge-types.md` (frontmatter `type: decision`, status accepted). Knowledge Type Vocabulary 의 5 어휘 closure 결정을 ADR 로 박음

### Phase 컨텍스트
- **Phase**: `phase-16` — Reliability Layer 강화 (RCA / ADR / Stale 탐지 / 포지셔닝)
- **본 SPEC 의 역할**: phase-16 의 *5 영역 얇은 보강* 중 **ADR 활성화** 담당. spec-16-01 (RCA + type 어휘) 의 type 슬롯을 ADR 도 사용자로 합류시켜 closure 완성. 후속 spec-16-03 (stale 탐지) 가 ADR 까지 검사 대상으로 삼을 수 있는 기반.

## 🎯 Key Review Points

1. **비강제 원칙 일관성** — 모든 체크박스가 미체크여도 ship 차단 없음. `walkthrough.md` / `spec.md` / `plan.md` / `hk-spec-critique.md` 4 군데 모두 "비강제" 명시 문구 박힘. constitution §6.4 *얇은 보강* 철학과 정렬.
2. **ADR-001 의 실증 가치** — Knowledge Type Vocabulary 결정은 spec-16-01 머지 시점부터 *암묵적으로 accepted* 상태였으나 ADR 로 명문화되지 않았던 long-lived decision. 본 ADR 은 *type 어휘 closure 가 RCA(failure-pattern) + ADR(decision) 두 카테고리에서 모두 grep 가능함* 을 실증.
3. **install 미러 동기화** — 도그푸딩 일관성을 위해 `sources/` 와 `.harness-kit/agent/` 양쪽을 같은 PR 에서 손댐. 모든 sync commit 직후 `diff` 로 동일성 확인.
4. **트리거 위치** — spec/plan 에선 본문 별도 섹션, walkthrough 에선 결정 기록 표 직후. 작성 흐름의 *자연스러운 자문 지점* 에 박힘.

## 🧪 Verification

### 자동 테스트 (grep / diff 기반)
```bash
# 본 spec 의 검증은 5 항목 일괄 수행 (plan.md §검증 계획 참조)
grep -l "## 📑 ADR 후보" sources/templates/spec.md sources/templates/plan.md
grep -l "ADR 승격 가이드" sources/templates/walkthrough.md
for f in templates/adr.md templates/spec.md templates/plan.md templates/walkthrough.md; do
  diff sources/$f .harness-kit/agent/$f
done
diff sources/commands/hk-spec-critique.md .claude/commands/hk-spec-critique.md
diff sources/governance/constitution.md .harness-kit/agent/constitution.md
grep -n "^type: decision$" docs/decisions/ADR-001-knowledge-types.md
grep -rh "^type:" docs/rca docs/decisions | sort -u
grep -n "ADR 후보 추출" sources/commands/hk-spec-critique.md
```

**결과 요약**:
- ✅ 트리거 헤더 grep: spec/plan/walkthrough 3 군데 모두 hit
- ✅ install 미러 diff: 6 파일 모두 sources ↔ install 동일
- ✅ ADR-001 frontmatter: `type: decision`
- ✅ type closure: `decision`, `failure-pattern` 두 어휘만 (정규 어휘 집합 내)
- ✅ critique prompt: "ADR 후보 추출" 2 군데 (prompt 본문 + 출력 형식)

### 통합 테스트
Integration Test Required = no. Phase 통합 테스트 시나리오 1 (Knowledge Type 일관성) 의 *전제 조건* 을 본 PR 이 마련 — `docs/decisions/` 첫 ADR 존재.

### 수동 검증 시나리오
1. **트리거 노출** — `.harness-kit/agent/templates/spec.md` 49 줄에 "📑 ADR 후보" 섹션 노출. 새 spec 작성 시 자연스럽게 보임. → 노출 확인 ✓
2. **critique 형식 확인** — `/hk-spec-critique` 호출 시 4 섹션 (유사 기법 / 요구사항 비판 / 대안 / **ADR 후보**) 출력 기대. 실제 호출 미수행 (prompt 형식만 검증). → 형식 hit 확인 ✓
3. **ADR-001 가독성** — 5 섹션 완비, `type: decision` frontmatter, 외부 진단 / 관련 spec 링크 명시. → 자기 검토 OK ✓

## 📦 Files Changed

### 🆕 New Files
- `sources/templates/adr.md` — ADR 본문 템플릿 (39 줄)
- `.harness-kit/agent/templates/adr.md` — install 미러 (sources 와 동일)
- `docs/decisions/ADR-001-knowledge-types.md` — 첫 ADR (64 줄)
- `specs/spec-16-02-adr-activation-trigger/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md` — 본 spec 산출물

### 🛠 Modified Files
- `sources/templates/spec.md` (+12, -0) — "📑 ADR 후보" 섹션 추가
- `.harness-kit/agent/templates/spec.md` — install 미러
- `sources/templates/plan.md` (+12, -0) — "📑 ADR 후보" 섹션 추가
- `.harness-kit/agent/templates/plan.md` — install 미러
- `sources/templates/walkthrough.md` (+15, -0) — "ADR 승격 가이드" 섹션 추가
- `.harness-kit/agent/templates/walkthrough.md` — install 미러
- `sources/commands/hk-spec-critique.md` (+15, -2) — sub-agent prompt 4 섹션화 + 출력 형식 보강
- `.claude/commands/hk-spec-critique.md` — install 미러
- `sources/governance/constitution.md` (+2, -2) — §6.3 ADR 정의 보강 + §6.4 Rules 첫 항목 갱신
- `.harness-kit/agent/constitution.md` — install 미러
- `backlog/phase-16.md` / `backlog/queue.md` — `sdd spec new` 자동 갱신

**Total**: 16 files changed (4 new + 11 modified + 1 spec 산출물 디렉토리)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (5/5)
- [x] (해당 없음) 통합 테스트 — Integration Test Required = no
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check 통과 (bash 키트 — 해당 없음, diff 동등성으로 대체)
- [x] 사용자 검토 요청 알림 완료 (PR 머지 대기)

## 🔗 관련 자료

- Phase: `backlog/phase-16.md` (Reliability Layer 강화)
- Walkthrough: `specs/spec-16-02-adr-activation-trigger/walkthrough.md`
- 관련 ADR: `docs/decisions/ADR-001-knowledge-types.md` (본 PR 에서 작성)
- 선행 spec: `specs/spec-16-01-rca-and-knowledge-types/` (type 어휘 도입)
- 외부 진단: https://velog.io/@typo/80-problem-in-agentic-coding (§2 Decision Ledger / §3 RCA)
