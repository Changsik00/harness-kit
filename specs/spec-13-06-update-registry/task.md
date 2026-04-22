# Task List: spec-13-06

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

- [ ] `git checkout -b spec-13-06-update-registry` (base: phase-13-dx-enhancements)

---

## Task 2: 테스트 작성 (TDD Red)

- [ ] `tests/test-update-registry.sh` 작성 — 5가지 시나리오
- [ ] 테스트 실행 → FAIL 확인
- [ ] Commit: `test(spec-13-06): add failing tests for sdd update-check command`

---

## Task 3: update-registry 구현

- [ ] `install.sh` — 레지스트리 갱신 블록 추가
- [ ] `sources/bin/sdd` — `cmd_update_check()`, case 분기, help 항목
- [ ] `.harness-kit/bin/sdd` 동기화
- [ ] 테스트 전체 PASS 확인
- [ ] Commit: `feat(spec-13-06): add sdd update-check and install registry`

---

## Task 4: Ship

- [ ] 전체 테스트 실행 → FAIL=0
- [ ] walkthrough.md 작성
- [ ] pr_description.md 작성
- [ ] Ship Commit: `docs(spec-13-06): ship walkthrough and pr description`
- [ ] Push: `git push -u origin spec-13-06-update-registry`
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
