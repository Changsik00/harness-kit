# harness-kit 도그푸딩 회고 v1

> **일시**: 2026-04-10
> **버전**: harness-kit 0.3.0
> **범위**: Phase 4 도그푸딩 첫 세션 — 실효성 진단 및 개선 방향

---

## 1. 경쟁 환경 분석: 우리만의 매력이 있는가?

### 1.1 주요 경쟁자 지형도

| 도구 | 초점 | 강제력 | SDD 프로세스 | 대상 에이전트 | GitHub Stars |
|------|------|--------|-------------|-------------|-------------|
| **harness-kit** | 거버넌스 + SDD | Hook + Constitution | 전체 (Phase/Spec/Plan/Task/Walk) | Claude Code 전용 | 비공개 |
| GitHub Spec Kit | SDD 템플릿 | 소프트 (권고) | Yes (Specify/Plan/Tasks/Implement) | 22+ 에이전트 | ~87K |
| BMAD-METHOD | 애자일 AI 거버넌스 | 에이전트 페르소나 + 품질 게이트 | Yes (애자일 스타일) | 멀티 에이전트 | ~44K |
| AWS Kiro | SDD IDE | IDE 내장 + Agent Hooks | Yes (Req/Design/Tasks) | 자체 IDE | ~3.4K |
| Everything Claude Code | 에이전트 성능 | Skills + Instincts | No | 멀티 에이전트 | ~149K |
| Ruflo (Claude Flow) | 멀티 에이전트 오케스트레이션 | Swarm 조정 | No | Claude Code | ~31K |
| Citadel | 에이전트 라우팅 + 비용 | 라이프사이클 훅 | No | Claude Code | ~486 |
| Chachamaru harness | 자율 개발 사이클 | TS 룰 엔진 (13 규칙) | 부분 (Plan/Work/Review) | Claude Code | ~465 |
| prove_it | 검증 전용 | Hook 기반 테스트 게이트 | No | Claude Code | ~167 |
| AGENTS.md | 크로스 툴 컨텍스트 | 패시브 (권고) | No | 범용 | 표준 |

### 1.2 harness-kit의 고유 포지션

**강점 (다른 도구에 없는 것)**:
- **헌법(Constitution) + 위임 모델**: 사용자 = 최종 결정자, 에이전트 = 위임 실행자라는 권한 구조를 명문화한 도구가 없음
- **Plan Accept 게이트의 하드 강제**: 대부분의 도구는 "권고" 수준. harness-kit은 bash hook으로 실제로 편집을 차단
- **Full SDD 아티팩트 체인**: Phase → Spec → Plan → Task → Walkthrough → PR Description 6단계 전체를 템플릿 + 자동화로 커버
- **한국어 퍼스트**: 모든 산출물이 한국어. 영어권 도구 일색인 시장에서 유일

**약점 (솔직한 진단)**:
- **Claude Code 단독 타겟**: GitHub Spec Kit은 22+ 에이전트, AGENTS.md는 범용 표준. 시장이 크로스 툴로 가고 있음
- **커뮤니티 부재**: 스타 87K(Spec Kit), 44K(BMAD), 149K(ECC) 대비 비공개 상태
- **한국어가 양날의 검**: 글로벌 채택 불가. 국내 Claude Code 사용자 풀도 작음

### 1.3 가장 큰 위협: GitHub Spec Kit

GitHub이 공식 SDD 툴킷을 출시한 상황. 철학은 동일하지만 핵심 차이:
- Spec Kit = **권고형** (에이전트가 잘 따르길 기대)
- harness-kit = **강제형** (hook으로 물리적 차단)

**판단**: "강제 거버넌스"라는 니치는 유효하나, Claude Code 전용이라는 제약이 시장 규모를 심각하게 제한.

---

## 2. macOS 전용 — 더 나은 대안은?

### 2.1 현재 제약

| 항목 | 현황 | 문제 |
|------|------|------|
| Shell | `#!/usr/bin/env bash` + `set -euo pipefail` | Linux 호환 가능하나 미검증 |
| 의존성 | `bash 4.0+`, `jq`, `git` (Homebrew) | Linux에서는 apt/yum으로 대체 가능 |
| 실질적 mac 전용 요소 | 없음 (macOS API 의존 0) | **사실상 크로스 플랫폼 가능** |

