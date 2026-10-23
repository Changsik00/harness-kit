# Task List: spec-30-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 1: 마커 파서 + `hooks-defaults` 검증기

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-30-02-wiki-knowledge-lint`

### 1-2. 테스트 (Red)
- [x] `tests/test-wiki-verify.sh` 작성 — Case 1~5, 8 (일치 침묵 / 기본값 변경 감지 / 표에 없는 hook / 마커 아래 표 없음 / 알 수 없는 키 / wiki 없음 침묵). fixture 는 임시 repo 에 hook 선언 파일 + wiki 페이지 구성
- [x] 실행 → Fail 확인
- [x] Commit: `test(spec-30-02): add failing test for hooks-defaults verification`

### 1-3. 구현 (Green)
- [x] `sources/bin/sdd` 에 `_wiki_verify_report` + `_wiki_verify_hooks_defaults` + 키 레지스트리 추가 → 사본 `cp`
- [x] 테스트 Pass → Commit: `feat(spec-30-02): verify wiki hook table against hook declarations`

---

## Task 2: `path-exists` + 크기 상한

### 2-1. 테스트 (Red)
- [x] Case 6 (존재하지 않는 `sources:` 경로), Case 7 (크기 상한 초과) 추가 → Fail
- [x] Commit: `test(spec-30-02): add failing test for path-exists and size cap`

### 2-2. 구현 (Green)
- [x] frontmatter `sources:`/`covers:` 파서 + 경로 존재 검사, 크기 상한 검사 추가 → 사본 `cp`
- [x] Pass → Commit: `feat(spec-30-02): check wiki source paths and page size caps`

---

## Task 3: doctor / status 연결 + 본 저장소 실측

### 3-1. 테스트 (Red)
- [x] Case 9 (본 저장소 실측 0건), doctor 출력에 W-5 노출 확인 케이스 추가 → Fail (연결 전)
- [x] Commit: `test(spec-30-02): add failing test for doctor wiring and repo measurement`

### 3-2. 구현 (Green)
- [x] doctor wiki layer 에 W-5 추가, `_status_diagnose` 연결 → 사본 `cp`
- [x] 본 저장소 첫 실행에서 불일치가 나오면 **문서(hooks.md)를 코드에 맞게 정정**
- [x] Pass → Commit: `feat(spec-30-02): wire wiki fact verification into doctor and status`

---

## Task 4: 신선도 신호 A 교정 + 문구 격하

### 4-1. 테스트 (Red)
- [x] Case 10 (components 에만 언급된 ADR 은 미반영 아님) 추가, `tests/test-wiki-freshness.sh` 를 새 정의에 맞게 조정 → Fail
- [x] Commit: `test(spec-30-02): add failing test for freshness signal A over whole wiki`

### 4-2. 구현 (Green)
- [x] `_wiki_freshness_report` 신호 A 대상을 `docs/wiki/` 전체(index.md 제외)로, 출력 문구를 "(보조)" 로 → 사본 `cp`
- [x] Pass → Commit: `fix(spec-30-02): search whole wiki for ADR mentions in freshness check`

---

## Task 5: `/hk-wiki-lint` 커맨드 + schema Lint 절

### 5-1. 테스트 (Red)
- [x] `test-wiki-verify.sh` 에 계약 케이스 추가: 커맨드 원본·사본 존재/동일, 5개 점검 항목 문구, "수정 금지(보고서만)" 문구, schema.md Lint 절에 역할 분담 문구 → Fail
- [x] Commit: `test(spec-30-02): add failing test for wiki-lint command contract`

### 5-2. 구현 (Green)
- [x] `sources/commands/hk-wiki-lint.md` 작성 → `.claude/commands/` 사본, `schema.md` Lint 절 개정
- [x] `doctor.sh`/설치 목록에 커맨드 등록이 필요한지 확인(예: 커맨드 목록 테스트 `test-uninstall-cmd-list`) 후 반영
- [x] 전체 `bash tests/run.sh` PASS → Commit: `feat(spec-30-02): add hk-wiki-lint semantic lint command`

---

## Task 6: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [x] **전체 테스트 실행** → 모두 PASS
- [x] `sdd doctor` 사실 검증 불일치 0건 확인
- [x] 수동 검증: 임시 복사본에서 hook 기본값 변경 → W-5 경고, `/hk-wiki-lint` 실행 결과 확인

### 📝 산출물 작성

- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] Commit: `docs(spec-30-02): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-30-02-wiki-knowledge-lint`
- [ ] PR 생성 (`gh pr create --base phase-30-wiki-as-knowledge`)
