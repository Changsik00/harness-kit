# Implementation Plan: spec-09-001

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-001-dir-layout`
- 시작 지점: `main`
- PR 타깃: `phase-09-install-conflict-defense` (첫 hk-ship 시 자동 생성)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **v0.4.0 breaking change**: 이 PR이 merge되면 v0.3 설치 프로젝트는 `update.sh` 실행 전까지 `sdd` 경로가 달라짐. 기존 설치 프로젝트 보유 시 `update.sh` 배포를 빠르게 따라야 함.
> - [ ] **dogfooding 자체 마이그레이션 포함**: 이 harness-kit 프로젝트의 `agent/` → `.harness-kit/agent/`, `scripts/harness/` → `.harness-kit/` 이동이 Task 7에 포함됨. 마이그레이션 후 `sdd` 실행 경로가 `.harness-kit/bin/sdd`로 변경됨.

> [!WARNING]
> - [ ] `sources/governance/` 문서는 설치될 때 `.harness-kit/agent/`로 복사되므로 이 문서 내 경로 참조를 모두 교체하면 v0.3 install과 호환되지 않음 (의도된 breaking change).
> - [ ] Task 7 실행 후 이 세션의 `sdd` 명령 경로가 변경됨. `bash .harness-kit/bin/sdd` 사용 필요.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **installed.json** | `.harness-kit/installed.json`에 `kitVersion` 기록 | v0.3 감지 기준: 이 파일 없으면 old-layout으로 판단 |
| **migration 전략** | backup → rename (rm 없음) | 실패 시 rollback 가능, 사용자 데이터 보호 |
| **gitignore 처리** | `!.harness-kit/` 추가 | macOS/GitHub 기본 `.gitignore` 템플릿의 `.*` 패턴 차단 |
| **sources/ 구조** | 변경 없음 — 복사 대상 경로만 변경 | sources/는 kit 원본, 경로 변경은 설치 로직만 책임 |

## 📂 Proposed Changes

### [install.sh]

#### [MODIFY] `install.sh`

섹션 4 설치 계획 텍스트, 섹션 8 디렉토리 생성, 섹션 9–12 복사 경로, 섹션 16 gitignore, 섹션 17 state 파일 경로 전부 교체.

```text
# 변경 전 → 변경 후 (핵심)
$TARGET/agent/                     → $TARGET/.harness-kit/agent/
$TARGET/scripts/harness/bin/lib    → $TARGET/.harness-kit/bin/lib
$TARGET/scripts/harness/hooks      → $TARGET/.harness-kit/hooks
$TARGET/scripts/harness/lib        → $TARGET/.harness-kit/lib
$TARGET/.claude/state/current.json → $TARGET/.harness-kit/installed.json
  (내용: kitVersion, installedAt)

# .gitignore 추가 항목
# harness-kit
!.harness-kit/
.harness-backup-*/
```

### [update.sh]

#### [MODIFY] `update.sh`

v0.3 old-layout 감지 및 migration 로직 추가.

```bash
# old-layout 감지 조건
if [ -d "$TARGET/agent" ] && [ ! -d "$TARGET/.harness-kit" ]; then
  # v0.3 → v0.4 migration
  # 1) 백업
  # 2) mv agent/ .harness-kit/agent/
  # 3) mv scripts/harness/ .harness-kit/ (bin/, hooks/ 이동)
  # 4) settings.json hook 경로 패치 (jq)
  # 5) .gitignore !.harness-kit/ 추가
