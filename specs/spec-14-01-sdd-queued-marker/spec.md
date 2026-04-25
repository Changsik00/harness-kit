# spec-14-01: queue.md sdd:queued 마커 정리

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-14-01` |
| **Phase** | `phase-14` |
| **Branch** | `spec-14-01-sdd-queued-marker` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-25 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`backlog/queue.md` 의 "📋 대기 Phase" 섹션에는 다음 마커가 정의되어 있다:

```markdown
<!-- sdd:queued:start -->
| Phase | 제목 | 상태 | SPECs |
|-------|------|------|-------|
<!-- sdd:queued:end -->
```

또한 `queue.md` 상단 안내문은 다음과 같다:

> sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요.

→ 사용자/에이전트는 모든 `sdd:*` 마커가 자동 갱신된다고 믿게 된다.

### 문제점

`docs/harness-kit-bug-01-sdd-queued-marker-unimplemented.md` 의 분석에 따르면, **`sdd` 바이너리에 `queued` marker 를 R/W 하는 코드가 0건**:

```bash
$ grep -n "queued" .harness-kit/bin/sdd
(0 matches)   # 보고서 시점엔 4건이었으나 모두 help/warning 워딩이고 본질은 동일
```

- `phase_new()` / `queue_mark_done()` / `queue_set_active()` 어디에서도 `sdd_marker_append/replace` 가 `"queued"` 마커 이름으로 호출되지 않음.
- 템플릿 (`sources/templates/queue.md`, `.harness-kit/agent/templates/queue.md`) 에는 마커만 선언되어 있고 구현 없음 — **dead marker**.

**실제 피해**:
1. queue.md 의 "📋 대기 Phase" 표가 phase 전이를 반영하지 못함 — 한 번 채워진 후 영구 stale.
2. agent.md §4.3 ("marker 영역은 sdd 자동 관리이므로 수기 편집 금지") 을 따르려는 에이전트는 표를 영구 낡은 상태로 남겨둠.
3. 안내문 ("sdd 가 마커 사이를 자동 갱신") 이 사용자/에이전트 모두에게 거짓 정보가 됨.

### 해결 방안 (요약)

두 옵션의 trade-off 를 분석한 결과 **Option B (마커 + 자동 갱신 안내문 제거)** 채택. queued 섹션은 Icebox 와 동일한 "사람이 직접 편집" 정책으로 통일.

#### 옵션 비교

| 기준 | Option A (구현 — `queue_sync_queued_table()`) | Option B (제거) |
|---|---|---|
| 코드 추가 | ~30 LOC + backlog/archive 양쪽 스캔 | 0 LOC |
| 안내문/현실 일관성 | ✅ 자동 갱신 = 사실 | ✅ 사람 편집 = 사실 |
| Dashboard 가치 | ✅ queued phase 가 여러 개일 때 빛남 | ⚠ 사람이 동기화 |
| 마이그레이션 | 필요 (기존 수기 표 보존 vs 강제 재생성 결정) | 불필요 |
| 회귀 위험 | 중 (sdd 호출 지점 3 곳 신규 호출 추가) | 거의 없음 |
| 실 사용 패턴 | 현재까지 queued phase 가 동시에 여러 개였던 적 없음 | 동일 |
| 일관성 | Icebox(사람 편집) 와 정책 분리 | Icebox 와 동일 정책 |
| YAGNI | ❌ 미래 가치를 위한 선구현 | ✅ 필요해지면 그때 구현 |

#### 채택 사유 (Option B)

1. **YAGNI**: 현재까지의 모든 phase 는 직렬 진행 (active 1개 + done N개). queued 가 동시에 여러 개였던 적 없음. 미래에 필요해지면 그때 구현해도 늦지 않음.
2. **일관성**: Icebox 가 이미 "사람 편집" 으로 명시됨. queued 도 같은 정책으로 통일하면 멘탈 모델 단순.
3. **단순성**: 코드 추가 0, 마이그레이션 불필요. 회귀 위험 사실상 0.
4. **`CLAUDE.md` 원칙 부합**: "No Over-engineering" — 도그푸딩 가치 검증 전 추상화 금지.

> 사용자가 Plan Accept 전 Option A 를 선호하면 plan.md/task.md 를 재작성. 본 spec.md 의 trade-off 분석은 그대로 의사결정 기록으로 보존.

## 🎯 요구사항

### Functional Requirements

1. `sources/templates/queue.md` 에서 `<!-- sdd:queued:start --> ~ <!-- sdd:queued:end -->` 마커 + 그 사이 표 헤더 제거.
2. `.harness-kit/agent/templates/queue.md` 에 동일 변경 (도그푸딩 동기화).
3. 본 프로젝트의 `backlog/queue.md` 도 동일하게 마커 제거.
4. `queue.md` 상단 안내문 재작성 — 자동 갱신 마커 (`active`, `specx`, `done`) 와 사람 편집 섹션 (`Icebox`, `대기 Phase`) 을 명시적으로 구분.
5. "📋 대기 Phase" 섹션 본문에 사람이 편집한다는 안내문 추가 (Icebox 의 안내문과 톤 통일).
6. 회귀 테스트 추가 — `tests/test-sdd-queued-marker-removed.sh`:
   - 템플릿 파일에 `sdd:queued` 마커가 없음을 검증.
   - 마커가 없는 queue.md 픽스처에서 `sdd phase done`, `sdd phase new`, `sdd status` 모두 정상 동작함을 검증.

### Non-Functional Requirements

1. **하위 호환**: 기존 사용자가 update.sh 를 실행해도 `backlog/queue.md` 는 보존 — 마커 제거를 강제하지 않음. 사용자가 직접 마커를 지우면 정합성 회복, 안 지워도 sdd 동작에는 영향 없음 (애초에 R/W 코드 부재).
2. **회귀 방지**: 향후 누군가 templates/queue.md 에 `sdd:queued` 마커를 다시 넣더라도 회귀 테스트가 즉시 잡아냄.

## 🚫 Out of Scope

- queued 섹션의 자동 갱신 기능 자체 (Option A 미채택). 필요해지면 별도 spec.
- backlog/ + archive/backlog/ 스캔 로직 신규 추가.
- `sdd` 바이너리 자체 로직 수정 — 본 spec 은 템플릿 + 회귀 테스트만 다룸.
- 기존 사용자 프로젝트의 queue.md 자동 마이그레이션 — update.sh 는 queue.md 를 건드리지 않음 (현재 정책 유지).

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS
- [ ] (Integration Test Required = no 이므로 해당 사항 없음)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-14-01-sdd-queued-marker` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
