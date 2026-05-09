# Walkthrough: spec-x-archive-clean-commit

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 수정 방식 | (A) `git add -A` 라인 삭제 / (B) 명시적 path 지정으로 변경 | (A) 삭제 | `git mv` 가 이미 rename 을 stage 하므로 추가 add 가 redundant. 명시적 path 도 가능하나 코드 간결성·유지보수성 면에서 삭제가 우월 |
| 무관 변경의 정의 | untracked 만 / modified 만 / 둘 다 | 둘 다 | 실제 사고 (`c0010e0`) 가 modified `.claude/settings.json` 을 흡수했으며, 이론적으로 untracked 도 위험 → 둘 다 회귀 케이스로 보호 |
| README.md 사용 | dummy 파일 vs 기존 README.md | 기존 README.md | 실제 프로젝트엔 항상 tracked 파일이 있으므로 더 현실적 |

## 💬 사용자 협의

- **주제**: 직전 archive 커밋 (`c0010e0`) 이 워킹트리 install drift 흡수한 사고 보고
  - **사용자 의견**: "1번 진행하자" — fix 우선순위로 수용
  - **합의**: SDD-x 모드, 슬러그 `archive-clean-commit` 으로 진행

## 🧪 검증 결과

### 단위 테스트
- **명령**: `bash tests/test-sdd-dir-archive.sh`
- **결과**: ✅ PASS=18 / FAIL=0 (Check 9 신규 4 assertion 포함)

### 회귀
- `bash tests/test-sdd-archive-search.sh` → ✅ 11/11 PASS
- `bash tests/test-sdd-status-cross-check.sh` → ✅ 7/7 PASS

### 수동 검증
1. **Action**: TDD Red — Check 9 추가 후 테스트 실행
   - **Result**: PASS=14 / FAIL=4 — `archive_files` 출력에 `unrelated.md`, `README.md` 가 함께 들어가 버그 재현 확인
2. **Action**: `sources/bin/sdd` 의 `git add -A` 라인 삭제
   - **Result**: PASS=18 / FAIL=0
3. **Action**: 도그푸딩 sync (`cp sources/bin/sdd .harness-kit/bin/sdd`)
   - **Result**: 차이 없음 확인

## 🔍 발견 사항

- **`git mv` 의 자동 staging 특성을 활용하면 추가 `git add` 가 불필요**: 본 사고는 "정리 차원에서 일단 add -A 해두자" 식의 방어적 코드가 오히려 의도치 않은 부작용을 만든 사례. 다른 sdd 명령 (`ship`, `phase done`, `specx done` 등) 도 유사 패턴이 있는지 점검 가치.
- **회귀 테스트가 archive commit 의 `--name-only` 출력을 직접 검증**: 단순히 워킹트리 상태만 보는 게 아니라 commit 자체의 내용을 검증해야 본 사고를 완전히 잡아낼 수 있음. 향후 git 관련 테스트의 모범 패턴.

## 🚧 이월 항목

- 다른 sdd 명령의 `git add` 패턴 점검 (`grep -n "git.*add" sources/bin/sdd`) — 별개 spec-x 후보.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 |
| **최종 commit** | (Ship 후 갱신) |
