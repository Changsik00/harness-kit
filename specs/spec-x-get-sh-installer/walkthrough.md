# Walkthrough: spec-x-get-sh-installer

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 버전 미지정 시 기본 소스 | main 브랜치 zip vs 최신 tag | main 브랜치 zip | 릴리즈/태그 생성 없이 즉시 동작. 사용자가 안정 버전 원할 땐 `--version` 지정 |
| update/uninstall 지원 범위 | get.sh에 모두 포함 vs install만 | install + update 포함, uninstall 제외 | uninstall은 설치된 kit 내 스크립트로 충분. 불필요한 복잡도 제거 |
| GitHub URL 구조 | REPO 변수로 분리 | 분리 | 레포 이전 시 한 곳만 수정 가능. 테스트는 패턴을 `Changsik00/harness-kit` 으로 수정 |
| README 기존 clone 방식 처리 | 삭제 vs `<details>` 로 접기 | `<details>` 접기 | 키트 개발자/기여자는 여전히 clone 방식이 필요함 |

## 💬 사용자 협의

- **주제**: 설치 UX 개선 방향
  - **사용자 의견**: npx 지원을 고민했으나, bash 툴킷에 Node.js 의존성 추가는 과함
  - **합의**: `curl | bash` 패턴의 `get.sh` 로 결정. VERSION 파일도 이 세션에서 `version.json` 으로 SSOT 전환

- **주제**: README 뱃지 동적화
  - **합의**: shields.io dynamic badge + `version.json` SSOT로 먼저 전환 후 본 spec 진행

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-get-sh.sh`
- **결과**: ✅ PASS 10 / FAIL 0

```text
=== test-get-sh ===
  ✅ PASS: get.sh 존재
  ✅ PASS: get.sh 실행 권한 있음
  ✅ PASS: --help 출력에 Usage 포함
  ✅ PASS: set -euo pipefail 포함
  ✅ PASS: bash 3.2+ 호환 구문
  ✅ PASS: trap EXIT 존재 (임시 디렉토리 정리)
  ✅ PASS: --version 플래그 처리 코드 존재
  ✅ PASS: --update 플래그 처리 코드 존재
  ✅ PASS: --yes 플래그 전달 처리 존재
  ✅ PASS: GitHub repo 참조 존재

=== 결과: PASS=10 FAIL=0 ===
```

## 🔍 발견 사항

- GitHub URL을 REPO 변수로 분리했더니 테스트의 `grep -q "github.com/Changsik00/harness-kit"` 가 매치 실패. 테스트 패턴을 `Changsik00/harness-kit` 으로 수정하여 해결. 구현 수정보다 테스트 의도를 명확히 하는 방향이 맞다고 판단.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 |
| **최종 commit** | `f136f43` |
