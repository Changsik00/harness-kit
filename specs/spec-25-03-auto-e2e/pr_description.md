test(spec-25-03): auto 안전장치 통합 e2e (측정 — 기계적 보장 + 정직한 한계)

## 📋 Summary

### 배경 및 목적
phase-25 가 auto 안전장치(25-01 askquestion 차단, 25-02 칸0/칸2)를 쌓았으나, phase-24 carry-over C1 은 **"한 사이클에서 조각이 함께 작동하는지"를 실제 실행으로 증명하는 e2e** 부재였다. 본 spec 이 그 측정기를 추가한다.

### 주요 변경 사항
- [x] `tests/test-e2e-auto-mode.sh` — 실제 install fixture 에서 auto 사이클 기계적 조각을 순차 구동 (8/8 PASS)
- [x] **결정 로그 누적 실증** — phase-24 의 `decision list --phase` 0건이 *기능 부재가 아니라 미사용*이었음 확정
- [x] **측정 한계 명시** — bash e2e 는 기계적 보장만 증명, 에이전트 행동(기본값 선택)은 #181 영역 (phase-25.md·walkthrough 에 못 박음)

### Phase 컨텍스트
- **Phase**: `phase-25`, base 브랜치 `phase-25-auto-reliability`
- **역할**: 25-01·25-02 의 *검산* + phase-24 성공기준 #2·#3 마감. impl 변경 0(측정 전용).

## 🎯 Key Review Points

1. **정직한 측정 경계**: e2e 가 증명하는 것(차단·경고·누적)과 못 하는 것(에이전트 기본값 선택 행동)을 명시 — "가짜 안심" 회피(#212 정신).
2. **③ 결정로그 발견**: 0건은 미사용이었음. 기능은 정상.
3. **lean spec**: 테스트 전용이나 측정 발견이 walkthrough 가치 → phase-FF 대신 spec 유지(ceremony 최소).

## 🧪 Verification
```bash
bash tests/test-e2e-auto-mode.sh   # 8/8
bash tests/run.sh                  # 75/75 (FAIL 0)
```

## 📦 Files Changed
### 🆕 New Files
- `tests/test-e2e-auto-mode.sh`: auto 통합 e2e (5영역 8검증)
### 🛠 Modified Files
- `backlog/phase-25.md`: e2e 커버리지 + 측정 한계 메모

**Total**: 2 files (+ spec 산출물)

## ✅ Definition of Done
- [x] e2e PASS + 전체 회귀 75/75
- [x] 결정 로그 누적 실데이터 증명
- [x] 측정 한계(행동 미측정 → #181) 명시
- [x] walkthrough / pr_description ship
- [x] 브랜치 push

## 🔗 관련 자료
- Phase: `backlog/phase-25.md` / ADR-009 Addendum
- GitHub #181(행동 기반 평가 — 측정 한계의 다음 단계), #212(가짜 안심 경계)
