# docs(spec-x-claude-md-nested): 디렉토리별 CLAUDE.md 도입 (sources/, specs/)

## 📋 Summary

### 배경 및 목적

Claude Code 의 CLAUDE.md auto-load 는 *디렉토리별* 로 동작합니다. 본 저장소는 *두 시점* 의 가이드 (키트 원본 / 도그푸딩 결과) 가 root CLAUDE.md 한 파일에 공존하여 작업할 때마다 "지금 어느 시점인가" 를 의식해야 하는 비용이 있었습니다.

Claude Code harness 가이드 (news.hada.io/topic?id=29556) 의 "context-scoped CLAUDE.md" 원칙 (인사이트 #3) 에 따라 디렉토리 특화 컨텍스트를 분리합니다.

### 주요 변경 사항

- [x] **`sources/CLAUDE.md` 신규** (20줄) — 키트 원본 시점 룰: 수정 영향 / `update.sh` 메커니즘 / bash 3.2+ 호환 / 하위 디렉토리 install 매핑
- [x] **`specs/CLAUDE.md` 신규** (22줄) — 작업 로그 시점 룰: 한국어 산출물 / 템플릿 강제 / immutable / archive 정책 / One Task = One Commit
- [x] **root `CLAUDE.md` 무변경** — scope 분리. 추가 슬림은 별 spec 에서 재검토.

### Phase 컨텍스트

- **Phase**: 없음 (spec-x — phase 비소속)
- **본 SPEC 의 역할**: 작업-시점-적합한 컨텍스트만 활성화 → 시점 혼동 / 컨텍스트 미스매치 비용 절감.

## 🎯 Key Review Points

1. **scope 분리 원칙**: root 를 건드리지 않고 *추가만* 함. nested 가 root 와 중복되지 않도록 *디렉토리 특화* 내용만 담음 (각 ≤ 25줄).
2. **`sources/governance/CLAUDE.md` 추가하지 않음**: Claude Code 가 상위 `sources/CLAUDE.md` 도 함께 로드하므로 한 단계로 충분. 필요 시점에 분리.
3. **auto-load 작동 가정**: 본 PR 의 가치는 Claude Code 의 디렉토리별 auto-load 가 의도대로 작동한다는 가정에 의존. 다음 세션에서 sources/ 또는 specs/ 하위 파일 편집 시 실제 확인 가능.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-install-claude-import.sh   # 기존 root @import / fragment / 멱등성
bash tests/test-marker-append-guard.sh
bash tests/test-marker-edge-cases.sh
```

**결과 요약**:
- ✅ `test-install-claude-import.sh`: 6/6 PASS
- ✅ `test-marker-append-guard.sh`: 5/5 PASS
- ✅ `test-marker-edge-cases.sh`: 8/8 PASS

### 수동 검증 시나리오

1. **분량 확인** → `wc -l sources/CLAUDE.md specs/CLAUDE.md` = 20 / 22 (각 ≤ 25)
2. **root 무변경** → `git diff main..HEAD -- CLAUDE.md` 출력 없음
3. **HARNESS-KIT 마커 보존** → root 자체 무변경이라 자동 보존

## 📦 Files Changed

### 🆕 New Files
- `sources/CLAUDE.md` (+20): 키트 원본 시점 컨텍스트
- `specs/CLAUDE.md` (+22): 작업 로그 시점 컨텍스트
- `specs/spec-x-claude-md-nested/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md`: 본 spec 산출물

### 🛠 Modified Files
- `backlog/queue.md` (+1, -1): specx 섹션 자동 갱신 (`sdd plan accept`)

### 🗑 Deleted Files
- (없음)

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 핵심 테스트 모두 통과
- [x] `walkthrough.md` ship commit
- [x] `pr_description.md` ship commit
- [x] PR 생성 및 사용자 검토 요청

## 🔗 관련 자료

- 직전 관련 spec: `spec-x-claude-md-slim` (root CLAUDE.md 1차 슬림)
- Walkthrough: `specs/spec-x-claude-md-nested/walkthrough.md`
- 영감 기사: news.hada.io/topic?id=29556 (Claude Code harness 가이드 — 인사이트 #3)
