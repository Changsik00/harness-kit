# fix(spec-09-011): backlog 대시보드 동기화 자동화

## 📋 Summary

### 배경 및 목적

`sdd archive` 실행 후 phase-N.md와 queue.md가 실제 진행 상황과 동기화되지 않아, "지금 어디, 다음 뭐" 파악이 불가능했다. 또한 PR 머지 후 에이전트가 다음 spec으로 맥락을 이어가는 절차가 정의되어 있지 않았다.

### 주요 변경 사항

- [x] `cmd_archive` 후처리 보강: state.json 초기화 + `| Active |` 매칭 + queue.md 갱신 + NEXT 안내
- [x] queue.md 템플릿 NOW/NEXT dead code 제거 (compute, don't store 원칙)
- [x] agent.md §6.3.1 Post-Merge Protocol 추가 (머지 후 맥락 연속성)
- [x] 테스트를 새 레이아웃(`.harness-kit/`)으로 마이그레이션 + 신규 케이스 추가

### Phase 컨텍스트

- **Phase**: `phase-09`
- **본 SPEC의 역할**: archive 후 대시보드 정합성 보장으로 SDD 워크플로우 연속성 확보

## 🎯 Key Review Points

1. **`cmd_archive` state 초기화 타이밍**: archive commit → phase.md 갱신 → state 초기화 → queue 갱신 → NEXT 안내 순서가 올바른지
2. **`| Active |` awk 매칭**: 기존 `| In Progress |`에 더해 `| Active |`도 `| Merged |`로 전이. 두 패턴 모두 `sub()`으로 처리

## 🧪 Verification

### 통합 테스트
```bash
bash tests/test-sdd-archive-completion.sh
```

**결과 요약**:
- ✅ In Progress → Merged 전이
- ✅ Active → Merged 전이
- ✅ state.json 초기화 (spec=null, planAccepted=false)
- ✅ phase done 유도 메시지
- ✅ NEXT spec 안내 출력
- ✅ specx done → queue.md 이동

## 📦 Files Changed

### 🛠 Modified Files

- `sources/bin/sdd`: cmd_archive 후처리 + queue_set_active_progress 정리
- `.harness-kit/bin/sdd`: 도그푸딩 동기화
- `sources/templates/queue.md`: NOW/NEXT 섹션 제거
- `.harness-kit/agent/templates/queue.md`: 도그푸딩 동기화
- `backlog/queue.md`: NOW/NEXT 섹션 제거
- `sources/governance/agent.md`: §6.3.1 Post-Merge Protocol 추가
- `.harness-kit/agent/agent.md`: 도그푸딩 동기화
- `tests/test-sdd-archive-completion.sh`: 새 레이아웃 + 신규 테스트

**Total**: 8 files changed
