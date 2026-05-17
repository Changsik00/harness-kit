# spec-17-05: Pre-Ship Fixes (phase-17 회고 Critical 6 건 sweep)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-17-05` |
| **Phase** | `phase-17` (운영 성숙도) |
| **Branch** | `spec-17-05-pre-ship-fixes` |
| **상태** | Planning |
| **타입** | Fix + Refactor + Docs |
| **Integration Test Required** | yes |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

phase-17 의 4 spec (17-01 ~ 17-04) 모두 merge 완료. phase-ship 직전 `/hk-phase-review` 독립 Opus 회고에서 **Critical 6 건** 식별:

**C1 — `install.sh` 가 신규 installed.json 에 캐시 필드 작성**:
- `install.sh:515-516` 가 여전히 `lastVersionCheck` / `latestKnownVersion` 두 필드를 `installed.json` 에 작성.
- spec-17-03 가 cache.json 으로 분리했으나 install.sh 미수정 — 신규 사용자는 install 직후 첫 SessionStart 에서 즉시 migration trigger → installed.json 변경 → 워킹트리 dirty.
- spec-17-03 의 "cleanliness 가정" 무효화 (신규 install 환경).

**C2 — `/hk-update` 가 cache 를 다시 installed.json 에 작성하도록 안내**:
- `sources/commands/hk-update.md:108` 가 cache 필드 갱신 destination 을 installed.json 으로 안내.
- spec-17-03 분리와 정면 충돌 — 에이전트가 `/hk-update` 충실 수행 시 *방금 migration 으로 제거한 캐시* 가 다시 installed.json 에 박힘.

**C3 — `installed.json.installedCommands` 에 신규 `hk` 누락**:
- `.harness-kit/installed.json:6-20` 에 `hk-*` 13 항목만 — `hk` (bare) 미등록.
- spec-17-02 가 `/hk` 신설했으나 installedCommands manifest 동기화 누락.
- uninstall.sh 가 manifest 기반 — `/hk` 가 orphan 화 위험.

**C4 — `queue.md` Icebox 의 spec 매핑 꼬임**:
- `backlog/queue.md:28,30` 에서 spec-17-02 (accessibility) 와 spec-17-03 (internal-reliability) 가 맞바뀜.
- 사용자/리뷰어 혼선 직접 야기.

**C5 — `tests/test-phase17-integration.sh` 부재**:
- spec-17-03 가 `phase-NN-integration.sh` 명명 규약 신설 후 phase-16 본만 작성.
- phase-17 자체의 통합 시나리오 4 (phase-17.md `🧪 통합 테스트 시나리오` 섹션) 가 자동화 안 됨.
- Phase Done 조건 미달 — phase-ship 의 정량 입력 부재.

**C6 — `CHANGELOG.md` 의 `## [Unreleased]` 섹션 부재**:
- spec-17-04 W7 룰의 첫 실증 시점이 *지금* (phase-17 phase-ship 직전) 이지만 [Unreleased] 섹션 자체 부재.
- 룰만 박히고 첫 실증 누락 → 다음 release commit 에 phase-17 catch-up 부담 그대로.

### 문제점

- **C1 + C2** — spec-17-03 의 *cleanliness* 약속이 install/update 경로에 누수. 신규 사용자 + /hk-update 호출 시 즉시 깨짐.
- **C3** — uninstall 시 orphan. dogfooding manifest 정합 깨짐.
- **C4** — backlog metadata drift. phase 재정의 시 sweep 누락 패턴.
- **C5** — phase-17 자체의 통합 자동화 0. 명명 규약 신설하고도 *자기 phase* 미적용.
- **C6** — W7 룰의 첫 실증 누락 → 룰이 *문서뿐* 인 상태.

### 해결 방안 (요약)

6 항목 한 spec 묶음:
1. **C1**: `install.sh` 의 cache 필드 작성 제거 — 신규 installed.json 에 두 필드 미포함.
2. **C2**: `sources/commands/hk-update.md:108` 의 cache 갱신 destination 을 `.harness-kit/cache.json` 으로 정정.
3. **C3**: `.harness-kit/installed.json.installedCommands` 에 `hk` 추가 (도그푸딩 자기 manifest 정합).
4. **C4**: `backlog/queue.md` Icebox 의 spec-17-02 / spec-17-03 매핑 정정.
5. **C5**: `tests/test-phase17-integration.sh` 작성 — phase-17.md 의 시나리오 4 자동화 (가능한 시나리오부터).
6. **C6**: `CHANGELOG.md` 에 `## [Unreleased]` 섹션 신설 + phase-17 draft entry 작성 (W7 룰 첫 실증).

## 🎯 요구사항

### Functional Requirements

1. **C1 — `install.sh` 의 cache 필드 작성 제거**:
   - `install.sh:515-516` 의 `lastVersionCheck` / `latestKnownVersion` 두 필드를 신규 `installed.json` 생성 로직에서 제거.
   - 결과: 신규 사용자가 install 직후 SessionStart 시 *migration trigger 없음* → 워킹트리 clean 유지.
   - `update.sh` 도 동일 로직 있으면 함께 제거.

