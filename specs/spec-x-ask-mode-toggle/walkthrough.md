# Walkthrough: spec-x-ask-mode-toggle

> uxMode 영구 설정의 토글 UX 개선 — CLI 액션 추가 + 슬래시 커맨드 신설.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 토글을 CLI 만 둘지, 슬래시도 만들지 | A: CLI 만 / B: CLI + 슬래시 / C: 슬래시만 | **B** | 사용자가 명시 선택. 발견성(`/` 자동완성)과 한 번 호출 토글 흐름을 모두 확보 |
| 슬래시 커맨드 이름 | `/hk-ux`, `/hk-ask`, `/hk-toggle-ask-mode`, `/hk-ask-mode` | **`/hk-ask-mode`** | 사용자 협의 결과. `/hk-plan-accept` 같은 명사+동사 패턴과 일관. `toggle-` 접두어는 의미상 잉여라 제외 |
| CLI 액션 명 | `toggle`, `flip`, `swap` | **`toggle`** | 가장 표준적 영어 단어. 기존 `[interactive|text]` enum 의 sibling 으로 자연스러움 |
| 반전 로직 위치 | 별도 함수 / `_config_ux_mode` 내부 분기 | **내부 분기** | 2~3 줄 변경에 함수 분리 가치 없음. 기존 setter 재사용 |
| 출력 포맷 | 새 포맷 / `ok "uxMode = $value"` 재사용 | **재사용** | set 액션과 동일 형식 → 사용자 학습 비용 0 |

### ADR 승격 가이드

- [x] 없음 — 기존 `uxMode` 설정의 UX 부가 기능. 새 아키텍처 결정 없음.

## 💬 사용자 협의

- **주제**: 슬래시 커맨드 추가 필요 여부
  - **사용자 의견**: "hk-mode 이런거 만들어야 하는거 아녔어? askQuesions 모드 말야"
  - **합의**: CLI 토글 + `/hk-ask-mode` 슬래시 (옵션 A) 로 진행. 이름은 `/hk-ask-mode` 로 확정 (`/hk-toggle-ask-mode` 는 길이 + `toggle-` 잉여로 제외)

- **주제**: user-scope `/hk-*` 슬래시 중복 (본 spec 시작 직전 발견)
  - **사용자 의견**: 중복 정리 — user-scope 삭제
  - **합의**: `rm ~/.claude/commands/hk-*.md` + `rm ~/.claude/commands/hk.md` 실행. 본 spec 범위 외 사전 정리 작업으로 처리

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-config.sh`
- **결과**: ✅ Passed (7 PASS / 0 FAIL)
- **추가 시나리오 (T5/T6)**:
  - T5: toggle 이 interactive ↔ text 양방향 반전 + 출력에 새 값 포함
  - T6: invalid 입력 에러 메시지에 `toggle` 노출

```text
T1: sdd config ux-mode text → installed.json uxMode=text  ✅
T2: sdd config ux-mode interactive → uxMode=interactive   ✅
T3: sdd config ux-mode (인자 없음) → 현재값 출력          ✅
T4: sdd config ux-mode invalid → 오류 출력                ✅
T5: sdd config ux-mode toggle → 현재값 자동 반전          ✅ (양방향)
T6: invalid 입력 에러에 toggle 허용값 노출                ✅
결과: PASS=7  FAIL=0
```

#### 통합 테스트
- Integration Test Required = no — 해당 없음.

### 2. 수동 검증

1. **Action**: `bash .harness-kit/bin/sdd config ux-mode`
   - **Result**: `uxMode: interactive` (현재값 표시)
2. **Action**: `bash .harness-kit/bin/sdd config ux-mode toggle`
   - **Result**: `✓ uxMode = text`
3. **Action**: 한 번 더 `... toggle`
   - **Result**: `✓ uxMode = interactive` (원복 확인)
4. **Action**: `bash .harness-kit/bin/sdd config ux-mode invalid`
   - **Result**: `✗ 허용된 값: interactive | text | toggle (입력: invalid)` (toggle 노출)

## 🔍 발견 사항

작업 중 발견한 *예상 못한* 항목 — 본 spec 범위 외이지만 기록 가치 있음:

1. **`sdd specx new` 의 spec.md Branch 필드 slug 중복 버그**
   `sdd specx new ask-mode-toggle` 실행 시 생성된 spec.md 의 Branch 필드가 `spec-x-ask-mode-toggle-ask-mode-toggle` (slug 가 두 번 들어감). 단순 변수 치환 오류로 추정. `sources/bin/sdd` 의 `cmd_specx_new` 부근에서 `$slug` 재대입 또는 sed/awk 치환 패턴 검토 필요.

2. **`tests/test-uninstall-cmd-list.sh` Scenario 1 pre-existing FAIL**
   `find sources/commands -name 'hk-*.md'` 는 `hk.md` (no dash) 를 제외하지만, `install.sh:497-507` 의 `*.md` glob 은 `hk.md` 도 포함 → manifest 에 `hk` 항목이 들어가 개수 불일치. Phase 17 `feat(spec-17-02)` 에서 `hk.md` 도입한 시점부터 노출되어 왔으나 별도 spec 으로 잡힌 적 없음. 글롭 패턴 통일 (둘 다 `hk-*.md` 또는 둘 다 `hk*.md`) 필요.

3. **거버넌스 단어 수 한계 초과 (6418w > 6000w)**
   `tests/test-governance-dedup.sh` 의 Check 3 가 거버넌스 문서 합산 단어 수 ≤ 6000 을 요구. 현재 6418w (main 부터 이미 6415w 초과 상태였음). 본 spec 의 §8.4 한 줄 갱신은 +3w. 한계 재설정 또는 거버넌스 다이어트 검토.

4. **release-0.11.0 PR 미머지 — installed.json `kitVersion` 불일치 가능성**
   main 의 `.harness-kit/installed.json` 은 여전히 `kitVersion: 0.10.0`. release-0.11.0 PR 이 본 spec PR 보다 먼저 머지되면 manifest conflict (kitVersion 라인) 발생 예정. 보존 가능한 conflict 이므로 별도 조치 없음.

## 🚧 이월 항목

위 1~3 모두 `backlog/queue.md` Icebox 에 한 줄씩 등록 (commit `d752811`).

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Opus 4.7) + dennis |
| **작성 기간** | 2026-05-17 |
| **최종 commit** | `d752811` (ship commit 작성 시점) |
