# Implementation Plan: spec-13-03

## 📋 Branch Strategy

- 신규 브랜치: `spec-13-03-test-auto-record`
- 시작 지점: `phase-13-dx-enhancements` (phase base branch)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `sdd run-test <cmd>` wrapper 방식 동의 여부 (PostToolUse hook 방식 아님)
> - [ ] exit code 0 = 자동 기록 / non-0 = 기록 없음 방식 동의 여부

> [!NOTE]
> - PostToolUse hook 방식은 도구 출력 파싱이 필요해 false positive 위험이 높음 → 제외
> - wrapper 방식은 exit code 기반이므로 신뢰성 높음

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **감지 방식** | exit code 기반 | 패턴 매칭보다 신뢰성 높음, false positive 없음 |
| **구현 위치** | `sources/bin/sdd` run-test 서브커맨드 | CLI 일관성, 독립 스크립트 불필요 |
| **stdout/stderr** | passthrough | 테스트 출력이 그대로 터미널에 보임 |
| **실패 처리** | exit code 그대로 전달 | 에이전트가 실패를 인지해 수정 가능 |

## 📂 Proposed Changes

### [CLI]

#### [MODIFY] `sources/bin/sdd`
`run-test` 서브커맨드 추가:
```text
cmd_run_test() {
  if [ $# -eq 0 ]; then
    # 사용법 출력 + exit 0
  fi
  # cmd 실행 (stdout/stderr passthrough)
  set +e; "$@"; local code=$?; set -e
  if [ "$code" -eq 0 ]; then
    cmd_test "passed"        # sdd test passed 자동 호출
    printf "✅ 테스트 통과 기록됨\n"
  fi
  return $code
}
```

#### [MODIFY] `sources/bin/sdd` (help 섹션)
```text
  run-test <cmd...>             테스트 실행 + 통과 시 자동으로 sdd test passed 기록
```

### [테스트]

#### [NEW] `tests/test-test-auto-record.sh`
1. `sdd run-test` 인자 없이 실행 → 사용법 안내 + exit 0
2. `sdd help`에 `run-test` 포함 확인
3. exit 0 명령 실행 → `lastTestPass` 갱신 확인
4. exit 1 명령 실행 → `lastTestPass` 갱신 안 됨 확인
5. `sources/bin/sdd` ↔ `.harness-kit/bin/sdd` 동기화 확인

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-test-auto-record.sh
```

### 수동 검증 시나리오
1. `bash sources/bin/sdd run-test` → 사용법 안내 출력
2. `bash sources/bin/sdd run-test bash tests/test-hk-doctor.sh` → 통과 후 lastTestPass 갱신 확인
3. `bash sources/bin/sdd run-test false` → exit 1, lastTestPass 갱신 안 됨

## 🔁 Rollback Plan

- 신규 서브커맨드 추가이므로 기존 기능 영향 없음
- 문제 시 sdd에서 `run-test` case 제거로 즉시 롤백

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
