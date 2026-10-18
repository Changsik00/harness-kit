# fix(spec-x-fix-failing-tests): 사전 실패 테스트 4건 정리

## 📋 Summary

### 배경 및 목적
`bash tests/run.sh --fast` 에서 4개 테스트가 실패하고 있었다 (spec-23-01 작업 중 main 대조로 본 변경과 무관한 사전 부채 확인). 각 항목을 *데이터 band-aid 가 아니라 근본* 으로 정리한다.

### 주요 변경 사항
- [x] **version-bump**: (a) README 리터럴 버전 grep → `version.json` dynamic badge 검증, (b) **Check 6 메타-러너 제거** (전체 스위트 재실행은 run.sh 책임 — set-e 침묵 종료·재귀·중복)
- [x] **update-stateful + sdd**: 폐기 산출물 `plan` 잔재 제거 — `sdd specx new` scaffold 루프 + S5 기대 목록(8→7)
- [x] **wiki-structure**: `sources:` 경로 검사를 archive-aware 로 (archive 된 walkthrough fallback)
- [x] **pr-merge-detect**: gh 부재 시뮬레이션을 hermetic 하게 (테스트 버그; sdd guard 는 기존재)
- [x] **phase17-integration (5번째, full 전용)**: 4c CHANGELOG 룰 grep 경로 `CLAUDE.md` → `docs/release-strategy.md` (#135 슬림화로 이동, stale 테스트)

## 🎯 Key Review Points

1. **#1·#4 는 테스트 수정**: README 와 sdd 코드는 올바름. 테스트 기대가 stale(리터럴 버전) / 시뮬레이션이 환경 의존적(homebrew 공유 디렉토리)이었던 것.
2. **#2 `plan` 폐기**: agent.md §4.2 템플릿 표·§5(spec.md=spec+plan 통합)에 정합. scaffold 가 빈 plan.md 를 만들던 근본 차단.
3. **#3 archive-aware**: 경로가 깨진 게 아니라 이동 — fallback 이 정확하고 archive 마다 재발하던 패턴 근절.
4. **미러**: sdd 변경(#2)은 `.harness-kit/bin/sdd` ↔ `sources/bin/sdd` byte-identical.

## 🧪 Verification

```bash
bash tests/test-version-bump.sh
bash tests/test-update-stateful.sh
bash tests/test-wiki-structure.sh
bash tests/test-pr-merge-detect.sh
bash tests/run.sh --fast
diff -q .harness-kit/bin/sdd sources/bin/sdd
```

**결과 요약**:
- ✅ version-bump: README dynamic badge 검증
- ✅ update-stateful: S5 7템플릿 (PASS=17)
- ✅ wiki-structure: 70/70
- ✅ pr-merge-detect: 5/5
- ✅ run.sh --fast: 4건 해소, 신규 FAIL 없음

## 📦 Files Changed

### 🛠 Modified Files
- `tests/test-version-bump.sh`: README 검사 → dynamic badge
- `tests/test-update-stateful.sh`: S5 `plan` 제거
- `tests/test-wiki-structure.sh`: archive-aware fallback
- `tests/test-pr-merge-detect.sh`: hermetic gh-absence 시뮬레이션
- `tests/test-phase17-integration.sh`: 4c grep 경로 docs/release-strategy.md 로
- `.harness-kit/bin/sdd` + `sources/bin/sdd`: specx scaffold 에서 `plan` 제거

## ✅ Definition of Done

- [x] 4개 대상 테스트 + `run.sh --fast` PASS
- [x] sdd 미러 byte-identical
- [x] walkthrough / pr_description ship commit

## 🔗 관련 자료

- Spec: `specs/spec-x-fix-failing-tests/spec.md`
- Walkthrough: `specs/spec-x-fix-failing-tests/walkthrough.md`
