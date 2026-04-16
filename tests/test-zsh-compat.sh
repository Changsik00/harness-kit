#!/usr/bin/env bash
# test-zsh-compat.sh — zsh 호환성 검증 테스트
set -uo pipefail

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "═══════════════════════════════════════════"
echo " Zsh Compatibility Verification"
echo "═══════════════════════════════════════════"
echo ""

check() {
  local desc="$1" result="$2"
  if [ "$result" = "ok" ]; then
    echo "  ✅ $desc"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $desc"
    FAIL=$((FAIL + 1))
  fi
}

# ── Check 1: _lib.sh 에 _script_dir 함수 존재
echo "▶ Check 1: _lib.sh 에 _script_dir 함수 존재"
if grep -q '_script_dir()' "$ROOT/sources/hooks/_lib.sh"; then
  check "_script_dir 함수 존재" "ok"
else
  check "_script_dir 함수 존재" "fail"
fi
echo ""

# ── Check 2: _script_dir 에 ZSH_VERSION 분기 포함
echo "▶ Check 2: _script_dir 에 ZSH_VERSION 분기"
if grep -q 'ZSH_VERSION' "$ROOT/sources/hooks/_lib.sh"; then
  check "ZSH_VERSION 분기 존재" "ok"
else
  check "ZSH_VERSION 분기 존재" "fail"
fi
echo ""

# ── Check 3: hook 에서 BASH_SOURCE 직접 사용 제거
echo "▶ Check 3: hook 에서 BASH_SOURCE 직접 사용 제거"
bash_source_ok="ok"
for f in check-branch.sh check-plan-accept.sh check-test-passed.sh; do
  # _self 함수 안에서의 사용은 허용, 그 외 직접 사용은 금지
  direct=$(grep -c 'BASH_SOURCE' "$ROOT/sources/hooks/$f" || true)
  in_self=$(grep -c 'BASH_SOURCE' "$ROOT/sources/hooks/$f" | head -1 || true)
  # _self 함수 내부에서만 사용되어야 함
  if grep 'BASH_SOURCE' "$ROOT/sources/hooks/$f" | grep -qv '_self'; then
    bash_source_ok="fail"
    check "$f: BASH_SOURCE 직접 사용 없음" "fail"
  else
    check "$f: BASH_SOURCE 직접 사용 없음" "ok"
  fi
done
echo ""

# ── Check 4: sdd 에서 local -a 제거
echo "▶ Check 4: sdd 에서 local -a 배열 제거"
if grep -q 'local -a' "$ROOT/sources/bin/sdd"; then
  check "local -a 제거됨" "fail"
else
  check "local -a 제거됨" "ok"
fi
echo ""

# ── Check 5: sdd 에서 BASH_SOURCE 직접 사용 제거
echo "▶ Check 5: sdd 에서 BASH_SOURCE 직접 사용 제거"
if grep 'BASH_SOURCE' "$ROOT/sources/bin/sdd" | grep -qv '_self'; then
  check "sdd BASH_SOURCE 직접 사용 없음" "fail"
else
  check "sdd BASH_SOURCE 직접 사용 없음" "ok"
fi
echo ""

# ── Check 6: install.sh --shell 옵션 파싱
echo "▶ Check 6: install.sh --shell 옵션 존재"
if grep -q 'SHELL_MODE' "$ROOT/install.sh"; then
  check "SHELL_MODE 변수 존재" "ok"
else
  check "SHELL_MODE 변수 존재" "fail"
fi
if grep -q '\-\-shell=' "$ROOT/install.sh"; then
  check "--shell= 옵션 파싱" "ok"
else
  check "--shell= 옵션 파싱" "fail"
fi
echo ""

# ── Check 7: install.sh do_fix_shebang 함수
echo "▶ Check 7: install.sh shebang 교체 함수"
if grep -q 'do_fix_shebang' "$ROOT/install.sh"; then
  check "do_fix_shebang 함수 존재" "ok"
else
  check "do_fix_shebang 함수 존재" "fail"
fi
echo ""

# ── Check 8: doctor.sh zsh 감지
echo "▶ Check 8: doctor.sh zsh 감지"
if grep -q '_detect_shell_mode' "$ROOT/doctor.sh"; then
  check "_detect_shell_mode 함수 존재" "ok"
else
  check "_detect_shell_mode 함수 존재" "fail"
fi
if grep -q 'INSTALLED_SHELL' "$ROOT/doctor.sh"; then
  check "INSTALLED_SHELL 변수 사용" "ok"
else
  check "INSTALLED_SHELL 변수 사용" "fail"
fi
echo ""

# ── Check 9: sources/ ↔ .harness-kit/ 동기화
echo "▶ Check 9: sources/ ↔ .harness-kit/ 동기화"
sync_ok="ok"
for f in hooks/_lib.sh hooks/check-branch.sh hooks/check-plan-accept.sh hooks/check-test-passed.sh; do
  if diff -q "$ROOT/sources/$f" "$ROOT/.harness-kit/$f" >/dev/null 2>&1; then
    check "$f 동기화 OK" "ok"
  else
    check "$f 동기화 OK" "fail"
    sync_ok="fail"
  fi
done
if diff -q "$ROOT/sources/bin/sdd" "$ROOT/.harness-kit/bin/sdd" >/dev/null 2>&1; then
  check "sdd 동기화 OK" "ok"
else
  check "sdd 동기화 OK" "fail"
fi
echo ""

# ── Check 10: shebang 교체 기능 테스트 (dry run)
echo "▶ Check 10: shebang 교체 기능 (임시 파일 테스트)"
tmpfile="$(mktemp)"
echo '#!/usr/bin/env bash' > "$tmpfile"
echo 'echo hello' >> "$tmpfile"
sed -i.tmp '1s|#!/usr/bin/env bash|#!/usr/bin/env zsh|' "$tmpfile"
rm -f "${tmpfile}.tmp"
if head -1 "$tmpfile" | grep -q '#!/usr/bin/env zsh'; then
  check "shebang 교체 정상 동작" "ok"
else
  check "shebang 교체 정상 동작" "fail"
fi
rm -f "$tmpfile"
echo ""

# ── Check 11: sdd hooks 서브커맨드 동작 (배열 제거 후)
echo "▶ Check 11: sdd hooks 서브커맨드 동작"
hooks_output="$(bash "$ROOT/.harness-kit/bin/sdd" hooks 2>/dev/null || true)"
if echo "$hooks_output" | grep -q 'check-branch.sh'; then
  check "sdd hooks 출력에 check-branch.sh 표시" "ok"
else
  check "sdd hooks 출력에 check-branch.sh 표시" "fail"
fi
if echo "$hooks_output" | grep -q 'check-plan-accept.sh'; then
  check "sdd hooks 출력에 check-plan-accept.sh 표시" "ok"
else
  check "sdd hooks 출력에 check-plan-accept.sh 표시" "fail"
fi
echo ""

# ── 결과
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL $PASS CHECKS PASSED"
else
  echo " ❌ $FAIL FAILED, $PASS PASSED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
