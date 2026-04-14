# phase-9: 설치 충돌 방어 — 디렉토리 은닉 + CLAUDE.md @import + 충돌 감지

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-{N}-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-9` |
| **Base Branch** | `phase-9-install-conflict-defense` |
| **상태** | In Progress |
| **시작일** | 2026-04-14 |
| **목표 종료일** | 미정 |
| **소유자** | ck |
| **버전** | v0.4.0 (breaking change — 디렉토리 레이아웃 변경) |

## 🎯 배경 및 목표

### 현재 상황

harness-kit을 기존 프로젝트에 설치할 때 세 가지 구조적 충돌 위험이 있다.

1. **디렉토리 이름 충돌**: `agent/`(LangChain·LangGraph 등에서 흔히 사용), `scripts/`(거의 모든 프로젝트에 존재) 이름으로 설치되어 기존 파일을 덮어쓰거나 git 충돌을 유발한다.
2. **CLAUDE.md 충돌**: 전체 블록을 append하는 방식이라 팀원이 동시에 CLAUDE.md를 수정할 경우 merge conflict가 발생하고, 파일 내 내용이 점점 길어진다.
3. **무결함 감지 부재**: 설치 전에 기존 디렉토리 충돌 여부를 확인하지 않아 사용자가 충돌 사실을 사후에야 알게 된다.

### 목표 (Goal)

- 모든 harness-kit 전용 파일을 `.harness-kit/` 숨김 디렉토리 아래로 이동하여 기존 프로젝트 네임스페이스를 침범하지 않는다.
- CLAUDE.md에는 `@import` 3줄만 추가하고, fragment는 `.harness-kit/`에 보관한다.
- 설치·업데이트 시작 시 충돌을 사전 스캔하고, 충돌이 있으면 사용자에게 경로 변경 옵션을 제안한다.
- v0.3 이하가 설치된 프로젝트에 `update.sh`를 실행하면 자동으로 신규 레이아웃으로 마이그레이션된다.

### 성공 기준 (Success Criteria)

1. `install.sh` 실행 후 프로젝트 루트에 `agent/`, `scripts/harness/` 디렉토리가 **생성되지 않는다**.
2. CLAUDE.md에 추가되는 내용이 3줄(`<!-- HARNESS-KIT:BEGIN -->`, `@.harness-kit/CLAUDE.fragment.md`, `<!-- HARNESS-KIT:END -->`) 이하다.
3. `agent/`나 `scripts/harness/`가 이미 존재하는 프로젝트에서 `install.sh` 실행 시 **충돌 없이** 설치된다.
4. v0.3이 설치된 프로젝트에서 `update.sh` 실행 시 구 레이아웃이 신규 레이아웃으로 자동 마이그레이션된다.
5. `backlog/`, `specs/`에 하네스와 무관한 내용이 있는 프로젝트에서 install 시 경고 + 경로 변경 확인을 묻는다.
6. 모든 기존 테스트(`bash tests/run-all.sh`) PASS.

## 🧩 작업 단위 (SPECs)

> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-9-001` | dir-layout | P1 | Done | `specs/spec-9-001-dir-layout/` |
| `spec-9-002` | claude-md-import | P1 | Done | `specs/spec-9-002-claude-md-import/` |
| `spec-9-003` | conflict-detection | P2 | Done | `specs/spec-9-003-conflict-detection/` |
| `spec-9-004` | root-config | P1 | Done | `specs/spec-9-004-root-config/` |
| `spec-9-005` | update-rewrite | P1 | Done | `specs/spec-9-005-update-rewrite/` |
| `spec-9-006` | gitignore-config | P1 | Active | `specs/spec-9-006-gitignore-config/` |
| `spec-9-007` | cleanup-versioned | P2 | Backlog | — |
| `spec-9-008` | readme-refresh | P2 | Backlog | — |
| `spec-9-009` | changelog | P2 | Backlog | — |
| `spec-9-010` | ship-idea-capture | P2 | Backlog | — |
| `spec-9-011` | preflight-ux | P3 | Backlog | — |
<!-- sdd:specs:end -->

