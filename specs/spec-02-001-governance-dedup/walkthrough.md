# Walkthrough: spec-02-001

> 거버넌스 문서 중복 제거 및 실효성 정리 증거 로그.

## 📋 실제 구현된 변경사항

- [x] constitution §9.2: PR 생성 규칙을 `/gh-pr`, `/bb-pr` 슬래시 커맨드 존재에 맞게 수정
- [x] agent.md: 10개 중복 항목을 constitution 참조(`→ constitution §X.Y`)로 대체
- [x] agent.md §6.5: Priority 1 (LSP) 삭제, Priority 3 (CLI 도구) 삭제, 섹션 축소
- [x] agent.md §2: sdd 경로 오류 수정 (`bin/sdd` → `scripts/harness/bin/sdd`)
- [x] agent.md §4.3: 섹션 번호 중복 수정 (두 번째 §4.3 → §4.4)
- [x] agent.md §6.6: "MUST stop" → "SHOULD ask" 완화
- [x] `agent/` 디렉토리를 `sources/governance/`와 동기화

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-governance-dedup.sh`
- **결과**: ✅ Passed (8/8 checks)
- **로그 요약**:
```text
▶ Check 1: 중복 문장 검출 → ✅ 중복 문장 0건
▶ Check 2: 동기화 → ✅ constitution.md OK, ✅ agent.md OK
▶ Check 3: 토큰 카운트 → 2637w → 2363w (274w 감소) ✅
▶ Check 4: Dead letter → ✅ LSP 제거, ✅ CLI 도구 제거
▶ Check 5: 섹션 번호 → ✅ 중복 없음
▶ Check 6: sdd 경로 → ✅ 올바름
ALL 8 CHECKS PASSED
```

### 2. 수동 검증

1. **Action**: `diff sources/governance/constitution.md agent/constitution.md`
   - **Result**: 동일 (exit 0)
2. **Action**: `diff sources/governance/agent.md agent/agent.md`
   - **Result**: 동일 (exit 0)
3. **Action**: agent.md에서 `→ constitution §` 참조 확인
   - **Result**: §4.3, §4.4, §5, §5.4, §6.1, §7, §9.1, §9.2 참조 → 10개 항목 커버

### 3. 증거 자료

- [x] 테스트 로그 (위 참조)
- [x] git diff 검증 완료

## 🔍 발견 사항

- agent.md의 word count 감소가 예상(~1,200 토큰)보다 적음 (274w ≈ ~400 토큰). 이는 중복이 "완전 동일 복사"보다 "재기술/확장"이 많았기 때문. 나머지 토큰 절감은 spec-02-002 (2단계 로딩)에서 달성 예정.
- `backlog/phase-N.md`의 "두 단계의 분리" 설명 3줄도 agent.md에서 제거함 (constitution §5.3에 경로 규칙이 있으므로 중복).

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-10 |
| **최종 commit** | `f0fa451` |
