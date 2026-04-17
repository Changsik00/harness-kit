# Implementation Plan: spec-09-11

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-11-backlog-sync`
- 시작 지점: `phase-09-install-conflict-defense`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `sdd archive` 후 state.json의 `spec`을 `null`로 초기화하면, archive 직후 `sdd status`에서 active spec이 "없음"으로 표시됨. 기존에 archive → push → PR 을 순차적으로 하는 흐름에 영향 없는지 확인
> - [ ] queue.md NOW/NEXT 섹션 제거 시, 기존 도그푸딩 프로젝트(이 repo)의 queue.md에서도 해당 섹션을 제거할 것인지

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
sdd archive (현재)              sdd archive (개선 후)
─────────────────               ─────────────────────
1. walkthrough 검증              1. walkthrough 검증
2. git commit                   2. git commit
3. phase.md Merged 갱신          3. phase.md Merged 갱신
   (In Progress만 매칭)            (Active + In Progress 모두 매칭)
4. phase done 유도               4. state.json 초기화
                                5. queue.md active 갱신
                                6. NEXT spec 안내 출력
                                7. phase done 유도
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **state 초기화** | archive 끝에서 `spec=null`, `planAccepted=false` | archive = "이 spec 작업 완료"이므로 상태 초기화가 자연스러움 |
| **NOW/NEXT** | 템플릿에서 제거 (compute, don't store) | state.json + compute_next_spec이 SSOT. 중복 저장은 동기화 실패 위험 |
| **agent.md** | §6.3에 "PR 머지 후 절차" 서브섹션 추가 | 에이전트가 머지 후 맥락을 이어가는 명시적 프로시저 필요 |

## 📂 Proposed Changes

### sdd CLI

#### [MODIFY] `sources/bin/sdd` — `cmd_archive` (L644~702)

1. awk 패턴에 `| Active |` 추가:
```bash
# 변경 전
/\| In Progress \|/
# 변경 후
/\| In Progress \|/ || /\| Active \|/
```

2. archive 커밋 후, phase.md 갱신 후에 state 초기화 + queue 갱신 + NEXT 안내:
```bash
state_set spec "null"
state_set planAccepted "false"
queue_set_active_progress

local next
next="$(compute_next_spec "$phase_id")"
if [ "$next" != "없음" ]; then
  log "⏭ 다음: $next → sdd spec new ${next#spec-*-*-}"
fi
```

#### [MODIFY] `sources/bin/sdd` — `queue_set_active_progress` (L324~346)

미사용 변수 `merged`, `next_spec` 제거.

### queue.md 템플릿

#### [MODIFY] `sources/templates/queue.md`

NOW/NEXT 마커 섹션 제거 (`## 🔴 NOW` ~ `<!-- sdd:next:end -->` 전체 삭제).

### 거버넌스 문서

#### [MODIFY] `sources/governance/agent.md` — §6.3 뒤에 추가

"PR 머지 후 절차 (Post-Merge Protocol)" 서브섹션:
- 사용자가 "머지 완료" 전달 → 에이전트가 `sdd status` 실행
- NEXT spec 확인 → 다음 spec 시작 제안
- 사용자 승인 후 `sdd spec new <slug>`

### 도그푸딩 동기화

#### [MODIFY] `.harness-kit/bin/sdd`

`sources/bin/sdd`와 동일하게 갱신 (도그푸딩 사본).

#### [MODIFY] `.harness-kit/agent/agent.md`

`sources/governance/agent.md`와 동일하게 갱신 (도그푸딩 사본).

#### [MODIFY] `.harness-kit/agent/templates/queue.md`

`sources/templates/queue.md`와 동일하게 갱신 (도그푸딩 사본).

#### [MODIFY] `backlog/queue.md`

NOW/NEXT 섹션 제거하여 새 템플릿과 일치시킴.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/run-all.sh
```

### 통합 테스트
```bash
# test fixture에서 sdd archive 실행 후:
# 1. state.json spec=null, planAccepted=false 확인
# 2. phase-N.md에서 Active → Merged 전이 확인
# 3. queue.md active 섹션 갱신 확인
# 4. stdout에 NEXT spec 안내 출력 확인
```

### 수동 검증 시나리오
1. `sdd archive` 실행 → state.json 확인: `spec=null`, `planAccepted=false`
2. phase-09.md에서 `| Active |` 행이 `| Merged |`로 전이되었는지 확인
3. `sdd status` 실행 → Active Spec: 없음, NEXT: 다음 Backlog spec 표시 확인

## 🔁 Rollback Plan

- `sources/bin/sdd`를 `git revert`로 이전 커밋으로 복원
- 도그푸딩 사본(`.harness-kit/`)은 `install.sh`로 재동기화

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
