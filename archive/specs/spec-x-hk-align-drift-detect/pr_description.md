# feat(spec-x-hk-align-drift-detect): add drift detection to sdd status

## 📋 Summary

### 배경 및 목적

multi-device 환경에서 작업하다 보면 다음 4 가지 sync 어긋남이 자연스럽게 발생합니다:

1. **원격 behind/ahead**: 다른 device 에서 PR 머지 후 이쪽 로컬은 fetch 안 한 상태
2. **워킹트리 잔재**: 다른 device 의 staged/untracked 작업이 로컬에 남음
3. **repo state 불일치**: phase-level PR 머지 후 `sdd phase done` 후처리 누락 → queue.md 가 stale
4. **install 부산물**: install 단계의 미완성 또는 도그푸딩 미적용

지난 세션 (2026-04-30) 에 위 4 가지가 모두 동시 발생해 사용자가 "정리 됐을 것" 이라 인지한 상태에서 stale `sdd status` 보고를 받는 일이 있었습니다. `hk-align` 의 `sdd status` 호출 단일 진입점에 **🔄 동기화 상태 (drift)** 자동 진단을 추가해 이를 차단합니다.

### 주요 변경 사항

- [x] `sdd status` 출력에 **🔄 동기화 상태** 섹션 추가 — 4 카테고리 자동 감지 (원격 / 워킹트리 / 정합성 / install)
- [x] `--no-drift` 옵션 + `HARNESS_DRIFT_FETCH=0` 환경변수 — 오프라인/CI escape hatch
- [x] `hk-align` 슬래시 커맨드와 `align.md` 거버넌스 동기 갱신 — 출력 형식에 동기화 섹션 명시 + "자동 정리 금지" 강조
- [x] 도그푸딩 — 본 프로젝트의 `.harness-kit/bin/sdd` 등 설치본 sync
- [x] `tests/test-sdd-drift.sh` 신규 — 5 시나리오 / 6 검증 모두 PASS

### Phase 컨텍스트

- **Phase**: 없음 (Solo Spec)
- **본 SPEC 의 역할**: multi-device 환경에서 작업 컨텍스트 신뢰성 회복. hk-align 의 단일 진입점에서 자동으로 sync 어긋남 감지.

## 🎯 Key Review Points

1. **drift 위치 결정 (status 통합)**: 단일 명령 원칙 (agent.md §6.4) 유지하면서 자동 보고. 새 명령 추가 안 함. `--no-drift` opt-out.
2. **자동 fetch 동작**: `git fetch --quiet 2>/dev/null || true` — 오프라인 시 silent fallback. `HARNESS_DRIFT_FETCH=0` 으로 끔.
3. **자동 정리 금지**: 본 spec 은 *감지·제안만*. `git pull` / `git reset` / `rm` / `sdd phase done` 어느 것도 자동 실행 안 함. 사용자가 명시 결정 후 직접 실행.
4. **`_status_diagnose` 와 정합성 메시지 중복**: drift (queue.md 기준) 와 diagnose (state.json 기준) 가 다른 각도에서 동일 사실을 보일 수 있음. 의도적으로 두 곳에 둔 이유 → walkthrough 결정 기록 참조.
5. **bash 3.2+ 호환**: `declare -A`, `mapfile`, `**` 등 bash 4 전용 미사용 (CLAUDE.md §3 정책 준수).

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-sdd-drift.sh
```

**결과 요약**:
- ✅ T1: 깨끗한 상태 → drift 섹션 출력 + "깔끔" 메시지
- ✅ T2: 원격 behind 1 → "behind 1" 보고
- ✅ T3: specs/ 미커밋 → "워킹트리: ... spec drift" 카운트
- ✅ T4: 모든 spec Merged 인데 phase active → "정합성: ... phase done 미실행 의심"
- ✅ T5: `--no-drift` → 동기화 섹션 미출력
- **PASS: 6  FAIL: 0**

### 회귀 테스트

```bash
bash tests/test-sdd-spec-new-seq.sh   # 5/5 PASS
bash tests/test-fixture-lib.sh        # 18/18 PASS
bash tests/test-install-manifest-sync.sh  # 6/6 PASS
```

### 수동 검증 — 도그푸딩

본 프로젝트에서 직접 실행 시 (작업 중 워킹트리 상태):

```text
🔄 동기화 상태
  워킹트리: 6 변경 (1 spec drift / 4 install drift / 1 일반)
  install 부산물: 1 (sources 동일 1 / 정체불명 0)
```

올바르게 분류됨. 신규 브랜치라 원격 섹션은 silent skip (의도).

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-drift.sh` (+150): 5 시나리오 단위 테스트
- `specs/spec-x-hk-align-drift-detect/spec.md`, `plan.md`, `task.md`, `walkthrough.md`, `pr_description.md`

### 🛠 Modified Files
- `sources/bin/sdd` (+186, -5): drift_check + 4 서브 함수 (_drift_remote, _drift_worktree, _drift_consistency, _drift_install) + cmd_status `--no-drift` 옵션 + cmd_help 갱신
- `sources/commands/hk-align.md` (+10, -2): §2 drift 자동 포함 + §5 출력 예시 갱신
- `sources/governance/align.md` (+10, -1): 동기 갱신
- `.harness-kit/bin/sdd`, `.harness-kit/agent/align.md`, `.claude/commands/hk-align.md`: 설치본 sync (도그푸딩)

## ✅ Definition of Done

- [x] `sdd status` 에 🔄 동기화 상태 섹션 추가 (drift 있으면 상세, 없으면 깔끔)
- [x] `--no-drift` 옵션 동작
- [x] bash 3.2 호환 단위 테스트 통과 (`tests/test-sdd-drift.sh` 6/6)
- [x] hk-align 슬래시 커맨드 + align.md 거버넌스 동기화
- [x] `walkthrough.md`, `pr_description.md` 작성 + ship commit
- [x] `spec-x-hk-align-drift-detect` 브랜치 push
- [x] PR 생성

## 🔗 관련 자료

- 선행 PR: #91 (phase-15 통합) + #92 (phase-15 finalize) — 본 spec 의 트리거가 된 꼬임 사례
- 후속 spec 후보:
  - `hk-phase-ship` 가 PR 머지 후 `sdd phase done` 자동 호출 (재발 차단)
  - `_status_diagnose` 와 drift 메시지 중복 정리
  - `.harness-kit/agent/templates/phase-ship.md` tracked 화
- Walkthrough: `specs/spec-x-hk-align-drift-detect/walkthrough.md`
