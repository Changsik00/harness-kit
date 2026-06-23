feat(spec-x-auto-mode-ux): /hk-auto 커맨드 + "검증 단계" 용어 개명

## 📋 Summary

### 배경 및 목적
0.20.0 auto 모드 출시 후 사용자 UX 검토에서 두 결함:
1. **`/hk-auto` 부재** — `/hk-turbo`·`/hk-ask-mode`는 있는데 auto 슬래시 커맨드만 없음(비대칭).
2. **"칸0/칸2" 용어 불명확** — #212 "비용 사다리"의 단계를 "칸N"으로 옮겼더니 원어민도 "space 2?"로 오해.

### 주요 변경 사항
- [x] **`/hk-auto` 커맨드** — `/hk-turbo` 패턴(governed↔auto 토글) + unattended 안전 안내(정지규칙·사후검증). 미러 + installed.json 등록 + README 노출.
- [x] **"칸N → 검증 N단계" 개명** — 번호↑=검증 강도·비용↑. 운영/정규 문서(README·hk-refute·check-test-trust·pre-commit·agent.md·ADR-009·CHANGELOG) + 미러.
- [x] 용어 개명 누락 봉인 회귀 테스트(`칸[0-9]` 0건).

### 용어 정의
| 신규 | 구 | 의미 |
|---|---|---|
| 위험 비례 검증 단계 | 비용 사다리 | 위험↑ → 더 높은(비싼) 검증 단계 |
| 검증 0단계 | 칸0 | 정적 가짜-green 체크. 토큰 0, 항상 |
| 검증 1단계 | 칸1 | 뮤테이션. 컴퓨트, 중요 모듈 (미구현) |
| 검증 2단계 | 칸2 | 적대적 의도 반증. LLM, 고위험만 |

## 🎯 Key Review Points
1. **개명 범위**: 운영/정규만. 완료 backlog(phase-25.md)·immutable walkthrough는 역사 기록이라 제외(grep 추적 가능).
2. **순서 있는 치환 + 중복 보정**: "사다리의 칸N" 복합형이 "검증 단계의 검증 N단계" 중복을 만들어 2곳 수동 정리.

## 🧪 Verification
```bash
bash tests/test-terminology.sh   # 3/3 (칸[0-9] 0건 + hk-auto 존재)
bash tests/run.sh                # 76/76
```

## 📦 Files Changed
- `sources/commands/hk-auto.md` (신규) + `.claude/commands/` 미러 + `installed.json`
- 개명: README · CHANGELOG · hk-refute · check-test-trust · pre-commit · agent.md · ADR-009 (+ 미러)
- `tests/test-terminology.sh` (신규)

## ✅ Definition of Done
- [x] `/hk-auto` + 미러 + 등록 + README 노출
- [x] "검증 N단계" 개명 + 미러 동기
- [x] terminology 테스트 PASS (칸[0-9] 0건)
- [x] 전체 회귀 76/76
- [x] walkthrough / pr_description ship + push + PR
