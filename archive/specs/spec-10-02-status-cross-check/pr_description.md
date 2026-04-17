# feat(spec-10-02): sdd status 자기 진단 엔진 추가

## 📋 Summary

### 배경 및 목적

`sdd status`는 state.json과 phase.md 값을 그대로 출력만 하여, 에이전트가 현재 상황을 스스로 판단하지 못하고 유저에게 불필요한 질문을 반복하는 문제가 있었다. 브랜치명 해석, git 이력 교차 검증, state.json 정합성 검사를 추가하여 자기 진단 도구로 강화한다.

### 주요 변경 사항
- [x] `_infer_work_mode()`: 브랜치 패턴에서 work mode 자동 추론 (SDD-P/SDD-x/phase base)
- [x] `_status_diagnose()`: phase.md ↔ git 교차 검증 + state.json 정합성 검사 + 행동 제안
- [x] Branch 라인에 work mode 표시: `Branch: spec-10-02-... (SDD-P (phase-10))`
- [x] 진단 섹션 `🔍 진단`: 불일치 발견 시만 표시, 구체적 정리 명령 안내

### Phase 컨텍스트
- **Phase**: `phase-10` (sdd 상태 진단 신뢰성 강화)
- **본 SPEC 의 역할**: status 명령의 자기 진단 능력을 확보하여 에이전트가 상태를 스스로 파악할 수 있게 함

## 🎯 Key Review Points

1. **awk `-F'|'` 파싱**: `$0`에서 `|`가 제거되므로 `$5` 필드로 직접 상태 비교. 기존 코드(`compute_next_spec`, `_check_phase_all_merged`)는 `$0` 패턴 사용 중 — 이번 spec에서는 신규 함수만 수정.
2. **pipefail 대응**: `git log | grep` 대신 git log를 변수에 캐시 후 grep. `set -uo pipefail` 환경에서 SIGPIPE 방지.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-status-cross-check.sh
```

**결과 요약**:
- ✅ Check 1: 브랜치 패턴 → work mode 추론 (4개 서브체크)
- ✅ Check 2: phase.md Done + git 머지됨 → 경고 + 행동 제안
- ✅ Check 3: state.json spec=null + phase=active → 안내
- ✅ Check 4: planAccepted=true + plan.md 없음 → 경고

### 전체 회귀
15개 테스트 파일 전부 PASS (0 failures)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-status-cross-check.sh`: status 자기 진단 단위 테스트 (4 시나리오, 7 체크)

### 🛠 Modified Files
- `sources/bin/sdd` (+124, -1): `_infer_work_mode`, `_status_diagnose` 함수 추가 + `cmd_status` 통합
- `.harness-kit/bin/sdd` (+124, -1): 도그푸딩 동기화

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-10.md`
- Walkthrough: `specs/spec-10-02-status-cross-check/walkthrough.md`
