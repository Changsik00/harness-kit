# Walkthrough: spec-x-install-phase-ship-template

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 템플릿 복사 방식 | (A) 하드코딩 리스트에 한 줄 추가 / (B) `sources/templates/*.md` 디렉토리 sync | **A** | 1줄 fix 가 회귀 위험 zero. 디렉토리 sync 는 구조 변경 — 별 spec 으로 분리. |
| 테스트 형태 | (A) 8개 파일 명시 / (B) `sources/templates/` 와 install 결과 동적 비교 | **A** | 명시 리스트가 의도를 코드에 박아두어 향후 `--minimal` 같은 옵션이 도입돼도 깨지지 않음. 정합성 ↑. |

## 💬 사용자 협의

- **주제**: 다음 작업 우선순위
  - **에이전트 추천**: Icebox 4건 중 #2 (phase-ship.md 템플릿 누락) — blast radius 최대 (모든 신규 사용자 영향), scope 최소 (1줄 fix), 컨텍스트 살아있음
  - **사용자 결정**: "좋아 진행해" → Icebox #2 채택, slug=`install-phase-ship-template`

## 🧪 검증 결과

### `tests/test-install-layout.sh`

```text
▶ Check 8: 8개 템플릿 모두 복사됨
  ✅ templates/queue.md 존재
  ✅ templates/phase.md 존재
  ✅ templates/phase-ship.md 존재
  ✅ templates/spec.md 존재
  ✅ templates/plan.md 존재
  ✅ templates/task.md 존재
  ✅ templates/walkthrough.md 존재
  ✅ templates/pr_description.md 존재
✅ ALL PASS (15/15)
```

### 전체 sweep

```bash
for t in tests/test-*.sh; do bash "$t" || echo "FAIL: $t"; done
# → Total fails: 0
```

## 🔍 발견 사항

### 1. 사일런트 회귀의 발견 경로

이 버그는 install.sh:262 가 처음 만들어진 시점부터 잠재해 있었음. 본 프로젝트가 `phase-ship.md` 를 직접 편집해 갖고 있던 잔재 덕에 우연히 동작했고, 직전 spec (`spec-x-update-preserve-state`) 의 도그푸딩에서 install 이 잔재를 덮어쓰며 처음 표면화됨.

→ 시사점: install 결과를 fixture 디렉토리에서 검증하는 테스트는 본 프로젝트의 잔재 영향을 받지 않으므로 잠재 버그 탐지에 효과적. Check 8 같은 형태가 다른 install 단계에도 확장 가능.

### 2. 본 프로젝트는 별도 도그푸딩 불필요

본 프로젝트엔 이미 `.harness-kit/agent/templates/phase-ship.md` 가 잔재로 존재하므로 도그푸딩으로 install 을 다시 돌리지 않아도 동작 영향 없음. 다음 정상 install/update 시점에 자동으로 sync 됨.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Opus) + dennis |
| **작성 기간** | 2026-04-27 (단일 세션, 직전 spec 직후) |
| **최종 commit** | `4ea6fac` (install.sh fix) |
| **총 commits** | 3 (test → fix → ship) |
