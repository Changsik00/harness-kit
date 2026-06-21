# spec-24-05: phase-ship 결정 로그 rollup (auto 체크포인트)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-24-05` |
| **Phase** | `phase-24` |
| **Branch** | `spec-24-05-phase-ship-checkpoint` |
| **Base 브랜치** | `main` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-06-22 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

24-03 이 `sdd decision add/list` 를 만들었다 — auto 모드에서 결정을 *active spec* 의 `walkthrough.md` `## 📌 결정 기록 (auto)` 표에 적재. `sdd decision list` 는 **현재 spec 하나만** 출력.

### 문제점

ADR-009 auto 규약 4: "결정 로그가 **phase-ship 에서 사람에게 일괄 노출**". 그런데 auto 가 phase 전체를 fire-and-forget 으로 돌면 결정이 *여러 spec* 의 walkthrough 에 흩어진다. 사람이 복귀하는 단일 검토 지점(phase-ship)에서 phase 전체 결정을 한 번에 볼 방법이 없다. `hk-phase-ship` 도 결정 로그를 모으지 않는다.

### 해결 방안

phase 전체 결정 로그 **rollup**: `sdd decision list --phase` 가 active phase 의 모든 spec(`specs/spec-{phaseN}-*/walkthrough.md`)에서 `결정 기록 (auto)` 행을 모아 spec 라벨과 함께 출력. `hk-phase-ship` 이 이를 go/no-go 검토 + PR 본문에 포함 → 자율 실행이 내린 결정이 phase-ship 한 곳에서 일괄 노출.

## 요구사항

1. `sdd decision list --phase` — active phase 의 전 spec walkthrough 에서 `결정 기록 (auto)` 행 집계, 각 행에 출처 spec 표시.
2. 결정 없는 spec 은 건너뜀. 결정 0건이면 "(결정 로그 없음)" graceful.
3. 기존 `sdd decision list`(현재 spec) 동작 불변.
4. `hk-phase-ship` 절차에 "결정 로그 rollup 노출" 단계 추가 (go/no-go + PR 본문).
5. state/phase 부재 시 graceful.

## Out of Scope

- spec 사이 테스트 게이트: 이미 `post-commit-verify`(24-03, ③연속 실패) + `check-test-passed` 가 담당 — 중복 구현 안 함.
- 결정 로그 포맷 변경 — 24-03 형식 그대로 재사용.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] rollup 은 walkthrough 의 `결정 기록 (auto)` 표만 집계 (사람이 쓴 `결정 기록` 섹션과 구분). 24-03 형식 의존.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| `sdd decision list --phase` | 전 spec walkthrough 순회 + 행 집계 | 단일 노출 지점 |
| 출처 표시 | 행 앞에 spec id | 어느 spec 결정인지 |
| `hk-phase-ship` | rollup 호출 단계 추가 | phase-ship = 사람 복귀 검토점 |

## Proposed Changes

#### [MODIFY] `sources/bin/sdd` (+ 미러 `.harness-kit/bin/sdd`)
- `cmd_decision` list 가 `--phase` 플래그 수용 → `_decision_list_phase`: `state.phase` 의 `specs/spec-{phaseN}-*/walkthrough.md` 순회, 각 파일의 `결정 기록 (auto)` 표 데이터 행 추출 후 spec id 열 추가해 집계 출력. 0건 graceful.

#### [MODIFY] `sources/commands/hk-phase-ship.md` (+ 미러 `.claude/commands/hk-phase-ship.md`)
- go/no-go 검토 단계에 `sdd decision list --phase` 실행 + 출력을 phase-ship PR 본문 "자율 결정 로그" 섹션에 포함하는 지시 추가.

#### [NEW] `tests/test-decision-phase.sh`
- 여러 spec walkthrough 에 결정 행 → `--phase` 가 전부 집계 + spec 라벨, 결정 없는 spec 스킵, 0건 graceful, 기존 `list`(현재 spec) 불변.

## 검증 계획

```bash
bash tests/test-decision-phase.sh
for t in tests/test-*.sh; do bash "$t" >/dev/null 2>&1 && echo "PASS $t" || echo "FAIL $t"; done
```

수동 검증 시나리오:
1. 2개 spec walkthrough 에 `decision add` 후 `sdd decision list --phase` → 기대: 양쪽 결정이 spec 라벨과 함께 출력
2. 결정 0건 phase → 기대: graceful 안내

## 롤백 계획

- `git revert` — 신규 서브플래그 + 커맨드 문서 추가만, 기존 `decision list`/phase-ship 동작 불변. state 영향 없음.

## ADR 후보

- [x] 없음 — ADR-009 가 거버닝 (auto 규약 4 의 구현).

## ✅ Definition of Done

- [ ] 모든 테스트 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-24-05-phase-ship-checkpoint` 브랜치 push 완료
