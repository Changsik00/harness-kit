# phase-8: 작업 관리 모델 재정립 — Queue·Phase base branch·완료 흐름 강제

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-8-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-8` |
| **상태** | In Progress |
| **시작일** | 2026-04-11 |
| **목표 종료일** | — |
| **소유자** | Dennis |
| **Base Branch** | `phase-8-work-model` (opt-in, 도그푸딩 첫 사례) |

## 🎯 배경 및 목표

### 현재 상황

harness-kit을 실제 사용하면서 세 가지 구조적 결함이 드러났다.

1. **Backlog stale**: `queue.md`, `phase.md`의 spec 상태가 git 현실과 diverge된다. spec/phase 완료 후 상태 갱신이 강제되지 않아 수동 관리에 의존하고, FF·spec-x 작업 시 더욱 심해진다.
2. **작업 분류 모델 부재**: Phase/Spec/spec-x/Icebox의 역할과 경계가 명문화되어 있지 않다. "다음에 뭘 해야 하나?"를 queue만 보고 즉시 답할 수 없다.
3. **Phase base branch 없음**: Phase가 오직 문서(`backlog/phase-N.md`)로만 존재하고 git에 없다. Epic Branch 패턴처럼 spec들이 phase 브랜치에 쌓이고 phase 완료 후 main에 들어오는 구조가 없어, spec 간 의존성 처리와 main 보호가 어렵다.

### 목표 (Goal)

- 작업 유형(Phase/Spec/spec-x/Icebox) 모델을 constitution에 명문화한다
- queue.md를 NOW/NEXT/Icebox 구조로 재설계하여 "지금 할 일, 다음 할 일"을 즉시 파악 가능하게 한다
- Phase base branch를 opt-in으로 지원한다 — spec PR이 phase 브랜치로 쌓이고, phase 브랜치가 main으로 합쳐진다
- hk-ship에 완료 흐름을 강제하여 backlog stale을 구조적으로 차단한다
- hk-align이 NOW/NEXT/Icebox를 명확히 출력하여 "다음 작업은?" 질문에 즉시 답한다

### 성공 기준 (Success Criteria)

1. `sdd status` 실행 시 NOW(현재 spec)와 NEXT(다음 spec)가 명확히 출력됨
2. `queue.md`에 NOW/NEXT/Icebox 섹션이 존재하고 sdd가 자동 갱신함
3. `sdd phase new --base` 플래그로 phase base branch 모드 설정 가능
4. hk-ship 실행 시 `sdd archive` 누락 시 경고 또는 차단
5. spec-x 완료 후 queue.md Icebox/완료 갱신이 hk-ship에 포함됨
6. hk-align 출력에 NOW/NEXT/Icebox 현황이 포함됨

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-8-001 | queue-redesign | P1 | Merged | `specs/spec-8-001-queue-redesign/` |
| spec-8-002 | phase-base-branch | P1 | Merged | `specs/spec-8-002-phase-base-branch/` |
| spec-8-003 | ship-completion-gate | P1 | Merged | `specs/spec-8-003-ship-completion-gate/` |
| spec-8-004 | align-and-governance | P2 | Merged | `specs/spec-8-004-align-and-governance/` |
| spec-8-005 | phase-ship | P1 | In Progress | `specs/spec-8-005-phase-ship/` |
<!-- sdd:specs:end -->

### spec-8-001 — 작업 분류 모델 정의 & Queue 재설계

- **요점**: Phase/Spec/spec-x/Icebox 역할을 constitution에 정의하고 queue.md를 NOW/NEXT/Icebox 구조로 재설계한다
- **방향성**:
  1. `constitution.md` §2에 작업 유형 정의 섹션 추가 (Phase, Spec, spec-x, Icebox 각 역할·진입·종료 조건)
  2. `sources/templates/queue.md` 구조 재설계 — NOW/NEXT(sdd 자동), Phase 진행률, spec-x 대기, Icebox(수동), 대기 Phase, 완료
  3. `sources/templates/phase.md` — spec 표에 In Progress 마킹 추가
  4. `sdd status` — NOW 외에 NEXT(phase 내 다음 미완료 spec) 출력 추가
  5. `sdd queue` — raw cat 대신 NOW/NEXT 하이라이트 포함 구조화 출력
  6. 현재 `backlog/queue.md` 및 `agent/constitution.md` 도그푸딩 반영
- **연관 모듈**: `sources/governance/constitution.md`, `sources/templates/queue.md`, `sources/templates/phase.md`, `sources/bin/sdd`

### spec-8-002 — Phase base branch 지원 (opt-in)

- **요점**: `sdd phase new --base` 플래그로 phase base branch 모드를 선언하고, hk-ship이 첫 PR 시점에 phase 브랜치를 just-in-time으로 생성한다
- **방향성**:
  1. `sdd phase new --base` — state.json / phase.md에 `baseBranch: true` 기록 (브랜치는 아직 생성 안 함)
  2. hk-ship에서 PR 직전: phase base branch 모드이면 phase 브랜치 존재 여부 확인 → 없으면 `git checkout -b phase-N main && git push -u origin phase-N` 자동 실행 후 PR target을 phase 브랜치로 변경
  3. `constitution.md` §5.4 브랜치 규칙 확장 — Phase base branch 명명 규칙 추가
  4. phase.md 메타 테이블에 **Base Branch** 항목 추가
- **연관 모듈**: `sources/bin/sdd`, `sources/commands/hk-ship.md`, `sources/governance/constitution.md`

### spec-8-003 — 완료 흐름 강제 (hk-ship 재설계)

- **요점**: hk-ship에 `sdd archive` 필수화, spec/phase done 자동 유도, spec-x/FF 완료 후 queue 갱신 규칙을 강제한다
- **방향성**:
  1. hk-ship에 체크포인트 추가: `sdd archive` 미실행 시 경고(warn 모드) 또는 차단(block 모드)
  2. `sdd archive` 성공 후 phase.md spec 상태 자동 Merged 갱신
  3. 해당 phase의 모든 spec이 Merged이면 phase done 유도 프롬프트 출력
  4. spec-x hk-ship 흐름에 queue.md 완료 섹션 갱신 단계 추가
  5. FF 완료 후 state.json이 변경되지 않음을 보장 (FF는 state를 건드리지 않는 원칙)
- **연관 모듈**: `sources/commands/hk-ship.md`, `sources/bin/sdd`, `sources/governance/agent.md`

### spec-8-004 — hk-align 강화 & 거버넌스 통합

- **요점**: hk-align이 NOW/NEXT/Icebox를 명확히 출력하고, agent.md에 작업 유형별 진입·종료 행동 규칙을 일괄 명문화한다
- **방향성**:
  1. hk-align 출력에 NOW/NEXT/Icebox 현황 섹션 추가 ("다음 작업은?" 즉시 답 가능)
  2. `agent.md` §3 Alignment Phase에 작업 유형별 행동 규칙 표 추가
  3. `agent.md` §6.3에 FF/spec-x/phase 완료 후 필수 체크리스트 명문화
  4. phase-8 자체가 base branch 모드이므로 도그푸딩 검증 포함
- **연관 모듈**: `sources/commands/hk-align.md`, `sources/governance/agent.md`, `agent/agent.md`

## 🧪 통합 테스트 시나리오

> phase-8는 base branch 모드로 진행 — 통합 테스트는 phase-8 브랜치에서 실행 후 main merge.

### 시나리오 1: NOW/NEXT 출력 정확성
- **Given**: phase-8 진행 중, spec-8-001 완료(Merged), spec-8-002 In Progress
- **When**: `sdd status` 실행
- **Then**: `NOW: spec-8-002`, `NEXT: spec-8-003` 출력
- **연관 SPEC**: spec-8-001

### 시나리오 2: Phase base branch just-in-time 생성
- **Given**: phase-8가 base branch 모드, spec-8-002 작업 완료, phase-8 브랜치 미존재
- **When**: hk-ship 실행
- **Then**: phase-8 브랜치 자동 생성 → spec-8-002 PR이 phase-8 타깃으로 생성됨
- **연관 SPEC**: spec-8-002

### 시나리오 3: hk-ship archive 강제
- **Given**: spec 작업 완료, `sdd archive` 미실행 상태
- **When**: hk-ship 실행
- **Then**: 경고 또는 차단 메시지 출력, archive 없이 push 진행 안 됨
- **연관 SPEC**: spec-8-003

### 시나리오 4: "다음 작업은?" 즉시 답 가능
- **Given**: phase-8 진행 중 + spec-x 하나 Icebox에 있음
- **When**: hk-align 실행
- **Then**: NOW/NEXT/Icebox 현황이 명확히 출력됨
- **연관 SPEC**: spec-8-004

### 통합 테스트 실행
```bash
# 수동 검증 — 자동화 시나리오는 각 spec의 단위 테스트로 커버
bash tests/test-phase8-integration.sh
```

## 🔗 의존성

- **선행 phase**: phase-7 (완료)
- **외부 시스템**: 없음
- **spec 내부 의존성**: spec-8-001 → spec-8-002, 003 / spec-8-001, 002, 003 → spec-8-004

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| hk-ship archive 강제가 기존 워크플로우 마찰 증가 | 사용자 불편 | warn 모드로 시작, 1주 후 block 승격 (Hook 단계론 준수) |
| phase base branch 도입 시 merge conflict 증가 | spec 간 충돌 | spec 단위를 독립적으로 유지, phase.md에 의존성 명시 |
| sdd queue 구조 변경 시 기존 queue.md 호환성 | 이전 format이 깨짐 | sdd가 마커 기반으로 점진적 갱신, 구형 포맷 fallback |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC이 `phase-8` 브랜치에 merge
- [ ] `phase-8` → `main` PR 완료
- [ ] 통합 테스트 시나리오 4종 PASS
- [ ] `sdd status`에서 NOW/NEXT 정상 출력 확인
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값 등 -->
