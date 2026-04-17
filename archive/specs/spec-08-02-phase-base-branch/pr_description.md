# feat(spec-08-02): add phase base branch support (opt-in --base flag)

## 📋 Summary

### 배경 및 목적

Phase는 문서(`backlog/phase-N.md`)로만 존재했고, git에 대응하는 브랜치가 없었다. 이로 인해 spec 간 의존성 처리가 불가능하고 phase 전체 통합 테스트를 main merge 전에 실행할 수단이 없었다.

`sdd phase new --base` 플래그를 추가하여 phase base branch 모드를 선언할 수 있게 한다. 실제 브랜치 생성은 첫 spec의 hk-ship 시점에 just-in-time으로 수행된다.

### 주요 변경 사항
- [x] `sdd phase new <slug> --base` — `baseBranch: "phase-N-slug"` 를 state.json 에 기록하고 phase.md 메타 갱신
- [x] `sdd phase new <slug>` (no flag) — `baseBranch: null` 기본값으로 하위 호환 유지
- [x] `sdd phase done` — `baseBranch` 를 null 로 초기화
- [x] `sdd status --json` — `baseBranch` 필드 자동 포함 (state_dump 경유)
- [x] `hk-ship` Step 4 — baseBranch 감지 → JIT 브랜치 생성 → PR 타깃 변경 명세 추가

### Phase 컨텍스트
- **Phase**: `phase-08`
- **본 SPEC 의 역할**: phase-08의 도그푸딩 첫 사례 — `phase-08-work-model` 브랜치에 spec-08-01 ~ spec-08-04 가 쌓이는 구조를 가능하게 함

## 🎯 Key Review Points

1. **`phase_new()` --base 파싱**: `${@:2}` 로 slug 이후 인수를 순회하여 `--base` 감지. slug 검증 후 파싱하므로 slug 오류와 플래그 오류가 분리됨.
2. **JIT 브랜치 생성 (hk-ship)**: `git ls-remote --exit-code` 로 remote 존재 여부를 확인 후 없을 때만 생성 → 멱등성 보장. `git checkout -` 로 spec 브랜치 복귀.
3. **state.json 하위 호환**: `--base` 없을 때 `baseBranch: null` 을 명시적으로 설정하여 키 누락 없이 일관된 JSON 구조 유지.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-sdd-base-branch.sh
```

**결과 요약**:
- ✅ Check 1: `sdd phase new --base` → baseBranch = "phase-N-slug" 저장
- ✅ Check 2: `sdd phase new` (no flag) → baseBranch = null
- ✅ Check 3: `sdd status --json` → baseBranch 키 포함
- ✅ Check 4: `sdd phase done` → baseBranch = null

### 수동 검증 시나리오
1. **`sdd phase new work-model --base`** → `sdd status --json | jq .baseBranch` = `"phase-N-work-model"` 확인
2. **`sdd status --json`** → baseBranch 필드 포함된 JSON 출력 확인
3. **`sdd phase done`** → `sdd status --json | jq .baseBranch` = `null` 확인

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-base-branch.sh`: 4종 단위 테스트

### 🛠 Modified Files
- `scripts/harness/bin/sdd` (+35, -6): phase_new --base 플래그 + phase_done baseBranch 초기화
- `sources/bin/sdd` (+35, -6): 위와 동일 동기화
- `sources/commands/hk-ship.md` (+22, -2): Step 4 base branch JIT 생성 명세

**Total**: 4 files changed (테스트 포함)

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (4/4)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-08.md`
- Spec: `specs/spec-08-02-phase-base-branch/spec.md`
- Walkthrough: `specs/spec-08-02-phase-base-branch/walkthrough.md`
