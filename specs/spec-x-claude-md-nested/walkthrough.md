# Walkthrough: spec-x-claude-md-nested

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| nested 도입 범위 | (A) 추가만 / (B) root 일부를 nested 로 이동 (slim) | **(A) 추가만** | scope 분리 원칙. root slim 은 별 결정 (이미 직전 spec-x-claude-md-slim 에서 1차 진행). 본 spec 은 "nested 도입" 자체에 집중. (B) 는 별 spec |
| `sources/governance/CLAUDE.md` 추가 여부 | 추가 / 비추가 | **비추가** | Claude Code 가 상위 `sources/CLAUDE.md` 도 함께 로드. 한 단계로 충분. governance 만의 추가 컨텍스트는 현재 없음 — 필요 시점에 분리 |
| 분량 상한 25줄 | 자유 / 25줄 / 더 작게 | **25줄** | nested 는 *디렉토리 특화* 만 담아야 root 와 중복 회피. 25줄이 합리적 marker — 결과: sources 20줄, specs 22줄 |

### ADR 승격 가이드

- [ ] ADR 승격 대상 있음
- [x] 없음 — 단순 docs 추가, cross-spec / long-lived 결정 아님

## 💬 사용자 협의

- **주제**: 직전 root slim 후속으로 어떤 인사이트 항목을 우선할지
  - **사용자 의견**: 1번 선택 — icebox 의 다른 인사이트 항목 진행
  - **합의**: 추천한 #2 (하위 디렉토리 CLAUDE.md) 부터 spec-x 로 진행

## 🧪 검증 결과

### 자동 테스트

| 테스트 | 결과 |
|---|---|
| `tests/test-install-claude-import.sh` | ✅ ALL PASS (6/6) — root @import / fragment 핵심 규칙 / 멱등성 보존 |
| `tests/test-marker-append-guard.sh` | ✅ ALL 5 CHECKS PASSED |
| `tests/test-marker-edge-cases.sh` | ✅ ALL 8 CHECKS PASSED |

`sdd test passed` → `lastTestPass: 2026-05-18T06:51:35Z`.

### 수동 검증

1. **Action**: `wc -l sources/CLAUDE.md specs/CLAUDE.md`
   - **Result**: 20 / 22 (각 ≤ 25 ✓)
2. **Action**: `git diff main..HEAD -- CLAUDE.md`
   - **Result**: 출력 없음 — root 무변경 확인.
3. **Action**: `grep "HARNESS-KIT" CLAUDE.md`
   - **Result**: `BEGIN` / `END` 마커 보존 (root 자체 무변경이라 당연).

## 🔍 발견 사항

- **Claude Code 의 nested CLAUDE.md auto-load 동작 가정**: 본 spec 의 가치는 "sources/ 또는 specs/ 의 파일을 편집할 때 해당 nested CLAUDE.md 가 자동 로드된다" 는 가정 위에 성립. 실제 작동 확인은 다음 세션에서 sources/ 하위 파일 편집 시 검증 가능. 만약 의도대로 작동하지 않으면 본 spec 의 효용 ↓ → 추가 spec 으로 root 에 명시적 reference 추가 검토.
- **`sdd specx new` Branch 필드 중복 버그 재확인** — spec.md 의 Branch 필드가 `spec-x-claude-md-nested-claude-md-nested` 로 생성됨. 직전 spec 도 동일 패턴. icebox 에 이미 등록되어 있음. *기록만 하고 본 spec 범위 외*.
- **scaffold walkthrough.md 템플릿** — `sdd specx new` 가 생성하는 walkthrough.md 는 빈 템플릿. 그러나 본 spec 의 walkthrough 는 ship 시점에 *덮어쓰기* 로 작성 — 템플릿이 미리 commit 되는 게 `add spec/plan/task` 의도와 약간 불일치. 다음 spec 부터 walkthrough 는 ship 단계에서 처음 생성하는 게 더 자연스러울 수 있음 (별 후속 검토).

## 🚧 이월 항목

- root `CLAUDE.md` 추가 슬림 — "두 시점 공존" 메타 가이드가 nested 도입 후에도 여전히 필요한지 재평가. 필요 시 별 spec-x.
- `sdd specx new` Branch 필드 중복 버그 (icebox 등록됨)
- LSP/MCP 활용 가이드 (인사이트 #3) — 다음 spec-x 후보
- 분기별 governance prune protocol (인사이트 #2) — 그 다음 spec-x 후보

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-18 |
| **최종 commit** | (push 후 갱신) |
