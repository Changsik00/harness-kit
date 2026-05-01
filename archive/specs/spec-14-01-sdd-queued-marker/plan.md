# Implementation Plan: spec-14-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-14-01-sdd-queued-marker` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함
- 본 PR 의 첫 commit 에 phase-14 셋업 변경분 (`backlog/phase-14.md` 생성, `backlog/queue.md` active/done 갱신) 도 함께 포함 — main 의 working tree 에 있으므로 spec 브랜치로 가져가서 함께 머지

## 🛑 사용자 검토 필요 (User Review Required)

> 본 Plan 을 Accept 하기 전에 사용자가 명시적으로 확인해야 할 항목들.

> [!IMPORTANT]
> - [ ] **Option B (마커 제거)** 채택 확정 — Option A (구현) 로 변경 원하시면 Plan Accept 전 알려주세요. 그 경우 plan.md/task.md 는 처음부터 재작성됩니다 (≈30 LOC 신규 + 마이그레이션 결정).
> - [ ] 본 PR 에 phase-14 셋업 commit (phase-14.md 신규 + queue.md active/done 갱신) 포함 — phase 첫 spec 의 표준 흐름으로, 별도 PR 으로 분리하지 않음.

> [!WARNING]
> - [ ] queue.md 상단 안내문 재작성 — 기존 한 줄 ("sdd 가 마커 사이를 자동 갱신하므로 마커는 그대로 두세요") 을 "자동 갱신 마커 vs 사람 편집 섹션" 으로 분리 표현. 기존 사용자가 본 안내문을 grep 으로 찾는 자동화가 있다면 영향 가능 (현실적 가능성 매우 낮음).

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
queue.md 섹션 정책 (변경 후)
─────────────────────────────────
📦 진행 중 Phase     → sdd 자동 갱신 (active 마커)
📥 spec-x 대기       → sdd 자동 갱신 (specx 마커)
🧊 Icebox            → 사람 편집
📋 대기 Phase        → 사람 편집  ← (변경) 마커 제거
✅ 완료              → sdd 자동 갱신 (done 마커)
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **queue.md 템플릿 (sources/)** | `sdd:queued` 마커 + 표 헤더 제거 | sdd 코드와 안내문 일치 |
| **queue.md 템플릿 (.harness-kit/agent/)** | 동일 변경 | 도그푸딩 동기화 |
| **본 프로젝트 backlog/queue.md** | 동일 변경 + 안내문 갱신 | 즉시 정합성 회복 |
| **상단 안내문** | "자동 갱신 마커 vs 사람 편집" 명시적 구분 | 사용자/에이전트가 잘못된 가정을 갖지 않도록 |
| **sdd 바이너리** | 변경 없음 | queued R/W 코드 자체가 부재 — 추가/제거 모두 불필요 |
| **회귀 테스트** | `tests/test-sdd-queued-marker-removed.sh` 신규 | 향후 누군가 마커를 다시 넣을 때 즉시 감지 |

## 📂 Proposed Changes

### 템플릿 정리

#### [MODIFY] `sources/templates/queue.md`

"📋 대기 Phase" 섹션 본문 변경:

```diff
 ## 📋 대기 Phase

-<!-- sdd:queued:start -->
-없음
-<!-- sdd:queued:end -->
+> 다음에 진행할 phase 를 자유롭게 메모합니다 (사람이 직접 편집).
+> 자동 갱신되지 않습니다 — Icebox 와 동일한 정책.
+
+없음
```

상단 안내문 변경:

```diff
 # Backlog Queue

 > 본 문서는 *대시보드* 입니다. ...
-> sdd 가 마커 사이를 자동 갱신하므로 마커 (`<!-- sdd:... -->`) 는 그대로 두세요.
-> 🧊 Icebox 섹션만 사람이 직접 편집합니다.
+> **자동 갱신 마커**: `active`, `specx`, `done` (마커 사이는 sdd 가 관리).
+> **사람 편집 섹션**: `Icebox`, `대기 Phase` (자유 메모).
```

#### [MODIFY] `.harness-kit/agent/templates/queue.md`

`sources/templates/queue.md` 와 동일 변경 (도그푸딩 동기화 — install.sh 가 sources/ → .harness-kit/agent/ 로 복사하는 구조이므로 둘이 동일해야 함).

#### [MODIFY] `backlog/queue.md`

본 프로젝트의 실제 queue.md 도 동일하게 정리. 단, 본 파일은 active/done 데이터가 채워져 있으므로 안내문/queued 섹션만 변경 (active, specx, done, Icebox 데이터는 보존).

### 회귀 테스트

#### [NEW] `tests/test-sdd-queued-marker-removed.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
# spec-14-01: sdd:queued 마커 제거 회귀 테스트
#
# 목적:
#   1. 템플릿(sources, .harness-kit/agent) 에 sdd:queued 마커가 없음을 검증.
#   2. 마커가 없는 queue.md 에서 sdd phase done / new / status 가 정상 동작.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Phase 1: 템플릿 검증
for tpl in "$ROOT/sources/templates/queue.md" "$ROOT/.harness-kit/agent/templates/queue.md"; do
  if grep -q "sdd:queued" "$tpl"; then
    echo "❌ $tpl 에 sdd:queued 마커가 남아 있음"
    exit 1
  fi
done

# Phase 2: 픽스처에서 sdd 명령 정상 동작
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT
# ... (test-sdd-queue-redesign.sh 와 같은 픽스처 셋업 패턴 사용)
# - sdd phase new + sdd phase done + sdd status 가 모두 exit 0 으로 끝나는지 검증

echo "✅ spec-14-01 회귀 테스트 PASS"
```

> 픽스처 셋업은 `tests/test-sdd-queue-redesign.sh` 의 패턴 재활용. 자세한 구현은 task.md 의 해당 task 에서 작성.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-queued-marker-removed.sh
```

또한 기존 테스트가 깨지지 않는지 확인:

```bash
bash tests/test-sdd-queue-redesign.sh
bash tests/test-sdd-status-cross-check.sh
```

### 통합 테스트

본 spec 의 `Integration Test Required = no` — 별도 통합 테스트 없음.

### 수동 검증 시나리오

1. **템플릿 grep**: `grep -r "sdd:queued" sources/ .harness-kit/agent/` → 0 매치 (안내문 내 코드 블록 제외).
2. **본 프로젝트 sdd 동작**: `bash .harness-kit/bin/sdd status` 정상 동작, queue.md 의 active/specx/done 데이터 보존 확인.
3. **새 프로젝트 install 시뮬**: `tests/` 의 픽스처 패턴으로 새 install 시 queue.md 가 마커 없이 생성됨을 확인.

## 🔁 Rollback Plan

- 본 spec 은 템플릿 + 안내문 + 회귀 테스트만 변경. `git revert <merge-commit>` 으로 즉시 복원 가능.
- 기존 사용자 영향 없음 (update.sh 가 queue.md 를 건드리지 않음).
- 회귀 테스트 추가도 별도 영향 없음 — 실패해도 PR CI 만 막힘.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