### spec-9-001 — 디렉토리 레이아웃 마이그레이션

- **요점**: `agent/` → `.harness-kit/agent/`, `scripts/harness/` → `.harness-kit/bin/` + `.harness-kit/hooks/`로 이동. install/update/uninstall/doctor.sh 및 sdd 바이너리의 경로 참조를 전면 교체한다.
- **방향성**:
  - `sources/` 내 파일은 구조 유지. 복사 대상 경로만 변경.
  - 설치 대상: `agent/` → `.harness-kit/agent/`, `scripts/harness/bin/` → `.harness-kit/bin/`, `scripts/harness/hooks/` → `.harness-kit/hooks/`
  - `settings.json` fragment의 hook 경로: `scripts/harness/hooks/*.sh` → `.harness-kit/hooks/*.sh`
  - `.harness-kit/installed.json` 신설: kitVersion, installedAt, config 기록
  - `.gitignore`에 `!.harness-kit/` explicit un-ignore 추가 (숨김 디렉토리 gitignore 위험 방지)
  - governance 문서(constitution.md, agent.md, align.md), CLAUDE.md의 `scripts/harness/bin/sdd` 참조 전부 교체
  - `update.sh` migration: `installed.json` kitVersion으로 v0.3 이하 감지 → 구 디렉토리 → 신 디렉토리 rename + 경로 패치 + 백업
- **참조**: Alignment Phase 논의 (2026-04-14) — 위험 요소 A, B, C, D
- **연관 모듈**: `install.sh`, `update.sh`, `uninstall.sh`, `doctor.sh`, `sources/bin/sdd`, `sources/hooks/`, `sources/claude-fragments/settings.json.fragment`, `sources/governance/*.md`

### spec-9-002 — CLAUDE.md @import 방식 전환

- **요점**: CLAUDE.md에 전체 블록을 직접 삽입하는 방식에서 `@.harness-kit/CLAUDE.fragment.md` @import 3줄로 교체. 기존 CLAUDE.md 내용을 보존하면서 HARNESS-KIT 블록만 교체한다.
- **방향성**:
  - `sources/claude-fragments/CLAUDE.md.fragment` → `.harness-kit/CLAUDE.fragment.md`로 이동
  - `install.sh` CLAUDE.md 처리: 기존 파일 읽기 → HARNESS-KIT 블록(또는 파일 끝)을 @import 3줄로 대체. 기존 내용 무결성 유지.
  - `update.sh`: CLAUDE.md 본문 불변. `.harness-kit/CLAUDE.fragment.md`만 업데이트.
  - @import 3줄 형식:
    ```
    <!-- HARNESS-KIT:BEGIN -->
    @.harness-kit/CLAUDE.fragment.md
    <!-- HARNESS-KIT:END -->
    ```
  - spec-9-001 완료 후 작업 (`.harness-kit/` 디렉토리가 먼저 존재해야 함)
- **참조**: Alignment Phase 논의 (2026-04-14) — CLAUDE.md 충돌 위험, 사용자 요청 1번
- **연관 모듈**: `install.sh`, `update.sh`, `sources/claude-fragments/CLAUDE.md.fragment`

### spec-9-003 — 충돌 감지 + config 시스템

- **요점**: 설치 전 기존 디렉토리 충돌을 스캔하고, 충돌 시 경로 변경 옵션을 제안한다. `harness.config.json`으로 `backlog/`, `specs/` 경로를 override할 수 있다.
- **방향성**:
  - 충돌 스캔 대상: `backlog/`, `specs/` (harness-kit이 만든 것이 아닌 내용 여부 확인)
  - 충돌 감지: `.harness-kit/installed.json` 부재 + 디렉토리에 내용이 있으면 "외부 콘텐츠"로 간주
  - 충돌 시 UX: 충돌 내역 출력 → 제안 경로 자동 생성 (예: `hk-backlog/`, `hk-specs/`) → 사용자 확인 (y/N 또는 직접 경로 입력) → `harness.config.json` 자동 작성
  - `harness.config.json` 스키마: `{ "backlogDir": "backlog", "specsDir": "specs" }`
  - `sdd` 바이너리가 `harness.config.json`을 읽어 경로 반영
  - spec-9-001 완료 후 작업
