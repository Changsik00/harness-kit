# refactor(spec-02-01): 거버넌스 문서 중복 제거 및 실효성 정리

## 📋 Summary

### 배경 및 목적
constitution.md와 agent.md 사이에 10개 항목의 중복 기술이 존재하여 토큰 낭비, 동기화 실패 위험, 권위 혼란이 발생. 또한 실효성 없는 규칙(LSP 위임, CLI 도구 목록)과 현실 불일치(PR 생성 규칙)가 발견됨.

### 주요 변경 사항
- [x] agent.md에서 10개 중복 항목을 `(→ constitution §X.Y)` 참조로 대체
- [x] §6.5 Tool Resolution: Priority 1 (LSP), Priority 3 (CLI 도구) 삭제 → "Static Analysis First" 2줄로 축소
- [x] constitution §9.2: PR 생성 규칙을 `/gh-pr`, `/bb-pr` 슬래시 커맨드에 맞게 수정
- [x] agent.md §2 sdd 경로 오류 수정, §4.3 섹션 번호 중복 수정
- [x] `sources/governance/` ↔ `agent/` 동기화 완료

### Phase 컨텍스트
- **Phase**: `phase-02` — 토큰 최적화 & 거버넌스 경량화
- **본 SPEC 의 역할**: 거버넌스 문서의 단일 진실 원천(SSOT) 확보 및 ~274 words 절감. phase-02의 토큰 최적화 목표 중 첫 단계.

## 🎯 Key Review Points

1. **constitution §9.2 PR 규칙 변경**: "사용자만 생성" → "에이전트가 슬래시 커맨드로 생성 가능, 단 사용자 확인 후". 기존 워크플로와 호환되는지 확인.
2. **§6.5 축소**: 24줄 → 2줄. 정적 분석 도구 우선 사용 원칙만 유지. 과도한 축소가 아닌지 확인.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-governance-dedup.sh
```

**결과 요약**:
- ✅ 중복 문장 0건
- ✅ sources ↔ agent 동기화 OK
- ✅ 274w 감소 (2637w → 2363w)
- ✅ Dead letter 제거 확인
- ✅ 섹션 번호 중복 없음
- ✅ sdd 경로 올바름

### 수동 검증 시나리오
1. **diff 검증**: `sources/governance/` ↔ `agent/` 동일 → 통과
2. **참조 커버리지**: agent.md의 constitution 참조가 10개 중복 항목 전부 커버 → 통과

## 📦 Files Changed

### 🆕 New Files
- `tests/test-governance-dedup.sh`: 거버넌스 중복 검증 테스트 (8 checks)

### 🛠 Modified Files
- `sources/governance/constitution.md` (+1, -1): §9.2 PR 생성 규칙 수정
- `sources/governance/agent.md` (+20, -48): 중복 제거 + 실효성 정리
- `agent/constitution.md` (+1, -1): sources 동기화
- `agent/agent.md` (+20, -48): sources 동기화

**Total**: 5 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (8/8)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-02.md`
- Walkthrough: `specs/spec-02-01-governance-dedup/walkthrough.md`
