---
description: 외부 도구 opt-in 통합 — Serena(LSP 코드 인텔리전스) 설치/제거
---

harness-kit 에 "있으면 더 좋은" 외부 도구를 **opt-in(default-off)** 으로 붙입니다.
현재 지원 확장: **Serena** (LSP 기반 코드 인텔리전스 MCP — 심볼 rename / find-references 를 grep 다단계 대신 단일 호출로).

> ⚠️ 확장은 MCP 서버이므로 **상시 컨텍스트 비용**이 듭니다. 켠 사람만 부담하도록 스코프를 신중히 고르세요.

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
- 등록 성공 시: Claude Code 를 **재시작/재연결**해야 Serena 도구가 활성화됨을 안내합니다.
- 미리 확인만 하려면 `--dry-run` 을 덧붙여 실행될 커맨드를 보여줄 수 있습니다.

### 3-제거. 제거

```bash
bash .harness-kit/bin/sdd extend serena --remove
```

출력을 그대로 전달합니다. 추가 설명은 최소화합니다.
