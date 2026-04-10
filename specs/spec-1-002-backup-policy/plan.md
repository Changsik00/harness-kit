# Implementation Plan: spec-1-002

## 📋 Branch Strategy

- 신규 브랜치: `spec-1-002-backup-policy`
- 시작 지점: `main`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 기본 보존 개수 3개가 적절한지 확인
> - [ ] git-clean 스킵 로직이 안전한지 확인 (uncommitted 변경이 있으면 무조건 백업)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **보존 정책** | 백업 후 오래된 것 삭제 | 삭제 먼저 하면 실패 시 복구 불가 |
| **git-clean 감지** | `git status --porcelain` 사용 | harness 파일만 검사하면 복잡. 전체 clean이면 스킵이 안전 |
| **--no-backup** | FORCE와 별도 플래그 | FORCE는 "덮어쓰기", no-backup은 "백업 안 함" — 의미 분리 |

## 📂 Proposed Changes

### install.sh

#### [MODIFY] `install.sh`

1. 인자 파싱에 `--no-backup` 추가
2. 백업 섹션(§7)에 git-clean 감지 + 보존 정책 추가:
   - git clean → 백업 스킵 + 로그
   - 백업 후 → 오래된 백업 삭제 (최근 N개만 유지)
3. install plan 출력에 no-backup 상태 표시

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오

1. install.sh를 5회 반복 실행 → `.harness-backup-*` 3개만 존재
2. `--no-backup` 옵션으로 실행 → 백업 디렉토리 미생성
3. git clean 상태에서 실행 → 백업 스킵 로그 출력

## 🔁 Rollback Plan

- install.sh 변경은 git revert로 즉시 원복 가능
- 이미 삭제된 백업은 복구 불가하나, git history가 보호

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
