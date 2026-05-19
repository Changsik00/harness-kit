# Walkthrough: spec-x-rootdir-device-fix

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| `rootDir` 제거 방식 | (A) 무시만 / (B) config에서도 제거 | B | 근본 원인 차단 — 기존 설치본은 하위 호환으로 무시 |
| TDD Red 조건 설계 | `spec/` 섹션 표시 vs 버전 문자열 | 버전 문자열 | `has_state=1`이면 specs 섹션 미출력 — 버전이 더 안정적 discriminator |
| Task 3에 sdd sync 포함 | 별도 spec-x vs 번들 | 번들 | check-branch.sh와 같은 커밋에 포함이 간결 |

### ADR 승격 가이드

- [x] ADR 승격 대상 있음 → 후보: `sdd-root-detection-anchor` — 파일시스템 앵커링 전략 채택 이유 (type: decision). 6개월 이상 유지, 후속 spec 의존 가능성 있음. (이번 PR 범위 외 — 향후 작성)

## 💬 사용자 협의

- **주제**: `harness.config.json`이 git 추적 상태일 때 `rootDir` 절대경로의 다중 디바이스 크리티컬섹션
  - **사용자 의견**: 팀 환경에서 실제로 발생하는 크리티컬섹션임을 지적
  - **합의**: `sdd_find_root()`를 파일시스템 앵커링으로 교체 + `install.sh`에서 `rootDir` 기록 제거

## 🧪 검증 결과

### 1. 자동화 테스트

#### `tests/test-sdd-root-detection.sh` (신규)
- **결과**: ✅ ALL PASS (4/4)
- **시나리오**:
  - A: 존재하지만 엉뚱한 rootDir → 올바른 루트(FIXTURE_A) 사용 확인
  - B: rootDir 없는 config → 정상 루트 탐지
  - C: 존재하지 않는 rootDir → fallback 정상

#### `tests/test-path-config.sh`
- **결과**: ✅ ALL PASS (10/10)
- **핵심**: rootDir 필드가 install 후 harness.config.json에 존재하지 않음 확인

#### `tests/test-hook-modes.sh`
- **결과**: ✅ ALL PASS (12/12)
- **발견**: sources/bin/sdd ↔ .harness-kit/bin/sdd 드리프트 감지 (spec-18-01 이후 미반영) → 이번 커밋에서 sync

### 2. 수동 검증

1. **Action**: 잘못된 rootDir(WRONG_ROOT) 주입 후 `sdd status` 실행
   - **Result**: (수정 전) `harness-kit ?` — WRONG_ROOT 사용 확인. (수정 후) `harness-kit 0.13.0` — FIXTURE_A 정상 사용

## 🔍 발견 사항

- `sdd status`의 `📁 specs/` 섹션은 `has_state=0`일 때만 출력됨 — install.sh가 `current.json`을 초기 생성하므로 fresh install 직후에도 `has_state=1`. 테스트 설계 시 주의 필요.
- `sources/bin/sdd` ↔ `.harness-kit/bin/sdd` 동기화가 릴리스 단위로 수동 관리됨 — update.sh 실행 없이 이미 드리프트 발생 가능. 자동화 고려 대상.

## 🚧 이월 항목

- 기존 설치본 `harness.config.json`에서 `rootDir` 자동 제거 → `update.sh` 연동 (Icebox)
- `sdd-root-detection-anchor` ADR 작성 (향후 spec-x)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + changsik |
| **작성 기간** | 2026-05-19 |
| **최종 commit** | `4eac4a9` |
