# Walkthrough: spec-11-003

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 명령 이름 | `sdd vault` / `sdd stash` / `sdd archive` 재사용 | `sdd archive` 재사용 | spec-11-001에서 deprecated 처리 완료. "archive"가 디렉토리 이동의 자연스러운 이름 |
| 이동 단위 | spec 개별 / phase 단위 | phase 단위 | spec 개별 이동은 phase.md와 불일치 위험 |
| deprecated 경로 처리 | 유지 / 제거 | 제거 | `sdd archive`가 새 기능으로 완전 교체. ship 테스트에서 Check 7(deprecated) 제거 |
| status 진단 임계값 | 10 / 20 / 30 | 20 | 현재 41개 → 아카이브 후 ~10개 예상. 20이면 적당한 알림 시점 |

## 💬 사용자 협의

- **주제**: align 시 아카이브 제안 워딩
  - **사용자 요구**: "완료된 항목이 많습니다. sdd archive로 정리하시겠습니까?" 유사 워딩
  - **합의**: status 진단에 자동 포함 + align.md §4에 제안 프로토콜 추가

## 🧪 검증 결과

### 1. 자동화 테스트

#### dir-archive 테스트
- **명령**: `bash tests/test-sdd-dir-archive.sh`
- **결과**: 10/10 PASS (dry-run, 이동, active 보존, spec-x 보존, keep, status 제안)

#### ship 테스트 (회귀)
- **명령**: `bash tests/test-sdd-ship-completion.sh`
- **결과**: 7/7 PASS

## 🔍 발견 사항

- queue.md done 섹션의 형식이 일관되지 않음 (table + bullet 혼재). awk 파서가 두 형식 모두 처리하도록 구현
- heredoc 내 `$()` 치환이 trailing newline을 먹어 테스트 fixture에서 마커가 같은 줄에 붙는 버그 발견 → 수정

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-16 |
| **최종 commit** | `d84db0d` |
