# spec-x-claude-md-slim: root CLAUDE.md 슬림화 및 릴리스 전략 분리

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-claude-md-slim` |
| **Phase** | `phase-x` |
| **Branch** | `spec-x-claude-md-slim` |
| **상태** | Planning |
| **타입** | Refactor (docs) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-18 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
- root `CLAUDE.md` 는 108줄. 매 세션 자동 로드되어 항상 컨텍스트에 상주.
- 그 중 **릴리스 전략 섹션 (line 49-84, ~36줄)** 은 "배포하자" 라는 사용자 명령을 받을 때만 사용됨. 평시 작업 (spec 작성, 코드 수정, 디버깅) 에서는 전혀 참조하지 않음.
- **"현재 단계" 섹션 (line 93-95)** 은 "Phase 4 도그푸딩 시작 직전" 으로 표기되어 있으나 실제로는 phase-17 까지 완료된 상태. stale 한 정보가 항상-온 컨텍스트로 로드 중.
- 추가로 `.harness-kit/CLAUDE.fragment.md` (16줄) 가 import 되어 자동 로드.

### 문제점
1. **항상-온 컨텍스트 토큰 낭비** — 릴리스 작업은 전체 작업의 1% 미만 빈도인데 항상 로드됨. 일반 작업의 모든 세션에서 36줄 분의 토큰을 비용으로 지불.
2. **stale 정보 노출** — "Phase 4 도그푸딩 시작 직전" 표기가 현재 상태와 맞지 않아 신규 세션이 잘못된 컨텍스트를 갖고 시작 가능.
3. **Claude Code harness 가이드 권장 (news.hada.io/topic?id=29556) 위배** — "root = 포인터, 상세 = 별도 파일" 원칙. 현재는 root 가 두꺼움.

### 해결 방안 (요약)
릴리스 전략 섹션을 `docs/release-strategy.md` 로 추출하고 root 에는 1-2줄 포인터만 유지. stale 한 "현재 단계" 섹션은 삭제. root CLAUDE.md 를 ~70줄 이하로 축소.

## 🎯 요구사항

### Functional Requirements
1. `docs/release-strategy.md` 신규 파일 생성 — 기존 "릴리스 전략" 섹션 내용 그대로 이전.
2. `CLAUDE.md` 의 "릴리스 전략" 섹션을 1-2줄 포인터 (예: "새 버전 출시 절차는 `docs/release-strategy.md` 참조") 로 대체.
3. `CLAUDE.md` 의 "현재 단계" 섹션 (stale) 삭제.
4. 다른 산출물 (`docs/decisions/`, `README.md`, 메모리 등) 에서 CLAUDE.md 의 릴리스 전략 섹션을 인용/참조하는 곳이 있는지 확인. 있으면 새 경로로 갱신.

### Non-Functional Requirements
1. **무손실** — 릴리스 전략의 모든 절차·룰·주의사항은 새 파일에 그대로 보존. 다음 릴리스 작업 시 문맥 부족 없도록.
2. **포인터 가독성** — root 에 남는 포인터 한 줄로도 "릴리스 명령 시 docs/release-strategy.md 를 먼저 읽어야 함" 이 분명히 전달되어야 함.
3. **install 정책 영향 없음** — `install.sh` 는 root `CLAUDE.md` 의 일부를 머지하지 않고 `HARNESS-KIT:BEGIN/END` 블록만 다룸. 슬림화는 install 동작에 무영향.

## 🚫 Out of Scope

- 하위 디렉토리 CLAUDE.md (`sources/CLAUDE.md`, `specs/CLAUDE.md`) 신설 — 별도 spec-x (icebox 항목) 로 분리.
- `.harness-kit/CLAUDE.fragment.md` 의 슬림화 — 본 spec 은 root CLAUDE.md 만 다룸.
- governance 문서 (`constitution.md`, `agent.md`) 슬림화 — `/hk-align` 호출 시에만 로드되므로 항상-온 비용 없음.
- 릴리스 전략 *내용* 자체의 수정 — 위치만 옮기고 내용 보존.

## 📑 ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — 단순 문서 분리, 거버넌스 변경 없음.

## ✅ Definition of Done

- [ ] `docs/release-strategy.md` 신규 생성 (내용 무손실)
- [ ] `CLAUDE.md` 슬림화 (~70줄 이하, 릴리스 전략은 포인터만, "현재 단계" 삭제)
- [ ] 다른 곳의 참조 갱신 (검색 결과 0건이면 생략)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-claude-md-slim` 브랜치 push 완료
- [ ] PR 생성 및 사용자 검토 요청