- **참조**: Alignment Phase 논의 (2026-04-14) — 위험 요소 E, 사용자 요청 3번
- **연관 모듈**: `install.sh`, `update.sh`, `sources/bin/sdd`, `sources/bin/lib/`

### spec-9-006 — gitignore config 옵션

- **요점**: `.harness-kit/`을 `.gitignore`에 추가할지 `install.sh`에서 묻고, 선택을 `harness.config.json`에 저장. 기본값은 gitignore(true).
- **방향성**:
  - `install.sh` 프롬프트: `.harness-kit/ 을 .gitignore 에 추가할까요? [Y/n]` (기본 Y)
  - `harness.config.json`: `"gitignore": true` 필드 추가
  - gitignore=true: `.gitignore` 에 `.harness-kit/` 추가 (현재 `!.harness-kit/` 반전)
  - gitignore=false: `!.harness-kit/` 명시적 un-ignore (현재 동작 유지)
- **연관 모듈**: `install.sh`, `.gitignore` 처리

### spec-9-007 — cleanup.sh (버전별 정리)

- **요점**: 버전 구간별 deprecated 파일/디렉토리 제거 로직을 `cleanup.sh`로 분리. `sources/migrations/` 인프라를 실제로 채움.
- **방향성**:
  - `cleanup.sh --from <ver> --to <ver> [--yes]`: 버전 구간의 migration 스크립트 순차 실행
  - `sources/migrations/0.4.0.sh`: v0.3 잔재(`agent/`, `scripts/harness/`) 제거
  - `update.sh`에서 `cleanup.sh` 호출
- **연관 모듈**: `cleanup.sh`, `update.sh`, `sources/migrations/`

### spec-9-008 — README 최신화

- **요점**: `README.md`를 v0.4.0 기준으로 최신화. FAQ 유효성 검토, Hook 모드 섹션 갱신, 설치 경로 `.harness-kit/` 반영.
- **연관 모듈**: `README.md`, `docs/`

### spec-9-009 — CHANGELOG / version history

- **요점**: `CHANGELOG.md` 신설. 버전별 변경 이력 기록. `update.sh` 완료 메시지에서 참조.
- **연관 모듈**: `CHANGELOG.md`, `update.sh`

### spec-9-010 — 거버넌스 흐름 보호 (idea-guard)

- **요점**: 작업 중 새 아이디어/의견 발생 시 현재 흐름을 보호하고 문서화 없는 방향 전환을 금지하는 거버넌스 강화.
- **방향성**:
  - **Idea Capture Gate** (`constitution.md` §5.x 신설): 작업 중 새 아이디어 발생 → 즉시 backlog stub 생성 → "완료 후 진행 / 지금 전환" 명시적 게이트. 문서화 없는 방향 전환 금지.
  - **Context Continuity Check** (`agent.md` 세션 시작 부분): 세션 시작 시 미완 spec / 파킹된 아이디어 확인. 새 미션 전 "이전 대화에서 미완된 항목이 있습니다" 알림.
  - **Opinion Divergence Protocol** (`constitution.md` §5.x 신설): 사용자 의견 ≠ 현재 목표 → 충돌 명시 → 조율안 제안 후 사용자 선택 → 결과를 backlog/phase에 기록.
  - PR 단계 포함: PR 리뷰 중 새 아이디어 → `hk-ship` 커맨드에 안내 추가.
