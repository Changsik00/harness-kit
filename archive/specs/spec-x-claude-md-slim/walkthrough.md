# Walkthrough: spec-x-claude-md-slim

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 릴리스 전략 새 위치 헤더 레벨 | h2 유지 (`## 릴리스 전략`) / h1 격상 (`# 릴리스 전략`) | **h1 격상** | 단독 문서이므로 h1 이 정석. 부제목도 h3→h2 로 한 단계씩 격상하여 단독 문서 톤 유지 |
| "현재 단계" 섹션 | 갱신 (Phase 17 완료로) / 삭제 | **삭제** | 항상-온 컨텍스트에 *상태가 빠르게 stale 해지는* 정보를 둔 것 자체가 안티패턴. 매번 갱신 강제하느니 제거하고 `sdd status` 가 진실의 원천 |
| `tests/run-all.sh` 부재 | 신설 / 발견만 기록 | **발견만 기록** | 본 spec 범위 밖. icebox 후보 (별 작업으로 분리) |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] 없음 — 단순 문서 분리. cross-spec / long-lived 결정 아님

## 💬 사용자 협의

- **주제**: 릴리스 전략을 root 에 둘지 별 파일로 분리할지
  - **사용자 의견**: 릴리스 작업은 빈도 1% 미만인데 36줄을 항상-온으로 두는 게 비효율적. Claude Code harness 가이드 (news.hada.io/topic?id=29556) 권장 "root = 포인터" 원칙
  - **합의**: `docs/release-strategy.md` 분리, root 는 1문장 포인터

- **주제**: "현재 단계" 섹션 (Phase 4 도그푸딩 표기) 처리
  - **사용자 의견**: 실제로는 phase-17 까지 완료. stale 정보가 자동 로드되면 신규 세션이 잘못된 컨텍스트로 시작
  - **합의**: 갱신 대신 *삭제*. 상태는 `sdd status` 가 단일 진실원

## 🧪 검증 결과

### 1. 자동화 테스트

`tests/run-all.sh` 가 부재하여 (plan 의 문서 오류 — icebox 기록 대상) 본 변경과 관련 있는 핵심 테스트 3개를 직접 실행.

| 테스트 | 결과 |
|---|---|
| `tests/test-install-claude-import.sh` | ✅ ALL PASS (6/6) — CLAUDE.md @import 보존, fragment 핵심 규칙 보존, 멱등성 |
| `tests/test-marker-append-guard.sh` | ✅ ALL 5 CHECKS PASSED — HARNESS-KIT 마커 영역 안정 |
| `tests/test-marker-edge-cases.sh` | ✅ ALL 8 CHECKS PASSED — 다중 마커 / 부재 / 정확 매치 |

`bash .harness-kit/bin/sdd test passed` → `lastTestPass: 2026-05-18T06:30:39Z`.

### 2. 수동 검증

1. **Action**: `wc -l CLAUDE.md`
   - **Result**: 71 (108 → 71, 약 34% 축소). 플랜의 "~70줄" 목표 부합.
2. **Action**: `grep -c "릴리스 전략" CLAUDE.md`
   - **Result**: 1 (포인터 존재).
3. **Action**: `grep "현재 단계" CLAUDE.md`
   - **Result**: 없음 (stale 섹션 제거 확인).
4. **Action**: `diff <(sed 변환된 원본 섹션) <(새 파일 본문)`
   - **Result**: 출력 없음 — 헤더 격상 외 내용 완전 일치.
5. **Action**: `grep -rn "릴리스 전략\|현재 단계" --include="*.md" .` 으로 외부 참조 검색
   - **Result**: archive immutable, CHANGELOG 의 과거 사실 기록, 다른 spec 의 task 메타 동음이의만 발견 — **갱신 대상 0건**.

## 🔍 발견 사항

- **`tests/run-all.sh` 부재** — plan.md / task.md 에 `bash tests/run-all.sh` 가 적혀 있으나 실제 파일이 존재하지 않음. 과거 spec 의 관용구를 복사한 것으로 보임. Plan 작성 시 명령어를 사전 확인하지 않는 것도 안티패턴. → **icebox 후보**: 통합 테스트 러너 신설 (또는 plan 템플릿 점검).
- **"현재 단계" 동음이의 대량** — `archive/specs/*/task.md` 마다 `| **현재 단계** | Planning |` 메타 필드가 있어 grep 결과를 시끄럽게 만듦. 본 spec 갱신 대상과 무관하지만 향후 grep 기반 정합성 검사 시 false positive 주의 필요.
- **task.md 의 "Phase" 메타** — spec-x 임에도 spec.md 의 `Phase` 필드에 `phase-x` 가 기재됨. spec-x 는 phase 미소속이므로 `없음` 또는 `-` 가 자연스러움. → 별 후속.

## 🚧 이월 항목

- `tests/run-all.sh` 또는 동등 통합 테스트 러너 신설 (icebox 후보)
- 하위 디렉토리 CLAUDE.md (`sources/CLAUDE.md`, `specs/CLAUDE.md`) 분리 — 이미 icebox 등록 완료
- 분기별 governance prune protocol — 이미 icebox 등록 완료

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-18 |
| **최종 commit** | (push 후 갱신) |
