---
kind: synthesis
sources:
  - archive/specs/spec-x-planning-economy/walkthrough.md
  - archive/specs/spec-17-04-governance-test-coherence/walkthrough.md
  - docs/decisions/ADR-002-planning-economy.md
  - docs/rca/RCA-001-sdd-ship-spec-add-missing.md
  - specs/spec-19-01-wiki-layer-bootstrap/walkthrough.md
  - specs/spec-19-03-doctor-wiki-slim/walkthrough.md
linked:
  - "[[wiki/decisions]]"
  - "[[ADR-002]]"
  - "[[RCA-001]]"
updated: 2026-05-28
---

# 반복 패턴 증류

> phase-08~18에서 반복 확인된 good pattern과 anti-pattern.
> 각 패턴에 최초 확인 출처 태그.

---

## ✅ Good Patterns

### bundle-before-spec-x
여러 작은 Icebox 항목이 같은 테마로 쌓이면 spec-x 여러 개 대신 하나로 묶어서 처리한다.

- **왜**: phase 응집도 유지 + ceremony 비용 절감
- **출처**: spec-17-04 "잡탕 cleanup", [[ADR-002]] Invariant 3
- **적용**: 3개 이상 소규모 항목이 같은 영역에 있을 때

---

### phase-FF (Phase Fast Flow)
phase 내에서 1-2 commit 규모 변경은 spec 아티팩트 없이 phase 브랜치에 직접 커밋한다.

- **왜**: ceremony(6,000-8,000 토큰)가 작업보다 클 때 ROI 음수
- **출처**: [[ADR-002]] Invariant 1, phase-17 내 소규모 수정들
- **적용**: 단일 파일, 가역적, 명백한 fix일 때 (사용자 명시 승인 필요)

---

### hook-gradual-escalation
새 hook은 반드시 경고 모드(exit 0 + stderr)로 시작하고, 1주 운영 후 차단 모드(exit 2)로 승격한다.

- **왜**: 즉시 차단하면 false positive로 워크플로 막힘. 관찰 기간이 안전망.
- **출처**: CLAUDE.md "Hook 단계론", phase-09, phase-16
- **적용**: 모든 신규 pre-commit / pre-push hook

---

### TDD-red-green-commit
테스트 작성(Red) → 구현(Green) → 커밋 순서를 지킨다. Red 커밋과 Green 커밋을 분리한다.

- **왜**: Red 커밋이 "무엇을 검증하려 했는가"를 코드 히스토리에 남김. 회귀 방지 기준점.
- **출처**: agent.md §6.1 Strict Loop Rule, 모든 phase 공통
- **적용**: 모든 testable behavior

---

### human-curates-llm-maintains
wiki synthesis 페이지는 LLM이 초안을 작성하지만, 포함 여부와 표현은 사람이 최종 결정한다.

- **왜**: LLM은 hallucinate 가능. wiki가 잘못된 결정을 사실인 양 기록하면 누적 오염.
- **출처**: Karpathy LLM Wiki 패턴, spec-19-01 설계
- **적용**: `/hk-wiki-ingest` 실행 시 항상 사용자 검토 후 커밋

---

## ❌ Anti-Patterns

### ceremony-over-work
1-2 commit 규모 작업에 full SDD ceremony(spec/plan/task/PR)를 적용한다.

- **왜 위험**: 6,000-8,000 토큰 + 사용자 검토 시간이 실제 변경보다 큼. ROI 음수.
- **출처**: [[ADR-002]] 직접 동기, phase-17 회고
- **대안**: FF(사용자 승인) 또는 spec-x로 demote

---

### silent-inter-spec-drift
다음 spec 시작 전 직전 spec의 실제 변경 영향을 검토하지 않고 원래 phase plan대로 진행한다.

- **왜 위험**: phase plan은 작성 시점의 예상일 뿐. 직전 spec이 이후 spec의 가정을 무너뜨릴 수 있음.
- **출처**: [[ADR-002]] Invariant 2, phase-17에서 spec-17-03→17-05 sweep
- **대안**: 매 spec 시작 시 `sdd spec new` pre-flight 출력 + walkthrough carry-over 점검

---

### bash-pipeline-sigpipe-trap
`set -euo pipefail` 환경에서 `cmd 2>&1 | grep -q "..."` 패턴은 오탐을 유발한다.

- **왜 위험**: `grep -q`는 첫 매치 후 파이프를 닫음 → cmd가 SIGPIPE로 종료 → `pipefail`이 비정상 종료로 처리. 특히 sdd같이 출력이 긴 명령에서 나타남.
- **출처**: spec-19-03 walkthrough §결정 기록 (Check 1 테스트 오탐)
- **대안**: `output=$(cmd 2>&1 || true); echo "$output" | grep -q "..."` 패턴으로 출력 먼저 캡처

---

### frontmatter-range-grep
YAML frontmatter 필드를 검증할 때 `grep "^field:"` 대신 frontmatter 범위로 한정한다.

- **왜 위험**: 문서 본문에 동일 패턴 예시가 있으면 false positive. 특히 스키마·컨벤션을 설명하는 파일(purpose.md 등)에서 발생.
- **출처**: spec-19-01 walkthrough §발견 사항 (purpose.md kind: 파싱 오탐)
- **대안**: `awk 'NR==1 && /---/{in_fm=1} in_fm && /^---/{exit} /^kind:/{print}' file.md`

---

### doc-accumulation-without-wiki
산출물(spec, walkthrough, ADR, RCA)만 계속 쌓고 증류 레이어(wiki)가 없어 지식이 누적되지 않는다.

- **왜 위험**: 세션마다 raw 재탐색. 111개 파일에서 결정 맥락을 찾으려면 대용량 컨텍스트 필요.
- **출처**: phase-19 배경 (이 spec의 존재 이유)
- **대안**: `/hk-wiki-ingest`로 archive할 때마다 wiki 갱신
