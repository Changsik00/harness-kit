# Walkthrough: spec-22-01

> extend 1호 — Serena(LSP) opt-in 설치 커맨드.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 등록 스코프 | local / user / project(.mcp.json 커밋) | **local 기본 + user 옵션, project 제외** | 커밋되는 `.mcp.json` 은 팀 전원에게 상시 컨텍스트 비용을 강요 → opt-in 원칙 위반 |
| 등록 주체 | 키트가 설정 파일 직접 머지 / `claude mcp add` 위임 | **위임** | Claude Code 네이티브 스코프(local/user/project)가 합의 모델과 일치, 소유권/충돌 회피 |
| Serena 실행 | `uv tool install` 바이너리 / `uvx` 인라인 | **uvx** | 별도 바이너리 라이프사이클 관리 회피(설치 단계 없음) |
| 추상화 시점 | 지금 레지스트리 / 검증 후 | **검증된 확장 3개 후 추출** | "추상화는 첫 사용자 검증 후" — 선프레임워크 함정 회피 (ADR-007) |
| TDD 분할 | task 별 Red→Green / 헬퍼 통합 구현 | **헬퍼 통합** | 멱등·remove 가 헬퍼의 한 단위라, Task 2 에서 함께 구현하고 Task 3 은 검증 테스트만 추가 |

## 💬 사용자 협의

- **주제**: LSP로 리팩토링 성능 개선 — Claude Code에 어떻게 붙일까
  - **합의**: Claude Code엔 네이티브 LSP가 없고 MCP가 유일 경로. 키트 원칙상 MCP는 default-off opt-in으로만. oh-my-pi는 별도 에이전트(차용 대상 아님), Serena가 적합한 콜라보 대상.
- **주제**: 직접 다 구현 vs 외부 도구 연결 + "extend 기능을 만들까"
  - **합의**: extend 방향은 맞으나 *프레임워크 선설계 금지*. 검증된 확장 1개(Serena) 먼저 구현 후 누적되면 추출.
- **주제**: 설치 스코프 (project 단위 키트라 global/local 질문 필요)
  - **합의**: "나만 설치" = `local`(이 프로젝트·개인, gitignore). global은 옵션. 커밋되는 `.mcp.json`은 제외.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-extend.sh`
- **결과**: ✅ Passed (6/6 — T1 스코프 거부 / T2 선행조건 부재 graceful / T3 dry-run / T4 정상 등록·기록 / T5 멱등 / T6 remove)
- 외부 의존(`uv`/`claude`)은 PATH stub + 상태파일 모사로 격리(머신 독립). `PATH=/usr/bin:/bin` 제한으로 실제 uv/claude 미개입.
- **회귀**: `bash tests/run.sh --fast` (매니페스트 정합 포함)

### 수동 검증
1. **Action**: `sdd extend serena --scope local --dry-run`
   - **Result**: 구성될 `claude mcp add serena --scope local -- uvx --from git+… --context claude-code --project <root>` 출력, 부작용 없음.

## 🔍 발견 사항

- **이 머신엔 `uv` 미설치** — 실제 end-to-end 등록은 미검증(stub 기반). 실전 검증은 phase-22 도그푸딩 단계(nextmarket-api 또는 uv 설치 후)에서 수행.
- **Claude Code 네이티브 MCP 스코프(local/user/project)가 합의된 스코프 모델과 정확히 일치** — `settings.local.json` 수작업 편집 불필요, `claude mcp add --scope` 로 위임 가능.
- `claude mcp add` 는 옵션이 name 뒤에 와도 허용(`-e KEY` 예시로 확인) → `claude mcp add serena --scope … --` 형태 사용.
- ADR 의 `~/.claude.json` 같은 **홈 경로는 inline-path stale 검사 오탐** — 백틱 제거로 회피.

## 🚧 이월 항목

- **end-to-end 실측(grep vs Serena 토큰)**: phase-22 success criterion #4 — phase 검증 단계에서 수행.
- 후속 확장(검색 .sh, 타 MCP) 누적 시 spec-22-02+ 로. 3개 도달 시 레지스트리 추출 검토(ADR-007).
