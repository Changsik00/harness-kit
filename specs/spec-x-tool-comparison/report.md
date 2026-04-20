# harness-kit 유사 툴 비교 리서치

> 작성일: 2026-04-20

---

## 1. 비교 매트릭스

| 기능 | harness-kit | Husky | Lefthook | pre-commit | lint-staged | commitlint | Cursor Rules | Copilot Instructions |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 설치 자동화 | ✅ | 🔶 | 🔶 | 🔶 | 🔶 | 🔶 | ❌ | ❌ |
| 프로젝트 타입 감지 | 🔶 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Pre-commit 자동화 | ✅ | ✅ | ✅ | ✅ | ✅ | 🔶 | ❌ | ❌ |
| 커밋 컨벤션 강제 | ✅ | 🔶 | 🔶 | 🔶 | ❌ | ✅ | ❌ | ❌ |
| AI 컨텍스트 제공 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| SDD 워크플로 강제 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 거버넌스 문서화 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | 🔶 | 🔶 |
| 상태 추적 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

**범례**: ✅ 완전 지원 / 🔶 부분 지원 / ❌ 미지원

---

## 2. 툴별 핵심 특징 요약

### Husky
Node.js/npm 프로젝트 전용 Git hooks 매니저. v9 기준 2kB 무의존, 13개 클라이언트 훅 지원, `core.hooksPath` 활용. 단 훅 스크립트는 개발자가 직접 작성해야 하며 JS 생태계에 묶여 있다. 1.5M+ GitHub 프로젝트에서 사용 중.

### Lefthook
Go 바이너리 기반 언어-무관 Git hooks 매니저. `lefthook.yml` 단일 파일로 선언적 설정, 병렬 실행이 기본값이라 대형 모노레포에서도 빠르다. `stage_fixed: true`로 포맷터 적용 후 자동 `git add` 가능. Docker 통합, `lefthook-local.yml` 개인 오버라이드, 원격 설정 참조 지원.

### pre-commit (Python)
언어 무관 훅 프레임워크. PyPI 훅 레지스트리를 통해 수백 개의 공용 훅을 재사용 가능. `--fail-fast` 옵션 지원. Python ≥3.10 필요. Rust 기반 대체제 prek가 10배 빠른 속도를 내세우며 등장.

### lint-staged
스테이징된 파일에만 linter/포맷터를 실행하는 npm 패키지. TypeScript 완전 지원, `tinyexec` 기반 프로세스 관리, 자동 git stash로 작업 보호, 모노레포에서 가장 가까운 설정 파일 자동 탐색. Husky/Lefthook과 함께 쓰는 것이 일반적.

### commitlint
Conventional Commits 표준에 따른 커밋 메시지 검증 도구. npm 기반 공유 설정(`@commitlint/config-conventional`), TypeScript 설정 파일 지원, CI/CD 파이프라인 직접 통합 가능.

### Cursor Rules (.cursor/index.mdc)
Cursor IDE AI에게 프로젝트 규칙을 전달하는 인스트럭션 파일. `.cursorrules`는 레거시, 현재는 `.cursor/index.mdc` 권장. Agent Mode에서 자율 실행 가능. 2,000단어 이내 유지 권장, 경로별 규칙 분리 지원. 코드 강제는 없고 AI 안내 전용.

### GitHub Copilot Instructions (copilot-instructions.md)
`.github/copilot-instructions.md`로 저장소 전역 규칙 정의. 경로별 `.github/instructions/*.instructions.md` 다중 파일 지원, YAML frontmatter로 glob 범위 지정. VS Code, JetBrains, GitHub.com 등 멀티 플랫폼 적용. 2페이지 이내 제한.

---

## 3. harness-kit Gap 분석

> harness-kit이 현재 커버하지 못하는 영역

### Gap 1: 다국어/다프레임워크 훅 레지스트리 부재
- **현상**: harness-kit의 pre-commit 훅들은 직접 작성된 bash 스크립트이며, 외부 훅 레지스트리나 커뮤니티 훅 재사용 메커니즘이 없다.
- **타 툴**: pre-commit은 수백 개의 공개 훅(`detect-secrets`, `hadolint`, `shellcheck` 등)을 설정 파일 한 줄로 가져올 수 있다. Lefthook도 원격 설정 참조를 지원.
- **구현 난이도**: 중간
- **사용자 가치**: 중간 (현재 NestJS 단일 스택이라 즉시 필요성은 낮으나 확장 시 높아짐)

### Gap 2: 병렬 훅 실행 미지원
- **현상**: hooks/들은 순차 실행된다. check-secrets, check-diff-size, check-test-passed 등 독립적인 훅들이 모두 직렬로 수행된다.
- **타 툴**: Lefthook은 병렬 실행을 기본값으로 제공. lint-staged도 독립 태스크를 병렬 처리.
- **구현 난이도**: 중간
- **사용자 가치**: 중간 (프로젝트 규모가 커질수록 체감 효과 증가)

### Gap 3: AI 인스트럭션 포맷 상호운용성 없음
- **현상**: harness-kit의 거버넌스 문서(constitution.md, agent.md)는 Claude Code 전용 포맷이다. Cursor나 Copilot을 같은 프로젝트에서 사용하는 팀은 별도 설정이 필요하다.
- **타 툴**: Cursor Rules와 Copilot Instructions는 각각 독립적인 AI 인스트럭션 표준을 가짐. Markdown 기반이라 변환은 쉽지만 자동화가 없다.
- **구현 난이도**: 낮음
- **사용자 가치**: 높음 (팀 내 IDE 다양성 현실 반영, 거버넌스 일관성 유지)

