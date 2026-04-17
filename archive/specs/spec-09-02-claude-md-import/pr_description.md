# feat(spec-09-02): switch CLAUDE.md install to 3-line @import

## 📋 Summary

### 배경 및 목적

harness-kit 설치 시 `CLAUDE.md`에 15줄 블록을 직접 append하던 방식을 `@import` 3줄로 교체한다. 실제 규약 내용은 `.harness-kit/CLAUDE.fragment.md`에 별도 관리하여 팀원 간 merge conflict 위험을 제거하고, update 시 사용자 CLAUDE.md를 건드리지 않는다.

### 주요 변경 사항
- [x] **install.sh**: HARNESS-KIT 블록을 3줄 `@import`로 교체 + `.harness-kit/CLAUDE.fragment.md` 복사
- [x] **sources/claude-fragments/CLAUDE.fragment.md**: 파일명 변경(`.md.fragment` → `.fragment.md`), 내용 정리
- [x] **update.sh**: 업데이트/마이그레이션 시 CLAUDE.md 백업 추가
- [x] **도그푸딩**: 이 프로젝트 CLAUDE.md → @import 방식으로 전환

### Phase 컨텍스트
- **Phase**: `phase-09` — install-conflict-defense
- **본 SPEC 의 역할**: CLAUDE.md merge conflict 위험 제거. spec-09-01(디렉토리 레이아웃)에 이어 두 번째 충돌 방어 레이어.

## 🎯 Key Review Points

1. **install.sh Section 15**: 구 방식 블록(`HARNESS-KIT:BEGIN` ~ 내용 ~ `HARNESS-KIT:END`)을 감지해 @import 3줄로 교체하는 awk 로직 — 기존 내용을 버리지 않는지 확인
2. **멱등성**: `install.sh` 재실행 시 `@import` 줄이 중복 삽입되지 않는지 (Check 5 검증)

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-install-claude-import.sh  # 6개 항목
bash tests/test-two-tier-loading.sh       # 7개 항목
```

**결과 요약**:
- ✅ `test-install-claude-import.sh`: 6/6 PASS
- ✅ `test-two-tier-loading.sh`: 7/7 PASS
- ✅ 전체 40/40 PASS

### 수동 검증 시나리오
1. 신규 repo에 `install.sh --yes` → CLAUDE.md에 3줄, fragment 파일 생성 확인
2. 구 방식 CLAUDE.md에 `install.sh --yes` → @import로 전환, 기존 내용 보존 확인

## 📦 Files Changed

### 🆕 New Files
- `.harness-kit/CLAUDE.fragment.md`: 도그푸딩 fragment
- `tests/test-install-claude-import.sh`: @import 방식 설치 검증 테스트
- `specs/spec-09-02-claude-md-import/`: spec, plan, task, walkthrough, pr_description

### 🛠 Modified Files
- `install.sh`: Section 15 @import 방식으로 전면 교체
- `update.sh`: CLAUDE.md 백업 로직 추가
- `tests/test-two-tier-loading.sh`: fragment 경로 업데이트

### 🗑 Deleted/Renamed Files
- `sources/claude-fragments/CLAUDE.md.fragment` → `CLAUDE.fragment.md`

**Total**: 8 files changed

## ✅ Definition of Done

- [x] `test-install-claude-import.sh` 6/6 PASS
- [x] `test-two-tier-loading.sh` 7/7 PASS
- [x] 전체 40/40 PASS
- [x] 도그푸딩 완료 (이 프로젝트 CLAUDE.md @import 전환)
- [x] walkthrough.md / pr_description.md 작성 완료

## 🔗 관련 자료

- Phase: `backlog/phase-09.md`
- Walkthrough: `specs/spec-09-02-claude-md-import/walkthrough.md`