- **연관 모듈**: `sources/governance/constitution.md`, `sources/governance/agent.md`, `sources/commands/hk-ship.md`

### spec-9-011 — preflight-ux

- **요점**: `install.sh` / `update.sh` 시작 시 충돌 스캔 결과 요약 출력, 이상 있을 때 사용자 확인.
- **연관 모듈**: `install.sh`, `update.sh`

## 🧪 통합 테스트 시나리오

> 자세한 구현은 `tests/` 디렉토리.

### 시나리오 1: 신규 설치 — 충돌 없는 빈 프로젝트

- **Given**: git 초기화만 된 빈 디렉토리
- **When**: `install.sh <dir>` 실행
- **Then**: `.harness-kit/agent/`, `.harness-kit/bin/`, `.harness-kit/hooks/` 생성됨. `agent/`, `scripts/harness/`는 생성되지 않음. CLAUDE.md에 @import 3줄만 추가됨.
- **연관 SPEC**: spec-9-001, spec-9-002

### 시나리오 2: 충돌 있는 프로젝트 설치

- **Given**: `agent/` 디렉토리가 이미 존재하는 프로젝트 (비harness-kit 콘텐츠)
- **When**: `install.sh <dir>` 실행
- **Then**: `agent/` 충돌 없이 통과 (`.harness-kit/`에 설치되므로). `backlog/`가 비어있지 않으면 경로 변경 제안 출력.
- **연관 SPEC**: spec-9-001, spec-9-003

### 시나리오 3: v0.3 → v0.4 마이그레이션

- **Given**: v0.3(`agent/`, `scripts/harness/`)이 설치된 프로젝트
- **When**: `update.sh` 실행
- **Then**: preflight에서 old-layout 감지 경고 출력 → 사용자 확인 → `agent/` → `.harness-kit/agent/`, `scripts/harness/` → `.harness-kit/`로 이동. 구 디렉토리 제거.
- **연관 SPEC**: spec-9-001, spec-9-004

### 시나리오 4: CLAUDE.md 기존 내용 보존

- **Given**: 내용이 있는 CLAUDE.md (HARNESS-KIT 블록 없음)
- **When**: `install.sh` 실행
- **Then**: 기존 CLAUDE.md 내용 그대로 유지. 파일 끝에 @import 3줄만 추가됨.
- **연관 SPEC**: spec-9-002

### 시나리오 5: harness.config.json 경로 override

- **Given**: `harness.config.json`에 `{ "backlogDir": "hk-backlog", "specsDir": "hk-specs" }` 설정
- **When**: `sdd status` 실행
- **Then**: `hk-backlog/queue.md`를 기준으로 상태 출력. `backlog/`는 참조하지 않음.
- **연관 SPEC**: spec-9-003

### 통합 테스트 실행

```bash
bash tests/run-all.sh
```

## 🔗 의존성

- **선행 phase**: phase-8 (완료)
- **외부 시스템**: 없음 (bash, jq, git만 사용)
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| `.harness-kit/`가 기존 `.gitignore`의 `.*` 패턴에 걸림 | `.harness-kit/` 전체 미추적 | `install.sh`에서 `!.harness-kit/` un-ignore 추가 (spec-9-001) |
| v0.3 migration 중 실패 시 partial state | 구/신 레이아웃 혼재 | migration 전 `.harness-backup-{TS}/` 백업 + 실패 시 rollback |
| settings.json hook 경로 갱신 누락 | 모든 hook silently 실패 | spec-9-001에서 fragment 교체 후 hook 경로 검증 스텝 추가 |
| `backlog/`, `specs/` config 변경 후 sdd 경로 불일치 | sdd status/archive 오동작 | `harness.config.json` 읽기를 sdd 공통 lib 함수로 통일 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC이 `phase-9-install-conflict-defense` 브랜치에 merge
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 1~6 정량 측정 완료
- [ ] 사용자 최종 승인 (`/hk-phase-ship`)

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
