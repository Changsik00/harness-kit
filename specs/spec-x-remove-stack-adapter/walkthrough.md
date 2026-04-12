# Walkthrough: spec-x-remove-stack-adapter

> 본 문서는 *증거 로그* 입니다.

## 📋 실제 구현된 변경사항

- [x] `stacks/` 디렉토리 삭제 (generic.sh, nodejs.sh)
- [x] `scripts/harness/lib/stack.sh` (설치 결과물) 삭제
- [x] `install.sh`에서 `--stack` 옵션, `detect_stack()`, stack 복사 로직 제거
- [x] `update.sh`에서 stack 복원 로직 제거
- [x] `doctor.sh`에서 stack 검증 항목 제거
- [x] `sdd` CLI에서 stack 변수/출력 제거
- [x] `hk-ship.md`에서 환경변수 → 에이전트 직접 판단 안내로 변경
- [x] `agent.md` §6.7 Stack Awareness 섹션 삭제
- [x] `plan.md` 템플릿에서 stack adapter 참조 수정
- [x] `CLAUDE.md`, `README.md`, `docs/REFERENCE.md`에서 stack 관련 문서 제거

## 🧪 검증 결과

### 1. 자동화 테스트

해당 없음 — 문서/스크립트 정리 작업으로 단위 테스트 대상 아님.

### 2. 수동 검증

1. **Action**: `bash -n install.sh`
   - **Result**: 구문 오류 없음 ✅
2. **Action**: `bash -n update.sh`
   - **Result**: 구문 오류 없음 ✅
3. **Action**: `bash -n doctor.sh`
   - **Result**: 구문 오류 없음 ✅
4. **Action**: `sdd status`
   - **Result**: `stack=` 출력 없음, 정상 동작 ✅
5. **Action**: `doctor.sh` 실행
   - **Result**: PASS 36 / WARN 1 (bash 3.2) / FAIL 0 ✅
6. **Action**: grep으로 잔여 HARNESS_STACK/HARNESS_TEST_CMD/stack.sh/stacks/ 참조 검색
   - **Result**: spec 문서(설명 목적) 외 잔여 참조 없음 ✅

### 3. 증거 자료

- doctor.sh 출력 로그 (위 참조)
- sdd status 출력 로그 (위 참조)

## 🔍 발견 사항

- `docs/USAGE.md`에는 stack 관련 내용이 없어 수정 불필요했음
- `.claude/state/current.json`은 `.gitignore` 대상이라 git add 불가 — 수동으로 `stack` 필드 제거 완료

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-12 |
| **최종 commit** | `f228058` |
