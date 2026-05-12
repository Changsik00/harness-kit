# fix(spec-x-output-format-consistency): 출력 형식 일관성 개선

## 📋 Summary

### 배경 및 목적

두 가지 출력 포맷 불일치 문제를 수정한다:
1. `sdd spec show`의 파일 목록이 `spec.md ✓` 형식으로 출력돼 Claude Code에서 클릭해 열 수 없었음
2. `hk-ship.md`의 Push 정보 블록이 박스(`━━━`) 형식으로 정의돼 있어 표 형식과 불일치

### 주요 변경 사항

- [x] `sources/bin/sdd` + `.harness-kit/bin/sdd`: `spec show` 파일 목록 → 전체 상대경로 출력
- [x] `sources/governance/agent.md` + `.harness-kit/agent/agent.md`: §8.1에 파일 경로 리스팅 규칙 추가
- [x] `sources/commands/hk-ship.md` + `.claude/commands/hk-ship.md`: Push 블록 → Markdown 테이블

### Phase 컨텍스트

- **Phase**: `spec-x` (Solo)
- **역할**: 출력 UX 일관성 개선

## 🎯 Key Review Points

1. **sdd spec show 출력**: 파일이 `specs/spec-x-foo/spec.md (N lines)` 형식으로 클릭 가능한 전체 경로 포함 여부
2. **agent.md §8.1**: 전체 경로 리스팅 규칙 + correct/wrong 예시 포함 여부
3. **hk-ship.md Push 테이블**: `| 브랜치 | ... |` Markdown 테이블 포맷 적용 여부

## 🧪 Verification

```bash
bash tests/test-governance-dedup.sh  # ALL 8 CHECKS PASSED
```

## 📦 Files Changed

### 🛠 Modified Files
- `sources/bin/sdd`: spec show 파일 목록 포맷 변경 (2줄)
- `.harness-kit/bin/sdd`: 동기화
- `sources/governance/agent.md`: §8.1 파일 경로 리스팅 규칙 추가 (+15줄)
- `.harness-kit/agent/agent.md`: 동기화
- `sources/commands/hk-ship.md`: Push 블록 → 테이블 (-9/+5줄)
- `.claude/commands/hk-ship.md`: 동기화

**Total**: 6 files changed

## ✅ Definition of Done

- [x] `bash tests/test-governance-dedup.sh` ALL PASS
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료
