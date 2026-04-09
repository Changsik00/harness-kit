# Task List: Spec-XXX

## Progress
- [ ] Spec 번호 확정 및 브랜치 생성
- [ ] spec.md 작성
- [ ] plan.md 작성
- [ ] task.md 작성
- [ ] 백로그 업데이트 (Note 추가)
- [ ] User Plan Accept

---

## Task 1: <Korean Title>
### 1-1. TDD Warming up
- [ ] Test Case 작성: `src/modules/xxx/xxx.service.spec.ts`
- [ ] Test 실행 (Fail): `npm test -- xxx.service`
- [ ] Commit: `test(spec-xxx): add test case for ...`

### 1-2. Implementation
- [ ] 코드 구현: `src/modules/xxx/xxx.service.ts`
- [ ] Test 실행 (Pass): `npm test -- xxx.service`
- [ ] Commit: `feat(spec-xxx): implement ...`

---

## Task N: Archiving & Hand-off (Mandatory)
<!-- 이 단계는 모든 작업 완료 후 수행합니다. -->
- [ ] Code Quality Check: `npm run lint`
- [ ] Run Full Tests: `npm test`
- [ ] **Walkthrough 작성**: `specs/XXX/walkthrough.md`
- [ ] **PR Description 작성**: `specs/XXX/pr_description.md` (템플릿 준수)
- [ ] **Archive Commit**: 위 파일을 `specs/`에 커밋 (`docs(spec-xxx): archive walkthrough and pr description`)
- [ ] **Push Feature Branch**: `git push -u origin feature/XXX-<name>` (PR 생성은 사용자가 hosted git UI에서 수행)
- [ ] **Notify User**: 푸시 완료 및 리뷰 요청 알림

## Summary
**총 Task**: X개  
**예상 커밋 수**: Y개  
**현재 진행**: Planning / Execution / Verification
