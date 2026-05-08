#!/usr/bin/env bash
set -euo pipefail

# harness-kit remote installer
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Changsik00/harness-kit/main/get.sh)
#   bash <(curl -fsSL ...) /path/to/project
#   bash <(curl -fsSL ...) --version 0.6.3 [/path/to/project]
#   bash <(curl -fsSL ...) --update [/path/to/project]
#   bash <(curl -fsSL ...) --uninstall [/path/to/project]
#   bash <(curl -fsSL ...) --yes

REPO="Changsik00/harness-kit"
VERSION=""
UPDATE=0
UNINSTALL=0
YES_FLAG=""
TARGET_DIR="$(pwd)"

usage() {
  cat <<EOF
Usage:
  bash <(curl -fsSL https://raw.githubusercontent.com/${REPO}/main/get.sh) [options] [target_dir]

Options:
  --version <ver>   특정 버전 설치 (git tag 기준, 예: 0.6.3)
  --update          기존 설치 업데이트
  --uninstall       제거 (backlog/, specs/, archive/ 산출물은 보존)
  --yes             모든 프롬프트 자동 수락
  --help            이 도움말 출력

Examples:
  # 현재 디렉토리에 최신 버전 설치
  bash <(curl -fsSL https://raw.githubusercontent.com/${REPO}/main/get.sh)

  # 특정 디렉토리에 설치
  bash <(curl -fsSL ...) ~/my-project

  # 특정 버전 설치
  bash <(curl -fsSL ...) --version 0.6.3 ~/my-project

  # 업데이트
  bash <(curl -fsSL ...) --update ~/my-project

  # 제거
  bash <(curl -fsSL ...) --uninstall ~/my-project
EOF
}

# 인자 파싱
while [ $# -gt 0 ]; do
  case "$1" in
    --help)      usage; exit 0 ;;
    --version)   VERSION="$2"; shift 2 ;;
    --update)    UPDATE=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --yes)       YES_FLAG="--yes"; shift ;;
    -*)          printf "알 수 없는 옵션: %s\n" "$1" >&2; usage >&2; exit 1 ;;
    *)           TARGET_DIR="$1"; shift ;;
  esac
done

# 임시 디렉토리 생성 + 종료 시 정리
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# 다운로드 URL 결정
if [ -n "$VERSION" ]; then
  ZIP_URL="https://github.com/${REPO}/archive/refs/tags/v${VERSION}.zip"
else
  ZIP_URL="https://github.com/${REPO}/archive/refs/heads/main.zip"
fi

printf "[get] harness-kit 다운로드 중... (%s)\n" "$ZIP_URL"

if ! curl -fsSL "$ZIP_URL" -o "$TMP_DIR/harness-kit.zip"; then
  printf "[get] 다운로드 실패: %s\n" "$ZIP_URL" >&2
  printf "[get] --version 지정 시 git tag 가 존재하는지 확인하세요.\n" >&2
  exit 1
fi

unzip -q "$TMP_DIR/harness-kit.zip" -d "$TMP_DIR"

KIT_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name "harness-kit-*" | head -1)"
if [ -z "$KIT_DIR" ]; then
  printf "[get] 압축 해제 실패: harness-kit 디렉토리를 찾을 수 없음\n" >&2
  exit 1
fi

# install / update / uninstall 실행
if [ "$UNINSTALL" -eq 1 ]; then
  printf "[get] 제거 실행: %s\n" "$TARGET_DIR"
  bash "$KIT_DIR/uninstall.sh" "$TARGET_DIR" $YES_FLAG
elif [ "$UPDATE" -eq 1 ]; then
  printf "[get] 업데이트 실행: %s\n" "$TARGET_DIR"
  bash "$KIT_DIR/update.sh" "$TARGET_DIR" $YES_FLAG
else
  printf "[get] 설치 실행: %s\n" "$TARGET_DIR"
  bash "$KIT_DIR/install.sh" "$TARGET_DIR" $YES_FLAG
fi
