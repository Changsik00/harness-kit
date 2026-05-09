# Walkthrough: spec-x-output-ux

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 상대경로 변환 방법 | `realpath --relative-to`, sed, `${var#prefix}` | `${var#$SDD_ROOT/}` | bash 3.2+ POSIX 파라미터 확장 — 외부 의존 없음 |
| doctor 표 정렬 | printf + ANSI 색 동시 사용 | 이름은 `printf "%-38s"` 패딩, 상태는 별도 `printf` | ANSI 코드가 `%s` 너비 계산을 깨뜨리므로 분리 필요 |
| installed 파일 동기화 | update.sh 자동 실행 vs 수동 cp | 수동 cp + git add -f | 테스트(`test-governance-dedup`, `test-hook-modes`)가 sources↔installed 정합성 검사하므로 수동 동기화 필수 |
| agent.md §8 언어 | 한국어 | 영어 | constitution/agent.md 4개 파일은 영어 전용 규칙 적용 |

## 💬 사용자 협의

- **주제**: 출력 UX 범위 결정
  - **사용자 의견**: 상대경로 + 이모지 + 표 포맷 + agent.md 규칙화
  - **합의**: 3개 영역으로 분리 (sdd 경로, doctor.sh 포맷, agent.md §8)

## 🧪 검증 결과

### 수동 검증

1. `bash .harness-kit/bin/sdd specx new ux-test` → `specs/spec-x-ux-test` (상대경로 확인)
2. `bash doctor.sh .` 섹션 6 → printf 컬럼 표 출력 확인
3. `bash tests/test-governance-dedup.sh` → PASS (초기 agent.md 불일치 → installed 파일 동기화 후 PASS)
4. `bash tests/test-hook-modes.sh` → PASS (sources/sdd 수정 후 .harness-kit/sdd cp로 동기화)

### 전체 테스트 결과

- `test-governance-dedup.sh`: ✅ PASS
- `test-hook-modes.sh`: ✅ PASS (동기화 후)
- `test-hk-doctor.sh`: ✅ PASS
- `test-git-precommit-hook.sh`: ✅ PASS
- `test-install-settings-hook.sh`: ✅ PASS
- `test-install-layout.sh`: ✅ PASS
- `test-update.sh`, `test-update-stateful.sh`: ✅ PASS
- `test-sdd-*` (11개): ✅ PASS

## 🔍 발견 사항

- `cp sources/bin/sdd .harness-kit/bin/sdd` 만으로는 `test-hook-modes.sh`가 실패함 — git add도 필요했음 (git이 `.harness-kit/`을 gitignore하지만 이미 tracked 파일은 `git add -f`로 스테이징 가능)
- `doctor.sh` 섹션 6은 기존에 PASS/FAIL/WARN 카운터를 `check_pass/warn/fail` 함수로 관리했는데, 표 포맷으로 전환하면서 직접 `PASS=$((PASS+1))` 패턴으로 변경 — 동작은 동일하지만 함수 추상화 레이어가 하나 빠짐. 향후 check_* 함수 시그니처 변경 시 주의.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 |
| **최종 commit** | `df586d3` |
