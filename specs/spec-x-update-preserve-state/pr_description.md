# fix(spec-x-update-preserve-state): update.sh state 손실 수정 + 0.6.1

## 📋 Summary

### 배경 및 목적

`update.sh` 가 보존하는 state 필드가 4개 (`phase`, `spec`, `planAccepted`, `lastTestPass`) 로 하드코딩되어 있어 `branch`, `baseBranch` 가 update 후 영구 소실되는 버그. `/hk-align` 의 `sdd status` 가 stale 한 컨텍스트를 보고하면서 에이전트가 잘못된 NEXT 추천을 하는 운영 사고로 이어졌음.

부가로 `install.sh` 의 state.json 템플릿에 `baseBranch` 필드가 처음부터 누락되어 있어, `sdd phase new --base` 가 실행될 때까지 스키마가 불완전했던 점도 함께 수정.

### 주요 변경 사항

- [x] **`update.sh` 의 state 보존 로직을 jq 객체 머지 패턴으로 교체** — 4개 필드 하드코딩 → 6개 필드 화이트리스트 (`phase`, `spec`, `branch`, `baseBranch`, `planAccepted`, `lastTestPass`)
- [x] **`install.sh` 의 state.json 템플릿에 `baseBranch: null` 명시 추가**
- [x] **버전 0.6.0 → 0.6.1** (patch, bug fix) — VERSION / CHANGELOG / README / test-version-bump.sh 동시 갱신
- [x] **회귀 테스트 4건 추가** — `tests/test-update.sh` 시나리오 A 확장 (branch/baseBranch/planAccepted/lastTestPass 보존, kitVersion 동기화) + 시나리오 C 신설 (install 직후 baseBranch 필드 존재)
- [x] **본 프로젝트 도그푸딩** — `bash update.sh --yes .` 로 자기 자신에 적용. `state.json.kitVersion`: 0.5.0 → 0.6.1 잔재 정리.

### 컨텍스트

- **Phase**: 없음 (spec-x, Solo Spec)
- **본 SPEC 의 역할**: 운영 사고 (stale state 로 인한 align 진단 오류) 의 근본 원인 차단

## 🎯 Key Review Points

1. **`update.sh` 의 jq merge 패턴**: 백업 객체 (`{phase, spec, branch, baseBranch, planAccepted, lastTestPass}`) 를 install.sh 가 새로 쓴 state 위에 `. * $saved` 로 덮어씀. 백업에 없는 키 (`kitVersion`, `installedAt`) 는 install 값이 그대로 유지되어 자동 동기화. → **새 필드 추가 시 jq projection 한 곳만 고치면 됨**.
2. **`install.sh` 템플릿의 `baseBranch: null`**: sdd 코드는 이미 `.baseBranch // empty` 로 graceful 처리 중이지만, 명시적 null 이 한 진영의 진실. 신규 설치 환경에서 스키마 일관성 확보.
3. **`test-update.sh` 시나리오 C**: 신규 install 직후 `baseBranch` 필드가 state.json 에 존재하는지 검증. 향후 install 템플릿에서 필드를 누락시키면 즉시 회귀로 잡힘.
4. **도그푸딩 부수 변경**: install 이 만들어내는 `.gitignore` 중복 추가, `settings.json` 재정렬 등은 의도와 무관한 노이즈로 판단해 revert. 단, 발견된 부수 이슈 3건 (gitignore self-host 충돌, phase-ship.md 템플릿 누락, settings.json ask 자동 추가) 은 `backlog/queue.md` Icebox 에 기록.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-update.sh
bash tests/test-version-bump.sh
for t in tests/test-*.sh; do bash "$t" || echo "FAIL: $t"; done
```

**결과 요약**:
- ✅ `tests/test-update.sh`: ALL PASS (11/11) — 시나리오 A 11개 + 시나리오 B 3개 + 시나리오 C 1개
- ✅ `tests/test-version-bump.sh`: ALL PASS (6/6)
- ✅ 전체 sweep (29개 test 파일): Total fails = 0

### 수동 검증 (도그푸딩)

1. `bash update.sh --yes .` → `업데이트 완료: 0.6.0 → 0.6.1`, doctor `PASS=40 WARN=1 FAIL=0`
2. `cat .claude/state/current.json` → `"kitVersion": "0.6.1"`, `"baseBranch": null` 필드 존재, `"spec"`/`"planAccepted"`/`"lastTestPass"` 모두 update 직전 값 유지 ✓
3. `bash .harness-kit/bin/sdd status` → 헤더 `harness-kit 0.6.1` (이전: 0.5.0)

## 📦 Files Changed

### 🆕 New Files
- `.claude/commands/hk-doctor.md` — 0.6.0 도입 슬래시 커맨드 (도그푸딩으로 본 프로젝트에 누락분 catch-up)
- `specs/spec-x-update-preserve-state/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md` — 본 spec 산출물

### 🛠 Modified Files
- `update.sh` (+11, -14): 4-필드 백업/복원 → 6-필드 jq 머지 패턴
- `install.sh` (+1): state.json 템플릿에 `baseBranch: null` 추가
- `VERSION` (+1, -1): 0.6.0 → 0.6.1
- `CHANGELOG.md` (+12): 0.6.1 항목 추가 (Fixed + Tests)
- `README.md` (+1, -1): 버전 배지 0.6.1
- `tests/test-update.sh` (+59, -2): 시나리오 A 확장 + 시나리오 C 추가
- `tests/test-version-bump.sh` (+2, -2): TARGET 0.6.1
- `backlog/queue.md` (+5, -2): specx 갱신 + Icebox 부수 이슈 3건 추가
- `.harness-kit/installed.json` (+2, -3): 도그푸딩으로 0.6.1 갱신
- `.harness-kit/hooks/check-staged-lint.sh` (mode 0644 → 0755): install 이 정정

### 🗑 Deleted Files
- `.harness-kit/agent/templates/phase-ship.md` (-70): install.sh 가 복사하지 않는 템플릿 — 본 프로젝트엔 잔재로 남아있던 것 도그푸딩 시 정리됨. 별 이슈로 Icebox 등록 (install.sh 가 sources/templates/phase-ship.md 를 복사하도록 수정 필요)

**Total**: 16 files changed, 5 commits

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (11/11 update + 6/6 version-bump + 전체 sweep PASS)
- [x] (Integration Test Required = no) — 해당 없음
- [x] `walkthrough.md` 작성 + ship commit
- [x] `pr_description.md` 작성 + ship commit
- [x] `spec-x-update-preserve-state` 브랜치 push
- [x] PR 생성 + 사용자 검토 요청 알림

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-update-preserve-state/walkthrough.md`
- Icebox 등록 부수 이슈: `backlog/queue.md` (3건, 2026-04-27 추가분)
