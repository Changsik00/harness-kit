chore(spec-13-07): bump version 0.5.0 → 0.6.0

## 변경 내용

- `VERSION`: `0.5.0` → `0.6.0`
- `.harness-kit/installed.json`: `kitVersion` → `0.6.0`
- `CHANGELOG.md`: phase-13 변경사항 (doctor, pr-watch, run-test) 0.6.0 항목 추가
- `README.md`: 버전 배지 갱신, `/hk-doctor` 슬래시 커맨드 추가, `sdd doctor` / `sdd pr-watch` / `sdd run-test` 서브커맨드 표 추가

## 테스트

```
tests/test-version-bump.sh — PASS=6 FAIL=0
```

전체 테스트 스위트 FAIL=0 확인.

## 관련 Spec

- spec-13-01: `sdd doctor` / `/hk-doctor` 구현
- spec-13-02: `sdd pr-watch` 구현
- spec-13-03: `sdd run-test` 구현
