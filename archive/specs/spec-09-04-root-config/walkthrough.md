# Walkthrough: spec-09-04

## 증거 로그

### Task 2: TDD Red — test-path-config.sh 업데이트

Check A를 "harness.config.json 미생성" → "생성 + rootDir 검증"으로 변경.

```
$ bash tests/test-path-config.sh
▶ 시나리오 A: --yes (기본값 경로)
  ❌ harness.config.json 미생성
  ❌ rootDir 불일치: expected=<fixture> actual=
  ✅ backlog/ 생성됨
  ✅ specs/ 생성됨
...
 ❌ 3/10 CHECKS FAILED
```

Commit: `8636e43 test(spec-09-04): update test-path-config for rootDir`

---

### Task 3: install.sh — rootDir 항상 기록

prefix 없어도 `harness.config.json`을 항상 생성하도록 수정.
- prefix 없음: `{"rootDir":"<TARGET>"}`
- prefix 있음: `{"rootDir":"<TARGET>","backlogDir":"...","specsDir":"..."}`

```
$ bash tests/test-path-config.sh
 ✅ ALL PASS (10/10)
```

Commit: `764445c feat(spec-09-04): always write rootDir to harness.config.json`

---

### Task 4: common.sh — rootDir 우선 읽기

`sdd_find_root`를 수정해 최대 10단계 내 `.harness-kit/harness.config.json`을 찾으면 `rootDir`를 직접 반환. 더 이상 `/`까지 무한 탐색하지 않음.

```bash
# 변경 전: CWD → / 무한 탐색
# 변경 후: CWD → 최대 10단계 → config의 rootDir 반환
```

전체 테스트:
```
tests/test-path-config.sh        → ✅ ALL PASS (10/10)
tests/test-hook-modes.sh         → ✅ ALL 12 CHECKS PASSED
tests/test-two-tier-loading.sh   → ✅ ALL 7 CHECKS PASSED
tests/test-install-claude-import.sh → ✅ ALL PASS (6/6)
```

Commit: `1012b80 refactor(spec-09-04): sdd_find_root reads rootDir from config`
