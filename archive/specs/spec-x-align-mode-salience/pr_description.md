# docs(spec-x-align-mode-salience): align 모드 부각 + intent 잔재 정리

## 📋 Summary

### 배경 및 목적
이번 세션 RCA 결과: 사용자가 세션을 turbo 로 착각한 채 governed 로 진행해 "왜 Plan Accept 를 묻지?"라는 모델 불일치가 발생했다. 원인은 ① 에이전트가 `Active Mode` 를 보고에 부각하지 않음, ② 이전 turbo 세션의 `Active Intent` 잔재가 혼선을 키움. `align.md` 에 모드 부각 + intent 잔재 정리 제안을 추가해 재발을 막는다.

### 주요 변경 사항
- [x] `align.md` §5 상태 보고 블록에 `Active Mode` (+ `Active Intent`) 라인 추가
- [x] §5.1 모드 부각 — governed + 기능/PR 착수 시 "Plan Accept 게이트 적용, turbo 비대상(§2.4)" 사전 고지
- [x] §5.2 Intent 잔재 점검 — `Active Intent` 감지 시 `sdd intent clear` 제안(자동 금지, §4 패턴 일관)
- [x] 설치본 `.harness-kit/agent/align.md` byte-identical 미러링

### 컨텍스트
- 타입: **spec-x** (docs, Phase 비소속)
- RCA 후속 — constitution/agent.md 는 단어 budget 압박으로 미수정, budget 비대상인 align.md 만 손댐.

## 🎯 Key Review Points

1. **align.md 만 수정**: 거버넌스 단어 budget(constitution+agent.md 8000w)을 건드리지 않으려는 의도적 범위 한정.
2. **코드 변경 없음**: `sdd status` 가 이미 Active Mode/Intent 를 출력하므로 doc 지시로 충분 — right-size.
3. **자동 정리 금지**: intent 잔재는 *제안만* (아카이브·drift 정리와 동일 no-auto 패턴).
4. **도그푸딩 sync**: sources ↔ 설치본 align.md 동일 확인.

## 🧪 Verification

```bash
bash tests/test-install-manifest-sync.sh   # 매니페스트 정합
bash tests/run.sh --fast                   # 전체 회귀
diff -q sources/governance/align.md .harness-kit/agent/align.md
```

**결과 요약**:
- ✅ 매니페스트 정합 6/6
- ✅ 전체 회귀 신규 회귀 0 (기존 실패 5건만 잔존 — 본 변경 무관)
- ✅ sources ↔ 설치본 align.md IDENTICAL

## 📦 Files Changed

### 🛠 Modified Files
- `sources/governance/align.md` (+15): Active Mode 라인 + §5.1 모드 부각 + §5.2 intent 잔재 점검
- `.harness-kit/agent/align.md` (+15): 설치본 미러
- `backlog/queue.md` (+1): specx 등록

**Total**: 3 핵심 파일 + spec 산출물

## ✅ Definition of Done

- [x] 매니페스트/회귀 정합 PASS (신규 회귀 0)
- [x] sources ↔ 설치본 align.md 동일
- [x] walkthrough/pr_description ship commit
- [x] 브랜치 push

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-align-mode-salience/walkthrough.md`
- 관련: 이번 세션 RCA (Plan Accept 요청 원인 분석)
