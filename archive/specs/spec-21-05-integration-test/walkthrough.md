# Walkthrough: spec-21-05

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| S4 케이스 수 | S4 단일 vs S4-a/S4-b 분리 | 두 개 분리 | check-plan-accept와 check-scope는 독립 훅 — 각각 명시적으로 검증 |
| `tests/run.sh` 포함 여부 | spec 별도 vs spec-21-05 포함 | 이 spec에 포함 | phase-21 Done 조건에 `run.sh` 명시됨, 1 commit 규모 |
| run.sh 기존 실패 처리 | 실패 무시 / 문서화 | 문서화 (walkthrough 기록) | 실패가 turbo 관련인지만 판별하면 됨 — pre-existing 실패는 별도 spec |
| S2 revert 검증 방법 | 출력 메시지 grep vs commit 수 비교 | commit 수 비교 | 메시지는 locale/format에 따라 변할 수 있음 — git 상태 변화가 더 신뢰도 높음 |

### ADR 승격 가이드

- [ ] 없음 — 통합 테스트 전략은 walkthrough로 충분

## 💬 사용자 협의

없음 — 계획대로 진행.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 통합 테스트 (spec-21-05)
- **명령**: `bash tests/test-turbo-mode.sh`
- **결과**: ✅ Passed (5/5)
- **로그 요약**:
```text
=== test-turbo-mode (integration) ===
S1: sdd mode turbo 활성화 → check-plan-accept 통과
  ✅ PASS: S1: sdd mode turbo → check-plan-accept 무차단
S2: turbo + intent.test FAIL → post-commit-verify revert
  ✅ PASS: S2: intent.test FAIL → revert commit 생성 (before=2 after=3)
S3: sdd mode turbo → governed 복귀 → check-plan-accept 차단
  ✅ PASS: S3: governed 복귀 → check-plan-accept 차단 재활성화
S4: governed 기본 → check-plan-accept/check-scope 정상 차단 (회귀)
  ✅ PASS: S4-a: governed 기본 → check-plan-accept 차단
  ✅ PASS: S4-b: governed 기본 → check-scope 이탈 차단
=== 결과: PASS=5 FAIL=0 ===
```

#### 전체 테스트 (`tests/run.sh`)
- **명령**: `bash tests/run.sh`
- **결과**: PASS 57 / FAIL 6 — **Turbo 관련 0 실패**
- **실패 항목 분석**: 6개 모두 phase-21 이전부터 존재하는 pre-existing 이슈
  - `test-drift-stale-adr`: 실제 환경 stale ADR-003 픽스처 격리 문제
  - `test-phase16-integration`: 동일 원인
  - `test-phase17-integration`: CLAUDE.md CHANGELOG 룰 검사 (pre-existing)
  - `test-pr-merge-detect`: 실제 `gh` 설치 환경에서 "미설치" 케이스 불일치
  - `test-version-bump`: README.md에 최신 버전 없음
  - `test-wiki-structure`: archive된 spec walkthrough 경로 불일치

### 2. 수동 검증

1. **Action**: `bash tests/test-turbo-mode.sh`
   - **Result**: 5/5 PASS — S1(happy path), S2(auto-revert), S3(governed 복귀), S4-a/b(회귀) 모두 통과

2. **Action**: `bash tests/test-turbo-hooks.sh`
   - **Result**: 8/8 PASS — 회귀 없음

## 🔍 발견 사항

- `tests/run.sh` 실행으로 기존에 숨어있던 6개 pre-existing 실패가 수면 위로 올라옴 — 별도 spec으로 순차 처리 필요 (Icebox에 캡처)
- S2 시나리오에서 `revert commit 생성` 을 commit 수 증가로 검증하는 패턴이 안정적 — 향후 비슷한 auto-revert 테스트에 재사용 가능

## 🚧 이월 항목

- `test-drift-stale-adr` / `test-phase16-integration` ADR 경로 픽스처 격리 수정 → Icebox
- `test-wiki-structure` sources 경로 archive 이동 후 갱신 → Icebox
- `test-pr-merge-detect` gh 설치 환경 처리 → Icebox
- `test-version-bump` README 버전 자동화 → Icebox

## 🔗 관련 문서

- 관련 spec: `specs/spec-21-01-mode-schema/`, `specs/spec-21-02-turbo-hooks/`, `specs/spec-21-03-intent-block/`, `specs/spec-21-04-governance-update/`
- 관련 phase: `backlog/phase-21.md`

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-06-13 |
| **최종 commit** | `b6ea822` |
