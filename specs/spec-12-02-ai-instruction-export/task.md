# Task List: spec-12-02

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 백로그 업데이트 (phase-12.md SPEC 표 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-12-02-ai-instruction-export`
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: 테스트 작성 (TDD Red)

- [ ] `tests/test-export-format.sh` 작성
  - Check 1: `--export-format` 미지정 → `.cursorrules` 생성 안 됨
  - Check 2: `--export-format=cursor` → `.cursorrules` 생성
  - Check 3: `.cursorrules` 내용이 CLAUDE.fragment.md를 포함
  - Check 4: `--export-format=copilot` → `.github/copilot-instructions.md` 생성
  - Check 5: 파일 이미 존재 시 덮어쓰기 경고 출력
- [ ] 테스트 실행 → FAIL 확인
- [ ] Commit: `test(spec-12-02): add failing tests for export-format option`

---

## Task 3: 구현 (TDD Green)

- [ ] `install.sh`에 `--export-format` 옵션 추가
  - 옵션 파싱 (`--export-format=cursor|copilot|none`)
  - `_export_ai_instructions()` 함수 구현
  - `--help` 출력 갱신
- [ ] 테스트 실행 → PASS 확인
- [ ] Commit: `feat(spec-12-02): add --export-format option to install.sh`

---

## Task 4: Ship

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-12-02): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-12-02-ai-instruction-export`
- [ ] **PR 생성** (사용자 승인 후)
- [ ] **사용자 알림**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-20 |
