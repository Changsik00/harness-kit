# Walkthrough: spec-21-01

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| mode 저장 위치 | 별도 파일 vs `current.json` 기존 필드 추가 | `current.json` 필드 추가 | `hook_state`가 이미 임의 키를 지원하므로 `_lib.sh` 무변경으로 훅에서 즉시 사용 가능. 별도 파일은 불필요한 복잡도 |
| 필드 부재 시 기본값 | `"turbo"` / `"governed"` | `"governed"` | 기존 설치에서 필드가 없으면 자동으로 기존 SDD ceremony 유지. 안전 방향 우선 |
| `sdd status` 표시 | turbo 일 때만 / 항상 표시 | 항상 표시 | 현재 모드가 무엇인지 사용자가 항상 알 수 있어야 함. governed가 기본이지만 명시적으로 보여주는 게 신뢰성을 높임 |

- [x] 없음 (ADR 승격 대상 없음 — 상위 결정은 spec-21-04 ADR-007 에서 다룸)

## 💬 사용자 협의

- **주제**: Turbo 모드를 기존 SDD 대체가 아닌 추가로 접근
  - **사용자 의견**: "그러면 이 방식으로 바꾸는게 아니라 이 방식을 추가하면?"
  - **합의**: Governed 모드 완전 유지, Turbo를 opt-in으로 추가. 기존 설치 영향 없음

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-mode-schema.sh`
- **결과**: ✅ Passed (7/7)
- **로그 요약**:
```text
=== test-mode-schema ===
T01: ✅ 기본값 governed 출력
T02: ✅ current.json mode=turbo 설정됨
T03: ✅ status 출력에 turbo 포함
T04: ✅ current.json mode=governed 복귀
T05: ✅ status 출력에 governed 포함
T06: ✅ sdd status 에 Active Mode 행 있음
T07: ✅ 잘못된 mode 값 → exit 1
결과: PASS=7 FAIL=0
```

#### 회귀 검증
- `tests/test-director-mode.sh`: ✅ PASS=22 FAIL=0
- `tests/test-sdd-status-cross-check.sh`: ✅ PASS=7 FAIL=0

### 2. 수동 검증

1. **Action**: `sdd mode status`
   - **Result**: `현재 모드: governed` 출력 — 필드 없는 기존 상태에서 기본값 동작 확인
2. **Action**: `sdd mode turbo`
   - **Result**: 확인 메시지 출력, `current.json` `"mode": "turbo"` 반영 확인
3. **Action**: `sdd status`
   - **Result**: `Active Mode: turbo` 행 표시 확인

## 🔍 발견 사항

- `hook_state mode` 는 `_lib.sh` 변경 없이 즉시 동작함 — spec-21-02 훅 분기 구현이 단순해질 것
- `sdd status` 의 `Active Mode` 행은 turbo가 아닌 경우 dim 색상으로 표시하여 시각적 강조를 차별화함

## 🚧 이월 항목

- 없음

## 🔗 관련 문서

- 관련 phase: `backlog/phase-21.md`

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-06-12 |
| **최종 commit** | `b7da5cf` |
