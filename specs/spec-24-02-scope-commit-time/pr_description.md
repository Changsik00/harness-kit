feat(spec-24-02): add commit-time blast-radius scope guard (warn mode)

## 📋 Summary

### 배경 및 목적

blast-radius scope 불변식(constitution §6.2)은 지금까지 PreToolUse `Edit|Write|MultiEdit` 매처(`check-scope.sh`)로만 강제됐다. ADR-009 가 지적한 우회 경로 — **MCP 경유 편집(예: Serena 쓰기)은 이 매처를 우회** — 때문에 도구를 바꾸면 가드가 무력화된다. auto 모드(unattended)에서는 사람이 실시간으로 못 잡으므로 선행조건 결함이다.

본 spec 은 scope 검사를 *모든 변경이 반드시 통과하는* **git 커밋 시점** 으로 정렬해 도구 무관하게 만든다.

### 주요 변경 사항
- [x] scope 매칭 순수 로직을 `_scope.sh` 로 추출 — 편집시점·커밋시점이 동일 불변식 공유 (DRY)
- [x] `check-scope.sh` 를 `_scope.sh` 위임으로 리팩터 (behavior-preserving)
- [x] git `pre-commit.sh` 에 커밋시점 scope 검사 추가 — **경고 모드**(stderr + exit 0)
- [x] 도그푸딩 미러(`.harness-kit/hooks/`) 동시 반영

### Phase 컨텍스트
- **Phase**: `phase-24` (auto-mode)
- **본 SPEC 의 역할**: auto 모드의 *선행조건* — blast-radius 가드를 도구 무관하게 정렬해, 이후 정지규칙 엔진(24-03)·논블로킹 결정(24-04)이 안전하게 올라탈 토대를 만든다. (성공 기준 #4)

## 🎯 Key Review Points

1. **검사 동작 조건**: `planAccepted` 가 아니라 *활성 spec + spec.md scope 패턴* 으로 동작 → turbo/auto(`planAccepted=false`)의 우회를 포착하는 핵심.
2. **경고 모드**: 위반해도 `exit 0` — 기존 plan-accept 차단 로직의 exit code 와 staged-lint/secret 흐름에 영향 없음. 차단 승격은 1주 운영 후 별건.
3. **위치 선택**: Bash 매처가 아닌 git 네이티브 hook — 모든 커밋 경로 발동(walkthrough 결정 기록 참조).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-scope-commit-time.sh
bash tests/test-git-precommit-hook.sh
```

**결과 요약**:
- ✅ `test-scope-commit-time`: 7/7 통과
- ✅ `test-git-precommit-hook`: 13/13 통과 (회귀 없음)
- ✅ 전체 스위트: 68/68 통과

### 수동 검증 시나리오
1. **scope 밖 staged**: `b.sh` staged → pre-commit → `⚠ [scope:warn] ... b.sh` 출력 + exit 0(커밋 통과)
2. **scope 내 staged**: in-scope 파일 실제 커밋(Task 2·3) → 경고 없음 (라이브 도그푸딩 hook 정상)

## 📦 Files Changed

### 🆕 New Files
- `sources/hooks/_scope.sh` / `.harness-kit/hooks/_scope.sh`: scope 매칭 순수 함수 라이브러리
- `tests/test-scope-commit-time.sh`: 신규 단위 테스트 (7 케이스)

### 🛠 Modified Files
- `sources/hooks/check-scope.sh` / `.harness-kit/hooks/check-scope.sh`: inline 매칭 → `_scope.sh` 위임
- `sources/hooks/pre-commit.sh` / `.harness-kit/hooks/pre-commit.sh`: 커밋시점 scope 경고 블록 추가

**Total**: 7 files changed (+331, -54)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (신규 7/7 + 전체 68/68)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint(shellcheck 미설치 — skip) / secret 통과
- [x] 사용자 검토 요청 알림 완료 (경고 모드 시작)

## 🔗 관련 자료

- Phase: `backlog/phase-24.md`
- ADR: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md` (거버닝)
