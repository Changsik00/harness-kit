# feat(spec-9-006): add gitignore config option to install.sh and update.sh

## 📋 Summary

### 배경 및 목적

`install.sh`는 `.harness-kit/`가 `.gitignore`의 `.*` 패턴에 걸리는 것을 방지하기 위해 `!.harness-kit/` (un-ignore)를 무조건 추가했다. 하지만 팀에 따라 하네스 설정을 git에서 숨기고 싶은 경우도 있어 사용자 선택권이 없었다.

### 주요 변경 사항

- [x] `install.sh`: `.harness-kit/` gitignore 처리를 사용자 선택으로 변경 (기본 Y = `.harness-kit/` 추가)
- [x] `install.sh`: `--gitignore` / `--no-gitignore` 플래그 추가
- [x] `install.sh`: `harness.config.json`에 `"gitignore": true|false` 필드 저장
- [x] `update.sh`: `gitignore` 설정을 config에서 읽어 재설치 시 보존
- [x] `tests/test-gitignore-config.sh` 신설 (11 checks, TDD)
- [x] `tests/test-install-layout.sh` Check 7 업데이트 (기본값 변경 반영)

### Phase 컨텍스트

- **Phase**: `phase-9` — 설치 충돌 방어
- **본 SPEC의 역할**: harness.config.json 설정 시스템 완성 (rootDir + backlogDir/specsDir에 이어 gitignore까지 사용자 설정 가능)

## 🎯 Key Review Points

1. **기본값 변경**: 기존 `!.harness-kit/` (un-ignore) → 신규 `.harness-kit/` (gitignore). 이 변경이 기존 설치에 영향을 주지 않도록 update.sh에서 config 값을 읽어 보존함.
2. **jq false 처리**: `.gitignore // "MISSING"`은 jq에서 `false`를 falsy로 처리해 "MISSING" 반환. `has("gitignore")`로 대체.
3. **멱등성**: `.gitignore`에 이미 `# harness-kit` 섹션이 있는 경우 중복 추가 없이 기존 라인을 교체.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-gitignore-config.sh
bash tests/test-install-layout.sh
```

**결과 요약**:
- ✅ `test-gitignore-config.sh`: 11/11 PASS
- ✅ `test-install-layout.sh`: 7/7 PASS
- ✅ `test-update.sh`: 7/7 PASS (update gitignore 보존 포함)

### 수동 검증 시나리오
1. **기본 설치**: `install.sh --yes ./proj` → `.gitignore`에 `.harness-kit/` 포함 확인
2. **--no-gitignore**: `install.sh --yes --no-gitignore ./proj` → `.gitignore`에 `!.harness-kit/` 포함 확인
3. **update 보존**: `update.sh --yes ./proj` → 기존 gitignore 설정 유지 확인

## 📦 Files Changed

### 🆕 New Files
- `tests/test-gitignore-config.sh`: gitignore config 옵션 검증 (11 checks)
- `specs/spec-9-006-gitignore-config/`: spec, plan, task, walkthrough, pr_description

### 🛠 Modified Files
- `install.sh` (+40, -8): `--gitignore`/`--no-gitignore` 플래그, Section 5b, Section 16/17 수정
- `update.sh` (+10, -2): gitignore 필드 읽기 + install 전달
- `tests/test-install-layout.sh` (+3, -3): Check 7 기본값 반영

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-9.md`
- Walkthrough: `specs/spec-9-006-gitignore-config/walkthrough.md`
