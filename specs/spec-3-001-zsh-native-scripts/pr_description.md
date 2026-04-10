# feat(spec-3-001): zsh 네이티브 스크립트 모드

## 📋 Summary

### 배경 및 목적
macOS 기본 bash는 3.2(GPLv2)로 기능 제한적이며, Homebrew로 bash 4.0+를 별도 설치해야 harness-kit을 사용할 수 있었다. 모든 스크립트에서 `${BASH_SOURCE[0]}`, `local -a` 배열 등 bash 전용 구문을 사용하고 있어 zsh에서 실행 불가능했다.

### 주요 변경 사항
- [x] `_lib.sh`에 `_script_dir` 셸 호환 함수 추가 (bash → `${BASH_SOURCE[0]}`, zsh → `${(%):-%x}`)
- [x] 3개 hook 및 sdd에서 bash 전용 구문 제거 (`BASH_SOURCE` 직접 사용, `local -a` 배열)
- [x] `install.sh --shell=zsh` 옵션 추가 — 복사 시 shebang 자동 교체
- [x] `doctor.sh`에 zsh 모드 감지 추가

### Phase 컨텍스트
- **Phase**: `phase-3` — macOS 네이티브 설치 모드
- **본 SPEC의 역할**: Homebrew bash 없이 macOS에서 harness-kit 설치/운영 가능하게 하는 핵심 기반 작업

## 🎯 Key Review Points

1. **`_self()` 인라인 함수**: 각 hook/sdd에서 source 전에 자기 위치를 찾아야 하므로, `_lib.sh`의 `_script_dir`과 별도로 인라인 함수가 필요. bash/zsh/fallback 3단 분기.
2. **배열 제거**: sdd의 `cmd_hooks` 함수에서 `local -a` + 0-based 인덱싱을 `"NAME:DEFAULT:FILE"` 문자열 + `for` 루프로 교체. bash/zsh 동일 동작.
3. **shebang 교체 전략**: `sources/` 원본은 bash shebang 유지, install.sh가 복사 시점에 sed로 교체.

## 🧪 Verification

```bash
bash tests/test-zsh-compat.sh
```
✅ 20/20 PASS

기존 테스트 회귀 없음:
- `test-hook-modes.sh` → 12/12 PASS
- `test-governance-dedup.sh` → 8/8 PASS
- `test-two-tier-loading.sh` → 7/7 PASS

## 📦 Files Changed

### 🛠 Modified Files
- `sources/hooks/_lib.sh` (+15): `_script_dir` 셸 호환 함수 추가
- `sources/hooks/check-branch.sh` (+2, -1): `_self()` 인라인 함수로 교체
- `sources/hooks/check-plan-accept.sh` (+2, -1): 동일
- `sources/hooks/check-test-passed.sh` (+2, -1): 동일
- `sources/bin/sdd` (+11, -12): 배열 제거 + `_self()` 교체
- `install.sh` (+40, -11): `--shell` 옵션 + `do_fix_shebang` + zsh 모드
- `doctor.sh` (+27, -7): zsh 감지 + 조건부 bash 체크
- `scripts/harness/` (5 files): sources/ 동기화

### 🆕 New Files
- `tests/test-zsh-compat.sh`: zsh 호환성 검증 테스트 (20 checks)

**Total**: 13 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (20/20)
- [x] 기존 테스트 회귀 없음
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료

## 🔗 관련 자료

- Phase: `backlog/phase-3.md`
- Walkthrough: `specs/spec-3-001-zsh-native-scripts/walkthrough.md`