### 2.2 진단

스크립트를 분석한 결과 **macOS 전용 API는 단 하나도 사용하지 않는다**. `bash`, `jq`, `git` 모두 Linux에서도 동작. "Mac 전용"은 설계 제약이 아니라 **테스트 범위의 제약**일 뿐.

### 2.3 제안

| 방안 | 노력 | 효과 |
|------|------|------|
| **A. Linux CI 테스트 추가** | 낮음 | GitHub Actions에 ubuntu-latest matrix 추가만으로 크로스 플랫폼 선언 가능 |
| **B. Docker 기반 테스트** | 중간 | `Dockerfile` 하나로 재현 가능한 테스트 환경 |
| **C. Windows/WSL 지원** | 높음 | WSL2 bash 호환이지만 경로 처리 등 이슈. 우선순위 낮음 |

**권장**: **방안 A** — `install.sh` + `doctor.sh` + hook 스크립트를 ubuntu-latest에서 돌리는 것만으로 "macOS + Linux 지원"을 선언할 수 있음. 실질적으로 macOS 고유 코드가 없으므로 노력 대비 효과가 가장 큼.

---

## 3. 토큰 소모 분석

### 3.1 harness-kit이 소비하는 토큰 구조

| 카테고리 | 줄 수 | 추정 토큰 | 로딩 시점 |
|----------|-------|----------|-----------|
| **constitution.md** | 129 | ~1,500 | 매 세션 (CLAUDE.md @import) |
| **agent.md** | 211 | ~2,500 | 매 세션 (CLAUDE.md @import) |
| **align.md** | 57 | ~700 | 매 세션 (CLAUDE.md @import) |
| **CLAUDE.md harness 블록** | ~30 | ~350 | 매 세션 (자동) |
| **템플릿 7종** (필요 시) | 383 | ~4,500 | Spec/Plan 작성 시 |
| **슬래시 커맨드** (호출 시) | 각 40~114 | 500~1,400 | 커맨드 호출 시 |
| **합계 (항상 로드)** | **~427** | **~5,050** | — |
| **합계 (최대, 모든 템플릿)** | **~1,177** | **~14,000** | — |

### 3.2 비용 맥락

- Claude Opus 4.6 입력 토큰: $15/1M tokens
- 매 세션 고정 비용: ~5,050 토큰 × $15/1M = **~$0.076/세션** (약 100원)
- 템플릿 포함 최대: ~14,000 토큰 = **~$0.21/세션** (약 280원)

### 3.3 문제점

1. **constitution + agent.md가 매 세션 ~4,000 토큰**: 내용이 중복되는 부분이 있음 (예: 커밋 형식이 constitution §9.2와 agent.md §6.3에 모두 기술)
2. **대화가 길어지면 누적 context 압박**: 긴 세션에서 compaction이 발생하면 거버넌스 규칙이 잘릴 수 있음
3. **템플릿을 매번 읽어야 함**: constitution §4.4가 "템플릿 안 읽고 산출물 생성 = CRITICAL VIOLATION"으로 규정하므로, 에이전트가 보수적으로 매번 Read를 호출

### 3.4 개선 제안

| 방안 | 절감 효과 | 위험 |
|------|----------|------|
| **A. 거버넌스 문서 통합** | constitution + agent.md 중복 제거 → ~30% 절감 (~1,200 토큰) | 문서 구조의 명확성 저하 |
| **B. 필수/선택 분리** | 핵심 규칙만 CLAUDE.md에, 상세는 필요 시 Read | 에이전트가 상세 규칙을 누락할 가능성 |
| **C. 템플릿 캐싱 전략** | 세션 내 한 번만 읽고, 이후는 메모리에서 참조 | 현재 Claude Code에 캐싱 메커니즘 없음 |
| **D. Compact-safe 요약 블록** | PreCompact hook으로 핵심 규칙 요약 주입 | 구현 복잡도 |

**권장**: **방안 B** — CLAUDE.md의 @import 대신 핵심 규칙 10줄 요약만 인라인하고, `/align` 호출 시에만 전체 거버넌스를 로드하는 2단계 전략. 일상적 작업에서 ~3,000 토큰 절감.

