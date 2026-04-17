# spec-x-remove-zsh-compat: zsh 호환 코드 제거

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-remove-zsh-compat` |
| **Branch** | `spec-x-remove-zsh-compat` |
| **타입** | Refactor |
| **작성일** | 2026-04-17 |

## 배경

zsh 호환 코드(_self() ZSH_VERSION 분기, install.sh --shell=zsh, do_fix_shebang)가 11개+ 파일에 존재하나, 기본 설치에서 절대 실행되지 않는 dead code. bash 4.0+가 필수 의존이므로 zsh 경로는 불필요.

## 변경 내용

1. `_self()` 함수 → `BASH_SOURCE[0]` 직접 사용으로 단순화 (11개 파일)
2. `_lib.sh`의 `_script_dir()` → BASH_SOURCE 기반으로 단순화
3. `install.sh` — `--shell` 옵션, `SHELL_MODE`, `do_fix_shebang` 제거
4. `doctor.sh` — `_detect_shell_mode` 제거, bash 버전 검사만 유지
5. `test-zsh-compat.sh` 삭제 (검증 대상이 없어짐)
6. `cmd_hooks`의 `.zshrc` 참조 제거
7. CLAUDE.md, README.md의 "zsh / bash" 표기 → "bash 4.0+" 전용으로 정리
8. `.harness-kit/` 도그푸딩 동기화
