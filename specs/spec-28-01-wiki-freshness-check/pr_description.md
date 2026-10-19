# feat(spec-28-01): add wiki freshness check to doctor and status

## 📋 Summary

### 배경 및 목적
`docs/wiki/` 는 `/hk-wiki-ingest` 수동 실행에만 의존해, 2026-06-03 이후 4개월간 방치돼도 알려 주는 신호가 없었다 (`decisions.md` 에 ADR-005~009 가 0건). wiki 가 낡았음을 결정론적 신호로 감지해 `sdd doctor` / `sdd status` 가 알리게 한다.

### 주요 변경 사항
- [x] `_wiki_freshness_report` 헬퍼 추가: 신호 A (wiki decisions/patterns 에 없는 ADR) + 신호 B (마지막 인제스트 날짜 이후 archive 된 walkthrough ≥ 5, 당일 제외, git 이력 기반)
- [x] `sdd doctor` wiki layer 에 W-4 추가 — 낡으면 ⚠, 아니면 "wiki 최신"
- [x] `sdd status` 🔍 진단에 동일 문구 `💡` 표시
- [x] 경고(exit 0)만 — 휴리스틱이므로 hook 단계론. wiki/archive/decisions/git 부재 시 침묵
- [x] 도그푸딩 사본 `.harness-kit/bin/sdd` 동기화

### Phase 컨텍스트
- **Phase**: `phase-28` (docs-freshness)
- **본 SPEC 의 역할**: 성공 기준 1 (wiki freshness 검사가 stale fixture 감지, 최신 fixture 침묵) 달성

## 🎯 Key Review Points

1. **신호 B 는 이름이 아니라 날짜 기준**: spec 디렉토리명이 wiki 에 인용됐는지 보면 인제스트 직후에도 대부분 "미반영"으로 오탐된다. `log.md` 마지막 인제스트 날짜 이후 git 이력을 본다.
2. **신호 A 는 `index.md` 제외**: 인벤토리 표가 모든 ADR 을 나열해 판정이 항상 "반영됨"이 된다. `decisions.md` / `patterns.md` 만 본다.
3. **임계값 (A=1, B=5)**: 보수적 시작 값. 운영 데이터 후 조정.
4. **git 의존**: shallow clone 이면 신호 B 가 과소 집계됨 (침묵 방향 실패라 허용).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-wiki-freshness.sh
bash tests/run.sh
```

**결과 요약**:
- ✅ `test-wiki-freshness`: 6 케이스 통과 (미반영 ADR, 최신 침묵, ≥5 archive, 당일 제외, 전제 부재 침묵, status 표시)
- ✅ `tests/run.sh`: PASS 82 / FAIL 0

### 수동 검증 시나리오
1. **본 저장소 `sdd doctor`** → `wiki 낡음: 미반영 ADR 1개 (ADR-004)` — 실제 누락을 적발 (정상 동작)
2. **본 저장소 `sdd status`** → 진단에 동일 문구 표시

## 📦 Files Changed

### 🆕 New Files
- `tests/test-wiki-freshness.sh`: 임시 git 저장소 fixture 6 케이스
- `specs/spec-28-01-wiki-freshness-check/*`: spec / task / walkthrough / pr_description

### 🛠 Modified Files
- `sources/bin/sdd`: `_wiki_freshness_report` 헬퍼, doctor W-4, status 진단 연결
- `.harness-kit/bin/sdd`: 도그푸딩 사본 동기화 (사본이 원본보다 뒤처져 있던 #231 의 `config models` 수정분도 함께 반영됨)
- `backlog/phase-28.md`: spec 표 갱신

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [ ] lint / type check 통과 — shellcheck 미설치로 Shell lint 건너뜀
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-28.md`
- Walkthrough: `specs/spec-28-01-wiki-freshness-check/walkthrough.md`
- 관련: spec-27-02 (`cmd_doctor` 확장·공유 헬퍼 선례), `docs/decisions/ADR-003-wiki-frontmatter-schema.md`
