# Task List: spec-x-tool-guidance

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: doctor.sh에 품질 도구 점검 섹션 추가

### 1-1. 구현
- [x] 기존 섹션 번호를 `/6` → `/7`로 변경
- [x] `[7/7] 프로젝트 품질 도구` 섹션 추가
- [x] 프로젝트 타입 감지 (package.json / pyproject.toml / go.mod)
- [x] Node.js: test, lint, typecheck 점검 + 안내 메시지
- [x] Python: pytest, linter, type checker 점검 + 안내 메시지
- [x] Go: test (내장 pass), linter 점검 + 안내 메시지
- [x] 감지 불가 시 일반 안내 warn
- [x] `doctor.sh` 실행하여 정상 동작 확인
- [x] Commit: `feat(spec-x-tool-guidance): add project quality tools check to doctor.sh`

---

## Task 2: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 검증 최종 확인
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Archive Commit**: `docs(spec-x-tool-guidance): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-tool-guidance`
- [ ] **PR 생성**: 에이전트가 `gh pr create` 또는 `/hk-pr-gh` 로 생성 (사용자 승인 후)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 2 |
| **예상 commit 수** | 2 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-12 |
