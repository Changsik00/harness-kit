# feat(spec-11-04): 아카이브 검색 통합

## 📋 Summary

### 배경 및 목적
spec-11-03에서 `sdd archive`로 디렉토리 아카이브가 가능해졌지만, 아카이브 후 `sdd spec list`, `sdd phase list` 등에서 항목이 사라지는 문제.

### 주요 변경 사항
- [x] `sdd spec list` — `archive/specs/` 탐색 + `(archived)` 표시
- [x] `sdd phase list` — `archive/backlog/` 탐색 + `(archived)` 표시
- [x] `sdd phase show` — archive fallback으로 archived phase 상세 표시
- [x] `sdd spec show` — archive fallback으로 archived spec 상세 표시
- [x] `sdd status --verbose` — archive spec 수 별도 표시
- [x] `sdd status` 진단 — archive 항목 수 표시
- [x] `C_YEL` → `C_YLW` 버그 수정

### Phase 컨텍스트
- **Phase**: `phase-11` — 식별자 체계 개선 및 디렉토리 아카이브
- **본 SPEC의 역할**: 아카이브 후에도 이력 접근 보장 (phase-11 마지막 spec)

## 🎯 Key Review Points

1. **archive fallback 범위**: `spec list`, `phase list/show`, `spec show`, `status`에만 적용. `compute_next_spec`, `cmd_ship`, `spec_new`는 archive 탐색 제외
2. **`C_YEL` 버그**: `common.sh`에 `C_YLW`만 정의 — `set -uo pipefail`에서 unbound variable 발생

## 🧪 Verification

```bash
bash tests/test-sdd-archive-search.sh    # 11/11 PASS
bash tests/test-sdd-ship-completion.sh   # 7/7 PASS
bash tests/test-sdd-dir-archive.sh       # 10/10 PASS
```

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-archive-search.sh`: 4개 체크, 11 assertions

### 🛠 Modified Files
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: archive fallback 추가 (6개 함수) + C_YEL 수정

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (28/28)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-11.md`
- Walkthrough: `specs/spec-11-04-archive-search/walkthrough.md`
