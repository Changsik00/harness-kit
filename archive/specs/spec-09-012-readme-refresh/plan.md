# Implementation Plan: spec-09-012

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-012-readme-refresh`
- 시작 지점: `phase-09-install-conflict-defense`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [x] VERSION 갱신은 phase PR 시 `0.5.0`으로 (이 spec에서는 README 내 배지만 `0.5.0`으로 선반영)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **레이아웃 트리** | 전면 교체 | `.harness-kit/` 은닉 디렉토리 구조로 변경됨 |
| **경로 참조** | 일괄 치환 | `agent/` → `.harness-kit/agent/`, `scripts/harness/` → `.harness-kit/` |
| **VERSION** | README 배지만 `0.5.0` 선반영, VERSION 파일은 phase PR 시 갱신 | phase-09 전체가 breaking change |

## 📂 Proposed Changes

#### [MODIFY] `README.md`

1. 버전 배지: `0.3.0` → `0.4.0`
2. 설치 레이아웃 트리: `.harness-kit/` 구조로 교체
3. CLAUDE.md 설명: `@import` 3줄 방식으로 갱신
4. 경로 참조 일괄 교체
5. queue.md NOW/NEXT → `sdd status` 실시간 계산 안내
6. 슬래시 커맨드 표에 `/hk-cleanup` 추가
7. install.sh 옵션에 `--no-gitignore` 추가
8. 명령 요약에 `cleanup.sh` 추가
9. sdd archive 설명 갱신
10. 워크플로 다이어그램에 Post-Merge 흐름 추가

#### VERSION 파일

이 spec에서는 변경하지 않음. phase PR (`/hk-phase-ship`) 시 `0.5.0`으로 갱신.

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오
1. README.md에서 `scripts/harness` grep → 0건
2. README.md에서 `agent/constitution` grep (`.harness-kit/` prefix 없는 것) → 0건
3. VERSION 파일 내용 = `0.4.0`

## 🔁 Rollback Plan

- `git revert` 한 커밋으로 복원

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
