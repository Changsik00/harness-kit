# feat(spec-20-03): add sdd ceremony delegation contract (agent.md §6.1)

## 📋 Summary

### 배경 및 목적
§6.8 은 일반 위임 규칙만 정의 — SDD ceremony(작성·실행)를 누가 하는지의 *구체적 분업 계약*이 비어 있었다. 본 spec 은 agent.md §6.1 에 "Director Mode delegation" 블록을 더해 디렉터/워커 역할을 못박는다.

### 주요 변경 사항
- [x] agent.md §6.1 **Director Mode delegation** 블록(영문 88w): 디렉터=의도·plan 핵심결정·게이트·증류검수 / 워커=task 분해·문서 직접쓰기·Strict Loop·**산출물 커밋**
- [x] 불변식: Plan Accept·Ship 게이트 위임 금지 / 워커 커밋 범위에 spec·plan·task 포함 / 검증=§6.8 규칙4
- [x] §6.8 에 cross-ref 1줄 + `tests/test-director-protocol.sh` 확장

### Phase 컨텍스트
- **Phase**: `phase-20` / **역할**: §6.8(일반 프로토콜)을 SDD 워크플로로 특화. 본 spec 이 *자기 자신을 만든 워크플로*를 규약화(도그푸딩).

## 🎯 Key Review Points
1. **워커 커밋 범위 규칙**: spec-20-01 에서 누락됐던 갭(워커가 산출물 미커밋)을 거버넌스로 박아 재발 차단.
2. **단어 예산**: 7613/8000(블록 88w). spec-20-04 전 §13 prune 판단 필요.
3. **이중 미러** parity 동일.

## 🧪 Verification
```bash
bash tests/test-director-protocol.sh   # 10/10
bash tests/test-governance-dedup.sh    # 8/8
bash tests/test-director-mode.sh       # 10/10
```

## 📦 Files Changed
### 🛠 Modified
- `sources/governance/agent.md` / `.harness-kit/agent/agent.md`: §6.1 블록 + §6.8 ref (미러)
- `tests/test-director-protocol.sh`: 분업 계약 검증 확장
- `backlog/phase-20.md`: spec-20-03 표 등록

**Total**: 3 modified (+ spec 산출물)

## ✅ Definition of Done
- [x] 단위 테스트 통과 (10/10 · 8/8 · 10/10)
- [x] 단어 예산 ≤ 8000w (7613)
- [x] `walkthrough.md` / `pr_description.md` ship commit
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료
- Phase: `backlog/phase-20.md` / 관련 ADR: `docs/decisions/ADR-006-director-mode.md`
