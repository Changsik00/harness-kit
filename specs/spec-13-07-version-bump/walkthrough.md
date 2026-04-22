# Walkthrough: spec-13-07

## 발견 사항

`sdd version` 이 `VERSION` 파일이 아니라 `.claude/state/current.json`의 `kitVersion` 필드를 읽는다는 점이 예상과 달랐다. `installed.json`만 바꾸면 되는 줄 알았는데, `current.json`도 별도로 업데이트해야 했다. 테스트가 이 누락을 잡아줬다 (Check 2 Red).

## 기술 결정

- `VERSION` 파일, `installed.json`, `current.json` 세 곳을 모두 업데이트. `current.json`은 gitignore 대상이라 python3로 직접 수정.
- README.md에 추가한 `sdd doctor`, `sdd pr-watch`, `sdd run-test` 세 항목은 각각 spec-13-01/02/03에서 구현됨 — 같은 phase 내 변경이므로 함께 문서화.
- CHANGELOG 0.6.0 항목은 각 spec 참조 링크(→ phase-13, spec-13-NN) 형식으로 추적성 확보.

## 테스트 설계

전체 스위트를 통합하는 Check 6에서 `tail -1` 패턴이 구분선(`═══...`)을 잡아 오탐 발생. exit code 기반으로 수정하여 해결.
