# Walkthrough: spec-16-04

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

> 작업 중 이슈가 발생했을 때, 어떤 선택지가 있었고 왜 이 방향을 결정했는지 기록합니다.

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| README 슬로건 배치 | A. 한영 병기 (italic + 한국어 부제 유지) / B. 영문으로 한국어 부제 교체 / C. Positioning 섹션 신설 | **A** | 외부(영문) 우선 시야 + 내부(한국어) 본문 진입 자연스러움 모두 확보. AskUserQuestion preview 비교 후 사용자 확정 |
| version.json 필드명 | A. `description` / B. `tagline` / C. `slogan` | **A** | npm/package.json convention 일관. 향후 marketplace/배지 노출 시 표준 키로 활용 가능 |
| constitution.md identity 위치 | A. 제목 직후 prefix / B. §1 직전 / C. 별 §0 신설 | **A** | invariant laws 정의의 *왜* 가 되는 문장. 기존 첫 문장과 두 문단 흐름이 자연스럽게 연결 ("이게 reliability 계층이다" → "그래서 이런 invariant laws") |
| constitution.md 언어 | A. 영문 / B. 한영 병기 | **A (영문)** | 메모리 룰 — 거버넌스 4 파일 영어 전용 (feedback_governance_english) |
| 슬로건 정확 문구 | A. phase-16.md 의 제안 그대로 / B. 약간 수정 | **A** | phase 정의 시점에 이미 사용자 검토된 표현. 본 spec 의 핵심은 *배치* 이지 *문구 결정* 아님 |

### ADR 승격 가이드

> 위 결정 중 *cross-spec / long-lived* 인 것이 있다면 ADR 로 승격합니다 (constitution §6.3).

- [ ] ADR 승격 대상 있음
- [x] **없음** — 본 spec 의 결정은 모두 *전술적 표기/위치 선택*. "한영 병기" 는 README 1 곳에 한정된 표현 선택이지, *프로젝트 invariant* 가 아님. ADR-002 후보 (다른 산출물에 슬로건 강제 확산하는 정책 도입) 가 발생하면 그때 별도.

## 💬 사용자 협의

- **주제**: README 슬로건 배치 방식 3 안 비교
  - **사용자 의견**: AskUserQuestion preview 로 한영 병기 vs 영문 교체 vs Positioning 섹션 비교 후 *"한영 병기 (추천)"* 선택
  - **합의**: `# harness-kit` 직후 영문 italic + 빈 줄 + 기존 한국어 blockquote
- **주제**: spec-16-04 가 README 손대는 게 Icebox 의 "접근성 개선 Phase" 와 충돌하는가
  - **에이전트 안내**: 본 spec 은 슬로건 / 정체성 *노출* 만, install 경로 같은 접근성 개선은 별도 Phase
  - **합의**: 명시적 Out of Scope 로 박음 (spec.md / pr_description.md)

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 검증 (grep / diff / jq)
- **명령**: plan.md §검증 계획 의 5 항목
- **결과**: ✅ Passed (5/5)
- **로그 요약**:
```text
=== Phase 시나리오 3: grep -l "reliability layer" 3 곳 ===
.harness-kit/agent/constitution.md
version.json
README.md

jq -r '.description' version.json
→ Not an AI coding framework. A reliability layer for AI-assisted engineering.

diff sources/governance/constitution.md .harness-kit/agent/constitution.md
→ (빈 출력 — identical)

grep "SDD(Spec-Driven Development) 거버넌스" README.md → hit (한국어 부제 보존)
grep "harness-kit is a reliability layer" sources/governance/constitution.md → hit
```

#### 회귀 테스트
- **명령**: `bash tests/test-drift-stale-adr.sh`
- **결과**: ✅ Passed (3/3) — spec-16-03 의 stale 탐지 영향 없음 (본 spec 은 문서 변경만)

### 2. 수동 검증

1. **README 시각** — `head -7 README.md` 출력에 영문 italic slogan → 한국어 blockquote 순서 ✓
2. **version.json valid** — `jq .` 에러 없음, 두 필드 출력 ✓
3. **constitution 흐름** — 첫 두 문단이 정체성 → invariant laws 정의 로 자연 연결 ✓

## 🔍 발견 사항

- **phase-16 통합 시나리오 3 의 "test 입력" 가벼움** — 본 시나리오는 *grep -l 3 곳 hit* 한 줄로 PASS 판정. 실제 *슬로건이 의도대로 노출되는지* 의 시각/맥락 검증은 수동. 향후 phase-ship 시 phase walkthrough 에 *외부 시야* (README rendered preview 등) 1 줄 추가 권장.
- **`sdd ship` marker 버그 (이번엔 깔끔)** — spec-16-03 ship 시점에 발견했지만, spec-16-04 의 `sdd spec new` 시점에는 또 중복 행 추가됨. *ship 은 in-place, new 는 append* 패턴으로 보임. Icebox 의 sdd marker 버그 RCA 후보에 패턴 추가 필요.
- **version.json schema 의존성**: `_drift_kit_version` 이 `version.json` 의 `version` 필드를 읽음. 새 `description` 필드 추가는 jq 호환 (filter 가 그대로 동작). 회귀 없음 확인.
- **README 한영 병기의 효과 측정 불가** — "외부 사용자 시야" 가설은 *측정 어려움*. 다음 phase 의 접근성 개선 시 GitHub stars / clone trend 와 결합해 추적 후보.

## 🚧 이월 항목

- phase-ship walkthrough 에 README rendered preview / Reliability layer 정체성 외부 노출 효과 1 줄 — `/hk-phase-ship` 단계에서 작성
- 다른 산출물 (CHANGELOG / install.sh 헤더 등) 슬로건 일치 — Icebox 후보 또는 spec-x
- `sdd spec new` marker append 버그 fix — Icebox 의 RCA 후보 (phase-16 done 후 spec-x)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-16 (단일 세션) |
| **최종 commit** | `29801d1` (Task 5 install sync) |
| **총 commit 수** | 5 (planning + readme + version + constitution + sync) — 검증 task 는 commit 없음 |
