# <type>(spec-XXX): <description>

## 📋 Summary

### 배경 및 목적
<!-- 왜 이 작업이 필요한지, 어떤 문제를 해결하는지 작성 -->

### 주요 변경 사항
<!-- Before / After 비교 또는 주요 개선 사항 요약 -->
- [x] Item A
- [x] Item B

## 🎯 Key Review Points
<!-- 리뷰어가 집중해야 할 설계 변경점이나 로직 -->
1. **Module A**: 리팩토링된 상속 구조 확인 필요
2. **State Graph**: 새로운 순환 연지 및 조건부 분기 로직

## 🧪 Verification

### Automated Tests
```bash
# Exact command running the tests
uv run pytest ...
```
**테스트 결과 요약:**
- ✅ `test_A`: 통과
- ✅ `test_B`: 통과

### Manual Verification (Scenarios)
1. **시나리오 1**: <동작 설명> -> <결과 확인>
2. **시나리오 2**: <동작 설명> -> <결과 확인>

## 📦 Files Changed

### 🆕 New Files
- `path/to/new_file.py`: <Description>

### 🛠 Modified Files
- `path/to/file.py` (+XX, -YY): <Brief change log>

**Total:** X files changed

## ✅ Definition of Done
- [x] 모든 단위/통합 테스트 통과
- [x] `walkthrough.md` 작성 및 아카이브 완료
- [x] `pr_description.md` 작성 및 아카이브 완료
- [x] Ruff lint 및 format 확인 완료
