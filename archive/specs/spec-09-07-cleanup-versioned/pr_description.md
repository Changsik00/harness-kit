# feat(spec-09-07): 버전별 정리 스크립트 (cleanup.sh)

## 📋 Summary

### 배경 및 목적

`sources/migrations/0.4.0.sh`에 migration 함수들이 정의되어 있지만 실제로 호출하는 코드가 없었다. 구 커맨드 파일(align.md, spec-new.md 등 9개)이 v0.3 → v0.4 업데이트 시에도 삭제되지 않는 문제.

### 주요 변경 사항
- [x] `cleanup.sh` 신설: `--from <ver> --to <ver>` 범위의 migration 파일을 semver 순 실행
- [x] macOS 호환 semver 비교 함수 (`sort -V` 미사용, 수동 dot-split)
- [x] `update.sh` 연동: state 복원 후 cleanup 호출 (non-fatal)

### Phase 컨텍스트
- **Phase**: `phase-09`
- **본 SPEC의 역할**: migration 인프라를 실제 동작하게 연결하여, 향후 버전 업데이트 시 구 파일 자동 정리 가능

## 🎯 Key Review Points

1. **semver 비교 로직**: macOS 기본 `sort`에 `-V` 옵션이 없어 bash 함수로 구현. 3자리(major.minor.patch) 비교.
2. **non-fatal 연동**: `update.sh`에서 cleanup 실패 시 경고만 출력하고 계속 진행.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-cleanup.sh   # 8/8 PASS
bash tests/test-update.sh    # 7/7 PASS
```

**결과 요약**:
- ✅ 범위 내 migration 실행: 파일 삭제 확인
- ✅ 범위 외 migration skip
- ✅ 동일 버전 빈 범위 정상 종료
- ✅ 존재하지 않는 파일 skip
- ✅ update.sh 기존 동작 유지

## 📦 Files Changed

### 🆕 New Files
- `cleanup.sh`: 버전별 migration 실행 스크립트
- `tests/test-cleanup.sh`: cleanup.sh 검증 테스트

### 🛠 Modified Files
- `update.sh` (+8, -2): cleanup.sh 호출 추가

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료

## 🔗 관련 자료

- Phase: `backlog/phase-09.md`
- Walkthrough: `specs/spec-09-07-cleanup-versioned/walkthrough.md`
