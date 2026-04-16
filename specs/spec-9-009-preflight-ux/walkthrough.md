# Walkthrough: spec-9-009

## 📋 실제 구현된 변경사항

- [x] `install.sh` — §3.5 Preflight 스캔 추가 (이미 설치됨, v0.3 잔재, 기존 hooks 감지)
- [x] `update.sh` — preflight 블록 추가 (다운그레이드 감지, v0.3 잔재) + state 복원 graceful fallback
- [x] `tests/test-preflight.sh` — 4개 시나리오 5개 체크

## 🧪 검증 결과

### 1. 자동화 테스트

#### test-preflight.sh
- **명령**: `bash tests/test-preflight.sh`
- **결과**: ✅ Passed (5/5)
- **로그 요약**:
```text
▶ 시나리오 A: 깨끗한 디렉토리 설치 (경고 없음)
  ✅ 설치 성공
▶ 시나리오 B: 이미 설치된 디렉토리
  ✅ "이미 설치됨" 경고 출력
▶ 시나리오 C: v0.3 잔재 레이아웃
  ✅ "v0.3" 경고 출력
  ✅ 설치는 정상 완료
▶ 시나리오 D: version downgrade (update.sh)
  ✅ "다운그레이드" 경고 출력
 ✅ ALL PASS (5/5)
```

#### 회귀 테스트
- `bash tests/test-update.sh` — ✅ 7/7 PASS
- `bash tests/test-install-layout.sh` — ✅ 7/7 PASS

## 🔍 발견 사항

- critique에서 권장한 대로 inline 방식이 깔끔하게 작동함. 공통 로직(v0.3 감지)이 2군데 중복이지만 3줄짜리라 문제 없음.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-15 |
| **최종 commit** | `3c459e4` |
