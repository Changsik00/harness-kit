# fix(spec-x-hook-bypass-fix): git pre-commit hook 추가 및 오버브로드 deny 규칙 수정

## 📋 Summary

### 배경 및 목적

harness-kit 훅은 `Edit|Write|MultiEdit` 툴만 보호하고 `Bash` 툴은 보호하지 않아, `echo > file` / `tee` 등 Bash 파일 쓰기로 Plan Accept gate를 우회할 수 있었다. 또한 `sources/claude-fragments/settings.json.fragment`의 `Write(~/**)` / `Edit(~/**)` deny 규칙이 홈 디렉토리 전체를 차단해 프로젝트 내 Edit/Write 툴이 동작하지 않는 역설적 상황이 발생했다.

### 주요 변경 사항
- [x] `sources/hooks/pre-commit.sh` 신규 추가 — staged-lint 실행 + Plan Accept 전 production 파일 staged 시 커밋 차단
- [x] `install.sh` — `.git/hooks/pre-commit` 설치 단계 추가 (idempotent, `--no-hooks` 연동)
- [x] `uninstall.sh` — `.git/hooks/pre-commit` harness 마커 블록 제거 단계 추가
- [x] `doctor.sh` — git pre-commit hook 설치 여부 체크 추가 (미설치 시 WARN + 재설치 안내)
- [x] `sources/claude-fragments/settings.json.fragment` — `Write/Edit(~/**)` → `~/.ssh/**`, `~/.aws/**`, `~/.gnupg/**`, `~/.config/gcloud/**` 구체적 경로로 교체

### Phase 컨텍스트
- **Phase**: 없음 (spec-x — 독립 수정)
- **본 SPEC의 역할**: 거버넌스 훅 bypass 취약점 수정 + Edit/Write 툴 정상화

## 🎯 Key Review Points

1. **`pre-commit.sh` whitelist 일치 여부**: `check-plan-accept.sh`의 whitelist와 동일하게 유지되어야 함 (`.harness-kit/`, `docs/`, `backlog/`, `specs/`, `.claude/`, `*.md`, `.gitignore`, `CLAUDE.md`, `version.json`)
2. **`install.sh` idempotent 보장**: 기존 `.git/hooks/pre-commit`이 있을 때 harness 마커 블록만 append하고, 재설치 시 중복 삽입 없음
3. **`uninstall.sh` awk 로직**: harness 블록만 제거하고 나머지 사용자 내용 보존. 파일이 비어지면 삭제

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-git-precommit-hook.sh
bash tests/test-install-settings-hook.sh
bash tests/test-staged-lint.sh
bash tests/test-hk-doctor.sh
bash tests/test-update.sh
```

**결과 요약**:
- ✅ `test-git-precommit-hook`: 10/10 PASS (신규)
- ✅ `test-install-settings-hook`: 7/7 PASS (Test 6 신규 포함)
- ✅ `test-staged-lint`: 6/6 PASS
- ✅ `test-hk-doctor`: 6/6 PASS
- ✅ `test-update`: 11/11 PASS

### 수동 검증 시나리오
1. `bash install.sh . --yes` → `.git/hooks/pre-commit` 생성 + `doctor.sh .` → PASS 출력
2. planAccepted=false 상태에서 production 파일 `git add` + `git commit` → 차단 메시지 출력
3. `bash uninstall.sh . --yes` → `.git/hooks/pre-commit` harness 블록 제거

## 📦 Files Changed

### 🆕 New Files
- `sources/hooks/pre-commit.sh`: git pre-commit hook — staged-lint + plan-accept 검증

### 🛠 Modified Files
- `install.sh` (+30): `.git/hooks/pre-commit` 설치 단계 추가
- `uninstall.sh` (+14): harness 블록 제거 단계 추가
- `doctor.sh` (+10): git pre-commit hook 설치 여부 체크
- `sources/claude-fragments/settings.json.fragment` (+6, -2): `~/**` → 구체적 경로
- `tests/test-install-settings-hook.sh` (+25): deny 규칙 테스트 추가
- `tests/test-git-precommit-hook.sh` (신규, +194): 통합 검증 테스트

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-hook-bypass-fix/walkthrough.md`
