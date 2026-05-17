# Walkthrough: spec-x-sdd-version-source-fix

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| kitVersion 읽기 소스 | A) `current.json` 유지 / B) `installed.json`으로 변경 | B | `installed.json`이 git-tracked SSOT. `current.json`은 gitignored라 `update.sh` 우회 시 스테일해짐 |
| `current.json` kitVersion 필드 처리 | A) 필드 제거 / B) 유지 (읽기 소스만 변경) | B | `update.sh`가 `del(.kitVersion)`으로 복원 시 제외하는 현행 패턴 유지. 별도 정리는 후속 spec-x로 가능 |
| 헬퍼 함수 도입 여부 | A) `cmd_version`·`cmd_status` 각각 인라인 / B) `_read_kit_ver()` 헬퍼 추출 | B | 두 곳에서 동일 로직 재사용. 향후 fallback 정책 변경 시 한 곳만 수정 |

## 💬 사용자 협의

- **주제**: 버전 표시 오류 근본 원인 분석
  - **사용자 의견**: `sdd status` 시작 시 0.6.2가 표시되는 이유와 자동 업데이트 권장 기능이 동작하지 않는 배경을 파악해달라 요청
  - **합의**: `current.json`(gitignored) vs `installed.json`(git-tracked) 두 SSOT 분리 문제 확인. 즉각 수정(FF)과 근본 수정(spec-x) 두 단계로 진행하기로 결정
- **주제**: 수정 범위
  - **사용자 의견**: 근본 수정 진행 요청 (SDD-x 추천 승인)
  - **합의**: `sources/bin/sdd` + `.harness-kit/bin/sdd` 동시 수정, `current.json` 필드는 유지

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-version-source.sh`
- **결과**: ✅ PASS=4 FAIL=0

```text
=== test-sdd-version-source ===

T1: installed.json=0.8.0, current.json=0.6.2 → status 헤더 0.8.0
  ✅ PASS: status 헤더에 installed.json 버전(0.8.0) 표시됨
  ✅ PASS: current.json 버전(0.6.2) 미표시 확인

T2: installed.json=0.8.0, current.json=0.6.2 → sdd version 0.8.0
  ✅ PASS: sdd version 에 installed.json 버전(0.8.0) 표시됨

T3: installed.json 없음 → sdd status 헤더 '?'
  ✅ PASS: installed.json 없을 때 '?' fallback 정상

결과: PASS=4  FAIL=0
```

### 2. 수동 검증

1. **Action**: `bash .harness-kit/bin/sdd status --brief`
   - **Result**: `harness-kit 0.8.0 | phase=none spec=spec-x-sdd-version-source-fix branch=spec-x-sdd-version-source-fix plan=true` — 올바른 버전 표시 확인

2. **Action**: 도그푸딩 인스턴스의 `current.json` kitVersion=0.6.2인 상태에서 `sdd status` 실행 (이 이슈의 원인 재현)
   - **Result**: 수정 전에는 0.6.2 표시. 수정 후 `installed.json`(0.8.0) 기준으로 0.8.0 표시 확인

## 🔍 발견 사항

- `current.json`의 `kitVersion` 필드는 이제 읽히지 않으므로 사실상 레거시. 추후 `update.sh`의 `del(.kitVersion)` 제외 패턴도 정리 가능 (별도 spec-x 후보)
- `_drift_kit_version()`은 이미 `installed.json` 기준으로 동작 중이므로 업데이트 알림 자체는 영향 없음

## 🚧 이월 항목

- `current.json`의 `kitVersion` 필드 및 `update.sh`의 `del(.kitVersion)` 패턴 정리 → 향후 필요시 spec-x로 추진

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + changsik |
| **작성 기간** | 2026-05-12 ~ 2026-05-12 |
| **최종 commit** | `8d1fd0c` |
