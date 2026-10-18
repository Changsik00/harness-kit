# feat(spec-24-02): commit-time scope check (dual-mode, 경고)

## 📋 Summary

### 배경 및 목적
ADR-009 Consequences: MCP 경유 편집(Serena 쓰기 등)이 `Edit|Write` 매처를 우회해 scope 검사를 안 거친다. auto(unattended)에서 특히 위험. scope 를 *도구가 아니라 diff* 기준의 blast-radius 가드로 만들기 위해 커밋 시점 검사를 추가.

### 주요 변경 사항
- [x] `check-scope.sh` dual-mode — scope 추출/매칭/안전경로/전제를 헬퍼로 분리(DRY)
- [x] commit 모드(`HARNESS_GIT_HOOK_MODE=1`): staged diff 전체 검사, **mode 무관**(turbo/auto 도) + **경고만(exit 0)**
- [x] `pre-commit.sh` 가 secret 뒤 scope(commit 모드) 호출
- [x] edit 모드는 기존대로 (turbo/auto bypass, 차단형)

### Phase 컨텍스트
- **Phase**: `phase-24` — auto 모드의 blast-radius 가드 정렬(선행조건)

## 🎯 Key Review Points

1. **mode 무관 + 경고 only 의 조합**: commit 모드는 turbo/auto 에서도 검사하지만(도구 무관 노출) 차단하지 않는다(auto 안 멈춤). blast-radius 를 사후 노출(phase-ship)하는 ADR-009 패턴.
2. **edit vs commit 동작 차이가 의도적**: edit=mode bypass+차단, commit=mode무관+경고. 헷갈리지 않게 헤더 주석에 명시.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-scope-commit.sh
```
**결과 요약**: ✅ 4/4 (범위밖 경고+exit0 / 범위안 무경고 / auto 에서도 경고 / .md 면제), 전체 68/68

### 수동 검증 시나리오
1. plan-accepted spec 에서 scope 밖 파일 staged + 커밋 → 커밋 성공 + stderr scope 경고
2. mode=auto 동일 → 여전히 경고 (mode 무관)

## 📦 Files Changed

### 🆕 New Files
- `tests/test-scope-commit.sh`: commit 모드 scope 검증

### 🛠 Modified Files
- `sources/hooks/check-scope.sh` (+ 미러): dual-mode 리팩터 (헬퍼 분리 + commit 분기)
- `sources/hooks/pre-commit.sh` (+ 미러): scope(commit 모드) 호출 추가

## ✅ Definition of Done
- [x] 모든 테스트 통과 (68/68)
- [x] walkthrough / pr_description ship commit
- [x] lint (shellcheck 미설치 — skip)
- [x] 사용자 검토 요청

## 🔗 관련 자료
- Phase: `backlog/phase-24.md`
- 관련 ADR: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md`
