# docs(spec-x-claude-md-slim): root CLAUDE.md 슬림화 — 릴리스 전략 분리

## 📋 Summary

### 배경 및 목적

root `CLAUDE.md` 는 매 세션 자동 로드되어 항상-온 컨텍스트로 상주합니다. 그 안의 **릴리스 전략 섹션 (~36줄)** 은 "배포하자" 명령 시점에만 사용되는 *저빈도·고용량* 정보였고, **"현재 단계" 섹션** 은 "Phase 4 도그푸딩 시작 직전" 으로 표기되어 있어 실제 (phase-17 완료) 와 불일치하는 *stale* 정보였습니다.

본 PR 은 Claude Code harness 가이드 (news.hada.io/topic?id=29556) 의 "root = 포인터, 상세 = 별 파일" 원칙에 따라 둘을 정리합니다.

### 주요 변경 사항

- [x] **릴리스 전략 → `docs/release-strategy.md`** — 36줄 분량을 별 문서로 이전, root 에는 1문장 포인터만 유지
- [x] **stale "현재 단계" 섹션 삭제** — 상태는 `sdd status` 가 단일 진실원
- [x] **CLAUDE.md 108줄 → 71줄** (약 34% 축소)

### Phase 컨텍스트

- **Phase**: 없음 (spec-x — phase 비소속)
- **본 SPEC 의 역할**: 평시 작업 (spec/plan/PR/디버깅) 의 항상-온 컨텍스트 비용 절감. 차후 모든 세션에 적용.

## 🎯 Key Review Points

1. **릴리스 전략 무손실 이전**: 새 `docs/release-strategy.md` 는 기존 섹션 내용을 1:1 복사. 헤더만 단독 문서 톤에 맞춰 h2→h1, h3→h2 격상. `diff` 로 본문 일치 확인 완료.
2. **포인터 가독성**: root 에 남은 한 줄 — `"배포하자" / "릴리스하자" 명령 시 alignment 없이 그 문서의 절차를 즉시 수행한다.` — 으로 "릴리스 명령 시 어디 봐야 하는지" 가 명확히 전달되는지.
3. **"현재 단계" 삭제 동의**: 갱신 대신 제거 결정. 항상-온 컨텍스트에 빠르게 stale 해지는 상태 정보를 두지 않는 패턴 정착.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-install-claude-import.sh   # CLAUDE.md @import 보존
bash tests/test-marker-append-guard.sh      # HARNESS-KIT 마커
bash tests/test-marker-edge-cases.sh        # 마커 edge cases
```

**결과 요약**:
- ✅ `test-install-claude-import.sh`: 6/6 PASS — `@.harness-kit/CLAUDE.fragment.md` import 보존, 기존 내용 보존, 멱등성
- ✅ `test-marker-append-guard.sh`: 5/5 PASS
- ✅ `test-marker-edge-cases.sh`: 8/8 PASS

### 수동 검증 시나리오

1. **CLAUDE.md 슬림화 확인** → `wc -l CLAUDE.md` = 71 (≤ 75 목표 달성)
2. **포인터 존재** → `grep -c "릴리스 전략" CLAUDE.md` = 1
3. **stale 섹션 제거** → `grep "현재 단계" CLAUDE.md` = 없음
4. **fragment import 보존** → `@.harness-kit/CLAUDE.fragment.md` 1건
5. **HARNESS-KIT 마커 보존** → `BEGIN` / `END` 둘 다 존재
6. **외부 참조 검색** → archive immutable + CHANGELOG 의 과거 사실 + 동음이의만 → 갱신 0건

## 📦 Files Changed

### 🆕 New Files
- `docs/release-strategy.md` (+36): 기존 CLAUDE.md "릴리스 전략" 섹션 무손실 이전, 헤더만 단독 문서 톤 격상
- `specs/spec-x-claude-md-slim/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md`: 본 spec 산출물

### 🛠 Modified Files
- `CLAUDE.md` (+1, -38): 릴리스 전략 섹션 → 1문장 포인터, "현재 단계" 섹션 삭제
- `backlog/queue.md` (+5, -0): specx 자동 갱신 + icebox 4개 항목 (root slim / governance prune / 하위 CLAUDE.md / LSP 가이드)

### 🗑 Deleted Files
- (없음)

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 핵심 테스트 모두 통과 (`test-install-claude-import.sh`, marker 테스트 2종)
- [x] `walkthrough.md` ship commit
- [x] `pr_description.md` ship commit
- [x] PR 생성 및 사용자 검토 요청

## 🔗 관련 자료

- 분리 대상 문서: `docs/release-strategy.md`
- Walkthrough: `specs/spec-x-claude-md-slim/walkthrough.md`
- 영감 기사: news.hada.io/topic?id=29556 (Claude Code harness 가이드)
