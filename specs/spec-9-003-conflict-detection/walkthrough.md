# Walkthrough: spec-9-003

## 증거 로그

### Task 2: TDD Red — test-path-config.sh 작성

```
$ bash tests/test-path-config.sh
 Path Config System Verification (spec-9-003)

▶ 시나리오 A: --yes (기본값 경로)
  ✅ 기본값 시 harness.config.json 미생성
  ✅ backlog/ 생성됨
  ✅ specs/ 생성됨

▶ 시나리오 B: --prefix hk-
  ❌ harness.config.json 미생성
  ❌ hk-backlog/ 미생성
  ❌ hk-specs/ 미생성
  ❌ backlog/ 가 생성됨 (prefix 경로를 써야 함)

▶ harness.config.json 값 검증
  ❌ 값 불일치: backlogDir=, specsDir=

▶ sdd status — config 경로 반영
  ✅ sdd status 정상 실행

 ❌ 4/9 CHECKS FAILED
```

Commit: `18687c6 test(spec-9-003): add failing test for path config system`

---

### Task 3: common.sh 경로 수정 + config 읽기

`sources/bin/lib/common.sh` 수정:
- `sdd_find_root`: `.harness-kit/installed.json` 감지 조건 추가
- `SDD_AGENT` → `$SDD_ROOT/.harness-kit/agent`
- `SDD_TEMPLATES` → `$SDD_ROOT/.harness-kit/agent/templates`
- `harness.config.json` 읽기 블록 추가 (jq + grep 폴백)
- `.harness-kit/bin/` 동기화

Commit: `2b6390b refactor(spec-9-003): fix common.sh agent paths and add config reading`

---

### Task 4: install.sh — prefix UX + config 생성

`install.sh` 수정:
- `--prefix` 플래그 파싱 (`--prefix=hk-` 또는 `--prefix hk-`)
- Section 5 추가: 기본값/prefix 선택 프롬프트 (`--yes` 시 스킵)
- `BACKLOG_DIR`/`SPECS_DIR` 변수 도입
- Section 8: `$BACKLOG_DIR`/`$SPECS_DIR` 로 디렉토리 생성
- Section 17: prefix 있으면 `harness.config.json` 작성

테스트 결과:
```
$ bash tests/test-path-config.sh
 ✅ ALL PASS (9/9)
```

Commit: `e1aae6e feat(spec-9-003): add prefix UX and harness.config.json to install.sh`

---

### Task 5: doctor.sh — config 반영

`doctor.sh` 수정:
- Section 2: `harness.config.json` 읽어 실제 backlog/specs 경로로 디렉토리 체크
- Section 5: `harness.config.json` 존재 확인 + backlogDir/specsDir 출력

```
$ bash doctor.sh
[2/7] 디렉토리 구조
✓ backlog
✓ specs
...
[5/7] State
✓ .harness-kit/installed.json 존재
  kit version: 0.4.0
```

Commit: `b8aa140 refactor(spec-9-003): doctor.sh reflects harness.config.json paths`

---

### 전체 테스트 결과 (Ship 직전)

```
bash tests/test-path-config.sh       → ✅ ALL PASS (9/9)
bash tests/test-hook-modes.sh        → ✅ ALL 12 CHECKS PASSED
bash tests/test-two-tier-loading.sh  → ✅ ALL 7 CHECKS PASSED
bash tests/test-install-claude-import.sh → ✅ ALL PASS (6/6)
```
