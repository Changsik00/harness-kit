# Task List: spec-13-04

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

- [ ] `git checkout -b spec-13-04-context-refresh` (base: phase-13-dx-enhancements)

---

## Task 2: 테스트 작성 (TDD Red)

- [ ] `tests/test-context-refresh.sh` 작성 — 6가지 시나리오:
  - `context-refresh.sh` 파일 존재 + 실행 권한 확인
  - 실행 시 `toolCallCount` 증가 확인
  - 인터벌 도달 전 stdout/stderr 출력 없음 확인
  - 인터벌 도달 시 `sdd status` 출력 포함 확인
  - `settings.json.fragment`에 PostToolUse 항목 포함 확인
  - `.claude/settings.json`에 PostToolUse 항목 포함 확인
- [ ] 테스트 실행 → FAIL 확인
- [ ] Commit: `test(spec-13-04): add failing tests for context-refresh hook`

---

## Task 3: context-refresh 훅 구현

- [ ] `sources/hooks/context-refresh.sh` 작성 — toolCallCount 증가, 인터벌 도달 시 sdd status 출력
- [ ] `sources/claude-fragments/settings.json.fragment`에 PostToolUse 섹션 추가
- [ ] `.claude/settings.json`에 PostToolUse 섹션 추가 (dogfooding)
- [ ] `.harness-kit/hooks/context-refresh.sh` 동기화
- [ ] 테스트 전체 PASS 확인
- [ ] Commit: `feat(spec-13-04): add context-refresh PostToolUse hook`

---

## Task 4: Ship

- [ ] 전체 테스트 실행 → FAIL=0
- [ ] walkthrough.md 작성
- [ ] pr_description.md 작성
- [ ] Ship Commit: `docs(spec-13-04): ship walkthrough and pr description`
- [ ] Push: `git push -u origin spec-13-04-context-refresh`
- [ ] PR 생성 (→ phase-13-dx-enhancements)
- [ ] 사용자 알림 완료

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (+ Pre-flight + Ship) |
| **예상 commit 수** | 2 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-22 |
