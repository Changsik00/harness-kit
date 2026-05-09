# feat(spec-x-get-sh-installer): curl 한 줄 원격 인스톨러 추가

## 📋 Summary

### 배경 및 목적

기존 harness-kit 설치는 `git clone` 또는 zip 다운로드 → `bash install.sh` 두 단계가 필요했다. `get.sh` 를 추가하여 clone 없이 curl 한 줄로 설치할 수 있도록 한다.

### 주요 변경 사항

- [x] `get.sh` 추가 — GitHub에서 소스 zip 다운로드 후 `install.sh` 실행
- [x] `--version`, `--update`, `--yes` 플래그 지원
- [x] `README.md` 설치 섹션을 curl 한 줄 방식으로 교체 (기존 clone 방식은 `<details>` 접기)
- [x] `tests/test-get-sh.sh` 추가 (10 checks)

### Phase 컨텍스트

- **Phase**: 없음 (Solo Spec)

## 🎯 Key Review Points

1. **get.sh 흐름**: `curl` → `unzip` → `install.sh` or `update.sh` 실행. 임시 디렉토리는 `trap EXIT` 으로 항상 정리됨
2. **버전 미지정 동작**: 기본값은 `main` 브랜치 최신 zip. 안정 버전이 필요하면 `--version 0.6.3` 지정 (git tag 기준)

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-get-sh.sh
```

**결과 요약**:
- ✅ PASS 10 / FAIL 0

### 수동 검증 시나리오
1. **기본 설치**: `bash <(curl -fsSL .../get.sh) /tmp/test-project` → harness-kit 설치 확인
2. **버전 지정**: `bash <(curl -fsSL .../get.sh) --version 0.6.3 /tmp/test` → 해당 버전 설치 확인
3. **업데이트**: `bash <(curl -fsSL .../get.sh) --update /tmp/test-project` → update.sh 실행 확인

## 📦 Files Changed

### 🆕 New Files
- `get.sh`: 원격 인스톨러
- `tests/test-get-sh.sh`: get.sh 검증 테스트 (10 checks)
- `specs/spec-x-get-sh-installer/`: spec/plan/task/walkthrough/pr_description

### 🛠 Modified Files
- `README.md`: 설치 섹션 curl 방식으로 교체

**Total**: 6 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (PASS 10 / FAIL 0)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-get-sh-installer/walkthrough.md`
