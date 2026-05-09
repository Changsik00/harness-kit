fix(install): pre-commit hook 재설치 시 chmod +x 누락 버그 수정

## 배경

`install.sh` 11b 섹션에서 `.git/hooks/pre-commit`에 harness 블록을 설치할 때,
파일을 새로 생성하는 경우만 `chmod +x`를 적용했음.
파일이 이미 존재하는 경우(재설치/업데이트)는 블록 append 후 `chmod +x` 없음.

결과: `update.sh` 또는 `install.sh` 재실행 후 hook이 실행 불가 상태로 남아
git이 조용히 무시 → Plan Accept 안전망 완전 무력화.

`spec-x-hook-bypass-fix`(PR #96)에서 구축한 안전망이 실제로는 동작하지 않았음.

## 변경 내용

### `install.sh`

11b 섹션 — 기존 파일 분기 후 공통 `chmod +x` 추가 (1줄):

```bash
# 수정 전: 새 파일 생성 시에만 chmod +x
# 수정 후: 기존 파일(append/skip) 경우도 chmod +x 항상 실행
if [ -f "$GIT_HOOK" ]; then
  ...
  chmod +x "$GIT_HOOK"   # ← 추가
else
  ...
  chmod +x "$GIT_HOOK"   # 기존
fi
```

### `tests/test-git-precommit-hook.sh`

Test 11 추가 — 재설치 후 실행 권한 복구 회귀 테스트:
- install → chmod 제거(버그 재현) → 재설치 → `-x` 권한 확인

## 테스트

- `test-git-precommit-hook.sh`: ✅ PASS 11/11
- 이 레포 `install.sh .` 재실행: `.git/hooks/pre-commit` → `-rwx--x--x` 확인
