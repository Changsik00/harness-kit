# Task List: spec-x-fix-failing-tests

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: 브랜치 생성
- [x] `git checkout -b spec-x-fix-failing-tests`

---

## Task 1: version-bump — dynamic badge 검증으로 수정
- [x] `tests/test-version-bump.sh` README 리터럴 버전 검사 → `version.json` dynamic badge 검증으로 교체
- [x] `bash tests/test-version-bump.sh` → README check PASS
- [x] Commit: `test(spec-x-fix-failing-tests): verify README version badge not literal`

---

## Task 2: update-stateful + sdd — 폐기 `plan` 잔재 제거
- [x] `.harness-kit/bin/sdd` `cmd_specx_new` scaffold 루프에서 `plan` 제거 + `sources/bin/sdd` 미러
- [x] `tests/test-update-stateful.sh` S5 기대 목록에서 `plan` 제거 (8→7)
- [x] `bash tests/test-update-stateful.sh` → PASS=17 FAIL=0, `diff -q` 미러 동일
- [x] Commit: `fix(spec-x-fix-failing-tests): drop deprecated plan template remnant`

---

## Task 3: wiki-structure — archive-aware 경로 검사
- [x] `tests/test-wiki-structure.sh` `check_sources_paths` 에 `archive/` fallback 추가
- [x] `bash tests/test-wiki-structure.sh` → 70/70 PASS
- [x] Commit: `test(spec-x-fix-failing-tests): resolve archived source paths in wiki check`

---

## Task 4: pr-merge-detect — gh 부재 시뮬레이션 수정
> 발견: guard(sdd line 2514 `command -v gh`)는 이미 존재. 실패 원인은 **테스트 버그** — no-gh PATH 에 `$BASH_DIR`(homebrew = gh 와 동일 디렉토리)를 넣어 gh 가 노출됨. → sdd 변경 불필요, 테스트의 시뮬레이션을 hermetic 하게.
- [x] `tests/test-pr-merge-detect.sh` gh 부재 시뮬레이션을 도구별 심볼릭(gh 만 제외)으로 교체
- [x] `bash tests/test-pr-merge-detect.sh` → 5/5 PASS
- [x] Commit: `fix(spec-x-fix-failing-tests): make gh-absence simulation hermetic in pr merge-detect test`

---

## Task 4.5: 실행 중 발견 항목 (사용자 승인 — 둘 다 포함)
> version-bump 심층 분석에서 (1) Check 6 메타-러너가 진짜 실패 원인, (2) full 모드 전용 5번째 실패(phase17 4c) 표면화.
- [x] `tests/test-version-bump.sh` Check 6 메타-러너 제거 (run.sh 가 오케스트레이터)
- [x] `tests/test-phase17-integration.sh` 4c grep 대상: `CLAUDE.md` → `docs/release-strategy.md` (#135 이동)
- [x] 두 테스트 PASS 확인
- [x] Commit: `fix(spec-x-fix-failing-tests): drop version-bump meta-runner + fix moved CHANGELOG rule path`

---

## Task 5: Ship (필수)

### 🚦 Pre-Push Quality Gate
- [x] `bash tests/run.sh` (full) → **PASS 65 / FAIL 0 / SKIP 0** (5건 전부 해소, 회귀 없음)
- [x] `diff -q .harness-kit/bin/sdd sources/bin/sdd` 동일

### 📝 산출물 작성
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] 빈 scaffold `plan.md` 제거 확인
- [x] Commit: `docs(spec-x-fix-failing-tests): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] `git push -u origin spec-x-fix-failing-tests`
- [x] PR 생성 → https://github.com/Changsik00/harness-kit/pull/196
