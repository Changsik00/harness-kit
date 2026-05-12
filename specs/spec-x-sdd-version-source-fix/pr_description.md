# fix(spec-x-sdd-version-source-fix): sdd status/version kitVersion SSOT를 installed.json으로 수정

## 📋 Summary

### 배경 및 목적

`sdd status` 헤더와 `sdd version`이 kitVersion을 `.claude/state/current.json`에서 읽고 있었다.
`current.json`은 gitignored SDD 작업 상태 파일이라, `update.sh`를 경유하지 않고 git 커밋으로 직접
버전을 올리는 도그푸딩 흐름에서 최초 설치 버전(0.6.2)이 계속 표시되는 문제가 발생했다.
`installed.json`(git-tracked)이 설치 버전의 실제 SSOT이므로, 이 파일을 읽도록 수정한다.

### 주요 변경 사항

- [x] `cmd_version()`: `state_get kitVersion` → `installed.json` 직접 읽기로 변경
- [x] `cmd_status()` has_state=1/0 양쪽 경로: `installed.json` 읽기 + 파일 없을 시 `?` fallback
- [x] `_read_kit_ver()` 헬퍼 함수 추출 — 두 곳에서 재사용, fallback 정책 단일화
- [x] `sources/bin/sdd` + `.harness-kit/bin/sdd` 동시 수정 (도그푸딩 동기화)
- [x] `tests/test-sdd-version-source.sh` 신규 추가 — 3개 시나리오 (버전 불일치/버전 명령/파일 없음)

### Phase 컨텍스트

- **Phase**: `spec-x` (Solo)
- **역할**: `sdd` 핵심 명령의 버전 표시 신뢰도 회복

## 🎯 Key Review Points

1. **`_read_kit_ver()` 헬퍼** (`sources/bin/sdd` +88~94행): `installed.json`에서 `.kitVersion`을 읽고, 파일 없거나 값 없으면 `"?"` 반환. 기존 `state_get kitVersion` 호출을 두 곳에서 이 헬퍼로 교체.
2. **has_state=0 fallback 경로** (기존 `kit_ver="?"`): 이제 `_read_kit_ver()`를 호출하므로, `current.json`이 없어도 `installed.json`이 있으면 올바른 버전이 표시됨.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-version-source.sh
```

**결과 요약**:
- ✅ T1: `installed.json`=0.8.0 / `current.json`=0.6.2 → `sdd status` 헤더 0.8.0
- ✅ T2: `installed.json`=0.8.0 / `current.json`=0.6.2 → `sdd version` 0.8.0
- ✅ T3: `installed.json` 없음 → `sdd status` 헤더 `?`

### 수동 검증 시나리오
1. `sdd status --brief` → `harness-kit 0.8.0 | ...` 확인
2. `sdd version` → `harness-kit 0.8.0` 확인

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-version-source.sh`: kitVersion 읽기 소스 검증 테스트 (3 시나리오)

### 🛠 Modified Files
- `sources/bin/sdd` (+11, -3): `_read_kit_ver()` 헬퍼 추가, `cmd_version`/`cmd_status` 수정
- `.harness-kit/bin/sdd` (+11, -3): 도그푸딩 인스턴스 동기화

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (PASS=4)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-sdd-version-source-fix/walkthrough.md`
