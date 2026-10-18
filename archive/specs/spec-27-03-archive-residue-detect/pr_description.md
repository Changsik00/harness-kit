# feat(spec-27-03): 완료 phase의 backlog 잔존을 `sdd status` 진단에 노출

> 첫 줄은 commit subject 와 정확히 일치해야 합니다 (`type(spec-...): description`).

## 📋 Summary

### 배경 및 목적
`sdd doctor`(spec-27-02)는 완료 phase의 `backlog/phase-NN.md` 잔존을 이미 검출하지만, 사용자가 일상적으로 보는 화면은 `sdd status`다. `cmd_archive()` 코드를 직접 확인한 결과 이미 완료 phase(활성 제외)를 기본값으로 정확히 아카이브 대상에 포함시키고 있어 — 실제 갭은 로직 버그가 아니라 **가시성**이었다. `sdd status`의 🔍 진단 섹션에 동일 헬퍼를 연결한다.

### 주요 변경 사항
- [x] `_status_diagnose()`에 `_backlog_completed_residue`(spec-27-02 공유 헬퍼) 연결
- [x] 완료 phase 잔존 시 `💡 완료 phase N개가 backlog/*.md 로 잔존 (...) — sdd archive 로 정리 가능` 한 줄 노출
- [x] `cmd_archive()` 자체는 변경 없음 (코드 확인 결과 이미 정확 — 스코프 문서화)
- [x] 실 데이터 검증: phase-23~26 잔존 4건 정확히 검출

### Phase 컨텍스트
- **Phase**: `phase-27` (docs-integrity)
- **본 SPEC 의 역할**: GitHub #168 세 제안 중 마지막. 이 PR 머지로 phase-27 전체 spec 완료 → `/hk-phase-ship` 대상.

## 🎯 Key Review Points

1. **스코프 재정의**: phase.md 원안은 "`sdd archive`가 놓친다"였지만, 코드 리딩 후 "이미 옳게 동작 — 갭은 가시성"으로 재정의했다. `cmd_archive()`를 건드리지 않은 이유가 spec.md/walkthrough.md에 명시돼 있다.
2. **헬퍼 재사용**: 새 파싱 로직 없이 spec-27-02의 `_backlog_completed_residue`를 그대로 호출 — 중복 구현 방지.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-status-backlog-residue.sh
bash tests/run.sh
```

**결과 요약**:
- ✅ `tests/test-status-backlog-residue.sh`: 2/2 통과
- ✅ `tests/run.sh`: 81/81 통과, FAIL 0

### 수동 검증 시나리오
1. **시나리오 1**: `sdd status` 실 저장소 실행 → 🔍 진단에 phase-23~24~25~26 잔존 안내 정확히 등장.

## 📦 Files Changed

### 🆕 New Files
- `tests/test-status-backlog-residue.sh`: 잔존 안내 등장/소멸 회귀 테스트
- `specs/spec-27-03-archive-residue-detect/spec.md`, `task.md`, `walkthrough.md`, `pr_description.md`: spec 산출물

### 🛠 Modified Files
- `sources/bin/sdd` (+10): `_status_diagnose()` 확장 (키트 원본, SoT)
- `.harness-kit/bin/sdd` (+10): 동일 변경 미러 (본 저장소 도그푸딩 설치본)

**Total**: 5 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] lint / type check 통과 (shellcheck 미설치로 skip — 환경 제약)
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-27.md`
- Walkthrough: `specs/spec-27-03-archive-residue-detect/walkthrough.md`
- 관련 이슈: GitHub #168 (제안 3) — 이 PR 머지 후 phase-27 완료, 이슈 close 가능
- 관련 spec: spec-27-02 (`_backlog_completed_residue` 헬퍼 출처)
- 관련 ADR: 없음