### Gap 4: staged 파일 기반 선택적 linting 없음
- **현상**: harness-kit의 pre-commit 훅은 스테이징된 파일만 선택적으로 linting하는 방식이 아니라 전체 검사 또는 단순 존재 확인 방식이다.
- **타 툴**: lint-staged는 스테이징된 파일에만 ESLint/Prettier를 실행해 훅 실행 시간을 최소화하고, 포맷 변경 사항을 자동 re-stage한다.
- **구현 난이도**: 낮음 (`git diff --cached --name-only` 기반으로 직접 구현 가능)
- **사용자 가치**: 높음 (대형 프로젝트에서 pre-commit 속도에 직접 영향)

### Gap 5: 프로젝트 타입 자동 감지 및 훅 구성 미지원
- **현상**: `install.sh` 실행 시 프로젝트 스택 구분 없이 동일한 훅 세트를 설치한다. 스택별 맞춤 훅 구성이 수동이다.
- **타 툴**: `package.json` / `go.mod` / `pyproject.toml` 감지 후 적합한 훅/linter 제안은 pre-commit이나 MegaLinter가 부분적으로 제공.
- **구현 난이도**: 중간
- **사용자 가치**: 높음 (NestJS 이후 다른 스택 확장 시 온보딩 마찰 제거)

---

## 4. harness-kit 고유 강점

> 타 툴이 제공하지 않는 harness-kit만의 차별점

1. **AI 행동을 코드 수준에서 강제하는 Plan-Accept Gate**: `planAccepted` 상태를 `PreToolUse` 훅으로 실시간 검사하여, plan 미승인 상태에서 AI가 production 코드를 편집하는 것을 물리적으로 차단한다. 어떤 기존 툴도 제공하지 않는 고유 기능.

2. **완전한 SDD 라이프사이클 관리**: Phase → Spec → Plan → Task → Walkthrough → PR로 이어지는 전체 워크플로를 단일 툴킷으로 제공한다. 설계 산출물 생성·검증·아카이브까지 포함한 종단간 워크플로.

3. **AI 에이전트 특화 거버넌스 문서 체계**: constitution.md와 agent.md는 AI의 행동 경계를 계약으로 정의한다. Cursor Rules가 "AI에게 힌트를 주는" 수준이라면, harness-kit은 "AI의 행동을 프로토콜로 제약"하는 수준.

4. **상태 기반 맥락 공유**: `.claude/state/current.json`으로 현재 활성 Phase/Spec/planAccepted를 영속화하여 AI와 사람 모두가 세션 간 맥락을 유지.

5. **슬래시 커맨드와 훅의 통합 거버넌스 루프**: `/hk-align` → `/hk-plan-accept` → 코드 작업 → `/hk-ship` → `/hk-pr-gh`로 이어지는 커맨드 체인이 Git hooks과 맞물려 작동하는 닫힌 루프 설계.

---

## 5. 다음 Phase 후보

| 우선순위 | 제목 | 근거 | 예상 규모 |
|---|---|---|---|
| 1 | staged 파일 기반 선택적 linting 통합 | Gap 4: bash로 구현 가능, NestJS 타깃에서 즉시 검증 가능, 사용자 가치 높음 | 소 |
| 2 | AI 인스트럭션 멀티포맷 export | Gap 3: constitution.md → .cursorrules / copilot-instructions.md 자동 생성. 구현 단순, 가치 높음 | 소 |
| 3 | 프로젝트 타입 감지 및 프로필 기반 설치 | Gap 5: harness-kit의 다스택 확장을 위한 기반 인프라. doctor.sh 감지 로직 확장 | 중 |
| 4 | 훅 레지스트리 및 커뮤니티 훅 통합 | Gap 1: pre-commit 방식의 외부 훅 URL 참조. 생태계 확장의 기반 | 중 |
| 5 | 병렬 훅 실행 엔진 | Gap 2: 독립 훅 병렬 실행으로 대형 프로젝트 대응. bash `wait`/`&` 패턴 또는 Lefthook 위임 | 중 |

---

## 6. 결론 및 권장사항

**포지셔닝**: harness-kit은 기존 툴들이 다루지 않는 영역 — "AI 에이전트의 행동을 설계 주도 개발 원칙에 따라 제약하는 거버넌스 레이어" — 을 점유하고 있다. Husky/Lefthook/pre-commit이 사람의 Git 작업을 검증한다면, harness-kit은 AI의 코드 편집 행위 자체를 검증한다. 이 포지셔닝은 AI 코딩 에이전트 확산과 함께 점점 중요해지며 경쟁 툴이 없다.

**단기 권장 (다음 1~2 Phase)**:
- Gap 4(staged linting)와 Gap 3(멀티포맷 export)은 규모가 작고 즉시 사용자 가치가 높다. NestJS 도그푸딩에서 검증 권장.
- Gap 5(프로젝트 타입 감지)는 harness-kit이 NestJS 단일 타깃을 벗어나 범용 툴로 성장하기 위한 전제 조건이다.

**장기 방향성**:
- Cursor Rules / Copilot Instructions와 대립이 아닌 협력 관계로 포지셔닝. harness-kit이 거버넌스 원본(constitution.md)을 관리하고, 다른 AI IDE용 포맷은 파생 산출물로 자동 생성하는 "거버넌스 단일 진실 원천(SSOT)" 전략.
- AI agent governance는 GitHub Copilot Enterprise도 착수한 영역. harness-kit의 오픈소스 특성과 Claude Code 특화 깊이가 충분한 차별화 요소이며, 훅 레지스트리 생태계 구축이 장기 해자가 될 수 있다.
