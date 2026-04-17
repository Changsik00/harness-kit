# spec-09-11: backlog 대시보드 동기화 자동화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-09-11` |
| **Phase** | `phase-09` |
| **Branch** | `spec-09-11-backlog-sync` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | yes |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd` CLI가 SDD 워크플로우의 상태를 관리하지만, `sdd archive` 이후 대시보드(queue.md, phase-N.md)가 실제 진행 상황과 동기화되지 않는다.

- `sdd status`는 `compute_next_spec()`으로 NEXT를 실시간 계산하여 **터미널에서는** 정확한 현황을 보여줌
- 그러나 `sdd archive` 후 state.json이 초기화되지 않고, phase-N.md의 `| Active |` 상태가 `| Merged |`로 전이되지 않음
- PR 머지 후 에이전트가 "다음 뭐 해야 하지?" 맥락을 이어가는 절차가 agent.md에 정의되어 있지 않음

### 문제점

1. **`cmd_archive` 근본 버그**: state.json의 `spec`, `planAccepted`을 초기화하지 않아 archive 후에도 이전 spec을 가리킴
2. **`| Active |` 미매칭**: awk가 `| In Progress |`만 매칭 → `| Active |` 상태의 spec은 영원히 갱신 안 됨
3. **`queue_set_active_progress` 미호출**: archive 후 queue.md active 섹션이 갱신되지 않음
4. **NEXT 안내 부재**: archive 완료 후 다음 spec이 무엇인지 사용자/에이전트에게 알려주지 않음
5. **에이전트 절차 부재**: "머지 했어" → 다음 spec 시작까지의 agent.md 프로시저가 없음
6. **queue.md NOW/NEXT dead code**: 템플릿에 마커가 있으나 sdd 코드 어디서도 쓰기하지 않음

### 해결 방안 (요약)

`sdd archive` 후처리를 보강하여 한 명령으로 대시보드 정합성을 보장하고, agent.md에 PR 머지 후 절차를 추가하여 맥락이 끊기지 않도록 한다. NOW/NEXT는 "compute, don't store" 원칙으로 실시간 계산만 유지하고 queue.md dead code를 제거한다.

## 🎯 요구사항

### Functional Requirements

1. `sdd archive` 완료 시 state.json 초기화: `spec=null`, `planAccepted=false`
2. `sdd archive`의 phase-N.md awk에서 `| Active |`도 `| Merged |`로 전이
3. `sdd archive` 끝에 `queue_set_active_progress` 호출하여 queue.md active 섹션 갱신
4. `sdd archive` 완료 메시지에 NEXT spec 안내 출력 (`compute_next_spec` 활용)
5. `sources/templates/queue.md`에서 NOW/NEXT 마커 섹션 제거
6. `sources/governance/agent.md` §6.3에 "PR 머지 후 절차" 추가

### Non-Functional Requirements

1. 기존 `sdd archive --check` 동작은 변경하지 않음 (검증만 수행)
2. 기존 테스트 전체 PASS 유지
3. `queue_set_active_progress`의 미사용 변수(`merged`, `next_spec`) 정리

## 🚫 Out of Scope

- queue.md에 NOW/NEXT 마커 자동 쓰기 (compute, don't store 원칙)
- `specs/` 디렉토리의 파일 아카이빙 (`specs/_archive/` 이동 등)
- `sdd phase done`의 phase-N.md 상태 갱신 (별도 scope)

## ✅ Definition of Done

- [ ] `sdd archive` 후 state.json이 `spec=null`, `planAccepted=false`로 초기화됨
- [ ] `| Active |` 상태의 spec이 archive 시 `| Merged |`로 전이됨
- [ ] archive 완료 후 queue.md active 섹션이 정확히 갱신됨
- [ ] archive 완료 메시지에 NEXT spec 정보가 출력됨
- [ ] queue.md 템플릿에서 NOW/NEXT dead code 제거됨
- [ ] agent.md에 PR 머지 후 절차가 문서화됨
- [ ] 모든 단위 테스트 PASS
- [ ] 통합 테스트 PASS
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-09-11-backlog-sync` 브랜치 push 완료
