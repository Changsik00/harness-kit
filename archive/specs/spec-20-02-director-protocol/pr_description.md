# feat(spec-20-02): add director mode protocol (agent.md §6.8)

## 📋 Summary

### 배경 및 목적

phase-20 의 디렉터 모드 *행동 규약*이 비어 있었다(spec-20-01 은 스위치만). 본 spec 은 agent.md 에 §6.8 Director Mode Protocol 을 추가해 디렉터의 운영 루프를 명문화하고, ADR-006 을 accepted 로 확정한다. spec-20-01 도그푸딩 발견(검증=행동/증류, 워커 커밋 범위)을 직접 반영했다.

### 주요 변경 사항
- [x] agent.md **§6.8 Director Mode Protocol** (영문, 172w): 의도 핸드셰이크 / scoped brief 위임 / distilled contract 반납 / **검증=행동·증류, 전문 재흡수 금지** / 게이트는 디렉터+사용자 / over-dispatch 금지
- [x] `ADR-006` proposed → **accepted** + 검증 불변식 흡수
- [x] `tests/test-director-protocol.sh` 신규 (용어 grep + 미러 parity + 단어 예산)

### Phase 컨텍스트
- **Phase**: `phase-20` / **역할**: 모드의 *행동 규약* — 후속 spec(ceremony 분업·모델 config·review 패널)이 따를 운영 프로토콜.

## 🎯 Key Review Points

1. **§6.8 규칙 4 (검증 불변식)**: 디렉터는 워커 transcript 전문을 재흡수하지 않고 테스트 재실행+증류 대조로 검수 — context 보존의 핵심.
2. **단어 예산**: 합계 7507/8000w 유지(§6.8 172w). 누적 압박은 후속 spec 에서 §13 prune 으로 관리.
3. **이중 미러**: `sources/governance/agent.md` ↔ `.harness-kit/agent/agent.md` 동일.

## 🧪 Verification
```bash
bash tests/test-director-protocol.sh   # 7/7
bash tests/test-governance-dedup.sh    # 8/8 (단어예산 + 미러 parity)
bash tests/test-director-mode.sh       # 10/10 (회귀)
```

## 📦 Files Changed

### 🆕 New Files
- `tests/test-director-protocol.sh`

### 🛠 Modified Files
- `sources/governance/agent.md` / `.harness-kit/agent/agent.md`: §6.8 추가 (미러)
- `docs/decisions/ADR-006-director-mode.md`: accepted + 검증 불변식
- `backlog/phase-20.md`: spec-20-02 표 등록

**Total**: 1 new + 4 modified (+ spec 산출물)

## ✅ Definition of Done

- [x] 단위 테스트 통과 (7/7 · 8/8 · 10/10)
- [x] 단어 예산 ≤ 8000w (7507)
- [x] `walkthrough.md` / `pr_description.md` ship commit
- [x] Shell 프로젝트 — lint/type check 불필요
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-20.md`
- 관련 ADR: `docs/decisions/ADR-006-director-mode.md` (본 spec 으로 accepted), `docs/decisions/ADR-005-context-orchestration.md`
