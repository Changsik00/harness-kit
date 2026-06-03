# spec-19-03: sdd doctor wiki 점검 + CLAUDE.md 슬림화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-19-03` |
| **Phase** | `phase-19` |
| **Branch** | `spec-19-03-doctor-wiki-slim` |
| **상태** | Planning |
| **타입** | Feature / Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-05-27 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- `sdd doctor` 는 필수 도구, 설치 파일, 훅 권한만 점검합니다 — wiki layer가 생겼지만 doctor는 모릅니다.
- root `CLAUDE.md` 는 71줄로 비교적 린하지만, 디렉토리 의미·대상 환경 섹션은 수정 빈도가 낮아 핵심 규칙의 signal-to-noise ratio를 낮춥니다.
- `sources/governance/` 에 rule prune 기준이 없어 오래된 규칙이 그대로 누적됩니다.
- governance 파일 총 단어 수: 6,462w (constitution 2,677w + agent 3,785w) — 7,000w 상한에 근접합니다.

### 문제점

1. **wiki layer blind spot**: `sdd doctor` 가 `docs/wiki/` 부재를 잡지 못합니다.
2. **[[wikilinks]] 고아 링크**: 파일 이동·이름 변경 시 링크가 끊겨도 감지 수단이 없습니다.
3. **stale docs**: decisions/, rca/ 파일이 90일+ 미참조 상태로 방치되어도 신호가 없습니다.
4. **governance bloat**: 단어 수 상한 없이 규칙이 누적되어 LLM 컨텍스트 비용이 올라갑니다.
5. **CLAUDE.md 주목도 희석**: 저빈도 참조 섹션이 섞여 있어 핵심 규칙의 가시성이 낮습니다.

### 해결 방안 (요약)

`sdd doctor` 에 wiki layer 점검 4종을 추가합니다. root `CLAUDE.md` 의 저빈도 섹션을 `docs/project-guide.md` 로 분리하고 포인터만 남깁니다. `sources/governance/constitution.md` 에 rule prune 권고 기준 섹션을 추가합니다.

## 🎯 요구사항

### Functional Requirements

1. `sdd doctor` — wiki layer 점검 섹션 신설 (4종):
   - **W-1**: `docs/wiki/` 디렉토리 부재 → `⚠ wiki layer 없음 — /hk-wiki-ingest 실행 권장`
   - **W-2**: `docs/wiki/*.md` 내 `[[wikilinks]]` 고아 링크 감지 → `⚠ N개 고아 링크`
   - **W-3**: `docs/decisions/` + `docs/rca/` 파일 중 90일+ git 미참조 → `⚠ N개 stale 문서`
   - **W-4**: `sources/governance/constitution.md` + `agent.md` 단어 수 합계 7,000w 초과 → `⚠ governance Nw (> 7000w 상한)`
2. root `CLAUDE.md` 슬림화:
   - `## 대상 환경 (고정)` + `## 디렉토리 의미` 섹션 → `docs/project-guide.md` 로 이동
   - CLAUDE.md 에는 포인터 1줄만 남김 (`자세한 내용: docs/project-guide.md`)
3. `sources/governance/constitution.md` 에 "Rule Prune Guidance" 섹션 추가:
   - 작성일 6개월+ AND 모델 2세대 경과 → 검토 권장
4. `.harness-kit/bin/sdd` doctor 동기화 (sources와 동일 변경)

### Non-Functional Requirements

1. bash 3.2+ 호환 — 날짜 비교는 `git log --format="%ct"` + `date +%s` 활용
2. W-2/W-3 는 대상 디렉토리가 없으면 skip (⚠ 출력 없음)
3. 기존 `sdd doctor` 출력 구조 유지 (섹션 추가만, 기존 섹션 변경 없음)

## 🚫 Out of Scope

- `[[wikilinks]]` 고아 링크 자동 수정 (감지만)
- docs/wiki/*.md 간 cross-link graph 분석
- CLAUDE.md의 HARNESS-KIT fragment 섹션 변경
- governance 파일 직접 prune (기준 문서화만)
- `.harness-kit/agent/constitution.md` 변경 (sources/ 원본만 수정, .harness-kit 동기화는 update.sh 역할)

## 📑 ADR 후보

- [x] 없음 — 임계값(90일, 7,000w)은 운영 경험 후 조정 예정이라 ADR 격상 불필요

## 🔗 관련 문서 (Related)

- 관련 wiki: [[wiki/decisions]], [[wiki/patterns]]
- 관련 ADR: [[ADR-003-wiki-frontmatter-schema]]
- 관련 RCA: 없음

## ✅ Definition of Done

- [ ] `sdd doctor` W-1~W-4 점검 4종 추가 및 동작 확인 (sources + .harness-kit 동기화)
- [ ] `docs/project-guide.md` 생성 + CLAUDE.md 포인터 교체
- [ ] `sources/governance/constitution.md` rule prune 기준 섹션 추가
- [ ] `tests/test-doctor-wiki.sh` 신규 작성 및 PASS 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-19-03-doctor-wiki-slim` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
