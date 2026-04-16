# Walkthrough: spec-10-004

> 본 문서는 *증거 로그* 입니다.

## 📋 실제 구현된 변경사항

- [x] `_check_phase_all_merged()`: `$5` 필드 비교로 전환, Done 포함 모든 non-Merged 상태 카운트
- [x] `_check_phase_all_merged()`: git 기반 교차 확인 — phase.md non-Merged이지만 git에 모두 머지됨 → 안내
- [x] `compute_next_spec()`: Done 우선 검색 추가 (Done > Backlog)
- [x] `_status_diagnose()`: git 기반 phase done 안내 — non-Merged spec이 있어도 git에 모두 머지됨 → "phase done 가능" 안내
- [x] `.harness-kit/bin/sdd` 도그푸딩 동기화

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-phase-done-accuracy.sh`
- **결과**: ✅ Passed (4/4)
- **로그 요약**:
```text
Check 1: Done 잔류 시 "모든 Merged" 미출력 → ✅ PASS
Check 2: 모든 spec Merged → "모든 Merged" 출력 → ✅ PASS
Check 3: Done + Backlog → NEXT = Done spec → ✅ PASS
Check 4: git 모두 머지 + phase.md Done 잔류 → phase done 안내 → ✅ PASS
```

#### 전체 회귀 테스트
- **명령**: 17개 테스트 파일 전체 실행
- **결과**: ✅ Passed (0 failures)

### 2. 수동 검증

1. **Action**: `sdd status` 실행 (phase-10 base 브랜치에서)
   - **Result**: NEXT가 정확히 다음 처리 필요 spec을 표시

## 🔍 발견 사항

- `-F'|'` + `$0` 패턴 매칭 문제가 `_check_phase_all_merged`와 `compute_next_spec`에도 존재 — `$5` 필드 비교로 전환하여 해결
- `_status_diagnose`에서 git_log_cache를 이미 구축하므로, git 기반 phase done 안내도 같은 캐시 활용

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + ck |
| **작성 기간** | 2026-04-16 |
| **최종 commit** | `9ad56be` |
