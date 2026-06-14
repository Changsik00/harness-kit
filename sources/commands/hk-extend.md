---
description: 외부 도구 opt-in 통합 — Serena(LSP 코드 인텔리전스) 설치/제거
---

harness-kit 에 외부 도구를 **opt-in** 으로 붙입니다 (여전히 사용자가 명시 실행해야 설치됨).
현재 지원 확장: **Serena** (LSP 기반 코드 인텔리전스 MCP — 심볼 rename / find-references 를 grep 다단계 대신 단일 호출로).

> ✅ **권장**: LSP 지원 언어(TypeScript/Python 등) 코드 프로젝트라면 Serena 설치를 권장합니다. 심볼 작업에서 grep 다단계보다 호출 수·컨텍스트를 줄여 "MCP 상시비용"을 상쇄합니다 (조건부 우선 사용 → ADR-008, agent.md §6.5).
> ⚠️ 단, 확장은 MCP 서버라 **상시 컨텍스트 비용**이 듭니다. bash 위주 등 비-LSP 프로젝트엔 이득이 적으니, 강점 영역이 있는 프로젝트에서 켜고 스코프를 신중히 고르세요.

## 절차

### 1. 의도 확인

사용자가 인자 없이 `/hk-extend` 를 호출했거나 `serena` 를 지목했으면 Serena 설치로 진행합니다.
`--remove` 의도(제거/끄기)면 3-제거 로 갑니다.

### 2. 스코프 질문

설치 스코프를 사용자에게 묻습니다. `.harness-kit/installed.json` 의 `uxMode` 에 따라:

- `uxMode: interactive` → `AskUserQuestion` 패널로, 옵션 2개:
  - **이 프로젝트, 나만** (`local`, 권장) — gitignore 되는 개인 설정. 켠 나만 비용 부담.
  - **내 모든 프로젝트** (`user`) — 모든 프로젝트에서 활성.
- `uxMode: text` (또는 필드 없음) → 평문으로:
  ```
  Serena 를 어디에 설치할까요?
    1) 이 프로젝트, 나만 (local, 권장)
    2) 내 모든 프로젝트 (user)
  ```

> 커밋되는 `.mcp.json`(팀 공유)은 지원하지 않습니다 — 팀 전원에게 상시 비용을 강요하기 때문(opt-in 원칙).
> [Recommendation] **이 프로젝트, 나만(local)** — 도그푸딩/검증 단계에서 기본값.

### 3-설치. 선택 스코프로 헬퍼 실행

```bash
bash .harness-kit/bin/sdd extend serena --scope <local|user>
```

- 헬퍼가 선행조건(`uv`, `claude` CLI)을 점검합니다. 부재 시 설치 없이 안내만 하고 종료하므로, 출력의 안내를 사용자에게 그대로 전달하세요.
- **등록 성공 시 반드시**: 사용자에게 **"Claude Code 를 재시작하세요"** 를 *명확한 다음 단계(필수)* 로 안내한다. MCP 도구는 세션 시작 시 로드되므로, 재시작 전에는 serena 도구가 보이지 않는다 — 이 사실을 함께 전달해 "그래서 지금 뭘 하지?" 가 없게 한다.
- 미리 확인만 하려면 `--dry-run` 을 덧붙여 실행될 커맨드를 보여줄 수 있습니다.

### 3-제거. 제거

```bash
bash .harness-kit/bin/sdd extend serena --remove
```

출력을 그대로 전달합니다. 추가 설명은 최소화합니다.
