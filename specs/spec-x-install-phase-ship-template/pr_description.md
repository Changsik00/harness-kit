# fix(spec-x-install-phase-ship-template): copy phase-ship.md template on install

## 📋 Summary

### 배경 및 목적

`install.sh:262` 의 템플릿 복사 루프가 `sources/templates/` 의 8개 파일 중 7개만 하드코딩으로 복사하고 `phase-ship.md` 를 누락. 결과:

- `sources/commands/hk-phase-ship.md:92` 가 명시적으로 읽도록 지시한 `.harness-kit/agent/templates/phase-ship.md` 가 신규 설치 환경에서 부재
- `constitution.md:67` 의 *"The Phase PR body MUST follow the `phase-ship.md` template."* mandatory 절차 실행 불가
- Silent failure: install 시점엔 에러 없음, 사용자가 phase 완료 시점에 처음 발견

직전 spec (`spec-x-update-preserve-state`) 의 도그푸딩에서 install 이 본 프로젝트의 phase-ship.md 잔재를 덮어쓰며 처음 표면화. Icebox 등록 후 즉시 후속 spec 으로 진입.

### 주요 변경 사항

- [x] **`install.sh:262`** — 템플릿 리스트에 `phase-ship.md` 추가 (1줄 변경)
- [x] **`tests/test-install-layout.sh`** — Check 8 신설: 8개 템플릿 모두 install 후 존재 검증 (회귀 방지)

## 🎯 Key Review Points

1. **1줄 fix**: `for f in queue.md phase.md` ... 에 `phase-ship.md` 추가. 회귀 위험 zero.
2. **명시 리스트 검증**: 테스트가 8개 파일을 하드코딩으로 검증 — 향후 `sources/templates/` 에 새 파일 추가 시 install.sh 와 테스트가 동기화되지 않으면 즉시 FAIL.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-install-layout.sh        # 15/15 PASS (Check 8: 8개 템플릿)
for t in tests/test-*.sh; do bash "$t" || echo "FAIL: $t"; done
# → Total fails: 0
```

### 수동 검증

신규 설치 fixture 에서 `.harness-kit/agent/templates/` 내용 확인:
- 이전: 7개 파일 (phase-ship.md 누락)
- 변경 후: 8개 파일 모두 존재

## 📦 Files Changed

### 🛠 Modified Files
- `install.sh` (+1, -1): 템플릿 리스트에 `phase-ship.md` 추가
- `tests/test-install-layout.sh` (+13): Check 8 (8개 템플릿 존재 검증)

### 🆕 New Files
- `specs/spec-x-install-phase-ship-template/spec.md`, `plan.md`, `task.md`, `walkthrough.md`, `pr_description.md`

**Total**: 7 files changed, 3 commits

## ✅ Definition of Done

- [x] 회귀 테스트 PASS (15/15)
- [x] 전체 sweep PASS (Total fails = 0)
- [x] walkthrough.md / pr_description.md ship commit
- [x] 브랜치 push + PR 생성

## 🔗 관련 자료

- 발견 경로: 직전 PR `spec-x-update-preserve-state` 도그푸딩 부산물 (Icebox #2)
- Walkthrough: `specs/spec-x-install-phase-ship-template/walkthrough.md`
