# Walkthrough: spec-x-doctor-hooks-path-fix

## 결정 기록
| 이슈 | 결정 | 이유 |
|---|---|---|
| 경로 하드코딩 | `.harness-kit/hooks` 로 단순 수정 | install.sh 가 항상 이 경로에 설치 |

## 발견 사항
- `test-hk-doctor.sh` 가 doctor 실행 여부만 검증하고 WARN 없음은 검증 안 했음 — 회귀 테스트 부재로 출시 이후 지금까지 감지 못함
- `sdd doctor` 를 실제로 실행해보기 전까지 발견되지 않는 전형적 "실행 경로 미검증" 버그

## 메타
| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성일** | 2026-05-09 |
| **최종 commit** | `450a2ae` |