---

## 4. 단일 에이전트의 한계 — Sub-agent 활용 필요성

### 4.1 현재 구조의 문제

```
사용자 ↔ 메인 에이전트 (constitution 로드 상태)
           ↓
     모든 작업을 단일 컨텍스트에서 수행
```

**비판적 사고 결여 패턴**:
- 자기가 작성한 spec을 자기가 검증 → 확인 편향 (confirmation bias)
- 자기가 작성한 코드를 자기가 리뷰 → "내가 쓴 건 맞겠지" 경향
- 긴 세션에서 초기 결정에 고착 (anchoring effect)
- 거버넌스 문서를 작성한 에이전트가 동시에 그 규칙을 따라야 함 → 자기 참조 문제

### 4.2 Sub-agent 활용 시나리오

| 시나리오 | Sub-agent 역할 | 기대 효과 |
|----------|---------------|----------|
| **Spec 리뷰** | 독립 에이전트가 spec.md를 읽고 빈틈/모호함 지적 | 확인 편향 제거 |
| **코드 리뷰** | prove_it 스타일의 독립 검증 에이전트 | 자기 리뷰 편향 제거 |
| **Plan 대안 제시** | "이 Plan의 약점은?" 만 묻는 비판 에이전트 | Devil's advocate 역할 |
| **토큰 절약** | 리서치/탐색을 sub-agent에 위임 | 메인 컨텍스트 보호 |

### 4.3 구현 방안

```
사용자 ↔ 메인 에이전트 (거버넌스 + 실행)
           ├→ [Explore] 코드베이스 탐색 (토큰 격리)
           ├→ [Critic]  Spec/Plan 비판적 리뷰 (독립 시점)
           └→ [Verify]  코드 리뷰 + 테스트 검증 (독립 검증)
```

**구현 수준별 옵션**:

| 수준 | 방법 | 복잡도 |
|------|------|--------|
| **Level 1** | 슬래시 커맨드에 "sub-agent 호출" 지시문 추가 | 낮음 |
| **Level 2** | `/spec-review`, `/code-review` 커맨드 신설 → Agent tool 활용 | 중간 |
| **Level 3** | PostToolUse hook으로 자동 리뷰 에이전트 트리거 | 높음 |

**권장**: **Level 2** — `/spec-review` 와 `/code-review` 슬래시 커맨드를 만들어, 사용자가 원할 때 독립 비판 에이전트를 호출하는 구조. 자동화(Level 3)는 토큰 비용이 과도.

---

## 5. 추가 개선 제안 (에이전트 시점)

### 5.1 즉시 개선 가능 (Quick Wins)

#### a) `sdd` CLI의 자기 진단 강화
현재 `doctor.sh`는 설치 검증 도구. 운영 중 "지금 뭐가 잘못됐는지"를 알려주는 `sdd diagnose` 가 없음.
```
sdd diagnose
→ ⚠️  plan.md 작성 후 72시간 경과, plan-accept 미완료
→ ⚠️  task 3/7 완료, 마지막 커밋 후 2시간 경과
→ ✅  브랜치 정상, 테스트 통과
```

#### b) 세션 간 컨텍스트 연속성
현재 `.claude/state/current.json`에 phase/spec/branch 상태를 저장하지만, **"마지막으로 무엇을 하고 있었는지"** 는 저장하지 않음. `sdd status` 에 `--context` 옵션 추가:
```
sdd status --context
→ 마지막 작업: spec-5-002-token-optimizer, Task 4/6 진행 중
→ 마지막 커밋: feat(spec-5-002): add token counting utility
→ 다음 예상 작업: Task 5 - 캐싱 레이어 구현
```

#### c) Hook 모드 전환의 UX 개선
현재 `HARNESS_HOOK_MODE=warn|block|off` 환경변수로 제어. 이것을 `sdd hooks` 서브커맨드로 감싸면 편의성 향상:
```
sdd hooks status     # 현재 모드 표시
sdd hooks warn       # 경고 모드
sdd hooks block      # 차단 모드
sdd hooks off        # 비활성화
```

