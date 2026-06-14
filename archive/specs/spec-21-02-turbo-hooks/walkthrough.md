# Walkthrough: spec-21-02

## 작업 요약

3 commit: test(TDD Red) → feat(훅 분기) → feat(post-commit-verify + 설정 등록)

## 발견 및 결정

### hook_tool_input 환경변수 방식
테스트 작성 중 `run_hook` 헬퍼에서 훅 파일명을 확장자 없이 호출하는 실수를 발견했다. `check-plan-accept` → `check-plan-accept.sh` 수정 후 T01~T04 올바른 Red 상태 진입.

### T03 spurious pass 방지
초기 T03 설계에서 scope 파일을 `src/allowed.ts` 로 하고 out-of-scope를 `src/not-in-plan.ts`로 설정했더니, `check-scope.sh`가 디렉토리 prefix (`src/`) 매칭으로 통과시키는 문제 발견. `other/out-of-scope.ts` 로 변경하여 정확한 실패 유도.

### auto-revert 방식 선택
`git revert HEAD --no-edit`를 사용. `git reset --hard HEAD~1` 대신 revert를 선택한 이유: revert는 커밋 히스토리에 자국을 남겨 "검증 실패로 롤백했다"는 이력이 명확히 기록됨. settings.json deny 목록에 `git reset --hard` 가 있어 auto-revert 실행 시 hook 차단 우려도 있었으나, post-commit-verify는 Stop 훅이고 deny 목록은 Bash 도구에만 적용되므로 무관함.

### 10분 가드 — 오래된 커밋 보호
Stop 훅은 Claude가 멈출 때마다 실행된다. 지난 세션의 커밋이나 사람이 직접 만든 커밋을 실수로 revert하지 않도록 10분(600초) 가드를 추가했다. T07/T08에서 `git commit` 직후 훅을 실행하므로 age < 600 조건을 항상 만족한다.

### process substitution vs temp file
`while read; done < <(jq ...)` 대신 temp file 방식을 채택했다. bash 3.2에서 process substitution은 사용 가능하지만, mktemp 방식이 macOS `date` 환경과 더 일관성 있다고 판단.

## 검증 결과

```
bash tests/test-turbo-hooks.sh  → PASS=8 FAIL=0
bash tests/test-mode-schema.sh  → PASS=7 FAIL=0
```
