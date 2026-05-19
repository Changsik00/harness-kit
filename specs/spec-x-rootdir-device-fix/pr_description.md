# fix(spec-x-rootdir-device-fix): rootDir 절대경로 다중 디바이스 크리티컬섹션 수정

## 📋 Summary

### 배경 및 목적

`harness.config.json`이 git 추적 상태일 때, `rootDir`의 절대경로가 커밋된다. 다른 디바이스/사용자가 clone하면 `sdd_find_root()`가 엉뚱한 경로를 프로젝트 루트로 사용하는 크리티컬섹션이 발생한다. 팀 환경에서 실제로 보고된 이슈.

### 주요 변경 사항

- [x] `sdd_find_root()` — `rootDir` 절대경로 의존 제거, `.harness-kit/` 위치 기반 파일시스템 앵커링으로 교체
- [x] `install.sh` — `harness.config.json` 출력에서 `rootDir` 필드 제거
- [x] `tests/test-sdd-root-detection.sh` — 신규: 다중 디바이스 시나리오 3종 검증
- [x] `tests/test-path-config.sh` — `rootDir` 부재 검증으로 업데이트
- [x] `sources/hooks/check-branch.sh` + 도그푸딩 — 주석 `§9.1` → `§10.1` 수정
- [x] `.harness-kit/bin/sdd` — spec-18-01 이후 누락된 sdd 바이너리 sync

### Phase 컨텍스트

- **Phase**: `spec-x` (독립)
- **본 SPEC 의 역할**: 다중 디바이스 환경에서 `sdd` CLI 루트 탐지 안정성 확보

## 🎯 Key Review Points

1. **`sdd_find_root()` 로직 단순화** (`sources/bin/lib/common.sh`, `.harness-kit/bin/lib/common.sh`): `rootDir` 분기 완전 제거. `.harness-kit/harness.config.json`, `.harness-kit/installed.json`, `.claude/state/current.json` 중 하나가 있는 디렉토리를 루트로 반환. 기존 설치본의 `rootDir` 필드는 무시됨 (하위 호환).
2. **`install.sh` 출력 변경**: `harness.config.json`에 `rootDir` 필드를 기록하지 않음. `backlogDir`, `specsDir`, `gitignore`만 유지.
3. **테스트 discriminator**: `sdd status` 출력의 버전 문자열(`harness-kit N.N.N` vs `harness-kit ?`)로 올바른 루트 사용 여부를 검증.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-sdd-root-detection.sh
bash tests/test-path-config.sh
bash tests/test-hook-modes.sh
```

**결과 요약**:
- ✅ `test-sdd-root-detection.sh`: 4/4 PASS
- ✅ `test-path-config.sh`: 10/10 PASS
- ✅ `test-hook-modes.sh`: 12/12 PASS

### 수동 검증 시나리오

1. **시나리오 A** (크리티컬 케이스): fresh install 후 `harness.config.json`의 `rootDir`를 다른 존재하는 경로로 교체 → `sdd status`가 `harness-kit N.N.N` (올바른 루트) 출력
2. **시나리오 B**: fresh install (rootDir 없음) → `sdd status` 정상 동작

## 📦 Files Changed

### 🆕 New Files

- `tests/test-sdd-root-detection.sh`: 다중 디바이스 루트 탐지 시나리오 3종 검증

### 🛠 Modified Files

- `sources/bin/lib/common.sh`: `sdd_find_root()` — rootDir 의존 제거
- `.harness-kit/bin/lib/common.sh`: 도그푸딩 반영
- `install.sh`: `harness.config.json`에서 rootDir 기록 제거
- `tests/test-path-config.sh`: rootDir 부재 검증으로 변경
- `sources/hooks/check-branch.sh`: 주석 §9.1 → §10.1
- `.harness-kit/hooks/check-branch.sh`: 도그푸딩 반영
- `.harness-kit/bin/sdd`: spec-18-01 이후 누락 sync

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-rootdir-device-fix/walkthrough.md`
