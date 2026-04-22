# Walkthrough: spec-13-01

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| doctor 진입점 위치 | 독립 스크립트 vs sdd 서브커맨드 | sdd 서브커맨드 | CLI 일관성 유지, 독립 스크립트 추가 시 install.sh 수정 필요 없이 sdd만 복사하면 됨 |
| gh 미설치 처리 | FAIL vs WARN | WARN (exit 0) | gh는 spec-13-02에서 필수성이 높아지지만 현재는 선택 도구. 차단하면 온보딩 마찰 증가 |
| Check 1 테스트 패턴 | PASS/WARN/FAIL 문자열 | "알 수 없는 명령" 부재 확인 | sdd help 텍스트에 TEST_PASSED 포함되어 오탐 발생 → 반전 패턴으로 수정 |

## 💬 사용자 협의

- **주제**: doctor를 phase-13의 첫 spec으로 진행
  - **사용자 의견**: 발견된 6가지 갭을 phase로 묶어 진행
  - **합의**: spec-13-01 onboarding-doctor부터 순서대로 구현

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-hk-doctor.sh`
- **결과**: ✅ ALL 6 CHECKS PASSED
- **로그 요약**:
```text
═══════════════════════════════════════════
 hk-doctor Verification (spec-13-01)
═══════════════════════════════════════════
  ✅ sdd doctor 명령 인식됨
  ✅ exit code 0
  ✅ hk-doctor.md 존재
  ✅ description frontmatter 포함
  ✅ sdd help에 doctor 포함
  ✅ bash / jq / git 항목 모두 포함
 ✅ ALL 6 CHECKS PASSED
```

#### 전체 테스트 스위트
- **명령**: `for t in tests/test-*.sh; do bash "$t" 2>&1 | tail -1; done`
- **결과**: ✅ 전체 FAIL=0

### 2. 수동 검증

1. **Action**: `bash sources/bin/sdd doctor`
   - **Result**: 필수 도구(bash/jq/git), 선택 도구(gh), 설치 파일, Claude Code 설정, 훅 파일 순서로 체크리스트 출력. bash 3.2 FAIL(시스템 bash) + hooks 디렉토리 WARN(이 repo는 source repo이므로 정상) 출력 확인.

2. **Action**: `bash sources/bin/sdd doctor` exit code 확인
   - **Result**: FAIL 항목 있어도 exit 0 — doctor는 보고 도구로 동작

## 🔍 발견 사항

- `sources/bin/sdd`를 수정하면 `.harness-kit/bin/sdd`도 동기화해야 함 (test-hook-modes.sh Check 5가 감지). 향후 sdd 수정 시 자동 sync 방법 고려 가능.
- macOS 시스템 bash(/usr/bin/bash)는 3.2이므로 harness-kit을 직접 설치한 환경에서는 Homebrew bash 경로 안내가 유용함.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + changsik |
| **작성 기간** | 2026-04-22 |
| **최종 commit** | `947753c` |
