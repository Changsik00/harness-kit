# Implementation Plan: spec-x-phase-17-define

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-phase-17-define`
- **시작 지점**: `main` (spec-x 는 항상 main 에서 분기 — 메모리 룰)
- **PR Target**: `main`
- 첫 task 가 브랜치 생성

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **phase-17 scope**: 3 spec (sdd marker bugs / installed.json 캐시 분리 / phase integration test + doctor) — alignment 에서 합의됨.
> - [ ] **Base branch 처음부터 사용**: phase-16 mid-phase 전환 경험 학습. 결정 기록 표에 명시.
> - [ ] **Out of Scope 7 건**: W1/W3/W4/W7/W9 + 접근성 개선 — Icebox 잔류, 명시적으로 phase-17 외.

> [!WARNING]
> - [ ] **phase 활성화는 별 작업**: 본 spec 은 *문서 작성* 만. 머지 후 사용자가 `sdd phase activate phase-17 --base` 호출 필요.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **phase 정의 방식** | spec-x-phase-17-define 한 PR | 과거 phase-{14,15,16} 동일 패턴. 분리된 review 가능 |
| **Spec 개수** | 3 spec | sdd marker 3종 묶음 (P0) + installed.json 분리 (P1) + integration test+doctor (P1). 4 spec 은 W1/W3/W4 잡탕 — Icebox 로 분리 |
| **Base branch 시점** | 처음부터 (phase-17 활성화 시) | phase-16 mid-phase 전환의 cost (rebuild, force-push) 회피 |
| **회고 항목 매핑** | 각 spec 에 phase-16 회고 W-번호 ref | 추적성 유지, 다음 회고에서 *처리 완료 vs 잔류* 구분 가능 |

## 📂 Proposed Changes

### [NEW] `backlog/phase-17.md`

phase 템플릿 (`.harness-kit/agent/templates/phase.md`) 준수. 주요 섹션 outline:

```markdown
# phase-17: 정합성 fix (Coherence Fix)

## 📋 메타
- Phase ID: phase-17
- 상태: Planning (대기)
- Base Branch: phase-17-coherence-fix (처음부터)
- 소유자: dennis

## 🎯 배경 및 목표
### 현재 상황
- phase-16 회고 (독립 Opus sub-agent) 에서 self-credibility 손상 식별
- RCA-001 invariant 위반 4 회 재발
- installed.json 캐시 필드 untracked drift 상시 발생
- phase-level integration test 자동화 부재

### 목표
1. sdd CLI 의 marker 관련 버그가 더 이상 productivity tax 를 만들지 않는다
2. `git status` 가 SessionStart 후에도 깨끗
3. phase-level integration test 자동화 진입점 확보
4. doctor.sh 가 phase-16 신규 산출물 (rca/decisions) 인지

### 성공 기준 (정량)
1. `sdd ship` / `sdd spec new` fixture 검증 — phase-N.md spec 표 행 수 멱등
2. `sdd phase done` entry 형식 `**phase-N** — 제목 — completed YYYY-MM-DD`
3. `git status` 가 SessionStart hook 실행 후 빈 출력
4. `tests/test-phase16-integration.sh` 작성 + 3 시나리오 자동 PASS
5. `doctor.sh` 가 docs/rca, docs/decisions, rca.md, adr.md 점검 포함

## 🧩 작업 단위 (SPECs)
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
| spec-17-01 | sdd-marker-bugs-fix | P0 | Backlog | (미생성) |
| spec-17-02 | installed-cache-separation | P1 | Backlog | (미생성) |
| spec-17-03 | phase-integration-test-and-doctor | P1 | Backlog | (미생성) |

### spec-17-01 — sdd CLI marker 버그 3 종 fix
- 요점: sdd ship + sdd spec new append → in-place update. sdd phase done title 추출.
- 회고 ref: W5 / W10 (RCA-001 prevention 직접 구현)
- 연관 모듈: sources/bin/sdd, .harness-kit/bin/sdd

### spec-17-02 — installed.json 캐시 필드 분리
- 요점: lastVersionCheck / latestKnownVersion → .harness-kit/cache.json + gitignore
- 회고 ref: C3
- 연관 모듈: sources/hooks/check-kit-version.sh, sources/bin/sdd (_drift_kit_version), install.sh

### spec-17-03 — phase-level integration test + doctor 확장
- 요점: tests/test-phase16-integration.sh 패턴 + doctor.sh 새 경로
- 회고 ref: W2 / W6
- 연관 모듈: tests/, doctor.sh

## 📌 결정 기록 (Review)
- Base branch 처음부터: phase-16 mid-phase 전환 cost 회피
- sdd marker 3종 한 spec: 동일 패턴, 한 PR 로 묶어 review 효율
- W1/W3/W4/W7/W9 + 접근성 개선 = Out of Scope: scope 폭주 방지

## 🧪 통합 테스트 시나리오
1. Marker idempotency — spec-x ship 반복 시 phase-N.md 행 수 불변
2. Cache separation — hook 후 git status 빈 출력
3. Phase integration self-test — test-phase16-integration.sh PASS

## 🔗 의존성
- 선행 phase: phase-16 (RCA/ADR/Stale/Positioning) — 본 phase 가 그것의 정합성 fix

## 📝 위험 요소
- phase-17 자체가 본질적으로 self-correction → 회귀 위험 ↑ → 통합 테스트 자동화로 완화
- 캐시 분리 시 기존 installed.json 의 사용자 환경 마이그레이션 — install.sh 가 호환 처리

## 🏁 Phase Done 조건
- [ ] 3 spec 모두 Merged
- [ ] 통합 시나리오 3 PASS
- [ ] 성공 기준 5 정량 측정 기록
- [ ] phase-16 회고 W5/W10/C3/W2/W6 모두 *closed* 처리
- [ ] 사용자 최종 승인
```

## 🧪 검증 계획 (Verification Plan)

### 단위 검증
```bash
# 1. phase-17.md 생성 확인
test -f backlog/phase-17.md
# 2. phase ID 정확
grep "Phase ID.*phase-17" backlog/phase-17.md
# 3. Base Branch 명시
grep "Base Branch.*phase-17-coherence-fix" backlog/phase-17.md
# 4. SPECs 3 행
grep -c "^| spec-17-0" backlog/phase-17.md
# 기대: 3
# 5. 회고 ref 명시
grep -E "W5|W10|C3|W2|W6" backlog/phase-17.md
```

### 통합 테스트
Integration Test Required = no. 본 spec 은 *문서 작성* 만.

### 수동 검증 시나리오
1. phase-17.md 본문 가독성 — phase-16.md 와 동일 구조
2. SPECs 표가 sdd:specs marker 안에 (자동 갱신 가능 상태)
3. 결정 기록 표에 4 결정 모두 박힘

## 🔁 Rollback Plan

- 문제 발생 시 PR revert. phase-17 활성화 전이라 다른 산출물 영향 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept
- [ ] (실행 후) phase-17.md 작성
- [ ] (실행 후) walkthrough.md / pr_description.md ship
