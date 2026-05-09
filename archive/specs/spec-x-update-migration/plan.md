# Implementation Plan: spec-x-update-migration

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-update-migration`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

> **참고**: 본 Spec은 구현이 Plan 작성 전에 사용자 요청으로 선행 완료된 상태입니다.
> 실행 단계에서는 브랜치 생성 후 기존 변경사항을 논리 단위별로 커밋합니다.

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] constitution에 `spec-x-{slug}` 패턴 추가 — 기존 "Orphan Specs are forbidden" 규칙을 완화하는 거버넌스 변경
> - [ ] `spec-x` 진입 조건 범위 합의 (chore/fix/docs/소규모 refactor 한정)

> [!WARNING]
> - [ ] constitution 변경은 `sources/governance/`와 `agent/` 양쪽 모두 반영 필요

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **마이그레이션 시스템** | `sources/migrations/{version}.sh` 파일 분리 | 버전별 독립 관리, 향후 추가 용이 |
| **state 보존** | update.sh가 install.sh 호출 전후로 jq로 저장/복원 | install.sh 수정 없이 버그 해소 |
| **spec-x 패턴** | constitution §4.1, §5.2에 명시적 예외 추가 | 소규모 자족적 변경의 공식 경로 |
| **CHANGELOG** | 프로젝트 루트에 수동 관리 파일 | git log 보완, 사용자 친화 이력 |

## 📂 Proposed Changes

### [거버넌스]

#### [MODIFY] `sources/governance/constitution.md` + `agent/constitution.md`
- §4.1에 `spec-x-{slug}` 예외 조항 추가
- §5.2에 Solo Spec ID 형식 및 진입 조건 추가

### [버전 관리]

#### [MODIFY] `VERSION`
- `0.3.0` → `0.4.0`

#### [NEW] `CHANGELOG.md`
- 0.1.0 ~ 0.4.0 버전 이력

#### [NEW] `sources/migrations/0.4.0.sh`
- `migration_cleanup()`: 폐기 파일 목록 (hk-spec-review.md, 구 prefix 커맨드 등)
- `migration_new_features()`: 신규 기능 안내 텍스트

### [update.sh]

#### [MODIFY] `update.sh`
- 버전 비교 (`_ver_gt`, `_ver_lte`)
- `sources/migrations/` 순회 및 구간 마이그레이션 실행
- install.sh 호출 전후 state 보존/복원
- `.harness-backup-*` 정리 안내
- `--yes`, `--shell=` 옵션 지원

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
# syntax 검증
bash -n update.sh
bash -n sources/migrations/0.4.0.sh
```

### 수동 검증 시나리오
1. `./update.sh --help` 실행 → 사용법 출력 확인
2. `./update.sh .` 실행 (0.3.0 state 기준) → 마이그레이션 안내 + 폐기 파일 제거 흐름 확인
3. `./update.sh --yes .` 실행 → 무인 처리 확인
4. 업데이트 후 `sdd status` → phase/spec/planAccepted 보존 확인

## 🔁 Rollback Plan

- `git revert` 또는 브랜치 미머지로 대응
- state 파일은 gitignore 대상이므로 직접 수정 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
