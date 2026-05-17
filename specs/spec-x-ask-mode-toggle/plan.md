# Implementation Plan: spec-x-ask-mode-toggle

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-ask-mode-toggle` (브랜치 이름 = spec 디렉토리 이름)
- 시작 지점: `main` (이미 fetch + ff 완료, clean)
- 첫 task 가 브랜치 생성 수행
- spec-x 메모리 룰: spec-x 는 항상 `main` 에서 분기 (phase 브랜치 분기 금지)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 슬래시 커맨드 이름 `/hk-ask-mode` 확정 (`/hk-ux`, `/hk-ask` 후보 → 사용자가 `ask-mode` 결정)
> - [ ] CLI 액션명 `toggle` 확정 (대안: `flip`, `swap` — 현 추천: `toggle`)
> - [ ] 토글 결과 출력 포맷: 기존 `ok "uxMode = $value"` 재사용 (별도 포맷 필요 없음)

> [!WARNING]
> - [ ] `sources/governance/agent.md` 수정은 정식 SDD-x 절차로 진행 중이므로 거버넌스 변경 정책 준수 — 본 spec 안에 포함됨
> - [ ] `.harness-kit/agent/agent.md` 는 install 산출물이지만 도그푸딩 룰에 따라 같은 PR 에서 sources/ 와 함께 갱신 (소스↔installed 정합성)

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
사용자  →  /hk-ask-mode  →  sdd config ux-mode toggle  →  installed.json 갱신
                                      │
                                      └─ 내부에서 현재값 읽음 → 반대 값 계산 → 기존 setter 재사용
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **CLI 액션명** | `toggle` | 기능을 가장 명확히 표현. `flip`/`swap` 보다 표준 영어 |
| **반전 로직 위치** | `_config_ux_mode` 내부 분기 | 별도 함수 분리 시 코드 양 대비 가치 적음 (2~3 줄). 기존 setter 재사용 |
| **출력 포맷** | `ok "uxMode = $value"` 재사용 | 기존 set 액션과 동일 형식 → 사용자 학습 비용 0 |
| **잘못된 값 처리** | 에러 메시지에 `toggle` 포함 | 사용자가 새 액션 학습 가능 |
| **슬래시 본문** | 단일 bash 한 줄 + 결과 그대로 출력 | `/hk-doctor` 패턴과 동일 (agent.md §6.4) |

### 📑 ADR 후보

- [x] 없음 — 기존 `uxMode` 설정의 UX 액션. 장기 자산 가치 없음.

## 📂 Proposed Changes

### CLI (sdd)

#### [MODIFY] `sources/bin/sdd`

위치: `_config_ux_mode` 함수 (line ~1440-1461)

변경:
- `value` 가 `toggle` 인 경우 현재값을 읽어 반전한 후 기존 set 로직 재사용.
- `case` 분기 허용값에 `toggle` 추가.
- die 메시지의 허용값 표시에 `toggle` 추가.

```bash
# (개략)
case "$value" in
  interactive|text) ;;
  toggle)
    local current
    current=$(jq -r '.uxMode // "interactive"' "$installed_json")
    if [ "$current" = "interactive" ]; then value="text"; else value="interactive"; fi
    ;;
  *) die "허용된 값: interactive | text | toggle (입력: $value)" ;;
esac
```

또한 도움말 헤더 (line 54-55) 의 `config ux-mode [interactive|text]` → `config ux-mode [interactive|text|toggle]`.

#### [NEW] `sources/commands/hk-ask-mode.md`

`/hk-ask-mode` 슬래시 커맨드. 본문은 `hk-doctor.md` 패턴 차용 (description 한 줄 + 단일 bash 호출 + 결과 그대로 출력).

### 거버넌스 (agent.md)

#### [MODIFY] `sources/governance/agent.md`

위치: §8.4 AskUserQuestion Tool Preference 의 마지막 단락.

기존:
```
To change: `sdd config ux-mode text` or `sdd config ux-mode interactive`
```

변경 후:
```
To change: `sdd config ux-mode [interactive|text|toggle]` (또는 슬래시: `/hk-ask-mode` — 현재값 자동 반전)
```

#### [MODIFY] `.harness-kit/agent/agent.md`

도그푸딩 정합성 유지를 위해 위와 동일 변경.

### 도그푸딩 동기화

#### [NEW] `.claude/commands/hk-ask-mode.md`

`sources/commands/hk-ask-mode.md` 의 동일 복사본 (install.sh 가 하는 일을 수동 적용).

#### [MODIFY] `.harness-kit/installed.json`

`installedCommands` 배열에 `"hk-ask-mode"` 추가 (알파벳 순서: `hk-archive` 다음, `hk-cleanup` 이전).

### 테스트

#### [MODIFY] `tests/test-sdd-config.sh`

T5 추가:
- 초기 `interactive` → `toggle` → `text` 확인.
- 다시 `toggle` → `interactive` 복원 확인.
- 출력 메시지에 새 값 포함 확인.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-config.sh
```

기대: T1~T4 + 신규 T5 모두 PASS.

### 회귀 검증

```bash
bash tests/test-install-manifest-sync.sh
bash tests/test-uninstall-cmd-list.sh
```

이유: `installedCommands` 배열 + `sources/commands/` 신규 추가가 manifest 동기화 / uninstall 정확성에 영향 없는지 확인.

### 수동 검증 시나리오

1. `bash .harness-kit/bin/sdd config ux-mode` 실행 → 현재값 표시 (예: `uxMode: interactive`).
2. `bash .harness-kit/bin/sdd config ux-mode toggle` → `✓ uxMode = text` 출력.
3. 다시 `toggle` → `✓ uxMode = interactive` 출력.
4. `bash .harness-kit/bin/sdd config ux-mode invalid` → 에러에 `toggle` 포함.
5. 새 세션에서 `/hk-ask-mode` 입력 → 슬래시 자동완성에 `(project)` 만 표시 (user-scope 중복 정리 후).

## 🔁 Rollback Plan

- CLI 변경은 단순 분기 추가 — revert 시 영향 없음.
- 슬래시 커맨드 파일은 추가/삭제만으로 토글 가능.
- `installed.json` 의 `installedCommands` 는 다음 release commit 에서 자동 동기화되므로, 수동 추가가 잘못되어도 다음 release 시 정정.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
