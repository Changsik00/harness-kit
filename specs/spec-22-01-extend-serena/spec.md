# spec-22-01: extend-serena — 확장 1호 Serena(LSP) 설치 커맨드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-22-01` |
| **Phase** | `phase-22` |
| **Branch** | `spec-22-01-extend-serena` |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-06-14 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

harness-kit 는 슬래시 커맨드(`sources/commands/*.md`) + bash 메타 CLI(`sources/bin/sdd`) + 훅으로 구성된 SDD 거버넌스 툴킷이다. 현재 **외부 MCP 도구를 다루는 코드가 전혀 없다**(`.mcp.json`/`mcpServers` 미사용). 한편 Claude Code 기본 루프는 코드 탐색을 `Grep`/`Read` 텍스트 도구로만 수행해, 심볼 rename·find-references 같은 리팩토링이 LSP 기반 IDE 대비 느리고 토큰 왕복이 많다.

### 문제점

- 사용자는 리팩토링 시 토큰 소비가 크고 느리다고 느낀다(VSCode의 즉각적 rename/find-references와 대비).
- LSP 기반 코드 인텔리전스(Serena MCP)가 이를 개선할 수 있으나, 키트엔 외부 도구를 연결할 *경로 자체가 없다*.
- 무작정 MCP 를 기본 탑재하면 컨텍스트 비용 0 원칙 및 ceremony cost 절감 노력과 충돌한다.

### 해결 방안

"있으면 더 좋은" 외부 도구를 **opt-in(default-off)** 으로 붙이는 첫 경로를 연다. 슬래시 커맨드 `/hk-extend` 가 사용 가능한 확장(현 시점 Serena 1개)을 안내하고 스코프를 물은 뒤, bash 헬퍼 `sdd extend` 가 실제 설치/등록/제거를 수행한다. 등록은 Claude Code 네이티브 `claude mcp add --scope <local|user>` 에 위임하고, 키트는 `installed.json` 에 설치 흔적만 기록한다. 확장 *레지스트리/프레임워크* 는 만들지 않고 Serena 한 개를 정직하게 구현한다(추상화는 검증된 확장 누적 후 — ADR-007).

## 요구사항

1. **슬래시 커맨드 `/hk-extend`**: 사용 가능한 확장 목록(현재 Serena: LSP 코드 인텔리전스, 비용·효용 한 줄 설명)을 보이고, 스코프(`local`=이 프로젝트·나만 / `user`=모든 프로젝트)를 사용자에게 물어 헬퍼를 호출한다. `local` 이 기본값.
2. **헬퍼 `sdd extend serena --scope <local|user>`**: 다음을 수행한다.
   - 선행조건 점검: `uv`(uvx 제공)와 `claude` CLI 존재 확인. 부재 시 설치를 진행하지 않고 안내 후 graceful 종료(비파괴, exit 0).
   - 스코프 검증: `local`/`user` 만 허용. `project`(.mcp.json 커밋) 및 기타 값은 거부하고 사유 출력.
   - 등록: `claude mcp add serena --scope <scope> -- <serena 실행 커맨드>` 실행.
   - 기록: `installed.json` 의 `extensions.serena` 에 `{scope, installedAt}` 기록(jq in-place).
3. **멱등성**: 이미 등록돼 있으면(재실행) 중복 등록하지 않고 "이미 설치됨(scope=…)" 안내. `sdd extend serena --remove` 로 `claude mcp remove serena` + `installed.json` 흔적 제거.
4. **`--dry-run`**: 실제 외부 호출 없이 구성될 `claude mcp add …` 커맨드를 출력하고 선행조건/스코프 검증까지만 수행(테스트·미리보기용).
5. **bash 3.2 호환** + 기존 sdd lib 컨벤션 준수. jq 로 JSON 처리.
6. **ADR-007**: extend opt-in 규약(default-off, 등록은 claude mcp add 위임, 검증된 확장 3개 누적 후에만 레지스트리 추출)을 문서화.
7. **install 정합**: `hk-extend.md` 추가가 install 매니페스트 동기화 테스트를 깨지 않는다(필요 시 매니페스트 갱신).

## Out of Scope

