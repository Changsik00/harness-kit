feat(spec-25-02): 사후 테스트 신뢰 — 칸0(commit-time 휴리스틱) + 칸2(의도 앵커 반증 골격)

## 📋 Summary

### 배경 및 목적
ADR-009 는 auto 의 안전이 *사후 검증*에 전적으로 의존한다고 못 박았고, `post-commit-verify` 는 "테스트 통과" 신호로 진행/revert 를 판단한다. spec-25-01 이 auto 의 "안 멈춤"을 보장한 지금, **안 멈추고 직진할 때 그 결과를 믿을 수 있는가**(GitHub #212)가 유일하게 남은 load-bearing 지점이다. 그 테스트가 거짓이면 안전망 전체가 거짓이다.

### 주요 변경 사항
- [x] **칸0** `check-test-trust.sh` (commit-time, 경고) — "구현 변경에 테스트 동반했나 / 단언 있나"의 정적 휴리스틱. 가짜 green 의 *동어반복·over-mock* 을 토큰 0 으로 적발.
- [x] **칸2 골격** `hk-refute` 커맨드 + agent.md §6.7 렌즈 — 고위험 변경 시 `spec.md` *의도*에 앵커한 적대적 *반증* 패스. auto 가 못 잡는 *방향 오류* 겨냥.
- [x] 위험 비례: 칸0 상시, 칸2 고위험만 (check-irreversible/scope 신호 재사용).
- [x] 도그푸딩 미러 + pre-commit 등록.

### Phase 컨텍스트
- **Phase**: `phase-25` (auto 신뢰성), base 브랜치 `phase-25-auto-reliability`
- **본 SPEC 의 역할**: 사용자 우려 2("쓰레기 결과를 내면 무용지물") 직접 해소. #212 비용 사다리의 칸0+칸2 를 sdd 에 안착(칸1 은 Icebox→phase-26).

## 🎯 Key Review Points

1. **칸0 휴리스틱의 coarse 함**: "구현 변경 + 테스트 무변경"은 싸지만 리팩터/문서 오탐 가능 → 경고 모드 시작 + 안전 경로 화이트리스트. self-match 오탐(`check-test-trust.sh` 이름의 'test')은 `_tt_is_test` 엄격화 + 테스트 E 로 고정.
2. **칸2 가 hook 아닌 커맨드인 이유**: 적대적 반증은 LLM 구동 → bash hook 불가. 입력을 *코드가 아니라 의도(spec)* 에 앵커해 동어반복을 끊음(#212).
3. **라이브 도그푸딩**: 칸0 이 본 PR 의 한 커밋(테스트 없는 hook 등록)을 실제로 경고함.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-test-trust.sh
bash tests/run.sh
```
**결과**: ✅ test-test-trust 5/5, 전체 **74/74** (FAIL 0)

### 수동 검증
1. **칸0 경고 (라이브)**: Task 2-2 커밋에서 pre-commit 이 테스트 없는 구현 변경을 경고(비차단). 미러는 안전 경로 제외.
2. **칸2 권고**: `hk-refute` 커맨드 등록 + 거버넌스 렌즈 존재(골격).

## 📦 Files Changed

### 🆕 New Files
- `sources/hooks/check-test-trust.sh` (칸0)
- `sources/commands/hk-refute.md` (칸2 골격)
- `tests/test-test-trust.sh` (5 케이스)

### 🛠 Modified Files
- `sources/hooks/pre-commit.sh`: 칸0 commit-time 등록
- `sources/governance/agent.md` §6.7: 위험비례 refute 렌즈
- `.harness-kit/*` / `.claude/commands/hk-refute.md`: 도그푸딩 미러

**Total**: 9 files changed (+357)

## ✅ Definition of Done

- [x] `test-test-trust.sh` PASS + 전체 회귀 74/74
- [x] 칸0 경고 경계 고정 + 칸2 골격(커맨드+트리거+절차) 존재
- [x] sources ↔ 설치본 미러 byte-identical
- [x] walkthrough / pr_description ship commit
- [x] 브랜치 push

## 🔗 관련 자료

- Phase: `backlog/phase-25.md`
- ADR: `docs/decisions/ADR-009-...md` (Addendum 2)
- GitHub #212(테스트 신뢰 비용 사다리 — 칸1 은 Icebox→phase-26), #181(행동 기반 평가)
