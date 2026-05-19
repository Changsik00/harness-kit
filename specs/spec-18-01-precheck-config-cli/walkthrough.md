# Walkthrough: spec-18-01

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| `sdd_marker_replace` 호출 전 마커 존재 여부 확인 | `sdd_marker_replace` 그냥 호출 vs 사전 grep | 사전 `grep -qF` 로 마커 확인 후 없으면 warn | `sdd_marker_replace`는 마커 없어도 no-op으로 파일을 재작성하는데, 이를 사용자가 인지 못할 수 있음. 명시적 warn이 더 안전 |
| 중복 add 시 종료 코드 | `die`(exit 1) vs `warn`(exit 0) | `warn` + return 0 | 중복은 오류가 아니라 멱등 동작. 명령 자체는 성공 처리 |
| `remove` 후 task.md 갱신 방식 | 마커 내 `[x]` 상태 보존 vs 전체 교체 | 전체 교체 | precheck 목록이 변경되면 체크 상태가 무의미해짐. 어차피 remove는 이미 실행한 precheck를 제거하는 시나리오 |

- [x] 없음 (ADR 승격 불필요 — spec-18 내부 구현 결정)

## 💬 사용자 협의

- **주제**: precheck 실패 시 자동 제거 vs 선택지 제시
  - **사용자 의견**: 실패 시 설정에서 지우거나 가이드에서 삭제할 수 있어야 함. 단, "잘못되면" 자동이 아니라 선택 가능해야 함
  - **합의**: `retry / remove / skip` 3가지 선택지 제시 (→ spec-18-03에서 구현). 본 spec은 `remove` 명령 자체만 구현.

- **주제**: `--yes` 플래그 범위
  - **사용자 의견**: config에 지정된 정보로 설정하되 `--yes`일 경우 체크 처리
  - **합의**: `hk-ship --yes` 플래그로 실행 없이 통과 처리 (→ spec-18-03). 본 spec은 CLI만.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-precheck-config.sh`
- **결과**: ✅ Passed (8/8)
- **로그 요약**:
```text
T1: precheck add → ✅ installed.json precheck[0] = 'npm run lint'
T2: 중복 add    → ✅ 배열 변화 없음 + 경고 출력
T3: list        → ✅ 두 명령 모두 출력됨 / 빈 상태 '없음' 출력
T4: remove 1    → ✅ 첫 항목 제거, 나머지 유지
T5: 범위 초과   → ✅ 오류 출력 + 배열 변화 없음
T6: 마커 있음   → ✅ task.md 마커 구간 갱신됨
T7: 마커 없음   → ✅ warn 출력 + installed.json 갱신 성공
결과: PASS=8  FAIL=0
```

### 2. 수동 검증

1. **Action**: `sdd config precheck add "npm run lint"`
   - **Result**: `✓ precheck 추가: npm run lint` 출력, `installed.json`에 배열 추가됨
2. **Action**: `sdd config precheck list`
   - **Result**: `1. npm run lint` 형태로 번호 포함 출력
3. **Action**: `sdd config precheck remove 1`
   - **Result**: `✓ precheck 제거: index 1` 출력, 배열에서 제거됨

## 🔍 발견 사항

- `sdd_marker_replace`는 마커가 없을 때 파일을 그냥 통과 기록하는 silent no-op 동작. `_sync_precheck_task_marker`에서 사전 `grep` 체크 패턴이 다른 marker sync 로직에도 일관성 있게 적용 필요할 수 있음. (spec-18-02 구현 시 참고)
- `jq 'any(. == $cmd)'` 패턴이 중복 감지에 깔끔하게 작동함 — 다른 배열 필드 관리에도 재사용 가능한 패턴.

## 🚧 이월 항목

- task.md 템플릿에 `<!-- sdd:precheck:start/end -->` 마커 추가 → spec-18-02
- `hk-ship` precheck 실행 + 실패 UX → spec-18-03
- `hk-update` 보존 처리 → spec-18-04

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-19 |
| **최종 commit** | `b611906` |
