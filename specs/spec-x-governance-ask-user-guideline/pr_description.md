# docs(spec-x-governance-ask-user-guideline): agent.md §8.4 AskUserQuestion 툴 사용 가이드라인 추가

## 📋 Summary

### 배경 및 목적

거버넌스 문서가 `AskUserQuestion` 툴을 인지하지 않고 텍스트 포맷(1/2, [Y/n])만 명시하여,
Agent가 중요한 결정 포인트에서도 텍스트 목록을 출력하게 됐다.
결과적으로 UX가 텍스트/[Y/n]/화살표선택 세 가지 형태로 혼재됐다.

`agent.md §8.4`를 신설해 주요 결정 포인트에서 `AskUserQuestion` 툴을 SHOULD 사용하도록
가이드라인을 추가한다. 기존 텍스트 포맷은 fallback으로 유지한다.

### 주요 변경 사항

- [x] `agent.md §8` 끝에 §8.4 `AskUserQuestion 툴 사용 권장` 섹션 신설
- [x] 권장 사용 포인트 4가지 명시: Alignment 모드 선택 / Plan Accept·Critique / PR 확인 / Idea Capture Gate
- [x] SHOULD 수준 — 환경 제약 시 텍스트 fallback 유지 명시
- [x] `sources/governance/agent.md` + `.harness-kit/agent/agent.md` 동시 수정 (도그푸딩 동기화)

### Phase 컨텍스트

- **Phase**: `spec-x` (Solo)
- **역할**: 거버넌스 UX 일관성 가이드라인 수립

## 🎯 Key Review Points

1. **§8.4 내용** (`sources/governance/agent.md` +320~341행): 권장 포인트 표, fallback 조건, `AskUserQuestion` 툴 사용 시 주의사항(옵션 2~4개, 트레이드오프 명시) 포함 여부 확인.
2. **기존 §5.2·§5.7 무변경**: constitution의 텍스트 포맷 규칙은 그대로 — 이 PR은 추가만 한다.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-governance-dedup.sh
```

**결과 요약**:
- ✅ 중복 문장 0건
- ✅ sources ↔ .harness-kit 동기화 OK
- ✅ 토큰 카운트 5400w (상한 6000w 이하)
- ✅ 섹션 번호 중복 없음

## 📦 Files Changed

### 🛠 Modified Files
- `sources/governance/agent.md` (+20): §8.4 신설
- `.harness-kit/agent/agent.md` (+20): 도그푸딩 동기화

**Total**: 2 files changed

## ✅ Definition of Done

- [x] 거버넌스 검사 ALL PASS
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-governance-ask-user-guideline/walkthrough.md`
