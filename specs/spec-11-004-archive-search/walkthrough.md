# Walkthrough: spec-11-004

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| fallback 방식 | 중앙 변수 / 함수별 명시 | 함수별 명시 | active 작업 함수(compute_next_spec 등)에 archive가 개입하면 안 됨 |
| 표시 방식 | 색상만 / 텍스트 마커 | `(archived)` 텍스트 | grep 가능, 색상 없는 환경에서도 구분 |

## 💬 사용자 협의

- **주제**: archive 검색 범위
  - **사용자 비평**: "다음 작업 검색시 문제가 없는지"
  - **합의**: `compute_next_spec`, `cmd_ship`, `spec_new` 등 active 함수는 archive 탐색 제외

## 🧪 검증 결과

### 1. 자동화 테스트

- `bash tests/test-sdd-archive-search.sh`: 11/11 PASS
- `bash tests/test-sdd-ship-completion.sh`: 7/7 PASS
- `bash tests/test-sdd-dir-archive.sh`: 10/10 PASS

### 2. 발견 및 수정

- `C_YEL` 미정의 변수 버그: `common.sh`에는 `C_YLW`만 정의되어 있음. `set -uo pipefail` 환경에서 unbound variable 오류 발생 → `C_YLW`로 수정

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-16 |
| **최종 commit** | `486f2ea` |