### 5.2 중기 개선 (Next Phase)

#### d) AGENTS.md 호환 레이어
AGENTS.md가 Linux Foundation 표준이 되고 있음. harness-kit이 설치 시 `AGENTS.md` 도 함께 생성하면:
- Cursor, Copilot, Codex 등 다른 에이전트도 기본 컨텍스트를 인식
- Claude Code 전용 거버넌스는 CLAUDE.md + hooks에 유지
- 진입 장벽 낮추기: "다른 도구에서도 쓸 수 있다"는 메시지

#### e) 비용 추적 (Cost Tracking)
Citadel처럼 세션별 토큰 소비를 추적하는 기능:
```
sdd cost
→ 현재 세션: ~45K tokens ($0.68)
→ 이번 Spec 누적: ~180K tokens ($2.70)
→ 거버넌스 오버헤드: 5,050 tokens/세션 (11%)
```
SessionStart hook + Stop hook으로 구현 가능. Claude Code의 usage 정보를 파싱해야 함.

#### f) 템플릿 버전 관리
`update.sh` 실행 시 템플릿이 덮어씌워지면 사용자 커스터마이징이 사라짐. 템플릿에 `<!-- user-custom:start -->` 마커를 도입하여 사용자 추가 섹션을 보존하는 구조.

### 5.3 장기 검토 (Backlog)

#### g) 플러그인 시스템 전환
현재 harness-kit은 `install.sh`로 파일을 복사하는 구조. Claude Code의 플러그인/마켓플레이스 시스템이 성숙하면, harness-kit을 플러그인으로 패키징하여 `enabledPlugins`로 설치하는 것이 가능. 설치/업데이트가 극적으로 단순해짐.

#### h) 멀티 에이전트 워크플로
Claude Code의 Agent Teams 기능이 안정화되면, BMAD-METHOD처럼 역할별 에이전트 분리를 고려:
- **Architect Agent**: Spec/Plan 작성 (거버넌스 로드)
- **Developer Agent**: 코드 실행 (Plan만 로드, 가벼움)
- **Reviewer Agent**: 독립 검증 (코드만 로드)

토큰 효율과 비판적 사고 두 마리 토끼를 잡을 수 있으나, 현재 Claude Code의 멀티 에이전트 지원이 충분하지 않음.

---

## 6. 종합 진단 매트릭스

| 항목 | 현재 상태 | 심각도 | 개선 방향 |
|------|----------|--------|----------|
| **경쟁 포지션** | "강제 거버넌스" 니치는 유효하나 시장 규모 제한 | 🟡 중간 | AGENTS.md 호환 + 영어 옵션 |
| **플랫폼 제한** | 실질적으로 크로스 플랫폼이지만 미검증 | 🟢 낮음 | Linux CI 테스트 추가 |
| **토큰 소모** | 세션당 ~5K 고정 + 템플릿 ~9K 추가 | 🟡 중간 | 2단계 로딩 전략 |
| **비판적 사고** | 단일 에이전트 자기검증 = 확인 편향 | 🔴 높음 | Sub-agent 리뷰 커맨드 |
| **세션 연속성** | 상태 파일 있으나 컨텍스트 부족 | 🟡 중간 | `sdd status --context` |
| **설치/업데이트** | install.sh 복사 방식, 템플릿 커스텀 손실 | 🟡 중간 | 마커 기반 보존 + 향후 플러그인 |

---

## 7. 우선순위 제안

### 즉시 (이번 도그푸딩 내)
1. 거버넌스 문서 중복 제거 → 토큰 ~30% 절감
2. `/spec-review` sub-agent 커맨드 → 비판적 사고 보완
3. `sdd status --context` → 세션 연속성

### 단기 (다음 Phase)
4. Linux CI 테스트 → 크로스 플랫폼 선언
5. `sdd diagnose` → 운영 자기진단
6. AGENTS.md 호환 레이어

### 중기 (로드맵)
7. 비용 추적 기능
8. 템플릿 사용자 커스텀 보존
9. 플러그인 시스템 전환 검토

---

*이 문서는 harness-kit 도그푸딩 Phase 4 첫 세션에서 FF 모드로 작성되었습니다.*
