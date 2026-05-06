# fix(spec-x-install-fragment-fixes): install.sh·fragment 잔존 버그 2건 수정

## 📋 Summary

### 배경 및 목적

도그푸딩(2026-04-27) 중 발견되어 Icebox에 기록된 버그 2건을 수정한다. 두 버그 모두 `install.sh` 또는 `settings.json.fragment`의 동작이 의도와 다르게 작동하여 UX를 저해하는 문제였다.

### 주요 변경 사항

- [x] **install.sh self-host gitignore guard**: `.harness-kit/` 하위에 git-tracked 파일이 있으면 `.gitignore`에 `.harness-kit/` 추가를 건너뜀. harness-kit 자기 자신에 install 시 추적 파일이 ignored 처리되는 문제 해결
- [x] **fragment git push ask 제거**: `settings.json.fragment`의 `ask` 섹션에서 `Bash(git push)` / `Bash(git push:*)` 2줄 제거. 신규 install 및 update 후 매 push마다 권한 프롬프트가 뜨는 문제 해결
- [x] **테스트 2건 추가**: Scenario H (self-host guard) + Test 5 (ask 섹션 git push 부재)

### Phase 컨텍스트

- **Phase**: 없음 (spec-x)
- **본 SPEC 의 역할**: Icebox 잔존 버그 2건 독립 수정

## 🎯 Key Review Points

1. **install.sh `_hk_self_host` guard** (`install.sh:442`): `git ls-files ".harness-kit/"` 출력 유무로 self-host 감지. `HK_GITIGNORE=1`(기본 ignore 모드)일 때만 체크하므로 `--no-gitignore` 플래그 사용 시에는 영향 없음
2. **fragment ask 섹션** (`sources/claude-fragments/settings.json.fragment`): `Bash(git:*)`가 allow에 있어 git push는 이미 허용됨. ask 항목 제거 후 check-branch.sh 훅이 main 브랜치 push 보호를 단독 담당

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-gitignore-config.sh
bash tests/test-install-settings-hook.sh
```

**결과 요약**:
- ✅ `test-gitignore-config.sh`: 12 / 12 PASS (Scenario H 신규)
- ✅ `test-install-settings-hook.sh`: 5 / 5 PASS (Test 5 신규)

### 수동 검증 시나리오

1. **self-host guard**: `./install.sh --yes .` 실행 → `.gitignore`에 `.harness-kit/` 추가 안 됨
2. **git push ask 제거**: 신규 fixture에 install → `settings.json` ask 섹션에 git push 없음

## 📦 Files Changed

### 🆕 New Files
- `specs/spec-x-install-fragment-fixes/spec.md`: spec 정의
- `specs/spec-x-install-fragment-fixes/plan.md`: 구현 계획
- `specs/spec-x-install-fragment-fixes/task.md`: 작업 목록
- `specs/spec-x-install-fragment-fixes/walkthrough.md`: 작업 기록
- `specs/spec-x-install-fragment-fixes/pr_description.md`: PR 설명 (이 파일)

### 🛠 Modified Files
- `install.sh` (+9, -1): self-host gitignore guard (`_hk_self_host` 플래그)
- `sources/claude-fragments/settings.json.fragment` (+0, -2): ask에서 git push 2줄 제거
- `tests/test-gitignore-config.sh` (+25): Scenario H 추가
- `tests/test-install-settings-hook.sh` (+14): Test 5 추가
- `backlog/queue.md` (-1): phase-ship.md 템플릿 누락 항목 제거 (이미 해결됨 확인)

**Total**: 10 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-install-fragment-fixes/walkthrough.md`
