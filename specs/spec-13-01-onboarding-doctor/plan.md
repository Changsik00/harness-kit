# Implementation Plan: spec-13-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-13-01-onboarding-doctor`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `sdd doctor`를 독립 스크립트가 아닌 `sources/bin/sdd` 서브커맨드로 통합하는 방향 동의 여부
> - [ ] `gh` 미설치 시 WARN (exit 0) 처리 — 나중에 FAIL 승격 고려

> [!WARNING]
> - [ ] `sources/bin/sdd`에 `doctor` 서브커맨드 추가 시 `sdd help` 출력도 갱신 필요

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **doctor 진입점** | `sdd doctor` 서브커맨드 | CLI 일관성 유지, 독립 스크립트 추가 불필요 |
| **슬래시 커맨드** | `hk-doctor.md` → `sdd doctor` 호출 지시 | 슬래시 커맨드는 얇은 wrapper, 로직은 CLI에 집중 |
| **gh 처리** | WARN (exit 0) | spec-13-02에서 gh 필수성 증가 예정, 지금은 선택 |
| **FAIL 시 종료** | exit 0 | doctor는 진단 도구, 차단 도구 아님 |

## 📂 Proposed Changes

### [CLI]

#### [MODIFY] `sources/bin/sdd`
`doctor` 서브커맨드 추가. 체크 항목별 함수 구조로 구현:
```text
cmd_doctor() {
  check_tool bash "4.0" "필수"
  check_tool jq "" "필수"
  check_tool git "" "필수"
  check_tool gh "" "선택(WARN)"
  check_file ".harness-kit/installed.json"
  check_file ".harness-kit/agent/constitution.md"
  check_hook_permissions
  check_file ".claude/settings.json"
  print_summary
}
```

#### [MODIFY] `sources/bin/sdd` (help 섹션)
`doctor` 명령 추가:
```text
  doctor                        환경 진단 — 필수 도구/파일/훅 권한 체크리스트 출력
```

### [슬래시 커맨드]

#### [NEW] `sources/commands/hk-doctor.md`
얇은 wrapper. 다음 명령을 실행하고 결과를 사용자에게 출력:
```text
bash .harness-kit/bin/sdd doctor
```

### [테스트]

#### [NEW] `tests/test-hk-doctor.sh`
다음 시나리오를 검증:
1. `sdd doctor` 실행 시 체크리스트 형식 출력 확인
2. `sources/commands/hk-doctor.md` 파일 존재 확인
3. `sdd doctor` 종료 코드가 0인지 확인 (FAIL 있어도 exit 0)
4. `sdd help` 출력에 `doctor` 포함 여부 확인

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-hk-doctor.sh
```

### 수동 검증 시나리오
1. `bash sources/bin/sdd doctor` 실행 → 체크리스트 출력 + 종합 판정 확인
2. `sources/commands/hk-doctor.md` 내용 확인 → sdd doctor 호출 지시 포함 여부
3. `bash sources/bin/sdd help` → `doctor` 항목 포함 여부

## 🔁 Rollback Plan

- 신규 서브커맨드 추가이므로 기존 기능 영향 없음
- 문제 시 `sdd` 파일에서 `doctor` case 제거로 즉시 롤백 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
