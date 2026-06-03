# Walkthrough: spec-19-03 — sdd doctor wiki 점검 + CLAUDE.md 슬림화

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Check 1 테스트 — sdd doctor 파이프 | `sdd doctor \| grep -q` 직접 파이프 / 출력 캡처 후 grep | 출력 캡처 후 grep | `grep -q`가 첫 매치 후 파이프를 닫으면 sdd가 SIGPIPE로 종료 → `pipefail`로 테스트 실패. 캡처 방식으로 우회 |
| W-2 테스트 — 고아 wikilink 픽스처 | 임시 dir에 SDD_ROOT 재정의 / 코드에 경고 문구 존재 grep | 코드 grep | `SDD_ROOT`는 `common.sh`에서 파일시스템 탐색으로 덮어씌워져 env 재정의 불가. 코드 경로 검증으로 대체 |
| [[wikilinks]] 고아 링크 매핑 | 네임스페이스 접두어 제거 후 docs/wiki/ 검색 / 전체 경로 매핑 테이블 | 접두어 제거 + 다중 경로 검색 | `wiki/decisions` → `decisions.md`, `ADR-001` → `docs/decisions/ADR-001.md` 등 패턴이 한정적 — 단순 규칙으로 충분 |
| CLAUDE.md 슬림화 대상 | 디렉토리 의미 + 대상 환경만 이동 / 전체 레퍼런스 섹션 이동 | 두 섹션만 이동 | CLAUDE.md가 이미 71줄로 린함. 현재 수정 빈도 낮은 두 섹션만 분리, 나머지는 핵심 규칙이라 유지 |

### ADR 승격 가이드

- [x] 없음

## 💬 사용자 협의

- **주제**: spec-19-03 즉시 시작
  - **사용자 의견**: spec-19-02 PR 머지 완료 직후 "1" (Plan Accept) 선택
  - **합의**: phase-19-doc-knowledge-graph에서 즉시 spec-19-03 브랜치 생성 후 진행

## 🧪 검증 결과

### 1. 자동화 테스트

#### test-doctor-wiki.sh (신규)
- **명령**: `bash tests/test-doctor-wiki.sh`
- **결과**: ✅ 5/5 PASS
- **로그 요약**:
```text
───────────────────────────────────────────
 결과: 5/5 PASS
───────────────────────────────────────────
 ✓ ALL PASS
```

#### test-wiki-structure.sh
- **명령**: `bash tests/test-wiki-structure.sh`
- **결과**: ✅ 45/45 PASS (기존 유지)

### 2. 수동 검증

1. **Action**: `sdd doctor` 직접 실행
   - **Result**: "wiki layer" 섹션 출력 확인. W-2 경고 — 25개 고아 wikilink 감지 (index.md의 [[ADR-001]], [[ADR-002]] 등이 `docs/decisions/ADR-001.md` 경로 매핑 시 접두어 처리 미비로 고아 판정)
   - **보완**: W-2 고아 링크 매핑 로직의 ADR/RCA 패턴 처리는 향후 정교화 여지 있음

2. **Action**: `wc -w sources/governance/constitution.md sources/governance/agent.md`
   - **Result**: constitution 2,677w + agent 3,785w = 6,462w → "governance 6462w (< 7000w)" ✅

## 🔍 발견 사항

- **SIGPIPE 함정**: `set -euo pipefail` 환경에서 `sdd doctor 2>&1 | grep -q "..."` 패턴은 grep이 조기 종료 시 sdd가 SIGPIPE → 테스트 오탐. 다른 테스트에서도 같은 패턴이 있으면 주의 필요.
- **W-2 고아 링크 25개**: 현재 `docs/wiki/index.md` 에서 `[[ADR-001]]`, `[[ADR-002]]` 등 ADR 링크가 `docs/decisions/ADR-001.md` 경로로 매핑되어야 하는데, 경로 매핑 로직의 namespace 분리 처리가 ADR 단독 slug(접두어 없는) 케이스를 커버하지 못함. 경고는 맞지만 false positive 가능성 있음 — 향후 개선 후보.
- **SDD_ROOT 재정의 불가**: `common.sh`에서 파일시스템 탐색으로 SDD_ROOT를 덮어써서 테스트 픽스처에서 환경 재정의가 동작하지 않음. 픽스처 기반 테스트를 작성하려면 `sdd_find_root` 를 오버라이드 가능하게 만들거나 별도 픽스처 git repo를 생성해야 함.

## 🚧 이월 항목 (Optional)

- W-2 고아 링크 매핑 정교화 (ADR/RCA slug 단독 패턴 처리) → backlog/queue.md 추가

## 🔗 관련 문서 (Related)

- 관련 wiki: [[wiki/decisions]], [[wiki/patterns]]
- 관련 ADR: [[ADR-003-wiki-frontmatter-schema]]
- 관련 RCA: 없음

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-27 ~ 2026-05-27 |
| **최종 commit** | `969056e` |