fi
```

### [uninstall.sh]

#### [MODIFY] `uninstall.sh`

- `rm -rf agent/` → `rm -rf .harness-kit/`
- `rm -rf scripts/harness/` → 제거 (`.harness-kit/` 안으로 통합)
- 백업 경로 업데이트

### [doctor.sh]

#### [MODIFY] `doctor.sh`

- `agent/`, `scripts/harness/` 경로 체크 → `.harness-kit/agent/`, `.harness-kit/bin/` 체크

### [sources/claude-fragments/settings.json.fragment]

#### [MODIFY] `sources/claude-fragments/settings.json.fragment`

- hook 경로: `scripts/harness/hooks/*.sh` → `.harness-kit/hooks/*.sh`

### [sources/governance/]

#### [MODIFY] `sources/governance/agent.md`

- `scripts/harness/bin/sdd` → `.harness-kit/bin/sdd` (2곳)
- `agent/constitution.md`, `agent/agent.md` → `.harness-kit/agent/constitution.md`, `.harness-kit/agent/agent.md`
- `agent/templates/` → `.harness-kit/agent/templates/` (템플릿 경로 표)

#### [MODIFY] `sources/governance/align.md`

- `bash scripts/harness/bin/sdd status` → `bash .harness-kit/bin/sdd status`
- `agent/constitution.md`, `agent/agent.md` → `.harness-kit/agent/` 참조

#### [MODIFY] `sources/governance/constitution.md`

- `agent/templates/` → `.harness-kit/agent/templates/`

### [sources/commands/]

#### [MODIFY] `sources/commands/hk-align.md`

- `@agent/constitution.md` → `@.harness-kit/agent/constitution.md`
- `@agent/agent.md` → `@.harness-kit/agent/agent.md`
- `@agent/align.md` → `@.harness-kit/agent/align.md`

#### [MODIFY] `sources/commands/hk-cleanup.md`

- `diff sources/governance/constitution.md agent/constitution.md` → `.harness-kit/agent/constitution.md`
- `ls agent/templates/` → `ls .harness-kit/agent/templates/`
- 동기화 명령 경로 일체 교체

#### [MODIFY] `sources/commands/hk-phase-ship.md`

- `agent/templates/phase-ship.md` → `.harness-kit/agent/templates/phase-ship.md`

### [VERSION]

#### [MODIFY] `VERSION`

- `0.3.0` → `0.4.0`

### [tests/]

#### [MODIFY] `tests/test-governance-dedup.sh`

- `agent/constitution.md` → `.harness-kit/agent/constitution.md` (Check 2 동기화 검증)

#### [NEW] `tests/test-install-layout.sh`

신규 레이아웃 검증 테스트:
1. 임시 git repo 생성
2. `install.sh --yes <tmpdir>` 실행
3. `.harness-kit/agent/`, `.harness-kit/bin/sdd` 존재 확인
4. `agent/`, `scripts/harness/` 미생성 확인
5. `.harness-kit/installed.json` kitVersion 확인
6. `.gitignore`에 `!.harness-kit/` 포함 확인
7. 임시 디렉토리 정리

### [dogfooding 자체 마이그레이션 — Task 7]

#### [MOVE] `agent/` → `.harness-kit/agent/`

이 harness-kit 프로젝트 자체의 installed governance 디렉토리 이동.

#### [MOVE] `scripts/harness/` → `.harness-kit/`

`bin/`, `hooks/`, `lib/` 전부 이동.

#### [MODIFY] `CLAUDE.md`

- `agent/constitution.md`, `agent/agent.md` 참조 교체
- `scripts/harness/bin/sdd` → `.harness-kit/bin/sdd`

#### [MODIFY] `.claude/settings.json`

- hook 경로: `scripts/harness/hooks/` → `.harness-kit/hooks/`

#### [MODIFY] `.gitignore`

- `!.harness-kit/` 추가, `.harness-backup-*/` 추가

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-install-layout.sh
bash tests/test-governance-dedup.sh
```

### 통합 테스트

```bash
bash tests/run-all.sh
```

### 수동 검증 시나리오

1. `bash .harness-kit/bin/sdd status` 실행 — 기대 결과: phase-09 active 정상 출력
2. `./install.sh --yes --dry-run /tmp/test-proj` — 기대 결과: `.harness-kit/` 경로만 출력, `agent/` 없음
3. `cat .harness-kit/installed.json` — 기대 결과: `kitVersion: "0.4.0"` 포함

## 🔁 Rollback Plan

- dogfooding 마이그레이션(Task 7) 실패 시: `git checkout -- .` + `git clean -fd .harness-kit/`로 복구
- 이미 push된 경우: `git revert`로 되돌리고 `agent/`, `scripts/harness/` 복원

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
