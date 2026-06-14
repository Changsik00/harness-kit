# Walkthrough: spec-x-drift-stale-adr-glob

> stale ADR 탐지기의 glob 오탐 수정 기록.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| glob 제외 범위 | (A) `*`,`?` 만 / (B) `*`,`?`,`[` 포함 | A | `[...]` 문자 클래스는 실제 파일 경로에서도 드물게 쓰일 수 있어 과배제 위험. 오탐 원인은 `*` 가 들어간 prose glob 이므로 `*`,`?` 만으로 충분 |
| 처리 방식 | (A) 탐지기 수정 / (B) ADR-003 본문에서 glob 제거 | A | ADR 본문의 glob 은 정당한 설명 표현. 도구가 prose 의 glob 을 파일로 오인하는 게 근본 원인 |

## 💬 사용자 협의

- **주제**: 잔재 2건(installed.json drift, stale ADR) 정리 방식
  - **합의**: installed.json 은 main 에 FF 커밋으로 분리 마감, stale ADR(실제로는 탐지기 false positive)은 별도 spec-x `fix` 로 처리 (Option 1).

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-drift-stale-adr.sh`
- **결과**: ✅ Passed
```text
  ✓ clean state: no stale ADR line
  ✓ fixture ADR (1 missing path) → stale ADR: 1 detected
  ✓ regression: ADR-998 (all-valid-paths fixture) → no stale line
  ✓ glob fixture: ADR-997 (glob-only paths) → no stale line
```
- 연관: `test-install-manifest-sync.sh` PASS, `test-sdd-drift.sh` PASS (미러 sync 회귀 없음)

### 수동 검증
1. **Action**: `HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status`
   - **Result**: 동기화 섹션에서 `stale ADR: 1 (missing-path) — ADR-003...` 라인이 사라짐.
2. **Action**: `diff -q .harness-kit/bin/sdd sources/bin/sdd`
   - **Result**: 동일(exit 0) — 미러 byte-identical 유지.

## 🔍 발견 사항

- **버그가 baseline 테스트까지 깨뜨리고 있었음**: 실제 ADR-003 의 glob 오탐 때문에 기존 `test-drift-stale-adr.sh` 의 Step 1(clean state)까지 실패 상태였다. 즉 이 false positive 는 단순 잡음이 아니라 회귀 테스트의 무결성을 이미 침식하고 있었다.
- **systemic 점검 결과 frontmatter 는 무관**: 처음엔 "spec archive 시 ADR `sources:` 경로가 끊긴다"는 systemic 패턴을 의심했으나, 탐지기는 frontmatter 가 아니라 **본문 backtick 토큰** 만 검사함을 확인. 6개 ADR/RCA 의 `sources:` archive 이동은 본 탐지기와 무관하여 Out of Scope 로 둠.

## 🚧 이월 항목

- 없음.
