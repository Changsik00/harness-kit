# Task List: spec-x-sdd-search

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new sdd-search`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-sdd-search` (main 에서 분기)
- [ ] Commit: 없음

---

## Task 2: SDD 산출물 commit

### 2-1. SDD 산출물 commit
- [ ] `git add specs/spec-x-sdd-search/spec.md specs/spec-x-sdd-search/plan.md specs/spec-x-sdd-search/task.md`
- [ ] Commit: `docs(spec-x-sdd-search): add spec/plan/task`

---

## Task 3: `sdd search` 테스트 작성 (TDD Red)

### 3-1. fixture 헬퍼 + T1~T7 시나리오
- [ ] `tests/test-sdd-search.sh` 작성
  - fixture: `make_fixture` (헬퍼 lib 활용 또는 인라인) — `specs/`, `archive/specs/`, `docs/decisions/`, `docs/rca/`, `backlog/` 생성 + 시나리오별 콘텐츠 주입
  - T1: 전체 scope, archive 매치 → 그룹 헤더 + 매치 라인
  - T2: 매치 없음 → exit 1 + "검색 결과 없음"
  - T3: `--scope=decisions` 만 → 다른 그룹 헤더 없음
  - T4: `--ignore-case` 매치
  - T5: regex `"foo|bar"` 매치
  - T6: 인자 없음 → die
  - T7: invalid scope → die
- [ ] `bash tests/test-sdd-search.sh` 실행 → 7 시나리오 모두 FAIL 확인 (sdd search 미구현)
- [ ] Commit: `test(spec-x-sdd-search): add failing tests for sdd search wrapper`

---

## Task 4: `sdd search` 구현 (TDD Green)

### 4-1. 함수 + dispatcher
- [ ] `sources/bin/sdd` 도움말에 `search` 한 줄 추가
- [ ] `sources/bin/sdd` dispatcher 에 `search) cmd_search "$@" ;;` 추가
- [ ] `cmd_search` + `_search_dispatch` + `_search_in` + `_print_group` 함수 추가
- [ ] `.harness-kit/bin/sdd` 동기화 (도그푸딩)
- [ ] `bash tests/test-sdd-search.sh` 실행 → 7 시나리오 모두 PASS 확인
- [ ] Commit: `feat(spec-x-sdd-search): add sdd search wrapper`

---

## Task 5: 회귀 검증

### 5-1. 기존 테스트 무회귀
- [ ] `bash tests/test-sdd-config.sh` PASS
- [ ] `bash tests/test-sdd-archive-search.sh` PASS
- [ ] `bash tests/test-governance-dedup.sh` cp 정합성 PASS (Check 3 — `sources/bin/sdd` ↔ `.harness-kit/bin/sdd`)
- [ ] Commit: 없음 (검증만)

---

## Task 6: Ship

> 모든 작업 task 완료 후 ship 절차.

- [ ] `bash .harness-kit/bin/sdd test passed` 기록
- [ ] **walkthrough.md 작성** (lat.md 참조 / 의도적 미포함 사항 / `find -exec` vs xargs 결정 등)
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-sdd-search): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-sdd-search`
- [ ] **PR 생성**: `gh pr create` (no-confirm)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 5 (Task 1 브랜치 + Task 2~4 = 3 commits + Task 6 ship = 1 commit) |
| **현재 단계** | Planning (Plan Accept 대기) |
| **마지막 업데이트** | 2026-05-17 |
