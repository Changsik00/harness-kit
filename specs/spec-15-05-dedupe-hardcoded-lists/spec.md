# spec-15-05: install/update 의 하드코딩 리스트 3개 → generic 메커니즘 (P1)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-15-05` |
| **Phase** | `phase-15` (base: `phase-15-upgrade-safety`) |
| **Branch** | `spec-15-05-dedupe-hardcoded-lists` |
| **상태** | Planning |
| **타입** | Refactor (+ 회귀 테스트) |
| **Integration Test Required** | no |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

spec-15-01 audit §4.2 의 **Pattern A — Schema Drift** 가 가장 빈번한 버그 원인. 본 spec 은 audit §5.4 P1 의 두 항목을 통합 해결:

3개 하드코딩 리스트:

1. **`install.sh:257-259` governance** (3개) — `for f in constitution.md agent.md align.md`
2. **`install.sh:262-264` templates** (8개) — `for f in queue.md phase.md phase-ship.md spec.md plan.md task.md walkthrough.md pr_description.md`
3. **`update.sh:120` state 백업 화이트리스트** (6개) — `jq -c '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}'`

### 문제점

#### 발현 사례

- **#83 (spec-x-install-phase-ship-template)** — 템플릿 디렉토리에 `phase-ship.md` 가 추가됐는데 install.sh:262 의 명단이 갱신되지 않아 install 누락. 1줄 fix 로 해결됐지만 *근본 원인은 그대로*.
- **#82 (spec-x-update-preserve-state)** — state.json 에 `branch`, `baseBranch` 가 추가됐는데 update.sh 의 백업 화이트리스트가 4개에서 멈춤. 2개 필드 영구 소실.

#### 패턴

세 위치 모두 **명시적 enumeration** — 추가 시 *2 곳 (또는 3 곳) 동기화* 필요. 기능 추가의 보호 장치가 사람의 기억에만 의존.

대조: `install.sh:269-280` (commands), `install.sh:285-298` (hooks), `install.sh:303-313` (bin) 은 **directory glob / `cp -rf`** 으로 동기화 자동. 이미 본 프로젝트 안에서 검증된 패턴.

### 해결 방안 (요약)

**generic 메커니즘** 으로 교체:

| 타깃 | 현재 | 신규 | 정책 |
|---|---|---|---|
| governance | hardcoded 3 | 디렉토리 glob | `for f in "$KIT_DIR/sources/governance"/*.md` |
| templates | hardcoded 8 | 디렉토리 glob | `for f in "$KIT_DIR/sources/templates"/*.md` |
| state 백업 | inclusion 6 | **exclusion** | `jq 'del(.kitVersion, .installedAt)'` |

state 의 경우 *inclusion (whitelist)* 대신 *exclusion (blacklist)* 사용 — install.sh 가 새로 쓰는 두 키 (`kitVersion`, `installedAt`) 만 제외하면 나머지는 자동 보존. 새 state 필드 추가 시 *update.sh 손대지 않음*.

## 🎯 요구사항

### Functional Requirements

1. **F1.** `install.sh:257-259` governance 복사 루프를 디렉토리 glob 으로 교체. `sources/governance/` 의 모든 `*.md` 자동 install.
2. **F2.** `install.sh:262-264` templates 복사 루프를 디렉토리 glob 으로 교체. `sources/templates/` 의 모든 `*.md` 자동 install.
3. **F3.** `update.sh:113-122` state 백업을 exclusion 으로 변경 — `jq -c 'del(.kitVersion, .installedAt)'`. 새 state 필드 자동 보존.
4. **F4.** **회귀 테스트** — `tests/test-install-manifest-sync.sh` 신규. `sources/governance/` 와 `sources/templates/` 의 파일 명단이 install 결과와 1:1 일치 검증 (drift 자동 감지).
5. **F5.** **state 보존 회귀** — `tests/test-update-stateful.sh` 또는 별 테스트에 *임의 신규 필드* (예: `_testCustomField`) 추가 → update → 보존 검증.

### Non-Functional Requirements

1. **NF1.** 기존 동작 변경 없음 — 현재 sources/governance/ 의 3개 .md, sources/templates/ 의 8개 .md 가 모두 동일하게 install 됨.
2. **NF2.** bash 3.2+ 호환.
3. **NF3.** state 의 *jq fallback* 보장 — jq 미설치 시 update.sh 의 기존 graceful skip 동작 유지.

## 🚫 Out of Scope

- governance/templates 디렉토리에 `.md` 외 파일 처리 — 현재 정책 (only `.md`) 유지. 다른 확장자가 필요하면 별 spec.
- `install.sh:447-466` `installed.json` 의 `installedCommands` 패턴 (spec-15-03) 을 templates/governance 에도 적용 — 기존 디렉토리 glob + `_md_files()` 가 이미 idempotent 라 *제거 동기화* 도 자동. 추가 명단 기록 불필요.
- update.sh 의 in-place upgrade 리팩토링 (P2 후보).
- `installedCommands` 와 동일한 `installedTemplates` / `installedGovernance` 추가 — 위와 동일 사유로 불필요.

## ✅ Definition of Done

- [ ] `install.sh` governance / templates 루프 디렉토리 glob 으로 교체
- [ ] `update.sh` state 백업 exclusion 으로 변경
- [ ] `tests/test-install-manifest-sync.sh` 신규 — drift 자동 감지 (≥ 4 checks)
- [ ] state 보존 회귀 테스트 추가 (≥ 2 checks)
- [ ] 기존 회귀 PASS (`test-install-layout`, `test-update`, `test-update-stateful`, `test-uninstall-cmd-list`, `test-version-bump`)
- [ ] `walkthrough.md` / `pr_description.md` ship + push + PR (base: `phase-15-upgrade-safety`)
