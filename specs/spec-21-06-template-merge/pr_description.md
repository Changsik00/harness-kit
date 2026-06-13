# refactor(spec-21-06): spec+plan 통합 및 SDD 산출물 경량화

## 📋 Summary

### 배경 및 목적

spec.md와 plan.md는 항상 같은 세션에서 연속으로 작성되고 Plan Accept도 둘 다 작성한 후에야 열렸다. 분리가 만드는 안전장치가 없으면서 ADR 후보·Mermaid 섹션이 두 파일에 중복 등장하고, task.md는 spec/plan/task 작성 자체를 task로 추적하는 메타 ceremony였다.

### 주요 변경 사항

- [x] `spec.md` + `plan.md` → 단일 `spec.md` 통합 (배경/요구사항 + 전략/Proposed Changes/검증 계획 병합)
- [x] `plan.md` 템플릿 삭제 (`sources/templates/plan.md`, `.harness-kit/agent/templates/plan.md`)
- [x] `task.md` 템플릿 — Pre-flight 섹션·진행 요약 테이블 제거
- [x] `walkthrough.md` 템플릿 — 관련 문서·메타 테이블·ADR 승격 가이드 prose 제거
- [x] `sdd spec new` → spec.md + task.md 2파일만 생성 (plan.md 제거)
- [x] `check-scope.sh` → 스코프를 plan.md 대신 spec.md의 Proposed Changes에서 읽음
- [x] `sdd plan accept` → plan+task 검증에서 spec+task 검증으로
- [x] `sdd status` Artifacts 표시 → plan ✓/✗ 제거
- [x] 거버넌스 문서(constitution.md, agent.md) plan.md 참조 → spec.md 업데이트
- [x] 테스트 5개 업데이트 (plan.md fixture → spec.md, Check 4 제거 등)

### Phase 컨텍스트
- **Phase**: `phase-21` (Ceremony 경량화)
- **본 Spec의 역할**: 문서 ceremony 감소 — spec당 파일 수 3→2, 중복 섹션 제거

## 🎯 Key Review Points

1. **check-scope.sh**: `plan.md` → `spec.md` 경로 변경. Proposed Changes 섹션 파싱 로직은 동일.
2. **plan_accept()**: `for f in plan task` → `for f in spec task`. spec.md placeholder 검사로 대체.
3. **기존 spec 디렉토리**: plan.md 소급 삭제 없음 — 과거 산출물 보존.

## 🧪 Verification

```bash
bash tests/run.sh
```

**결과**: PASS 56 / FAIL 7 (신규 FAIL 없음 — 7개 모두 pre-existing)

## 📦 Files Changed

### 🗑 Deleted Files
- `sources/templates/plan.md`
- `.harness-kit/agent/templates/plan.md`

### 🛠 Modified Files
- `sources/templates/spec.md` — plan 섹션 병합
- `sources/templates/task.md` — Pre-flight·진행 요약 제거
- `sources/templates/walkthrough.md` — 빈 placeholder 섹션 제거
- `sources/bin/sdd` / `.harness-kit/bin/sdd` — spec_new, plan_accept, spec_show 업데이트
- `sources/hooks/check-scope.sh` / `.harness-kit/hooks/check-scope.sh` — plan.md → spec.md
- `sources/governance/constitution.md` / `.harness-kit/agent/constitution.md`
- `sources/governance/agent.md` / `.harness-kit/agent/agent.md`
- `tests/test-install-layout.sh`, `test-sdd-spec-completeness.sh`, `test-sdd-status-cross-check.sh`, `test-turbo-hooks.sh`, `test-turbo-mode.sh`
