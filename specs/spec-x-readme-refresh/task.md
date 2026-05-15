# Task List: spec-x-readme-refresh

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-readme-refresh` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 의존성 명세 정정 (bash 4.0+ → 3.2+)

### 2-1. 의존성 표 / 코드 블록 수정
- [x] `README.md` 의 `## 🖥 대상 환경 및 의존성` 표에서 `bash 4.0+` 표현 제거 → `bash 3.2+` 로 변경
- [x] macOS 행 비고 정리 (필요 시) — *기본 bash 3.2 로 동작*
- [x] `brew install bash jq git` → `brew install jq git` (bash 제외) + 주석 정리
- [x] 수동 점검: `grep -n "bash 4" README.md` 가 비어 있는지 확인
- [x] Commit: `docs(spec-x-readme-refresh): align bash dependency with 3.2+ compatibility`

---

## Task 3: 키트 의도/철학 보강

### 3-1. "왜 이 구조인가" 문단 추가 + Plan Accept 의미 보강
- [x] `README.md` 의 "💡 이 키트는 무엇인가" 섹션 끝(표 다음, "📖 핵심 개념" 직전) 에 mini 문단 추가:
  - 이해 부채(understanding debt) 방지
  - 선언형 명세 (spec.md = 무엇/왜, plan.md/task.md = 어떻게)
  - Plan Accept = 가정 검증 게이트
  - walkthrough.md 의 역할 (결정/디버깅/예외 기록)
- [x] "🚀 시작하기" Step 4 (Plan Accept) 설명에 "가정·범위 검증 게이트" 1줄 자연스럽게 추가
- [x] 수동 점검: 톤·이모지·표 일관성, 마크다운 렌더링
- [x] Commit: `docs(spec-x-readme-refresh): clarify kit intent and plan accept as assumption gate`

---

## Task 4: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 마크다운 렌더링 시각 점검 (표 / 코드블록 / mermaid 깨짐 없음)
- [x] `git diff main -- README.md` 가 plan 범위 안인지 확인
- [x] **walkthrough.md 작성** (예상 못한 발견·결정 이유 위주, 변경 나열 금지)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Ship Commit**: `docs(spec-x-readme-refresh): ship walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-x-readme-refresh`
- [x] **PR 생성**: `/hk-pr-gh` 또는 `gh pr create` (Plan Accept 후 자동 진행, 사용자 확인 생략)
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 (Task 2, 3, 4 ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-15 |
