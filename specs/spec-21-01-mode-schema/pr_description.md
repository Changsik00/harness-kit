# feat(spec-21-01): add sdd mode subcommand and Active Mode status display

## 📋 Summary

### 배경 및 목적

phase-21 Turbo 모드 추가의 첫 번째 스펙. Turbo 모드 전환을 위해 `state.json` 에 `mode` 필드를 도입하고 `sdd mode` CLI 서브커맨드를 구현한다. 이 필드는 이후 스펙(훅 분기, intent 블록)의 토대가 된다.

### 주요 변경 사항

- [x] `sdd mode [turbo|governed|status]` 서브커맨드 추가 — `state.json` 의 `mode` 필드 읽기/쓰기
- [x] `sdd status` 출력에 `Active Mode` 행 추가 — 현재 모드 항상 표시
- [x] `sources/bin/sdd` 동일 변경 미러링 — install/update 경로 반영
- [x] `tests/test-mode-schema.sh` 7개 케이스 테스트 추가

### Phase 컨텍스트

- **Phase**: `phase-21` — Turbo 모드 추가
- **본 SPEC 의 역할**: 모드 시스템의 기반 스키마. 이후 spec-21-02(훅 분기)가 `hook_state mode` 로 이 필드를 읽어 Turbo/Governed 동작을 분기함

## 🎯 Key Review Points

1. **`cmd_mode()` 설계**: `state_set`/`state_get` 기존 함수를 그대로 활용. `_lib.sh` 및 `state.sh` 무변경으로 훅 호환성 보장
2. **기본값 fallback**: `mode` 필드 부재 또는 `null` → `"governed"` 로 처리. 기존 설치에서 동작 변화 없음

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-mode-schema.sh
```

**결과 요약**:
- ✅ `T01` 기본값 governed
- ✅ `T02` mode=turbo 설정
- ✅ `T03` status turbo 출력
- ✅ `T04` mode=governed 복귀
- ✅ `T05` status governed 출력
- ✅ `T06` sdd status Active Mode 행
- ✅ `T07` 잘못된 값 exit 1

### 수동 검증 시나리오
1. `sdd mode status` → `현재 모드: governed` 출력
2. `sdd mode turbo` → 확인 메시지 + `current.json mode=turbo`
3. `sdd status` → `Active Mode: turbo` 행 표시

## 📦 Files Changed

### 🆕 New Files
- `tests/test-mode-schema.sh`: sdd mode 서브커맨드 단위 테스트 (7 케이스)
- `specs/spec-21-01-mode-schema/spec.md`: 스펙 문서
- `specs/spec-21-01-mode-schema/plan.md`: 구현 계획
- `specs/spec-21-01-mode-schema/task.md`: 태스크 목록
- `specs/spec-21-01-mode-schema/walkthrough.md`: 작업 기록
- `specs/spec-21-01-mode-schema/pr_description.md`: 이 파일

### 🛠 Modified Files
- `.harness-kit/bin/sdd` (+40): `cmd_mode()` + dispatch + status 표시 + help 갱신
- `sources/bin/sdd` (+40): 동일 변경 미러링

**Total**: 8 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (7/7)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-21.md`
- Walkthrough: `specs/spec-21-01-mode-schema/walkthrough.md`
