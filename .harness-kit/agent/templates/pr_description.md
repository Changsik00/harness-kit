# <type>(spec-{phaseN}-{seq}): <한 줄 설명>

> 첫 줄은 commit subject 와 정확히 일치해야 합니다 (`type(spec-...): description`).
> hosted git UI 에 그대로 붙여넣기 좋도록 작성합니다.

## 📋 Summary

### 배경 및 목적
<!-- 왜 이 작업이 필요한지, 어떤 문제를 해결하는지 -->

### 주요 변경 사항
- [x] <Before/After 또는 주요 개선 사항 1>
- [x] <항목 2>
- [x] <항목 3>

### Phase 컨텍스트
- **Phase**: `phase-{phaseN}`
- **본 SPEC 의 역할**: <Phase 목표 달성에 어떤 기여를 하는가>

## 🎯 Key Review Points

<!-- 리뷰어가 집중해야 할 핵심 변경점/로직 -->

1. **<핵심 영역 1>**: <왜 주의 깊게 봐야 하는지>
2. **<핵심 영역 2>**: <어떤 결정이 중요한지>

## 🧪 Verification

### 자동 테스트
```bash
# 본 SPEC 의 단위 테스트 실행 명령
```

**결과 요약**:
- ✅ `<test name>`: 통과
- ✅ `<test name>`: 통과

### (해당 시) 통합 테스트
```bash
# 통합 테스트 실행 명령
```

### 수동 검증 시나리오
1. **시나리오 1**: <동작> → <결과>
2. **시나리오 2**: <동작> → <결과>

## 📦 Files Changed

### 🆕 New Files
- `<path/to/new_file>`: <설명>

### 🛠 Modified Files
- `<path/to/file>` (+XX, -YY): <간단 변경 요약>

### 🗑 Deleted Files
- `<path/to/old_file>`: <삭제 사유>

**Total**: X files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] (해당 시) 통합 테스트 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] lint / type check 통과
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-{phaseN}/phase.md`
- Walkthrough: `specs/spec-{phaseN}-{seq}-{slug}/walkthrough.md`
- 관련 ADR (있다면): `docs/decisions/ADR-NNN-...md`
