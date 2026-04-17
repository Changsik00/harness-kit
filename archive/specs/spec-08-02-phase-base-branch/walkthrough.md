# Walkthrough: spec-08-02

> 본 문서는 *증거 로그* 입니다. "무엇을 했고 어떻게 검증했는지" 를 미래의 자신과 리뷰어에게 남깁니다.

## 📋 실제 구현된 변경사항

- [x] `scripts/harness/bin/sdd` — `phase_new()` 에 `--base` 플래그 파싱 추가
- [x] `scripts/harness/bin/sdd` — `baseBranch` 계산 + `state_set baseBranch` 호출 (phase-{N}-{slug} 형식)
- [x] `scripts/harness/bin/sdd` — phase.md 메타 `Base Branch` 필드에 브랜치명 기재
- [x] `scripts/harness/bin/sdd` — `--base` 없을 때 `baseBranch = null` 기본값 설정
- [x] `scripts/harness/bin/sdd` — `phase_done()` 에 `state_set baseBranch "null"` 추가
- [x] `sources/bin/sdd` — 위와 동일 변경 동기화 (diff 검증으로 일치 확인)
- [x] `sources/commands/hk-ship.md` — Step 4 에 phase base branch JIT 생성 명세 추가
- [x] `sources/commands/hk-ship.md` — Step 5-A 에 `--base $PR_BASE` 안내 추가
- [x] `tests/test-sdd-base-branch.sh` — 4종 단위 테스트 작성 (TDD)

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-base-branch.sh`
- **결과**: ✅ Passed (4/4)
- **로그 요약**:
```text
Check 1: sdd phase new slug --base → state.json에 baseBranch 저장
  ✅ PASS: baseBranch = "phase-01-work-model"

Check 2: sdd phase new slug (no --base) → baseBranch = null
  ✅ PASS: baseBranch = null (--base 없을 때 기본값)

Check 3: sdd status --json → baseBranch 키 포함
  ✅ PASS: status --json 출력에 baseBranch 키 존재 (값: phase-01-work-model)

Check 4: sdd phase done → baseBranch = null
  ✅ PASS: phase done 후 baseBranch = null

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  결과: PASS=4  FAIL=0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2. 수동 검증

1. **Action**: fixture에서 `sdd phase new work-model --base` 실행
   - **Result**: state.json에 `"baseBranch": "phase-01-work-model"` 정상 기록

2. **Action**: `sdd status --json` 실행
   - **Result**: `baseBranch` 키가 JSON 출력에 포함됨 (state_dump 통해)

3. **Action**: `sdd phase done` 실행
   - **Result**: `baseBranch` = `null` 으로 초기화됨

4. **Action**: fixture에서 `sdd phase new simple-phase` (no --base) 실행
   - **Result**: `baseBranch` = `null` (기본값 유지)

5. **Action**: `diff scripts/harness/bin/sdd sources/bin/sdd`
   - **Result**: no output (두 파일 완전 일치)

### 3. 증거 자료

- 테스트 스크립트: `tests/test-sdd-base-branch.sh` (4 checks)
- hk-ship 변경: `sources/commands/hk-ship.md` Step 4 + 5-A

## 🔍 발견 사항

- **Fixture lib 경로**: `sdd` 는 `${BASH_SOURCE[0]}` 기준으로 `lib/` 을 찾으므로, fixture 테스트 시 `scripts/harness/lib/` 이 아닌 `scripts/harness/bin/lib/` 에 심링크를 생성해야 함. 이를 `make_fixture()` 헬퍼 함수로 표준화함.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Claude Sonnet 4.6) + Dennis |
| **작성 기간** | 2026-04-11 |
| **최종 commit** | `30ea009` |
