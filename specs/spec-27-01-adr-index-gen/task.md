# Task List: spec-27-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-27-01-adr-index-gen` (base: `phase-27-docs-integrity`)

---

## Task 2: 테스트 작성 (TDD Red)

### 2-1. 실패하는 테스트 작성
- [x] `tests/test-adr-index.sh` 작성 — fixture ADR(2~3개, id/type/date/status + 제목행)로 다음을 검증:
  - `docs/decisions/README.md` 없을 때 `sdd adr-index --check` → exit 1
  - `sdd adr-index` 실행 후 README.md 마커 구간에 fixture ADR 이 번호순으로 테이블 등장
  - 재실행 시 파일 변화 없음(idempotent)
  - 필드 하나를 바꾼 뒤 `--check` → exit 1 (drift 감지)
  - 원복 후 `--check` → exit 0
- [x] 테스트 실행 → Fail 확인 (`adr-index` 명령 미구현이라 실패)
- [x] Commit: `test(spec-27-01): add failing test for adr-index generation`

---

## Task 3: 구현 (TDD Green)

### 3-1. `cmd_adr_index` 구현
- [x] `sources/bin/sdd` 에 `cmd_adr_index()` 추가 (frontmatter 파싱 + 제목행 추출 + 정렬 + bash 라인 루프 기반 마커 치환 + `--check` 모드)
- [x] `case "$cmd"` 디스패치에 `adr-index) cmd_adr_index "$@" ;;` 등록
- [x] `.harness-kit/bin/sdd` 에 동일 변경 미러 (도그푸딩 설치본)
- [x] 테스트 실행 → Pass 확인 (`bash tests/test-adr-index.sh`, `bash tests/run.sh` 79/79)
- [x] Commit: `feat(spec-27-01): implement sdd adr-index generator`

---

## Task 4: 실 데이터 적용

### 4-1. `docs/decisions/README.md` 최초 생성
- [ ] `bash .harness-kit/bin/sdd adr-index` 실행
- [ ] 생성된 `docs/decisions/README.md` 수동 확인 — 기존 9개 ADR 전부 번호순 등장
- [ ] Commit: `docs(spec-27-01): generate docs/decisions/README.md ADR index`

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] **전체 테스트 실행** → 모두 PASS (`bash tests/run.sh`)

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] Commit: `docs(spec-27-01): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-27-01-adr-index-gen`
- [ ] PR 생성 (`gh pr create` 또는 `/hk-pr-gh`, base: `phase-27-docs-integrity`)
