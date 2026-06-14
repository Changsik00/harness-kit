# Task List: spec-x-drift-stale-adr-glob

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: glob 오탐 수정 (TDD)

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-drift-stale-adr-glob`

### 1-2. 테스트 작성 (TDD Red)
- [x] `tests/test-drift-stale-adr.sh` 에 glob fixture 케이스 추가: glob 패턴(`docs/wiki/*.md`)만 포함한 ADR fixture 가 stale 로 잡히지 않아야 함
- [x] `bash tests/test-drift-stale-adr.sh` 실행 → Fail 확인 (실 ADR-003 오탐으로 Step 1 부터 실패)
- [x] Commit: `test(spec-x-drift-stale-adr-glob): add failing case for glob false positive`

### 1-3. 구현 (TDD Green)
- [x] `_drift_stale_adr()` 토큰 필터에 glob 메타문자(`*`,`?`) 제외 추가: `.harness-kit/bin/sdd` + `sources/bin/sdd` (byte-identical)
- [x] `bash tests/test-drift-stale-adr.sh` 실행 → 전체 Pass 확인
- [x] `diff -q .harness-kit/bin/sdd sources/bin/sdd` → 동일 확인
- [x] Commit: `fix(spec-x-drift-stale-adr-glob): exclude glob tokens from stale ADR check`

---

## Task 2: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [x] `bash tests/test-drift-stale-adr.sh` → PASS
- [x] `HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status` → `stale ADR` 라인 없음 확인

### 📝 산출물 작성

- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] Commit: `docs(spec-x-drift-stale-adr-glob): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-x-drift-stale-adr-glob`
- [ ] PR 생성 (`gh pr create` 또는 `/hk-pr-gh`)
