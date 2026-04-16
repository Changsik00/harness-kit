# Task List: spec-02-001

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-02.md SPEC 표 갱신)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-02-001-governance-dedup`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: constitution.md PR 생성 규칙 수정 (소스 원본)

### 2-1. `sources/governance/constitution.md` 수정
- [x] §9.2: "PR creation is delegated to the User" → 에이전트가 `/gh-pr` 등으로 생성 가능하되 사용자 확인 필요로 수정
- [x] Commit: `fix(spec-02-001): update pr creation rule to reflect slash commands`

---

## Task 3: agent.md 중복 제거 + 실효성 정리 (소스 원본)

### 3-1. `sources/governance/agent.md` 리팩토링
**중복 제거 (10개 항목):**
- [x] §0: Plan Accept 중복 → constitution §4.3 참조로 축소
- [x] §4: 한국어 요구사항 재기술 → constitution §4.4 참조
- [x] §5: 브랜치 형식 재기술 → constitution §5.4 참조
- [x] §6.1: One Task = One Commit 재언급 → constitution §7 참조
- [x] §6.1: main 브랜치 확인 → constitution §9.1 참조
- [x] §6.3: 커밋 형식/타입/예시, Pre-Push, PR 생성 → constitution §9.2 참조
- [x] §7: main 직접 커밋 재언급 → constitution §9.1 참조

**실효성 정리 (6개 항목):**
- [x] §2: sdd 경로 `bin/sdd status` → `scripts/harness/bin/sdd status` 수정
- [x] §4.3 번호 중복 → 두 번째 §4.3 (Hard Stop)을 §4.4로 변경
- [x] §6.5 Priority 1 (LSP) 삭제
- [x] §6.5 Priority 3 (CLI 도구 목록 + sed/awk/grep 금지) 삭제
- [x] §6.5 축소: Priority 2 내용을 인라인 1~2줄로 정리, 독립 섹션 제거
- [x] §6.6: "멈추라" → "사용자에게 확인" 완화

- [x] 전체 리뷰: 참조 정확성, 규칙 의미 보존, 섹션 번호 연속성 확인
- [x] Commit: `refactor(spec-02-001): deduplicate and clean up agent.md`

---

## Task 4: 도그푸딩 동기화

### 4-1. `agent/` 동기화
- [x] `sources/governance/constitution.md` → `agent/constitution.md` 복사
- [x] `sources/governance/agent.md` → `agent/agent.md` 복사
- [x] diff 검증: 각 쌍이 동일한지 확인
- [x] Commit: `chore(spec-02-001): sync agent/ with sources/governance/`

---

## Task 5: 검증 테스트

### 5-1. 검증 스크립트 작성 및 실행
- [x] `tests/test-governance-dedup.sh` 작성: constitution과 agent.md 사이 동일 문장 검출
- [x] 테스트 실행 → 중복 0건 확인, 8/8 checks PASS
- [x] 토큰 카운트 비교: 2637w → 2363w (274w 감소, ~10%)
- [x] Commit: `test(spec-02-001): add governance dedup verification test`

---

## Task 6: Hand-off (필수)

> 모든 작업 task 완료 후 수행합니다.

- [x] 전체 테스트 실행 → 모두 PASS (8/8)
- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Archive Commit**: `docs(spec-02-001): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-02-001-governance-dedup`
- [x] **사용자 알림**: 푸시 완료 + PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 5 (Task 1은 브랜치만) |
| **현재 단계** | Hand-off |
| **마지막 업데이트** | 2026-04-10 |
