# Implementation Plan: spec-x-readme-refresh

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-readme-refresh` (브랜치 이름 = spec 디렉토리 이름, `feature/` prefix 없음)
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **의존성 명세 변경**: `bash 4.0+` → `bash 3.2+` 로 정정. macOS 기본 bash 로 동작 가능을 강조하고 `brew install bash` 안내를 제거한다.
> - [ ] **"왜 이 구조인가" 문단 신설**: "💡 이 키트는 무엇인가" 섹션 끝부분에 1~2 문단 추가. 핵심 키워드: 이해 부채 / 선언형 명세 / walkthrough 의 역할 / Plan Accept = 가정 검증 게이트.

> [!WARNING]
> - 없음 (docs only, breaking change 없음)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---|:---|:---|
| **의존성 표** | Linux 행은 best-effort 표기를 유지하되 bash 4.0+ → 3.2+ 로 통일. macOS 행 비고는 *기본 bash 3.2 로 충분* 임을 명시. | 실제 코드와 `CLAUDE.md` "작업 원칙 3" (bash 3.2+ 호환) 과 일치시키기 위함. |
| **`brew install` 명령** | `brew install bash jq git` → `brew install jq git`. bash 설치는 의무가 아님을 주석으로 명시. | 새 사용자가 불필요한 설치를 하지 않도록. |
| **"왜" 문단 위치** | 별도 섹션 신설하지 않고 "💡 이 키트는 무엇인가" 섹션 내부 끝부분에 mini 문단으로 추가. | README 길이 폭증 방지 + 의도 섹션 가까이에 둠으로써 첫 인상에서 "왜" 가 잡힘. |
| **walkthrough 역할** | 본문 "왜" 문단에서 1줄로 언급. FAQ 의 walkthrough 항목은 그대로 유지. | 중복 방지하되 본문 가시성을 한 번 확보. |
| **Plan Accept 보강** | "🚀 시작하기" Step 4 설명에 "가정·범위 검증 게이트" 1줄 추가. 표 / mermaid 그림은 그대로. | 가장 적은 변경으로 의미 부여. |
| **테스트 정책** | docs only — 자동 테스트 없음. 수동 마크다운 렌더링 점검만. | README 변경은 빌드/런타임 영향 없음. |

## 📂 Proposed Changes

### README

#### [MODIFY] `README.md`

**변경 1 — 의존성 명세 정정** (1 commit)

- `## 🖥 대상 환경 및 의존성` 표:
  - Linux 행 비고에서 `bash 4.0+` 표현 제거 (또는 `bash 3.2+` 로 변경).
  - macOS 행 비고는 *기본 bash 3.2 로 동작* 임을 명시 (필요 시).
- 의존성 코드 블록:
  - `brew install bash jq git` → `brew install jq git`.
  - 주석 정리: `macOS 기본 bash 3.2 로 동작 — bash 설치 불필요`.

**변경 2 — 키트 의도/철학 보강** (1 commit)

- "💡 이 키트는 무엇인가" 섹션 끝(표 다음, "📖 핵심 개념" 직전) 에 짧은 mini 섹션 추가. 예시 골자:
  > 🎯 **이 키트는 "이해 부채(understanding debt)" 를 막기 위한 도구다.**
  >
  > 에이전트가 빠르게 코드를 뽑는 시대에 가장 비싼 비용은 *나중에 그 코드를 설명하지 못하는 것* 이다. harness-kit 은 그래서 다음 세 가지를 구조로 강제한다:
  >
  > - **선언형 명세 우선** — `spec.md` 가 *무엇/왜*, `plan.md` / `task.md` 가 *어떻게*. 가정과 범위를 사람이 먼저 박은 뒤에야 에이전트가 코드를 만진다.
  > - **Plan Accept = 가정 검증 게이트** — 단순한 "go" 신호가 아니라, 잘못된 전제 위에 5개 PR 이 쌓이는 사고를 막는 마지막 검문소.
  > - **walkthrough.md** — 구현 내용 나열이 아니라 *예상 못한 발견·디버깅·결정 이유* 만 기록한다. 6개월 뒤 자기 코드를 설명할 수 있게.

- Step 4 (Plan Accept) 설명 보강: 첫 줄 또는 본문 어딘가에 다음 한 줄을 자연스럽게 끼움.
  > 이 단계는 단순 승인이 아니라 *가정·범위·접근법을 명시적으로 검증* 하는 게이트입니다 — 잘못된 전제 위에 코드가 쌓이는 것을 막습니다.

> 위 두 변경은 의도 보강이라는 하나의 논리적 단위이므로 **commit 하나** 로 묶는다 (One Task = One Commit).

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트
없음 (docs only).

### 수동 검증 시나리오

1. README.md 를 GitHub 미리보기 또는 마크다운 뷰어로 열어 표·코드블록·mermaid 가 깨지지 않는지 확인.
2. `grep -n "bash 4" README.md` 결과가 비어 있음을 확인 (정정 누락 방지).
3. 새 mini 문단이 기존 톤과 어색하지 않은지 한 번 통독.
4. `git diff main -- README.md` 가 본 plan 의 범위를 벗어나지 않는지 확인.

## 🔁 Rollback Plan

- 단일 PR / 2개 작업 commit 이므로 PR revert 또는 `git revert` 로 즉시 복원 가능. 데이터/상태 영향 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
