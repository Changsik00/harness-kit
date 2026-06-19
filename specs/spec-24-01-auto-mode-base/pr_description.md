# feat(spec-24-01): add auto mode (CLI + status + hook 인식)

## 📋 Summary

### 배경 및 목적
ADR-009(accepted)가 정의한 `auto`(자율·unattended) 모드를 *선택할 방법 자체가 없었다*. 본 SPEC 은 후속(24-03 정지규칙, 24-04 논블로킹 결정)이 올라탈 **모드 토대** 를 만든다 — auto 의 행동은 일단 turbo 동급으로 두고 plumbing 만.

### 주요 변경 사항
- [x] `sdd mode auto` 추가 (state.mode=auto, settings git push 허용, status/help 표시)
- [x] 모드 게이트 훅 4개가 auto 를 turbo 와 동일 인식: `check-plan-accept`·`check-scope`·`post-commit-verify`
- [x] **버그 수정**: `pre-commit.sh` 가 mode 를 무시해 turbo 에서 *편집은 되는데 커밋만 막히던* 불일치 해소 (turbo/auto 면제, lint/secret 은 유지)
- [x] ADR-009 frontmatter 인라인 주석 제거 (phase16 integration 적발분)

### Phase 컨텍스트
- **Phase**: `phase-24` (auto 모드)
- **본 SPEC 의 역할**: 모드 토대 — 24-02~05 가 얹힐 기반

## 🎯 Key Review Points

1. **pre-commit turbo 버그 수정**: 편집 게이트(`check-plan-accept`)와 커밋 게이트(`pre-commit`)의 mode 인식 불일치였음. lint/secret(blast-radius 가드)은 그대로 유지하고 Plan Accept 게이트만 면제하는지 확인.
2. **auto = turbo 동급(현재)**: 토대 단계라 의도적으로 동일. 정지규칙·결정로그는 24-03, 논블로킹 결정은 24-04. "이름만 auto" 임을 spec 에 명시.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-mode-auto.sh
```
**결과 요약**:
- ✅ `test-mode-auto`: 6/6 (전환·상태·status·훅 비차단·control·잘못된 모드 거부)
- ✅ 전체 스위트: 67/67

### 수동 검증 시나리오
1. `sdd mode auto` → `sdd status`: `Active Mode: auto` 표시
2. auto + active spec + planAccepted=false 에서 production 편집 hook: exit 0 (비차단)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-mode-auto.sh`: auto 모드 토대 테스트

### 🛠 Modified Files
- `sources/bin/sdd` (+ 미러): cmd_mode auto case, _settings_mode_patch, cmd_status, help
- `sources/hooks/check-plan-accept.sh`·`check-scope.sh`·`post-commit-verify.sh` (+ 미러): turbo|auto 인식
- `sources/hooks/pre-commit.sh` (+ 미러): turbo/auto Plan Accept 게이트 면제 (버그 수정)
- `docs/decisions/ADR-009-...md`: frontmatter 주석 제거

## ✅ Definition of Done
- [x] 모든 단위 테스트 통과 (67/67)
- [x] `walkthrough.md` / `pr_description.md` ship commit
- [x] lint 통과 (shellcheck 미설치 — skip)
- [x] 사용자 검토 요청

## 🔗 관련 자료
- Phase: `backlog/phase-24.md`
- 관련 ADR: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md`
