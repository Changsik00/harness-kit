# refactor(spec-8-001): 작업 분류 모델 정의 & Queue NOW/NEXT/Icebox 재설계

## 📋 Summary

### 배경 및 목적

harness-kit에 작업 유형(Phase/Spec/spec-x/Icebox)의 역할과 경계가 명문화되어 있지 않았고, queue.md에서 "지금 뭘 하고 있는지, 다음은 뭔지"를 즉시 파악할 수 없었다. 또한 `sdd status`가 현재 spec만 알고 다음 spec은 계산하지 않았다.

### 주요 변경 사항
- [x] `constitution.md` §3 Work Type Model 추가 — Phase/Spec/spec-x/Icebox 각각의 역할·진입·종료 조건 명문화
- [x] `queue.md` 템플릿 재설계 — NOW/NEXT(최상단 포커스) + Icebox(아이디어 보관소) 구조 도입
- [x] `phase.md` 템플릿 — Base Branch 필드 추가, `In Progress` 상태 값 추가
- [x] `sdd status` — NEXT 항목 추가 (phase.md에서 첫 번째 Backlog spec 자동 계산)
- [x] `sdd queue` — 구조화 출력(색상 하이라이트) + `--raw` 플래그 추가

### Phase 컨텍스트
- **Phase**: `phase-8` (base branch 모드, 도그푸딩 첫 사례)
- **본 SPEC 의 역할**: 작업 관리 모델의 기반 정의 — spec-8-002(phase base branch), spec-8-003(완료 흐름 강제), spec-8-004(hk-align 강화)가 이 모델 위에 구축됨

## 🎯 Key Review Points

1. **constitution §3 Work Type Model**: Phase/Spec/spec-x/Icebox의 경계가 명확한지, 진입·종료 조건이 실제 워크플로우와 일치하는지
2. **compute_next_spec() 구현**: phase.md spec 표 파싱이 다양한 포맷에서 안정적으로 동작하는지 (awk `|` 구분자 파싱)
3. **queue.md 마커 구조**: 신규 마커(`sdd:now`, `sdd:next`, `sdd:specx`)가 기존 마커와 충돌 없이 공존하는지

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-queue-redesign.sh
```

**결과 요약**:
- ✅ `sdd status NEXT 행 존재`: 통과
- ✅ `NEXT = 첫 번째 Backlog spec`: 통과
- ✅ `sdd queue NOW/NEXT/Icebox 섹션`: 통과
- ✅ `sdd queue --raw 원문 출력`: 통과
- ✅ `모든 Merged 시 NEXT = 없음`: 통과

### 수동 검증 시나리오
1. `sdd status` → `NEXT: spec-8-002-phase-base-branch` 출력 확인
2. `sdd queue` → 색상 하이라이트된 NOW/NEXT/Icebox 섹션 확인
3. `sdd queue --raw` → 마커 포함 원문 출력 확인

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-queue-redesign.sh`: TDD 단위 테스트 5종

### 🛠 Modified Files
- `sources/governance/constitution.md` (+85, -30): §3 Work Type Model 추가, §3~§11 → §4~§12 번호 재부여
- `agent/constitution.md` (+85, -30): 도그푸딩 반영 (동일 변경)
- `sources/templates/queue.md` (+45, -15): NOW/NEXT/Icebox 구조로 재설계
- `sources/templates/phase.md` (+6, -1): Base Branch 필드, In Progress 상태 추가
- `scripts/harness/bin/sdd` (+42, -5): compute_next_spec(), cmd_status NEXT, cmd_queue 구조화 출력
- `backlog/queue.md` (+41, -13): 도그푸딩 반영 (신규 구조)

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (5/5)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-8.md`
- Walkthrough: `specs/spec-8-001-queue-redesign/walkthrough.md`
