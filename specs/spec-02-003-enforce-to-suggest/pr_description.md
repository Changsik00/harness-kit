# feat(spec-02-003): Hook 모드 분리 및 전환 UX

## 📋 Summary

### 배경 및 목적
모든 hook이 동일한 `HARNESS_HOOK_MODE` 환경변수를 공유하여 개별 제어 불가. main 브랜치 보호(check-branch)는 안전 관련이므로 항상 block이어야 하지만, 다른 hook과 같은 warn 기본값을 사용 중.

### 주요 변경 사항
- [x] `_lib.sh`에 per-hook 모드 해석 추가 (`HARNESS_HOOK_MODE_{NAME}` 우선)
- [x] check-branch.sh: 기본 `block` (main 보호 강화)
- [x] check-plan-accept/test-passed: 기본 `warn` 유지 (명시적)
- [x] `sdd hooks` 서브커맨드: 모드 조회 및 전환 안내

### Phase 컨텍스트
- **Phase**: `phase-02` — 토큰 최적화 & 거버넌스 경량화
- **본 SPEC 의 역할**: 불필요한 강제를 제안으로 전환, main 보호는 강화

## 🎯 Key Review Points

1. **check-branch.sh block 기본값**: main에서 실수 commit 시도 시 차단됨. 의도적 동작.
2. **per-hook 환경변수**: `HARNESS_HOOK_MODE_BRANCH=warn`으로 개별 override 가능.

## 🧪 Verification

```bash
bash tests/test-hook-modes.sh
```
✅ 12/12 PASS

## 📦 Files Changed

### 🛠 Modified Files
- `sources/hooks/_lib.sh` (+28, -7): hook_resolve_mode 함수 추가
- `sources/hooks/check-branch.sh` (+1): hook_resolve_mode BRANCH block
- `sources/hooks/check-plan-accept.sh` (+1): hook_resolve_mode PLAN_ACCEPT warn
- `sources/hooks/check-test-passed.sh` (+1): hook_resolve_mode TEST_PASSED warn
- `sources/bin/sdd` (+71, -2): hooks 서브커맨드 추가
- `scripts/harness/` 동기화 (5 files)

### 🆕 New Files
- `tests/test-hook-modes.sh`: 검증 테스트 (12 checks)

**Total**: 11 files changed

## ✅ Definition of Done

- [x] 모든 테스트 통과 (12/12)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료

## 🔗 관련 자료

- Phase: `backlog/phase-02.md`
- Walkthrough: `specs/spec-02-003-enforce-to-suggest/walkthrough.md`
