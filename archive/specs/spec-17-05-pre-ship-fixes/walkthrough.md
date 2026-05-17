# Walkthrough: spec-17-05

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|:---|:---|
| Review Critical 처리 범위 | C1–C4 / C1–C6 전수 / C6 만 | **C1–C6 전수, spec-17-05 한 spec 묶음** | review 의 Critical 은 phase-17 의 *자기 성공 기준* 미달 6 건 — 묶어 ship 1 회로 phase-ship 직전 정리 |
| C5 시나리오 3 (curl install) 자동화 | 포함 / skip | **skip + 명시 표시** | end-to-end 검증은 fixture 디렉토리 + actual curl pipe bash 필요. 본 spec 의 *방어선* 범위 초과 — Icebox |
| C5 시나리오 2 cleanliness 검증 방식 | `git status --porcelain` 빈 출력 / tracked 파일 비변동 + installed.json 캐시 부재 | **tracked 비변동 + installed.json cache 부재** | 첫 시도 (전체 git status) 는 본 테스트 파일 자체가 untracked 일 때 false fail. *cleanliness 의 본질* 은 "hook 이 tracked 파일을 modify 안 함" + "installed.json 에 cache 잔재 없음" — 그 두 점만 직접 검증 |
| C6 [Unreleased] 위치 | 최상단 헤더 직후 / `## [0.9.1]` 직전 / 별 file | **`---` 분리선 다음, `## [0.9.1]` 직전** | 기존 형식 일관 — 다음 release commit 이 같은 위치 stamp |
| C6 draft entry 출처 | 본 phase 만 / 본 spec 포함 / next release tag 까지 | **본 phase + 본 spec 포함 (#122~#126)** | draft 작성 시점이 본 spec 안 — 본 PR (#126 가설) 도 다음 release 에 포함. 다른 entry 와 같은 release commit 에서 stamp |
| C3 hk 위치 | 알파벳 순 / installedCommands 끝 | **알파벳 순 (hk-align 앞)** | install.sh 의 manifest glob 출력 순서 (sources/commands/*.md) 와 일치. 다음 install 결과와 정합 |
| Plan Accept 호출 시점 | 첫 commit hook block 후 / Task 1 전 선제 | **Task 1 전 선제 호출** | spec-17-04 의 마찰점 발견 사항 — `sdd plan accept` 누락 → Task 3 commit 차단 학습. 본 spec 에서는 첫 task 직전에 선제 호출하여 Strict Loop 매끄럽게 |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 6 항목 모두 *기존 결정의 누수 sealing / metadata 정합 / 테스트 신규 / draft 작성*. 새 invariant 박힘 없음. cache.json 분리 자체 (spec-17-03) 가 ADR 후보였으나 본 spec 은 그 결정의 *완수* 만.

## 💬 사용자 협의

- **주제**: phase-ship 전 Critical 처리 범위
  - **사용자 의견**: "C1–C6 전수 — spec-x 묶음으로 처리"
  - **합의**: phase-17 의 5번째 spec (spec-17-05) 로 묶음 — 본 phase 의 자기 success criteria 완수가 목적이라 phase 소속이 spec-x 보다 정합.
- **주제**: Plan Accept
  - **사용자 의견**: "Accept — 실행 시작"
  - **합의**: Task 1 (branch + planning) 부터 자동 진행. 선제 `sdd plan accept` 호출로 spec-17-04 의 hook 차단 마찰 회피.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 검증
- **명령**: 각 변경 항목 grep / jq / diff 검증
- **결과**: ✅ Passed
- **로그**:
```text
- C1: grep "lastVersionCheck\|latestKnownVersion" install.sh update.sh → 0 / 0 hits
- C2: diff sources/commands/hk-update.md .claude/commands/hk-update.md → 0 (sync ok)
       grep "cache.json" 양쪽 1 hit
- C3: jq '.installedCommands | length' .harness-kit/installed.json → 14
       jq '.installedCommands | index("hk")' → 0
- C4: grep "접근성 개선" backlog/queue.md → "spec-17-02" (정확)
       grep "installed.json 캐시" backlog/queue.md → "spec-17-03" (정확)
- C5: bash tests/test-phase17-integration.sh → 3 passed / 1 skipped
- C6: grep "## \[Unreleased\]" CHANGELOG.md → 1 hit + Added/Fixed/Changed 소제목 모두
```

#### 통합 테스트 (phase-17 자체)
- **명령**: `bash tests/test-phase17-integration.sh`
- **결과**: ✅ Passed (3/4, 1 skip)
- **로그**:
```text
  ✓ Scenario 1: Marker 멱등성 (test-sdd-marker-idempotent 3/3 PASS)
  ✓ Scenario 2: 워킹트리 cleanliness (hook 이 tracked 미수정 + installed.json cache 필드 없음)
  - Scenario 3: curl install end-to-end (skip: fixture 환경 필요 — Icebox)
  ✓ Scenario 4: Governance/test grep + phase16 self-test (4 sub-checks PASS)
```

#### 회귀 테스트
- `tests/test-sdd-marker-idempotent.sh` — 3/3 PASS ✓
- `tests/test-drift-stale-adr.sh` — 3/3 PASS ✓
- `tests/test-phase16-integration.sh` — 3/3 PASS ✓
- `sdd status` — drift 0 + 워킹트리 깔끔 ✓

### 2. C5 첫 시도 false fail 후 수정

- **시나리오 2** 의 초기 구현 `git status --porcelain | wc -l == 0` 이 *test 파일 자체가 untracked* 인 시점에 false fail.
- **수정**: hook 실행 *전/후* 의 `git diff --name-only` 비교 + `installed.json` 의 cache 필드 부재 직접 jq 검증.
- **의미**: 테스트가 *cleanliness 의 본질* (tracked 파일 비변동 + 약속한 데이터 부재) 을 검증 — *환경 무관* (untracked 파일 존재 여부 안 탐). 더 정확한 invariant.

## 🔍 발견 사항

- **install.sh 의 cache 필드 작성은 spec-17-03 에서 *발견 못 한 누수*** — spec-17-03 가 hook + sdd 의 read/write 경로만 보고 *install 시점의 초기값* 을 놓침. *변경 영향 범위 탐색* 의 일반화 가능 패턴 — 본 spec 회고가 `/hk-phase-review` 독립 감사로 잡아냄. 회고 자동화의 *직접적 가치 실증*.
- **/hk-update.md 의 cache 안내** — 도구 (sdd / hook) 와 안내 문서 (slash command) 가 SSOT 분리될 때 *문서 drift* 위험. spec-17-03 가 도구 두 곳 (hook, sdd) sync 했으나 *문서* 는 검토 대상 외였음. *문서도 install asset* — 미러 sync 대상에 명시 필요 (별 spec / governance).
- **C3 도그푸딩 매니페스트 stale** — install.sh 의 manifest 생성 로직은 *동적* (glob) 이라 신규 install 자동 정합. 본 저장소 (도그푸딩) 만 stale — `installed.json` 이 *한 번 작성 후 거의 갱신 안 되는* tracked 파일이라 동일 패턴 미래 발생 가능. release commit 시점에 `installedCommands` 재계산 자동화 후보 (별 spec).
- **Plan Accept 선제 호출 효과** — spec-17-04 의 마찰 (Task 3 commit 시 차단) 이 본 spec 에서 Task 1 직전 선제 호출로 즉시 해소. 메모리에 잇몸 자동화 안 됐지만 *작업 패턴* 으로 학습 적용 — 다음 spec 도 동일 패턴 권장.
- **Scenario 2 false fail 학습** — 테스트가 *환경 잡음* (untracked 파일) 에 노출되면 fragile. *invariant 의 본질* 만 직접 검증 (hook 전/후 diff + jq) 하는 게 더 robust.

## 🚧 이월 항목

- **install.sh 의 installedCommands manifest 재계산 자동화** — release commit 시점에 `installedCommands` 를 `sources/commands/*.md` 로부터 재생성하는 release-time hook 또는 sdd subcommand. C3 같은 도그푸딩 매니페스트 stale 재발 방지 — 별 spec.
- **/hk governance/README 표 반영 (review W2/W3)** — 다음 phase.
- **task.md 4 spec 일괄 sweep + check-task-checkbox.sh block 모드 승격 (review W1)** — 다음 phase.
- **CLAUDE.md "현재 단계 Phase 4" 갱신 (review W4)** — 별 FF 또는 다음 phase 시작 시.
- **시나리오 3 (curl install end-to-end) 자동화** — fixture 디렉토리 + actual curl pipe bash + doctor.sh 검증. tests/fixtures/ 안 임시 클론 디렉토리 패턴 — Icebox.
- **cache migration 로직 DRY (review W6)** — hook + sdd 두 곳 동일 migration. 다음 phase 또는 Icebox.
- **stale ADR 검사 isolated run (review W7)** — 진정한 fixture 격리 (temp dir 안 단독 실행). Icebox.
- **slash command (`hk-update.md` 등) install 미러 sync drift 검사 hook** — 본 spec 의 C2 가 만약 sources 만 고치고 .claude/ 미러 안 고쳤다면 silent drift. doctor.sh 의 templates checklist 패턴을 commands 에도 확장 — 별 spec.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-17 |
| **최종 commit** | `c22e20a` (Task 7 — C6 CHANGELOG) — Task 8 검증만 / Task 9 ship 본 commit |
| **총 commit 수** | 8 (planning + C1 + C2 + C3 + C4 + C5 + C6 + ship) |
| **발견 출처** | `/hk-phase-review` 독립 Opus 서브에이전트 회고 (Critical 6 건 + Warning 10 건). 본 spec 은 Critical 만 처리 — Warning 은 이월 항목 / 다음 phase. |
