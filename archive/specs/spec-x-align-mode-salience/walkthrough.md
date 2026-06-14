# Walkthrough: spec-x-align-mode-salience

> align 보고에 모드 부각 + intent 잔재 정리 제안 추가. 이번 세션 RCA의 후속.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 변경 범위 | constitution/agent.md 포함 / align.md만 | **align.md만** | 거버넌스 단어 budget(8000w, constitution+agent.md) 압박 — align.md는 budget 비대상이라 안전 |
| 감지 방식 | sdd status 코드에 stale-intent 플래그 추가 / doc 지시 | **doc 지시** | sdd status가 이미 Active Mode/Intent 출력 — align이 "행동"만 지시하면 충분. 코드+테스트 회피(right-size) |
| 잔재 정리 | 자동 clear / 제안만 | **제안만(자동 금지)** | §4 아카이브·drift 정리와 동일 no-auto 패턴. 사용자 결정 존중 |
| 섹션 배치 | 새 ## 섹션 / §5 하위 ### | **§5 하위 ###(5.1, 5.2)** | 모드 부각·intent 점검은 "상태 보고(§5)"의 일부 — 번호 재정렬 churn 회피 |

## 💬 사용자 협의

- **주제**: 왜 Plan Accept를 요청했는가 (RCA)
  - **합의**: 오작동 아님 — governed + 기능/ADR 작업이라 Plan Accept가 헌법상 유일 경로(turbo는 §2.4로 이 유형 금지). 진짜 원인은 "모드 모델 불일치(사용자는 turbo로 착각) + 에이전트가 모드 미부각 + intent 잔재". → 예방책으로 align에 모드 부각 + intent 정리 반영(option 1) 선택.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-install-manifest-sync.sh` / `bash tests/run.sh --fast`
- **결과**: ✅ 매니페스트 정합 6/6. 전체 회귀에서 신규 회귀 0 (기존 실패 5건만 잔존 — extend 때와 동일, 본 변경 무관).

### 수동 검증
1. **Action**: `diff -q sources/governance/align.md .harness-kit/agent/align.md`
   - **Result**: IDENTICAL (도그푸딩 sync 확인).
2. **Action**: align.md §5 블록 확인
   - **Result**: `Active Mode` 라인 + §5.1 모드 부각 + §5.2 intent 잔재 점검 존재.

## 🔍 발견 사항

- **`sdd intent clear` 가 이미 존재** — align이 가리킬 실제 정리 명령이 있어 doc 지시만으로 완결.
- **`sdd status` 는 이미 Active Mode·Active Intent 를 출력** — 빠진 건 코드가 아니라 "align이 그걸 부각·조치하라"는 지시였음.
- 이번 세션 시작 시 실제로 `Active Intent: test goal` 잔재가 있었음(이전 turbo 미종료) — 본 변경의 동기를 실증.

## 🚧 이월 항목

- constitution §2.4 완화("소규모 기능 turbo 허용") 논의 → premature-execution 가드 약화 우려, 별도 ADR 후보 (본 spec Out of Scope).
- 세션 시작 잔재 `Active Intent: test goal` 자체 정리는 다음 align에서 새 지시(§5.2)대로 사용자에게 제안 예정.
