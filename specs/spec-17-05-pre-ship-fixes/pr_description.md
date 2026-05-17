# fix(spec-17-05): Pre-Ship Fixes — phase-17 회고 Critical 6 건 sweep

> ★ **PR Target**: `phase-17-coherence-fix` (main 직 PR 아님 — phase base branch 모드)

## 📋 Summary

### 배경 및 목적

phase-17 의 4 spec 머지 후 `/hk-phase-review` 독립 Opus 서브에이전트 회고에서 **Critical 6 건** 식별. phase-ship 직전 한 spec 묶음으로 sweep — phase-17 의 *자기 성공 기준* 완수.

- **C1** — `install.sh:515-516` 가 신규 installed.json 에 cache 필드 작성 (spec-17-03 와 충돌)
- **C2** — `/hk-update.md` 가 cache destination 을 installed.json 으로 안내 (spec-17-03 와 충돌)
- **C3** — `.harness-kit/installed.json.installedCommands` 에 신규 `hk` 누락 (도그푸딩 매니페스트 stale)
- **C4** — `queue.md` Icebox 의 spec-17-02 ↔ 17-03 매핑 꼬임 (typo)
- **C5** — `tests/test-phase17-integration.sh` 부재 (명명 규약 자기 미적용)
- **C6** — `CHANGELOG.md` 의 `## [Unreleased]` 섹션 부재 (W7 룰 첫 실증 누락)

### 주요 변경 사항

- [x] **C1** — `install.sh` 의 `lastVersionCheck` / `latestKnownVersion` 두 줄 제거. 신규 사용자 install 직후 워킹트리 clean.
- [x] **C2** — `sources/commands/hk-update.md` + `.claude/commands/hk-update.md` 의 cache jq destination 을 `.harness-kit/cache.json` 으로 정정.
- [x] **C3** — `.harness-kit/installed.json.installedCommands` 에 `"hk"` 추가 (알파벳 순 첫 위치). length 13 → 14.
- [x] **C4** — `backlog/queue.md:28,30` 의 spec-17-02 / spec-17-03 매핑 swap.
- [x] **C5** — `tests/test-phase17-integration.sh` 신규 (4 시나리오 / 3 PASS / 1 skip — curl install end-to-end 는 Icebox). 시나리오 2 는 hook 전/후 `git diff --name-only` 비교 + `jq has(...)` 로 *cleanliness 의 본질* 직접 검증.
- [x] **C6** — `CHANGELOG.md` 에 `## [Unreleased]` 섹션 신설 + phase-17 4 PR (#122 ~ #125) + 본 PR (#126) draft entry. W7 룰 첫 실증.

### Phase 컨텍스트

- **Phase**: `phase-17` — 운영 성숙도 (Operational Maturity)
- **Base branch**: `phase-17-coherence-fix`
- **본 SPEC 의 역할**: phase-17 의 *pre-ship sweep* (5번째 spec). 회고에서 식별된 Critical 6 건을 처리 — phase-ship 직전 cleanup. 본 PR 머지 후 phase-17 phase-ship 진입.

## 🎯 Key Review Points

1. **C1 + C2 — spec-17-03 의 누수 sealing** — spec-17-03 가 *읽기/쓰기 경로* (hook + sdd) 만 분리하고 *초기값 작성 시점 (install.sh) + 안내 문서 (hk-update)* 의 동일 변경을 놓쳤음. 회고가 잡아냄 — 회고 자동화의 직접적 가치 실증.
2. **C5 시나리오 2 — cleanliness 의 본질 검증** — 초기 구현 `git status --porcelain | wc -l == 0` 이 untracked 파일에 fragile. 수정: hook 전/후 `git diff --name-only` 비교 + `installed.json` 에 cache 필드 부재 jq 직접 검증. *환경 무관* 한 invariant 만 검증.
3. **C6 — W7 룰 첫 실증** — 본 spec 머지 후 phase-17 phase-ship 시 추가 entry 누락 없음. 다음 release commit 은 `## [Unreleased]` → `## [0.9.2] — YYYY-MM-DD` 로 stamp.
4. **회귀 0** — marker-idempotent / drift-stale-adr / phase16-integration / phase17-integration (신규) 4 종 모두 PASS. drift 0 + 워킹트리 clean.
5. **review Warning 10 건은 본 spec scope 외** — task.md 미체크 일괄 sweep (W1) / `/hk` governance 반영 (W2) / README 표 (W3) / Phase 4 stale (W4) 등은 다음 phase. 본 spec 은 Critical 만.

## 🧪 Verification

### 단위 + 통합 + 회귀
```bash
# C1
grep -c "lastVersionCheck\|latestKnownVersion" install.sh update.sh   # → 0 / 0

# C2
diff sources/commands/hk-update.md .claude/commands/hk-update.md      # → 0 (sync)
grep "cache.json" sources/commands/hk-update.md                       # ≥1 hit

# C3
jq -r '.installedCommands | length' .harness-kit/installed.json       # → 14
jq -r '.installedCommands | index("hk")' .harness-kit/installed.json  # → 0

# C4
grep "접근성 개선" backlog/queue.md | grep -q "spec-17-02"             # PASS
grep "installed.json 캐시" backlog/queue.md | grep -q "spec-17-03"     # PASS

# C5 (신규 통합 테스트 자체)
bash tests/test-phase17-integration.sh   # 3 passed / 1 skipped

# C6
grep -q "## \[Unreleased\]" CHANGELOG.md                              # PASS

# 회귀
bash tests/test-sdd-marker-idempotent.sh   # 3/3 PASS
bash tests/test-drift-stale-adr.sh          # 3/3 PASS
bash tests/test-phase16-integration.sh      # 3/3 PASS
bash .harness-kit/bin/sdd status            # drift 0 / 워킹트리 clean
```

## 📦 Files

### root
- `install.sh` — cache 필드 제거 (C1)
- `CHANGELOG.md` — [Unreleased] + phase-17 draft entry (C6)
- `backlog/queue.md` — Icebox 매핑 swap (C4)

### sources/commands/
- `sources/commands/hk-update.md` — cache destination 정정 (C2)

### .claude/commands/ (install mirror)
- `.claude/commands/hk-update.md` (sync C2)

### .harness-kit/
- `.harness-kit/installed.json` — installedCommands 에 hk 추가 (C3)

### tests/
- `tests/test-phase17-integration.sh` (신규 — C5)

### specs/
- `specs/spec-17-05-pre-ship-fixes/{spec,plan,task,walkthrough,pr_description}.md`

## 🔁 Rollback

본 PR revert. 6 항목 모두 *문서/매니페스트/테스트 신규* — 코드 동작 변경 최소 (install.sh 두 줄 제거).
- C1 revert 시 hook migration 이 다시 trigger (legacy → cache.json) — 양방향 호환.
- C6 revert 시 [Unreleased] 사라짐 — 다음 release commit 시 catch-up 부담 그대로 (룰만 박힌 상태).

## 🔗 Related

- Phase: `backlog/phase-17.md`
- Spec: `specs/spec-17-05-pre-ship-fixes/spec.md`
- Walkthrough: `specs/spec-17-05-pre-ship-fixes/walkthrough.md`
- 선행 spec: `spec-17-01` (#122) / `spec-17-02` (#123) / `spec-17-03` (#124) / `spec-17-04` (#125)
- 출처: `/hk-phase-review` 독립 Opus 회고 Critical 6 건
