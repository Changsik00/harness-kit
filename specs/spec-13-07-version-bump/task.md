# Task List: spec-13-07

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-13.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-13-07-version-bump` (base: phase-13-dx-enhancements)

---

## Task 2: 테스트 작성 (TDD Red)

- [ ] `tests/test-version-bump.sh` 작성 — 4가지 시나리오:
  - `VERSION` 파일에 `0.6.0` 포함 확인
  - `sdd version` → `0.6.0` 출력 확인
  - `CHANGELOG.md` 존재 + `0.6.0` 포함 확인
  - 전체 테스트 스위트 FAIL=0 확인
- [ ] 테스트 실행 → FAIL 확인
- [ ] Commit: `test(spec-13-07): add failing tests for version 0.6.0`

---

## Task 3: 버전 bump 실행

- [ ] `VERSION` → `0.6.0`
- [ ] `.harness-kit/installed.json` kitVersion → `0.6.0`
- [ ] `CHANGELOG.md` 작성
- [ ] 테스트 전체 PASS 확인
- [ ] Commit: `chore(spec-13-07): bump version 0.5.0 → 0.6.0`

---

## Task 4: Ship

- [ ] 전체 테스트 실행 → FAIL=0
- [ ] walkthrough.md 작성
- [ ] pr_description.md 작성
- [ ] Ship Commit: `docs(spec-13-07): ship walkthrough and pr description`
- [ ] Push: `git push -u origin spec-13-07-version-bump`
- [ ] PR 생성 (→ phase-13-dx-enhancements)
- [ ] 사용자 알림 완료

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (+ Pre-flight + Ship) |
| **예상 commit 수** | 2 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-23 |
