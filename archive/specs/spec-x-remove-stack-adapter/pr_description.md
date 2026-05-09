# refactor(spec-x-remove-stack-adapter): stack adapter 시스템 제거

## 📋 Summary

### 배경 및 목적

Stack adapter(`stacks/generic.sh`, `stacks/nodejs.sh`)는 프로젝트의 기술 스택을 감지하여 `HARNESS_TEST_CMD`, `HARNESS_LINT_CMD` 등 환경변수를 export하는 시스템이었다. 분석 결과 유일한 소비자가 에이전트 프롬프트(`hk-ship.md`)뿐이고, 실제 hook이나 sdd CLI에서 이 환경변수를 사용하지 않았다. 에이전트(Claude)가 프로젝트 설정 파일을 직접 읽고 판단하는 것이 더 정확하고 최신성이 보장되므로 제거한다.

### 주요 변경 사항
- [x] `stacks/` 디렉토리 및 `scripts/harness/lib/stack.sh` 삭제
- [x] `install.sh`에서 `--stack` 옵션, `detect_stack()`, stack 복사 로직 제거
- [x] `update.sh`, `doctor.sh`, `sdd` CLI에서 stack 참조 제거
- [x] `hk-ship.md`에서 환경변수 → 에이전트 직접 판단 안내로 변경
- [x] `agent.md` §6.7 Stack Awareness 섹션 삭제
- [x] 문서(`CLAUDE.md`, `README.md`, `REFERENCE.md`)에서 stack 관련 내용 제거

### Phase 컨텍스트
- **Phase**: 없음 (Solo Spec)
- **본 SPEC 의 역할**: 실효성 없는 추상화 계층 제거로 키트 단순화

## 🎯 Key Review Points

1. **hk-ship.md 품질 게이트 변경**: 환경변수 기반 → 에이전트가 프로젝트 설정 파일을 확인하여 lint/test 명령 결정. 에이전트 자율성에 의존하게 되므로 적절한지 확인 필요
2. **install.sh 호환성**: `--stack` 옵션 제거로 기존 CI 스크립트에서 이 옵션을 사용 중이라면 실패할 수 있음

## 🧪 Verification

### 수동 검증 시나리오
1. `bash -n install.sh` → 구문 오류 없음 ✅
2. `doctor.sh` 실행 → PASS 36 / WARN 1 / FAIL 0 ✅
3. `sdd status` → stack 출력 없음, 정상 동작 ✅
4. grep 잔여 참조 → spec 문서 외 없음 ✅

## 📦 Files Changed

### 🗑 Deleted Files
- `stacks/generic.sh`: fallback stack adapter
- `stacks/nodejs.sh`: Node.js stack adapter
- `scripts/harness/lib/stack.sh`: 설치된 stack adapter 결과물

### 🛠 Modified Files
- `install.sh` (+3, -43): stack 감지/복사 로직 제거
- `update.sh` (+1, -8): stack 복원 로직 제거
- `doctor.sh` (+5, -12): stack 검증 항목 제거
- `scripts/harness/bin/sdd` (+2, -7): stack 변수/출력 제거
- `sources/commands/hk-ship.md` (+6, -15): 환경변수 → 에이전트 직접 판단
- `.claude/commands/hk-ship.md` (+6, -15): 동기화
- `sources/governance/agent.md` (-5): §6.7 삭제
- `agent/agent.md` (-5): 동기화
- `sources/templates/plan.md` (+1, -1): stack adapter 참조 수정
- `agent/templates/plan.md` (+1, -1): 동기화
- `CLAUDE.md` (+3, -7): stacks 관련 설명 제거
- `README.md` (+1, -10): stack 트리/옵션/FAQ 제거
- `docs/REFERENCE.md` (+1, -63): stack 옵션/환경변수/어댑터 섹션 제거

**Total**: 16 files changed, -292 lines

## ✅ Definition of Done

- [-] 모든 단위 테스트 통과 — 테스트 대상 아님 (문서/스크립트 정리)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-remove-stack-adapter/walkthrough.md`
