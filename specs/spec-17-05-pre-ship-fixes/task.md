# Task List: spec-17-05

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (sdd spec new — marker fix 정상 ✓ 5 번째 실증)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

- [ ] `git checkout -b spec-17-05-pre-ship-fixes` (from `phase-17-coherence-fix`)
- [ ] `git add backlog/phase-17.md backlog/queue.md specs/spec-17-05-pre-ship-fixes/`
- [ ] Commit: `chore(spec-17-05): add planning artifacts`

---

## Task 2: C1 — install.sh cache 필드 제거

- [ ] `install.sh:515-516` 두 줄 (`lastVersionCheck`, `latestKnownVersion`) 제거
- [ ] 검증: `grep -c "lastVersionCheck\|latestKnownVersion" install.sh update.sh` → 0 / 0
- [ ] Commit: `fix(spec-17-05): drop cache fields from install.sh installed.json (C1)`

---

## Task 3: C2 — /hk-update cache destination 정정

- [ ] `sources/commands/hk-update.md` ~line 100-110 의 cache jq 명령 + 안내 문구를 `.harness-kit/cache.json` 으로 정정
- [ ] install 미러 sync: `.claude/commands/hk-update.md`
- [ ] 검증: `grep -q "cache.json" sources/commands/hk-update.md .claude/commands/hk-update.md` → 양쪽 hit
- [ ] Commit: `fix(spec-17-05): update /hk-update cache destination to cache.json (C2)`

---

## Task 4: C3 — installed.json installedCommands `hk` 추가

- [ ] `.harness-kit/installed.json` 의 `installedCommands` 배열에 `"hk"` 추가 (알파벳 순 첫 위치, hk-align 앞)
- [ ] 검증: `jq -r '.installedCommands | length' .harness-kit/installed.json` → 14
- [ ] 검증: `jq -r '.installedCommands | index("hk")' .harness-kit/installed.json` → 숫자
- [ ] Commit: `fix(spec-17-05): add hk to installedCommands manifest (C3)`

---

## Task 5: C4 — queue.md Icebox 매핑 정정

- [ ] `backlog/queue.md:28` — `spec-17-03` → `spec-17-02` (접근성 = 17-02)
- [ ] `backlog/queue.md:30` — `spec-17-02` → `spec-17-03` (internal-reliability = 17-03)
- [ ] 검증: `grep "접근성 개선" backlog/queue.md | grep -q "spec-17-02"` / `grep "installed.json 캐시" backlog/queue.md | grep -q "spec-17-03"`
- [ ] Commit: `fix(spec-17-05): correct queue.md Icebox spec-17-02/03 mapping (C4)`

---

## Task 6: C5 — tests/test-phase17-integration.sh 신규

- [ ] `tests/test-phase17-integration.sh` 작성 (plan.md §C5 시나리오 4 — 1/2/4 PASS + 3 skip)
- [ ] `chmod +x tests/test-phase17-integration.sh`
- [ ] 실행 → 3 passed / 1 skipped
- [ ] Commit: `test(spec-17-05): add tests/test-phase17-integration.sh (3/4 scenarios) (C5)`

---

## Task 7: C6 — CHANGELOG.md [Unreleased] 신설 + phase-17 draft

- [ ] `CHANGELOG.md` 최상단 (`# CHANGELOG` 안내 + `---` 다음, `## [0.9.1]` 앞) 에 `## [Unreleased]` 섹션 신설
- [ ] `Added` / `Fixed` / `Changed` 소제목별 phase-17 4 PR + 본 spec 변경 사항 draft entry
- [ ] 각 항목 끝에 `(#PR번호)` 인용 (#122, #123, #124, #125, #126)
- [ ] 검증: `grep -q "## \[Unreleased\]" CHANGELOG.md` → PASS
- [ ] Commit: `docs(spec-17-05): add [Unreleased] section with phase-17 draft entry (C6)`

---

## Task 8: 회귀 + 통합 검증

- [ ] `bash tests/test-sdd-marker-idempotent.sh` → 3/3 PASS
- [ ] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS
- [ ] `bash tests/test-phase16-integration.sh` → 3/3 PASS
- [ ] `bash tests/test-phase17-integration.sh` → 3 passed / 1 skipped
- [ ] `bash .harness-kit/bin/sdd status` → 정상 + drift 0
- [ ] `git status --porcelain` → 빈 출력 (cleanliness)
- [ ] Commit: 없음 (검증만)

---

## Task 9: Ship

- [ ] **walkthrough.md 작성** — 6 항목 결정 + 검증 + 발견 (phase-review 의 Critical sweep)
- [ ] **pr_description.md 작성** — C1~C6 sweep 요약 + phase-17 phase-ship 진입 안내
- [ ] **Ship Commit**: `docs(spec-17-05): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-17-05-pre-ship-fixes`
- [ ] **PR 생성**: `gh pr create --base phase-17-coherence-fix`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 9 (Pre-flight + 8 실행, Task 8 검증만) |
| **예상 commit 수** | 8 (planning + C1 + C2 + C3 + C4 + C5 + C6 + ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-17 |
