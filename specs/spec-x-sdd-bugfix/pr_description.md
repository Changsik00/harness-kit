# fix(spec-x-sdd-bugfix): sdd specx Branch 중복 버그 + 테스트 glob 불일치 수정

## 📋 Summary

### 배경 및 목적

icebox에 오래 쌓여있던 버그 2개를 한 번에 수정한다.

### 주요 변경 사항
- [x] `sdd specx new <slug>` Branch 필드 중복 수정 — `spec-x-foo-foo` → `spec-x-foo` (sources + .harness-kit 동기화)
- [x] `tests/test-uninstall-cmd-list.sh` Scenario 1 glob 수정 — `hk-*.md` → `*.md` (install.sh 동작과 일치)

## 🎯 Key Review Points

1. **sed 선행 치환**: `{seq}-{slug}` 복합 패턴을 먼저 치환해 중복을 방지. 일반 `sdd spec new` (phase spec) 는 `{seq}` 와 `{slug}` 가 다른 값이므로 영향 없음.
2. **테스트 glob**: install.sh가 `*.md` (hk.md 포함) 를 설치하므로, 테스트 기대값도 동일 패턴이어야 함.

## 🧪 Verification

```bash
bash tests/test-uninstall-cmd-list.sh   # PASS=9 FAIL=0
bash tests/test-install-claude-import.sh  # ALL PASS (6/6)
bash tests/test-marker-append-guard.sh    # ALL 5 CHECKS PASSED
bash tests/test-marker-edge-cases.sh      # ALL 8 CHECKS PASSED
```

수동: `sdd specx new test-slug` → Branch = `spec-x-test-slug` ✅

## 📦 Files Changed

- `sources/bin/sdd` (+1, -1): specx_new() sed 선행 치환 추가
- `.harness-kit/bin/sdd` (+1, -1): dogfooding 동기화
- `tests/test-uninstall-cmd-list.sh` (+2, -2): glob 패턴 수정

**Total**: 3 files changed

## ✅ Definition of Done

- [x] `sdd specx new test-slug` Branch = `spec-x-test-slug` 확인
- [x] `tests/test-uninstall-cmd-list.sh` ALL PASS
- [x] 기존 회귀 테스트 ALL PASS
