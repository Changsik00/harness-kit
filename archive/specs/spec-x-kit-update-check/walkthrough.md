# Walkthrough: spec-x-kit-update-check

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 버전 조회 방법 | git ls-remote --tags vs curl version.json | curl + version.json | GitHub에 태그가 없어서 git ls-remote 가 빈 결과 반환. version.json 이 SSOT인 이 프로젝트 패턴과 일치 |
| semver 비교 | 단순 != vs latest > installed 만 알림 | latest > installed 만 알림 | 개발 브랜치에서 installed 가 main 보다 높은 경우 역방향 알림 방지 |
| update.sh 실행 | 에이전트가 직접 실행 vs 사용자 안내 | 사용자 안내 | update.sh 는 uninstall → install 재실행으로 파일 교체하는 파괴적 작업 |

## 💬 사용자 협의

- **주제**: git ls-remote 로 태그 조회 vs curl 로 version.json 직접 읽기
  - **발견**: GitHub 레포에 태그가 없어서 git ls-remote 빈 결과 → 기능 동작 안 함
  - **합의**: curl + version.json (B안) 으로 전환

## 🧪 검증 결과

- `curl -sf .../main/version.json | jq -r .version` → `0.6.3` 정상 조회 ✓
- `sdd status` — installed 0.7.0 > latest 0.6.3 이므로 역방향 알림 없음 ✓
- `installed.json` — `lastVersionCheck`, `latestKnownVersion` 캐시 기록 ✓
- `test-governance-dedup.sh` PASS 8/8, `test-hook-modes.sh` PASS 12/12, `test-git-precommit-hook.sh` PASS 11/11 ✓

## 🔍 발견 사항

- install.sh 가 `installed.json` 재작성 시 state.json 도 초기화됨 (기존 known issue). 이번에도 python3 로 수동 복구. Icebox 후보.
- PR 머지 후 GitHub main 이 0.7.0 이 되면 다른 프로젝트의 `sdd status` 에서 "0.7.0 사용 가능" 알림이 정상 표시됨.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-09 |
| **최종 commit** | `395975b` |
