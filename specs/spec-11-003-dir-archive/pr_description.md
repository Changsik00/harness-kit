# feat(spec-11-003): 디렉토리 아카이브 기능

## 📋 Summary

### 배경 및 목적
`specs/` 디렉토리에 41개 폴더가 쌓여 탐색이 어려움. 완료된 오래된 항목을 자동으로 정리할 수단이 필요.

### 주요 변경 사항
- [x] `sdd archive [--keep=N] [--dry-run]` 명령 신설 — 완료 phase의 spec/backlog를 `archive/`로 `git mv`
- [x] `sdd status` 진단: specs/ 20개+ 디렉토리 시 아카이브 제안
- [x] align.md에 아카이브 제안 프로토콜 추가 (§4)
- [x] 테스트 10개 + 기존 테스트 회귀 수정

### Phase 컨텍스트
- **Phase**: `phase-11` — 식별자 체계 개선 및 디렉토리 아카이브
- **본 SPEC의 역할**: 디렉토리 폭증 문제 해결, align 시 정리 제안

## 🎯 Key Review Points

1. **queue.md 파싱**: done 섹션에서 완료 phase 추출 — table + bullet 두 형식 모두 처리
2. **`--keep=N`**: 최근 N개 완료 phase 유지. 기본 0 = active phase만 남김
3. **deprecated 경로 제거**: `sdd archive`가 새 기능으로 완전 교체. ship 테스트 Check 7 제거

## 🧪 Verification

```bash
bash tests/test-sdd-dir-archive.sh      # 10/10 PASS
bash tests/test-sdd-ship-completion.sh   # 7/7 PASS
bash tests/test-sdd-phase-done-accuracy.sh # 4/4 PASS
```

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-dir-archive.sh`: 6개 체크, 10 assertions

### 🛠 Modified Files
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: cmd_archive 신규 구현 + status 진단
- `sources/governance/align.md` / `.harness-kit/agent/align.md`: §4 아카이브 제안 추가
- `tests/test-sdd-ship-completion.sh`: Check 7 deprecated 제거

**Total**: 6 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (21/21)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-11.md`
- Walkthrough: `specs/spec-11-003-dir-archive/walkthrough.md`
