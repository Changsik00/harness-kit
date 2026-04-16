# Implementation Plan: spec-09-002

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-002-claude-md-import`
- 시작 지점: `phase-09-install-conflict-defense`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **@import 실제 동작**: Claude Code가 `CLAUDE.md` 내 `@.harness-kit/CLAUDE.fragment.md` 줄을 실제로 파싱·로딩하는지 확인 필요. 동작하지 않으면 핵심 전제가 깨짐.
> - [ ] **fragment 파일명**: `CLAUDE.fragment.md` vs `CLAUDE.md.fragment` — 설치 대상 파일명을 `.harness-kit/CLAUDE.fragment.md`로 확정.

> [!WARNING]
> - [ ] **기존 설치 마이그레이션**: `update.sh`가 구 방식 블록(15줄 직접 삽입)을 감지해 3줄 @import로 전환. 기존 CLAUDE.md 내용 보존이 핵심.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **CLAUDE.md 삽입** | `@import` 3줄만 삽입 | merge conflict 최소화 |
| **fragment 위치** | `.harness-kit/CLAUDE.fragment.md` | spec-09-001의 `.harness-kit/` 레이아웃과 일관성 |
| **sources 원본** | `sources/claude-fragments/CLAUDE.fragment.md`로 파일명 변경 | `.md.fragment` 확장자가 비표준 |
| **update.sh** | CLAUDE.md 불변, fragment만 교체 | 사용자 CLAUDE.md 보호 |

### @import 3줄 형식

```markdown
<!-- HARNESS-KIT:BEGIN -->
@.harness-kit/CLAUDE.fragment.md
<!-- HARNESS-KIT:END -->
```

## 📂 Proposed Changes

### [install.sh]

#### [MODIFY] `install.sh` — Section 15 (CLAUDE.md 갱신)

현재: `CLAUDE_FRAGMENT` 내용 전체를 CLAUDE.md에 직접 append
변경: `.harness-kit/CLAUDE.fragment.md` 복사 후 CLAUDE.md에 3줄 @import 삽입

```bash
# 변경 후 로직
DEST_FRAGMENT="$TARGET/.harness-kit/CLAUDE.fragment.md"
cp "$CLAUDE_FRAGMENT_SRC" "$DEST_FRAGMENT"

# CLAUDE.md에 3줄만 삽입 (기존 블록 교체 또는 append)
IMPORT_BLOCK="<!-- HARNESS-KIT:BEGIN -->\n@.harness-kit/CLAUDE.fragment.md\n<!-- HARNESS-KIT:END -->"
```

### [sources/claude-fragments/]

#### [RENAME] `CLAUDE.md.fragment` → `CLAUDE.fragment.md`

파일명 정리. 내용은 동일(현재 `CLAUDE.md.fragment` 내용 유지하되 경로 참조 `.harness-kit/agent/` 로 수정).

### [update.sh]

#### [MODIFY] `update.sh` — CLAUDE.md 처리 로직

- CLAUDE.md 본문은 수정하지 않는다.
- `.harness-kit/CLAUDE.fragment.md`만 sources의 최신 fragment로 교체한다.
- **마이그레이션 감지**: CLAUDE.md 내 `HARNESS-KIT:BEGIN` 블록이 `@.harness-kit/CLAUDE.fragment.md` 줄 없이 내용이 있으면 구 방식으로 판단 → 블록을 3줄 @import로 교체.

### [tests/]

#### [NEW] `tests/test-install-claude-import.sh`

TDD Red 단계:
- 임시 repo에 `install.sh --yes` 실행
- `.harness-kit/CLAUDE.fragment.md` 존재 확인
- `CLAUDE.md`에 `@.harness-kit/CLAUDE.fragment.md` 줄 존재 확인
- `CLAUDE.md` 내 직접 삽입 내용(에이전트 운영 규약 등) 미존재 확인
- fragment 내 `핵심 규칙 요약` 존재 확인
- 멱등성: 재실행 시 @import 줄 중복 없음 확인

#### [MODIFY] `tests/test-two-tier-loading.sh`

Check 1(fragment에 `@agent/` import 없음)은 이미 통과 중. fragment 경로(`FRAGMENT` 변수)를 `.harness-kit/CLAUDE.fragment.md`로 업데이트 필요.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트
```bash
bash tests/test-install-claude-import.sh
bash tests/test-two-tier-loading.sh
```

### 통합 테스트
```bash
# 임시 repo에 install → CLAUDE.md @import 확인
# update → fragment만 교체, CLAUDE.md 불변 확인
```

### 수동 검증 시나리오
1. 신규 프로젝트에 `install.sh --yes` → `CLAUDE.md`에 3줄만 삽입, `.harness-kit/CLAUDE.fragment.md` 생성 확인
2. 기존 설치(구 방식) 프로젝트에 `update.sh` → CLAUDE.md가 @import 방식으로 전환, 사용자 내용 보존 확인
3. `install.sh --yes` 재실행 → `@.harness-kit/CLAUDE.fragment.md` 줄 중복 없음 확인

## 🔁 Rollback Plan

- `update.sh`가 migration 전 CLAUDE.md 백업 생성 (`.harness-backup-{TS}/CLAUDE.md`)
- 문제 시 백업에서 복원: `cp .harness-backup-{TS}/CLAUDE.md CLAUDE.md`

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
