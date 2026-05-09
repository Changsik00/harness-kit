fix(doctor): sdd doctor hooks 경로 버그 수정 + 회귀 테스트 추가

## 문제
`sdd doctor` 의 `_check_hooks` 가 `scripts/harness/hooks` 를 하드코딩.
실제 install 경로는 `.harness-kit/hooks/` 이므로 install 후에도 항상 WARN 발생.

## 수정
- `sources/bin/sdd` `_check_hooks` 경로: `scripts/harness/hooks` → `.harness-kit/hooks`
- `tests/test-hk-doctor.sh` Check 6 추가: install 후 hooks WARN 없음 회귀 검증

## 테스트
- `test-hk-doctor.sh`: ✅ PASS 7/7
- `sdd doctor` 실행: ✅ ALL PASS
