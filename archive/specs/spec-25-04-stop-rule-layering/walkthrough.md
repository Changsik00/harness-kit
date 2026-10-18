# Walkthrough: spec-25-04

> 비가역 행동 2층 모델(deny=never-justify / hook=context-dependent) 명문화 + W3 데드락 해소 *준비*. 플립은 6/26 으로 미룸.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 지금 warn→block 플립할지 | 계획대로 승격 / 준비만 | **준비만** | check-irreversible 가 2026-06-19 추가라 3일째 — CLAUDE.md #5 "1주 운영 후 승격" 미달. 지금 플립은 키트 자기 원칙 위반 + 오탐 데드락 리스크 |
| reset --hard 감지 폭 (🛑검토1) | narrow(`HEAD~` 등) / 광의 | **광의 + 경고** | warn 이라 동작 변화 0, deny 가 실제 차단 유지 → 공백 없음. 노이즈는 운영 관찰 후 narrow 화 결정 |
| 2층 모델 ADR 승격 (🛑검토2) | 신규 ADR / hook 헤더+walkthrough | **hook 헤더+walkthrough** | ADR-009 가 이미 ② 를 다룸. 분류표를 *코드 옆*(hook 헤더)에 두는 게 재발 방지에 더 직접적. 별도 ADR 미생성 |
| 데드락 명령 이관 시점 | 지금 deny 에서 제거 / 플립과 묶음 | **플립과 묶음(6/26)** | 지금 deny 에서 빼면 hook 이 warn 이라 그 사이 무방비 공백. 이관=플립 동시 |

## 💬 사용자 협의

- **주제**: §11.3 재검증 — 25-04 의 block 승격이 1주 원칙과 충돌
  - **합의**: 25-04 를 "2층 모델 명문화 + 데드락 해소 설계 + 승격 준비"로 재정의. 실제 플립 + deny→hook 이관은 2026-06-26 phase-FF(phase-25.md 기등록).

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-stop-rules.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (stop-rules 17/17, 전체 75/75, FAIL 0)
```text
T9 reset --hard → 경고 / T9b rebase --onto → 경고
T9c reset --soft → 무경고 / T9d rebase main → 무경고 (경계)
T10b block 모드 reset --hard → exit 2 (승격 준비)
```

### 수동 검증
1. **Action**: `CLAUDE_TOOL_INPUT_command="git reset --hard HEAD~1"` 로 hook 실행
   - **Result**: ⚠ 경고(context-dependent), exit 0. 플립 전이라 차단 안 함.
2. **플립/deny 미변경 확인**: settings.json deny 그대로, hook 기본 warn 유지 — 동작 변화 없음(경고 1종 추가).

## 🔍 발견 사항

- **칸0(spec-25-02)이 TDD red/green 분리 커밋에서 경고를 냄**: Task 2(impl) 커밋에 테스트가 없음(테스트는 Task 1 별도 커밋) → 칸0 가 "구현-무테스트"로 경고. 기능상 정상이나 **TDD 흐름에서 칸0 의 알려진 coarseness** — One-Task-One-Commit + red/green 분리가 칸0 의 commit 단위 가정과 어긋난다. 경고일 뿐 비차단이라 수용. 향후 칸0 narrow 화 시 "직전 커밋에 동반 테스트 있으면 면제" 고려.
- **2층 모델이 코드 옆에 박히니 경계가 분명해짐**: "왜 reset --hard 는 deny 이자 hook 인가(이중 방어, 플립 시 hook 단독)"가 hook 헤더로 자명. W3 데드락의 근본(hook 이 그 명령을 *감지조차 못 함*)이 해소됨 — 이제 플립이 1줄 mechanical.

## 🚧 이월 항목

- **2026-06-26 phase-FF**: check-irreversible 기본값 warn→block + deny 에서 `git reset --hard`·`git rebase --onto` 제거(hook 단독 이관). phase-25.md phase-FF 표에 기등록.
- **칸0 narrow 화** (선택): TDD red/green 분리 면제 규칙 — 운영 노이즈 관찰 후 phase-26 검토.
