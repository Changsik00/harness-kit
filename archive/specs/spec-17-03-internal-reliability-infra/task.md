# Task List: spec-17-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (sdd spec new — marker fix 정상 동작 ✓ 3 번째 실증)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

- [ ] `git checkout -b spec-17-03-internal-reliability-infra` (from `phase-17-coherence-fix`)
- [ ] `git add backlog/phase-17.md backlog/queue.md specs/spec-17-03-internal-reliability-infra/`
- [ ] Commit: `chore(spec-17-03): add planning artifacts`

---

## Task 2: Cache 분리 (.gitignore + cache.json 설계)

### 2-1. .gitignore + cache.json 분리 준비
- [ ] `.gitignore` 에 `.harness-kit/cache.json` 추가
- [ ] (필요 시) installed.json 의 캐시 필드 수동 제거 + cache.json 생성 시연
- [ ] Commit: `chore(spec-17-03): gitignore cache.json + scaffold cache file`

---

## Task 3: Hook (check-kit-version.sh) cache 분리 + migration

### 3-1. sources/hooks/check-kit-version.sh
- [ ] cache.json 정의 (CACHE_JSON 변수)
- [ ] migration 로직 추가 (installed.json 캐시 필드 있으면 cache.json 으로 이동 + installed.json 정리)
- [ ] read/write 경로 cache.json 으로 전환 (kitVersion / kitOrigin 은 여전히 installed.json)
- [ ] install 미러 sync
- [ ] 수동 검증: hook 실행 → cache.json 생성, installed.json 캐시 필드 부재
- [ ] Commit: `fix(spec-17-03): move cache fields to .harness-kit/cache.json (hook)`

---

## Task 4: sdd `_drift_kit_version` cache 분리

### 4-1. sources/bin/sdd
- [ ] `_drift_kit_version` 함수 (line 285-341) 의 read/write 경로 cache.json 으로 전환
- [ ] install 미러 sync
- [ ] 수동 검증: `sdd status` → 정상 동작 + 워킹트리 clean
- [ ] Commit: `fix(spec-17-03): use cache.json in sdd _drift_kit_version`

---

## Task 5: Phase integration script

### 5-1. tests/test-phase16-integration.sh
- [ ] plan.md §Proposed Changes Fix 2 그대로 작성 (3 시나리오 + trap cleanup)
- [ ] `chmod +x tests/test-phase16-integration.sh`
- [ ] 실행 → 3/3 PASS
- [ ] Commit: `test(spec-17-03): add tests/test-phase16-integration.sh (3 scenarios)`

---

## Task 6: Doctor 확장

### 6-1. doctor.sh templates + dirs checklist
- [ ] templates list (line 81) 에 `rca.md` / `adr.md` 추가
- [ ] dir list (line 67-72 부근) 다음에 optional dirs (docs/rca, docs/decisions) silent skip 분기 추가
- [ ] 실행 → 새 항목 hit + 기존 사용자 (rca/decisions 부재) false negative 0
- [ ] Commit: `feat(spec-17-03): extend doctor.sh checklist for phase-16 artifacts`

---

## Task 7: (선택) sdd_marker_grep helper 일반화

- [ ] 시간 남으면 — helper 가 backtick + plain 두 패턴 매칭. cmd_spec_new 의 우회 분기 단순화
- [ ] 회귀: test-sdd-marker-idempotent.sh PASS 유지
- [ ] Commit (선택): `refactor(spec-17-03): generalize sdd_marker_grep`

---

## Task 8: 회귀 + 통합 검증

- [ ] `bash tests/test-sdd-marker-idempotent.sh` → 3/3 PASS
- [ ] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS
- [ ] `bash tests/test-phase16-integration.sh` → 3/3 PASS
- [ ] `git status --porcelain` → 빈 출력 (cleanliness)
- [ ] `bash doctor.sh` → 신규 항목 hit
- [ ] Commit: 없음 (검증만)

---

## Task 9: Ship

- [ ] **walkthrough.md 작성** — 3 묶음 결정 + 검증 + 발견
- [ ] **pr_description.md 작성** — phase-17 시나리오 2 PASS 명시
- [ ] **Ship Commit**: `docs(spec-17-03): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-17-03-internal-reliability-infra`
- [ ] **PR 생성**: `gh pr create --base phase-17-coherence-fix`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 9 (Pre-flight + 8 실행, Task 7 선택) |
| **예상 commit 수** | 7-8 (planning + .gitignore + hook + sdd + test + doctor + [helper] + ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-17 |
