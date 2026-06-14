# Phase Ship: phase-22 — extend (외부 도구 opt-in 통합)

## 📋 Overview

Claude Code 기본 루프의 텍스트 기반 탐색은 LSP IDE 대비 리팩토링이 느리고 토큰 왕복이 많다. 이를 개선하되 "컨텍스트 비용 0 우선" 원칙과 충돌하지 않도록, 외부 도구를 **opt-in(default-off)** 으로 붙이는 **extend** 경로를 도입하고 그 1호로 Serena(LSP) 설치 커맨드를 제공한다.

## 📦 Scope: 계획 vs 실제

| 구분 | 항목 | 비고 |
|:---:|---|---|
| ✅ 완료 | spec-22-01: extend-serena — `/hk-extend` + `sdd extend serena` (PR #191) | |
| ⏭ 이연 | grep vs Serena 토큰 실측 (성공기준 #4) | main 진입이 전제(닭-달걀) → post-ship, nextmarket-api 도그푸딩에서 수행 |

## 📊 Spec Summary

| PR | Spec | 핵심 변경 |
|---|---|---|
| #191 | spec-22-01-extend-serena | `sdd extend serena` 헬퍼(스코프/dry-run/멱등/remove) + `/hk-extend` + ADR-007 |

## ✅ Success Criteria Checklist

| # | 기준 | 결과 | 증거 |
|:---:|---|:---:|---|
| 1 | `/hk-extend` 로 Serena 스코프 선택(local 기본/user) 설치 | ✅ PASS | `tests/test-extend.sh` T1·T4, `sources/commands/hk-extend.md` |
| 2 | 멱등 설치/제거 + `claude mcp list` 노출 | ✅ PASS | T5(멱등)·T6(remove) (stub 기반) |
| 3 | extend 규약 ADR-007 명문화 | ✅ PASS | `docs/decisions/ADR-007-extend-opt-in.md` |
| 4 | grep vs Serena 토큰 실측 1회 | ⏭ 이연 | main 릴리스 후 nextmarket-api 도그푸딩에서 수행 (opt-in이라 안전) |

## 🧪 Integration Test Results

| # | 시나리오 | 결과 | 증거 |
|:---:|---|:---:|---|
| 1 | Serena local 설치 → `mcp list` 노출 → remove | ✅ PASS | test-extend T4·T6 (PATH stub + 상태파일 모사) |
| 2 | 선행조건(`uv`) 부재 → graceful 종료(비파괴) | ✅ PASS | test-extend T2 |

> 통합 테스트는 외부 `uv`/`claude` 를 stub 으로 격리(머신 독립). 실제 end-to-end 등록은 uv 설치 환경(도그푸딩)에서 검증 예정.

## 🏗 Architecture Decisions

- **등록 위임**: 키트가 설정 파일을 직접 편집하지 않고 Claude Code 네이티브 `claude mcp add --scope` 에 위임. 스코프(local/user/project)를 네이티브가 제공.
- **스코프 정책**: `local`(이 프로젝트·개인) 기본 / `user` 옵션 / 커밋되는 `.mcp.json`(`project`) 제외 — opt-in(켠 사람만 비용) 원칙.
- **추상화 시점**: 레지스트리 선설계 금지 — Serena 1개를 하드코딩, 검증된 확장 3개 누적 후 추출 (ADR-007).

## ⚠️ Known Issues / Technical Debt

- **end-to-end 미검증**: 본 작업 머신에 `uv` 미설치 → 실제 Serena 등록은 stub 기반만 통과. 실전 검증은 도그푸딩 단계.
- **기존 테스트 5건 pre-existing FAIL** (`test-drift-stale-adr`, `test-pr-merge-detect`, `test-update-stateful`, `test-version-bump`, `test-wiki-structure`): main 에서도 동일 실패 — extend 무관, Icebox 기록.
- **right-size 회고**: 단일 확장에 base 브랜치 phase 를 씌워 PR 이 2겹(spec→phase, phase→main)이 됨. 향후 단발 확장은 spec-x 로.

## 📝 Follow-up Work

- grep vs Serena 토큰 실측 (nextmarket-api 도그푸딩) → 효용 확인 후 확장 누적
- 권한 프롬프트 줄이기 (`/fewer-permission-prompts`) → `backlog/queue.md` Icebox
- 기존 테스트 5건 그린화 spec-x → Icebox

## 📊 Stats

- **Files changed**: 15
- **Lines**: +1124, -1
- **Test suites**: test-extend (6 checks) + 회귀 56 PASS
- **Specs**: 1개 완료, 1개 기준(#4) 이연
