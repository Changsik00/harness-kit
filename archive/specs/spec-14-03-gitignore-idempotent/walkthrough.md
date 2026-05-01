# Walkthrough: spec-14-03

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 멱등 처리의 단위 | A: 헤더 grep + 일괄 추가 (기존) / B: 4 라인 각각 라인별 grep | **B** | 헤더 누락 / 사전 라인 / 라인 일부 누락 케이스 모두 보강 |
| `_gi_ensure()` 헬퍼 위치 | A: install.sh 내부 블록 스코프 / B: sources/install/lib/*.sh 분리 | **A** | 단일 사용처 — 별도 디렉토리 신규 도입은 over-engineering |
| `.harness-kit/` ↔ `!.harness-kit/` 토글 처리 | A: sed 변환 후 ensure / B: 양쪽 모두 grep + 분기 | **A** | 토글 시 sed 가 한 번에 변환 → ensure 가 부재 시만 추가. 양쪽 분기 분리는 코드 중복 |
| 회귀 테스트의 count_line 함수 set -e 호환 | `\|\| echo 0` (initial) / `\|\| true` (revised) | revised | initial 은 grep 이 출력한 "0" 과 echo 출력 "0" 이 합쳐져 "00" 이 나옴 |

## 💬 사용자 협의

- **주제**: 라인별 멱등 로직 채택
  - **사용자 의견**: Plan Accept (1) 으로 채택
  - **합의**: 정상 케이스 동작 변화 0, 누락/중복 케이스만 보강.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (본 spec 신규)
- **명령**: `bash tests/test-gitignore-idempotent.sh`
- **결과**: ✅ Passed (22/22)
- **로그 요약**:
```text
▶ D-1~4: 첫 install 후 4 라인 각각 정확히 1 회 ✅
▶ D-5~8: 재install (동일 옵션) ✅
▶ E: 헤더만 수동 삭제 후 재install ✅
▶ F: 사용자 사전 라인 + 첫 install ✅
▶ G: 라인 일부 누락 후 재install ✅
▶ H: --gitignore → --no-gitignore 토글 ✅
ALL 22 CHECKS PASSED
```

#### 회귀 테스트
- `test-gitignore-config.sh` ✅ 11/11 (기존 A~G 시나리오)
- `test-install-layout.sh` ✅ 7/7 (전체 install 흐름)
- `test-doctor-bash-version.sh` ✅ 3/3 (spec-14-02 회귀)

### 2. 수동 검증

1. **Action**: 픽스처에서 헤더만 삭제 후 재install — `.harness-backup-*/` 가 2회 → 1회 로 정상화
   - **Result**: 변경 후 정확히 1 회.
2. **Action**: 본 프로젝트 .gitignore 에서 `grep -c '^\.harness-backup-\*/$'`
   - **Result**: 1 회 — 기존 정상 케이스도 영향 없음.

## 🔍 발견 사항

- **TDD Red 단계의 수치 분포가 의외로 작음**: 22 검증 중 5건만 fail (E-2/3/4, F-2, G-3). D 시나리오 8건은 이미 PASS — 기존 install.sh 도 단순 재install 케이스는 멱등이었음. 본 spec 의 가치는 *엣지 케이스 보강* 에 집중.
- **count_line 함수의 set -e + grep -c 조합 함정**: `grep -cE ... 2>/dev/null || echo 0` 패턴은 매치 0 일 때 grep 의 "0" + echo 의 "0" 을 모두 출력하여 "0\n0" → tr -d '[:space:]' 후 "00" 이 됨. `|| true` 로 수정. 향후 같은 패턴 사용 시 주의.
- **install.sh 의 다른 멱등 블록**: settings.json (jq + unique) 과 CLAUDE.md (awk BEGIN-END 통째 교체) 는 이미 견고. 본 spec 의 패턴 (`_gi_ensure`) 은 .gitignore 에만 적용 — 다른 곳까지 확장하면 over-engineering.

## 🚧 이월 항목

- 없음. spec-14-04 (`sdd_marker_append` 가드) 가 다음 spec.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-25 |
| **최종 commit** | `2840c2b` (fix: make .gitignore idempotent at line level) |
