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
| `spec-9-001` | dir-layout | P? | Active | `specs/spec-9-001-dir-layout/` |
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

### spec-9-004 — install/update.sh 시작 시 안전 문의 통합

- **요점**: `install.sh`와 `update.sh` 시작 시 충돌 스캔 결과를 요약 리포트로 출력하고, 이상이 있을 때는 사용자 확인 후 진행한다.
- **방향성**:
  - 공통 함수: `_harness_preflight_check()` — 충돌 스캔, 버전 확인, migration 필요 여부 판단
  - `install.sh`: preflight → 리포트 출력 → 충돌 있으면 확인 → 기존 설치 계획 출력 → 진행
  - `update.sh`: preflight → 현재 버전 vs 신규 버전 diff → migration 필요 시 경고 → 사용자 확인
  - `--yes` 플래그: preflight 리포트 출력 후 확인 없이 진행 (CI 호환)
  - spec-9-003 완료 후 작업 (충돌 감지 함수가 먼저 필요)
- **참조**: 사용자 요청 4번
- **연관 모듈**: `install.sh`, `update.sh`, `sources/bin/lib/`

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
