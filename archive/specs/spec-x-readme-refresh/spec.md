# spec-x-readme-refresh: README 최신화 및 키트 의도/철학 보강

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-readme-refresh` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-readme-refresh` |
| **상태** | Planning |
| **타입** | Docs |
| **Integration Test Required** | no |
| **작성일** | 2026-05-15 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- README.md 는 0.9.1 시점의 명령 셋·워크플로·디렉토리 구조 대부분을 반영하고 있다.
- "💡 이 키트는 무엇인가" / "📖 핵심 개념" 섹션이 *무엇이 있는가* 를 잘 설명한다.
- FAQ 에 walkthrough 의 의미 있는 작성 원칙이 1줄 정도 정리되어 있다.

### 문제점

1. **의존성 표기가 outdated** — Linux 행에 `bash 4.0+`, macOS 코드 블록에 `brew install bash jq git` 이 남아 있어 "macOS 기본 bash 3.2 호환" 이라는 실제 코드 상태(`CLAUDE.md` 의 "대상 환경 (고정)" 표·작업 원칙 3) 와 불일치한다. 새 사용자가 불필요하게 bash 를 brew 로 깔도록 유도한다.
2. **키트의 "왜" 가 약하다** — 외부 진단(아젠틱 코딩의 8문제: 가정 전파 / 추상화 비대화 / 죽은 코드 축적 / 아부성 동의 / 이해 부채 …) 에 본 키트가 *우연이 아니라 구조적으로 대응* 하고 있다는 점이 README 의 기능 나열 톤에 묻혀 있다. 키트를 처음 보는 사람이 "왜 Plan Accept 가 필요하지?" 의 동기를 곧장 잡지 못한다.
3. **walkthrough 의 의도가 본문에서 약하다** — FAQ 에는 있으나, 키트가 *이해 부채* 라는 안티패턴을 막기 위해 walkthrough.md 라는 별도 파일을 두었다는 설계 의도가 본문 어디에서도 명시되지 않는다.
4. **Plan Accept 의 정체성이 약하다** — Step 4 설명이 "승인" 절차로만 묘사된다. 실제로는 *가정·범위·접근 방식을 명시적으로 검증하는 게이트* 라는 의미가 빠져 있다.

### 해결 방안 (요약)

사실 정정(의존성 명세) + 의도/철학 보강(짧은 "왜" 문단) + 본문 워크플로 1줄 보강. 새 섹션을 신설하지 않고 기존 섹션 안에서 마무리한다. 새 hook·명령·템플릿 추가는 하지 않는다 (사용자 결정: "추가 구현은 불필요").

## 🎯 요구사항

### Functional Requirements

1. README 의 의존성 표기에서 `bash 4.0+` 강제 표현을 제거하고 `bash 3.2+` 로 통일한다. `brew install` 안내에서 `bash` 를 제외한다.
2. "💡 이 키트는 무엇인가" 섹션 끝(또는 "📖 핵심 개념" 으로 이어지기 직전) 에 1~2 문단 분량의 "왜 이 구조인가" 를 추가한다. 다음 세 가지를 자연스러운 산문으로 엮는다:
   - **이해 부채(understanding debt) 방지** — 코드를 작성하기 전에 의도를 문서로 박는 이유.
   - **선언형 명세** — spec.md 가 *무엇/왜*, plan.md/task.md 가 *어떻게* 라는 분리.
   - **walkthrough.md 의 역할** — 구현 나열이 아니라 결정/디버깅/예외의 기록.
3. "🚀 시작하기" Step 4 (Plan Accept) 설명에 "이 단계는 가정·범위 검증 게이트" 라는 1줄을 보강한다.

### Non-Functional Requirements

1. 기존 README 의 한국어 톤과 표·이모지 스타일을 보존한다.
2. 새 섹션 신설을 지양하고 기존 섹션 안에 보강한다 (문서 길이 폭증 방지).
3. 마크다운 렌더링이 깨지지 않는다 (표·코드블록·mermaid 유지).
4. 본 변경은 docs only — 코드·hook·템플릿·명령 변경 없음.

## 🚫 Out of Scope

- 새 hook / 명령 / 템플릿 / skill 추가 (사용자 결정: 4개 항목은 이미 구조적으로 대응됨)
- spec.md / plan.md 템플릿에 "암묵적 가정" / "기각한 단순 대안" 등 신규 섹션 추가
- critique 강제화 등 거버넌스 변경
- 영문화·다국어 (1차 한국어 유지)
- 다이어그램 신규 작성 (기존 mermaid 그대로)

## ✅ Definition of Done

- [ ] README.md 의 의존성 명세·"왜" 문단·Plan Accept 설명 3가지 변경 반영
- [ ] 마크다운 렌더링 시각 점검 통과
- [ ] `walkthrough.md` / `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-readme-refresh` 브랜치 push 완료, PR 생성
- [ ] merge 후 `sdd specx done readme-refresh` 로 queue.md 갱신
