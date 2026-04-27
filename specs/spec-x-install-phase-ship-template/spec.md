# spec-x-install-phase-ship-template: install.sh 가 phase-ship.md 템플릿을 복사하도록 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-install-phase-ship-template` |
| **Phase** | `phase-x` (Solo Spec) |
| **Branch** | `spec-x-install-phase-ship-template` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-27 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`install.sh:262` 의 템플릿 복사 루프는 7개 파일을 하드코딩으로 복사한다:

```bash
for f in queue.md phase.md spec.md plan.md task.md walkthrough.md pr_description.md; do
  do_cp "$KIT_DIR/sources/templates/$f" "$TARGET/.harness-kit/agent/templates/$f"
done
```

`sources/templates/` 디렉토리에는 **8개** 파일이 존재한다:
- queue.md, phase.md, spec.md, plan.md, task.md, walkthrough.md, pr_description.md (7개 — 복사됨)
- **phase-ship.md** (1개 — 복사 안 됨)

### 문제점

1. **`/hk-phase-ship` 동작 불가**: `sources/commands/hk-phase-ship.md:92` 가 `.harness-kit/agent/templates/phase-ship.md` 를 명시적으로 읽도록 지시한다. 신규 설치 환경에서는 이 파일이 없어 PR 본문 작성 단계가 실패하거나 fallback 으로 빈 PR 이 생성됨.
2. **constitution mandatory 위반**: `constitution.md:67` 이 *"The Phase PR body MUST follow the `phase-ship.md` template."* 로 명시. 템플릿 부재 시 mandatory 절차 자체가 실행 불가능.
3. **Silent failure**: install 시 에러가 발생하지 않으므로 사용자가 phase-ship 을 실제로 시도하기 전까지 문제를 모름. 본 프로젝트(harness-kit 자체)는 직접 편집한 잔재 덕에 우연히 동작하다가 spec-x-update-preserve-state 도그푸딩에서 install.sh 가 잔재를 덮어쓰며 처음 드러남.

### 해결 방안 (요약)

`install.sh:262` 의 템플릿 리스트에 `phase-ship.md` 한 단어 추가. 회귀 방지를 위해 `tests/test-install-layout.sh` 에 8개 템플릿 모두 존재 검증 케이스 추가.

## 🎯 요구사항

### Functional Requirements

1. **F1.** `bash install.sh --yes <target>` 실행 후 `<target>/.harness-kit/agent/templates/phase-ship.md` 가 존재하고 `sources/templates/phase-ship.md` 와 동일해야 한다.
2. **F2.** 8개 템플릿(`queue`, `phase`, `phase-ship`, `spec`, `plan`, `task`, `walkthrough`, `pr_description`) 모두 install 후 존재해야 한다.

### Non-Functional Requirements

1. **NF1.** 회귀 테스트 — 향후 `sources/templates/` 에 새 파일이 추가될 때 install.sh 와 테스트가 동기화되지 않으면 즉시 FAIL 해야 한다 (앵커 sweep 효과).
2. **NF2.** bash 3.2+ 호환.

## 🚫 Out of Scope

- 템플릿 복사 로직을 디렉토리 sync 방식으로 리팩토링 (예: `cp -r sources/templates/* target/`) — 별 spec 후보. 본 spec 은 1줄 fix 만.
- `phase-ship.md` 자체 내용 수정 — 별 작업.
- `/hk-phase-ship` 슬래시 커맨드 동작 검증 — install 만 보장. PR 작성 시점 동작은 별 e2e 영역.
- `update.sh` 동작 별도 검증 — 이미 `tests/test-update.sh` 가 install 결과를 그대로 사용하므로 자동 회귀 커버됨.

## ✅ Definition of Done

- [ ] `tests/test-install-layout.sh` 에 8개 템플릿 존재 검증 추가 → 신규 케이스 FAIL 확인 (Red)
- [ ] `install.sh:262` 의 리스트에 `phase-ship.md` 추가 → 신규 케이스 PASS (Green)
- [ ] 전체 테스트 sweep PASS
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-install-phase-ship-template` 브랜치 push 완료
- [ ] PR 생성 + 사용자 검토 요청 알림