2. **C2 — `/hk-update` cache 갱신 destination 정정**:
   - `sources/commands/hk-update.md:108` (또는 해당 절차 안내 줄) 의 cache 필드 갱신 destination 을 `.harness-kit/cache.json` 으로 정정.
   - 에이전트가 `/hk-update` 절차 충실 수행 시 cache.json 만 갱신, installed.json 미터치.

3. **C3 — installedCommands manifest 에 `hk` 추가**:
   - `.harness-kit/installed.json.installedCommands` 배열에 `".claude/commands/hk.md"` 추가 (위치는 알파벳 순 또는 기존 패턴).
   - install.sh 의 manifest 생성 로직도 `hk` 포함하도록 수정 (있다면).

4. **C4 — `backlog/queue.md` Icebox 매핑 정정**:
   - 28 줄: `~~접근성 개선~~ → phase-17 spec-17-02` (현재 spec-17-03 → 수정)
   - 30 줄: `~~installed.json 캐시 (C3)~~ ... → phase-17 spec-17-03` (현재 spec-17-02 → 수정)

5. **C5 — `tests/test-phase17-integration.sh` 작성**:
   - phase-17.md `🧪 통합 테스트 시나리오` 의 4 시나리오 중 *자동화 가능한 것* 부터:
     - 시나리오 1 (Marker 멱등성) — `tests/test-sdd-marker-idempotent.sh` 위임 검증
     - 시나리오 2 (워킹트리 cleanliness) — SessionStart hook 실행 후 `git status --porcelain` 빈 출력
     - 시나리오 4 (governance/test grep) — §6.4 "Used in" 마크 + ADR 가이드 + CHANGELOG 룰 grep
     - 시나리오 3 (curl install end-to-end) — *제외* (fixture 환경 필요, 본 spec 범위 초과)
   - 명명: `tests/test-phase17-integration.sh` (spec-17-03 의 명명 규약 첫 자기 적용).
   - 결과: 3 시나리오 PASS (시나리오 3 은 `skip` 표시).

6. **C6 — `CHANGELOG.md [Unreleased]` 신설 + phase-17 draft**:
   - `CHANGELOG.md` 최상단 `# CHANGELOG` 헤더 직후, `## [0.9.1]` 앞에 `## [Unreleased]` 섹션 신설.
   - phase-17 의 주요 변경 사항 draft entry 작성 — `Added` / `Fixed` / `Changed` 소제목별 정리. 각 항목 끝에 `(#PR번호)` 인용.
   - W7 룰 첫 실증 — 다음 release commit 에서 `## [Unreleased]` → `## [0.9.2] — YYYY-MM-DD` stamp.

### Non-Functional Requirements

1. **install 미러 sync** — `install.sh` / `sources/commands/hk-update.md` 변경 시 `.harness-kit/` 미러 sync.
2. **회귀 0** — 기존 3 테스트 (test-sdd-marker-idempotent / test-drift-stale-adr / test-phase16-integration) + 신규 test-phase17-integration 모두 PASS.
3. **bash 3.2+ 호환** — 새 test script.

## 🚫 Out of Scope

- **task.md 4 spec 일괄 sweep (W1)** — review 의 Warning. 본 spec 은 *Critical 6 건* 만. 다음 phase 또는 별 spec-x.
- **check-task-checkbox.sh hook block 모드 승격 (W1 후속)** — 다음 phase.
- **`/hk` governance/README 표 반영 (W2/W3)** — 다음 phase.
- **CLAUDE.md "현재 단계 Phase 4" 갱신 (W4)** — 별 FF 또는 spec-x.
- **시나리오 3 (curl install end-to-end) 자동화** — fixture 환경 필요, 본 spec 범위 초과. Icebox.
- **cache migration 로직 DRY (W6)** — 다음 phase 또는 Icebox.
- **stale ADR 검사 isolated run (W7 회고)** — Icebox.

## ✅ Definition of Done

- [ ] C1: `install.sh` (+ `update.sh`) cache 필드 작성 제거 + install 미러 sync
- [ ] C2: `sources/commands/hk-update.md` cache destination cache.json 으로 정정 + install 미러 sync
- [ ] C3: `.harness-kit/installed.json.installedCommands` 에 `hk` 추가
- [ ] C4: `backlog/queue.md` Icebox 매핑 정정 (line 28/30)
- [ ] C5: `tests/test-phase17-integration.sh` 작성 + 3 시나리오 PASS (시나리오 3 skip)
- [ ] C6: `CHANGELOG.md` `## [Unreleased]` 섹션 + phase-17 draft entry
- [ ] 회귀: marker-idempotent / drift-stale-adr / phase16-integration / phase17-integration (신규) 4 종 PASS
- [ ] `walkthrough.md` / `pr_description.md` ship commit
- [ ] PR 생성 (target: `phase-17-coherence-fix`)
