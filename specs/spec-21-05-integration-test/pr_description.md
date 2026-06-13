# test(spec-21-05): add turbo mode integration tests and run.sh

## 📋 Summary

### 배경 및 목적

spec-21-01~04로 Turbo 모드 전체 컴포넌트가 구현됐으나 end-to-end 통합 테스트가 없었다. 모드 전환 → 훅 분기 → 커밋 → 사후 검증 → revert 흐름을 하나의 시나리오로 검증하고, `tests/run.sh`로 전체 테스트 실행 진입점을 제공한다.

### 주요 변경 사항
- [x] `tests/test-turbo-mode.sh` — 4개 통합 시나리오 (5개 assertions)
  - S1: `sdd mode turbo` 활성화 후 `check-plan-accept` 무차단 (happy path)
  - S2: `intent.test` FAIL → `post-commit-verify` 가 자동 revert
  - S3: `sdd mode governed` 복귀 후 `check-plan-accept` 재차단
  - S4-a/b: governed 기본 상태에서 훅 정상 차단 (회귀)
- [x] `tests/run.sh` — 전체 테스트 스위트 실행 진입점 (`--fast` 옵션 지원)

### Phase 컨텍스트
- **Phase**: `phase-21` (Turbo 모드 추가)
- **본 SPEC 의 역할**: phase-21 Done 조건 충족 — 통합 테스트 시나리오 검증 + 전체 회귀 기준선 수립

## 🎯 Key Review Points

1. **S2 revert 검증**: 메시지 grep 대신 commit 수 비교 사용 — `before < after` 이면 revert commit 생성 확인. locale/format 변화에 강건
2. **run.sh 기존 실패 6개**: 모두 phase-21 이전 pre-existing 이슈. Turbo 관련 0 실패 확인
3. **격리**: 각 시나리오 독립 tmpdir — 실제 `.claude/state/` 무영향

## 🧪 Verification

### 통합 테스트
```bash
bash tests/test-turbo-mode.sh
```

**결과**: ✅ 5/5 PASS

### 전체 회귀 테스트
```bash
bash tests/run.sh
```

**결과**: PASS 57 / FAIL 6 (6개 모두 pre-existing, Turbo 관련 0 실패)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-turbo-mode.sh`: Turbo 모드 end-to-end 통합 테스트 (4 시나리오)
- `tests/run.sh`: 전체 테스트 스위트 실행 진입점

**Total**: 2 files changed

## ✅ Definition of Done

- [x] 통합 테스트 5/5 PASS
- [x] Turbo 관련 회귀 0 확인 (run.sh)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-21.md`
- Walkthrough: `specs/spec-21-05-integration-test/walkthrough.md`
- 선행 spec: `specs/spec-21-01-mode-schema/` ~ `specs/spec-21-04-governance-update/`