- 확장 **레지스트리/카탈로그** 추상화(여러 확장을 데이터로 기술하는 일반화) — 검증된 확장 3개 누적 후 별도 spec.
- Serena 외 다른 확장(검색 .sh, 타 MCP) — 후속 spec-22-02+.
- `.mcp.json`(팀 공유, 커밋) 경로 지원 — opt-in 원칙상 기본 제외(향후 명시 옵션으로 재검토 가능, 본 spec 아님).
- 도그푸딩 토큰 실측(grep vs Serena) — phase 검증 단계(success criterion #4)에서 수동 수행, 본 spec 의 자동 테스트 대상 아님.
- Serena 바이너리 영구 설치(`uv tool install`) 라이프사이클 관리 — `uvx` 실행 등록으로 대체(별도 바이너리 관리 회피).

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **확장 추적 위치**: `installed.json` 에 `extensions` 객체 신설(설치 흔적 기록). 키트는 실제 MCP 등록 저장소(`~/.claude.json`)를 소유하지 않으므로, 이 기록은 "키트를 통해 설치 시도함"의 흔적이며 진짜 등록 상태는 `claude mcp list` 가 SSOT. 이 분리에 동의하는가?
> - [ ] **Serena 실행 커맨드 핀**: 후보는 `uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant`. 정확한 플래그(프로젝트 경로 전달 방식 등)는 구현 시점 Serena 공식 문서로 재확인 후 확정한다.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **등록 주체** | `claude mcp add` 에 위임 | Claude Code 네이티브 스코프(local/user/project)가 합의된 스코프 모델과 일치, 키트가 설정 파일 직접 편집 안 함 |
| **스코프 기본값** | `local`(이 프로젝트·나만) | opt-in(default-off) — 켠 사람만 컨텍스트 비용 부담 |
| **로직 위치** | bash 헬퍼(`sdd extend`) + 얇은 슬래시 커맨드 | 컨텍스트 비용 0 원칙(bash > slash). 커맨드는 오케스트레이션만 |
| **Serena 실행** | `uvx`(설치 없이 실행) 등록 | 별도 바이너리 라이프사이클 관리 회피 |
| **추상화** | Serena 하드코딩(레지스트리 없음) | 첫 사용자 검증 후 추출 — 선프레임워크 함정 회피 |
| **테스트** | `--dry-run` + PATH stub(`uv`/`claude` 가짜 주입) | 외부 의존 없이 헬퍼 로직·멱등·검증 테스트 |

## Proposed Changes

#### [NEW] `sources/bin/lib/extend.sh`
`sdd extend` 서브커맨드 구현. 함수: 선행조건 점검, 스코프 검증, Serena 등록 커맨드 구성, dry-run 출력, installed.json 기록/제거, 멱등 처리.

#### [MODIFY] `sources/bin/sdd`
`extend` 서브커맨드 dispatch case 추가 + `lib/extend.sh` source. usage/help 에 `extend` 항목 추가.

#### [NEW] `sources/commands/hk-extend.md`
`/hk-extend` 슬래시 커맨드. frontmatter `description` + 본문(확장 목록 안내 → 스코프 질문 → `sdd extend` 호출). `uxMode` 에 따라 AskUserQuestion/텍스트 폴백.

#### [NEW] `docs/decisions/ADR-007-extend-opt-in.md`
extend opt-in 규약 ADR(type: decision).

#### [MODIFY] `README.md` (해당 시)
extend 섹션 추가 — Serena opt-in 설치법 + MCP 상시 컨텍스트 비용 명시.

#### [MODIFY] install 매니페스트 (필요 시)
`hk-extend.md` 추가로 `test-install-manifest-sync` 가 깨지면 매니페스트 목록 갱신.

#### [NEW] `tests/test-extend.sh`
헬퍼 검증: 선행조건 부재 graceful, 스코프 검증, dry-run 커맨드 구성, installed.json 기록, 멱등(재실행 차단), remove.

## 검증 계획

```bash
# 단위 테스트
bash tests/test-extend.sh
# 전체 회귀(매니페스트 정합 포함)
bash tests/run.sh --fast
```

수동 검증 시나리오:
1. `uv`/`claude` 있는 환경에서 `sdd extend serena --scope local --dry-run` — 기대: 구성될 `claude mcp add serena --scope local -- uvx …` 출력, 외부 호출/기록 없음.
2. `sdd extend serena --scope local` 실행 후 `claude mcp list` — 기대: `serena` 노출, `installed.json` 에 `extensions.serena.scope=local`.
3. 재실행 — 기대: "이미 설치됨" 안내(중복 등록 없음).
4. `sdd extend serena --remove` 후 `claude mcp list` — 기대: `serena` 사라짐, installed.json 흔적 제거.
5. `uv` 없는 환경(PATH stub 제거) — 기대: 안내 후 graceful 종료, 등록 시도 없음.

## ADR 후보

- [x] ADR 가치 있는 결정 있음 → 후보: `extend-opt-in` (type: `decision`) — extend 의 default-off / 등록 위임 / 추상화 시점 규약
- [ ] 없음

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (`tests/test-extend.sh` + `tests/run.sh --fast` 회귀)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-22-01-extend-serena` 브랜치 push 완료
