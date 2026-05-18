# Implementation Plan: spec-x-claude-md-nested

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-claude-md-nested` (= spec 디렉토리 이름)
- 시작 지점: `main` (memory `feedback_specx_branch_from_main.md` 준수)
- 첫 task 가 브랜치 생성 수행

> Note: scaffold `sdd specx new` 가 spec.md 의 Branch 필드를 `spec-x-{slug}-{slug}` 로 중복 입력하는 버그 (icebox 등록됨) — spec.md 에서 수동 보정 완료.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] root CLAUDE.md 는 *건드리지 않는다* 는 결정 — nested 추가만으로 충분하고, root slim 은 별 spec 으로 분리 (시점 분리와 *추가 슬림* 은 서로 다른 결정).
> - [ ] nested CLAUDE.md 내용이 root 와 *중복되지 않도록* 의식 — root 는 메타 가이드 (두 시점 공존 설명) / nested 는 *그 시점에서만 유효한* 디렉토리 특화 컨텍스트.

## 🎯 핵심 전략

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **`sources/CLAUDE.md`** | 신규 — 키트 원본 시점 룰만 (수정 영향, update 메커니즘, sources/ 디렉토리 의미, bash 호환 룰 reminder) | sources/ 하위 파일 편집 시 자동 로드 → "키트 원본 시점" 컨텍스트 명시화 |
| **`specs/CLAUDE.md`** | 신규 — 작업 로그 시점 룰만 (한국어 산출물, 템플릿 위치, immutable 정책, archive 관계) | specs/ 하위 파일 편집 시 자동 로드 → "작업 로그 시점" 컨텍스트 명시화 |
| **`root CLAUDE.md`** | **변경 없음** | scope 분리. 별 spec 에서 root slim 재검토 |
| **`sources/governance/CLAUDE.md`** | 추가 안 함 | Claude Code 가 상위 sources/CLAUDE.md 도 함께 로드. 한 단계로 충분 |
| **내용 분량** | 각 ≤ 25줄 | nested 는 *디렉토리 특화* 만. 길어지면 root 와 중복 가능성 ↑ |

### 📑 ADR 후보

- [x] 없음 — 단순 docs 추가.

## 📂 Proposed Changes

### 신규 파일

#### [NEW] `sources/CLAUDE.md`

대략 다음 구조 (한국어):

```markdown
# sources/ — 키트 원본 시점

이 디렉토리는 **harness-kit 자체** 의 원본입니다. 여기의 파일은 `install.sh` 또는 `update.sh` 를 통해 *다른 프로젝트에* 복사되어 적용됩니다.

## 핵심 주의

- **수정 영향**: 이 디렉토리의 파일을 수정해도 *이미 install 된 프로젝트* 는 자동으로 갱신되지 않습니다. `update.sh` 가 그 역할입니다.
- **bash 3.2+ 호환**: 모든 스크립트는 bash 3.2 (macOS 기본) 에서 동작해야 합니다. bash 4+ 전용 기능 (`declare -A`, `mapfile`, `**` globstar, `${var,,}`, `coproc`) 금지.
- **한국어 산출물 원칙**: 거버넌스 문서 (`sources/governance/`) 외 사용자-대면 산출물 (templates, commands 설명) 은 한국어.

## 하위 디렉토리

| 경로 | install 대상 | 역할 |
|---|---|---|
| `governance/` | `.harness-kit/agent/` | constitution / agent.md / align.md (행동 규약) |
| `templates/` | `.harness-kit/agent/templates/` | spec/plan/task 등 산출물 양식 |
| `commands/` | `.claude/commands/` | 슬래시 커맨드 (`/hk-*`) |
| `hooks/` | `.claude/scripts/harness/hooks/` | 후크 스크립트 |
| `bin/` | `.harness-kit/bin/` | `sdd` 메타 명령 |
| `claude-fragments/` | `.claude/settings.json` / `CLAUDE.md` 머지 | fragment 조각 |
```

목표: ≤ 25줄.

#### [NEW] `specs/CLAUDE.md`

대략 다음 구조 (한국어):

```markdown
# specs/ — 작업 로그 시점

이 디렉토리는 진행 중 / 완료된 **spec 의 산출물 보관소** 입니다. archive 와의 차이: 머지 후 정리 전까지는 `specs/`, 정리 후 `archive/specs/` 로 이동.

## 핵심 주의

- **한국어 산출물**: spec.md / plan.md / task.md / walkthrough.md / pr_description.md / critique.md 모두 한국어.
- **템플릿 강제**: 신규 산출물 작성 시 `.harness-kit/agent/templates/` 의 해당 템플릿을 *읽고* 따를 것 (constitution §5.4).
- **머지 후 immutable**: PR 머지된 spec 의 산출물은 사후 수정하지 않습니다. 후속 결정은 *새 spec* 으로.
- **archive 정책**: `archive/specs/*` 는 grep / 정합성 검사에서 false positive 의 원천. 외부 참조 갱신 시 archive 는 건너뜁니다.
```

목표: ≤ 25줄.

### 변경 없음

- `CLAUDE.md` (root) — 의도적 무변경.
- `install.sh`, `update.sh` — nested CLAUDE.md 는 `HARNESS-KIT:BEGIN/END` 마커 영역 외이므로 install 정책에 무관.

## 🧪 검증 계획

### 수동 검증
1. **분량 확인** — `wc -l sources/CLAUDE.md specs/CLAUDE.md` 각 ≤ 25.
2. **root 무변경** — `git diff main..HEAD -- CLAUDE.md` 출력 없음.
3. **install 회귀 없음** — `bash tests/test-install-claude-import.sh` PASS (root 만 검사하므로 영향 없을 것).
4. **마커 보존** — `grep "HARNESS-KIT" CLAUDE.md` 결과 변동 없음.

### 자동화 테스트
```bash
bash tests/test-install-claude-import.sh
bash tests/test-marker-append-guard.sh
bash tests/test-marker-edge-cases.sh
```

기존 PASS 셋이 그대로 PASS 해야 함.

## 🔁 Rollback Plan

- 신규 파일 2개 삭제로 rollback 가능 — root / install 무변경이므로 안전.
- PR 미머지 close 로도 동일 효과.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
