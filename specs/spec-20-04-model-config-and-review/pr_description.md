# feat(spec-20-04): model role config + review panel + mediated-dialogue pattern

## 📋 Summary

### 배경 및 목적
phase-20 디렉터 모드의 남은 3 조각을 **한 spec 으로 마감**한다(D4 — ceremony 유닛 절감). ① 모델 티어를 역할 기반 config 로 de-hardcode, ② review 를 페르소나 패널 옵션으로, ③ 중재 패턴을 wiki 기록으로.

### 주요 변경 사항
- [x] **모델 역할 config**: `agent.md §6.6` → director/worker/scout 역할·책무 표(모델 이름 0). 실제 모델은 `harness.config.json` `models` 매핑, `sdd config models` 로 조회
- [x] **review 패널 옵션**: `hk-code-review`/`hk-spec-critique`/`hk-phase-review` 에 페르소나 패널(렌즈별 워커 병렬 → 디렉터 종합·중재) + **소규모 diff 단일 fallback**
- [x] **중재 패턴**: `docs/wiki/patterns.md` `mediated-design-dialogue`(종료조건·증류)

### Phase 컨텍스트
- **Phase**: `phase-20` / **역할**: 디렉터 모드 **마감 spec** — 머지 후 `/hk-phase-ship` 으로 phase 종결.

## 🎯 Key Review Points
1. **모델 이름 de-hardcode**: `grep -cE "Opus|Sonnet|Haiku|claude-" agent.md` = 0. 세대 churn 에 거버넌스 불변.
2. **review 패널은 옵션**: 디렉터 모드 off / 소규모 diff = 기존 단일 리뷰어. 회귀 안전.
3. **§6.6 일관성**: §6.1/§6.7/§6.8 과 중복 정리(같은 파일 분절 편집 문제 해소).
4. **단어 예산**: 7563/8000.

## 🧪 Verification
```bash
bash tests/test-director-mode.sh        # 22/22
bash tests/test-director-protocol.sh    # 10/10
bash tests/test-governance-dedup.sh     # 8/8 (단어예산 + 미러 parity)
bash .harness-kit/bin/sdd config models # 역할→모델 매핑 출력
```

## 📦 Files Changed
### 🆕 New
- `harness.config.json` (`models` 키)
### 🛠 Modified
- `sources/governance/agent.md` / `.harness-kit/agent/agent.md`: §6.6 재작성 + §6.7 ref (미러)
- `sources/bin/sdd` / `.harness-kit/bin/sdd`: `config models`
- `hk-code-review` / `hk-spec-critique` / `hk-phase-review` (+ `.claude/` 미러): 패널 옵션
- `docs/wiki/patterns.md`: mediated-design-dialogue
- `tests/test-director-mode.sh`: 역할표 + config models 검증

**Total**: 1 new + 다수 modified (미러 포함)

## ✅ Definition of Done
- [x] 단위 테스트 22/22 · 10/10 · 8/8
- [x] 모델 이름 하드코딩 0 · 단어 예산 ≤8000 · 미러 parity
- [x] review 패널 옵션 + 단일 fallback
- [x] walkthrough/pr ship

## 🔗 관련 자료
- Phase: `backlog/phase-20.md` / ADR: `docs/decisions/ADR-006-director-mode.md`
