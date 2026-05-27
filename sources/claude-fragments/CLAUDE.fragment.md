## 에이전트 운영 규약 (harness-kit)

이 프로젝트는 harness-kit 의 거버넌스를 따릅니다.
SDD 작업 시작 시 `/hk-align` 슬래시 커맨드를 호출하면 전체 거버넌스가 로드됩니다.

**핵심 규칙 요약**:
- Plan Accept 전에는 PLANNING 모드 (코드 편집 금지)
- One Task = One Commit
- Phase ID: `phase-{N}` (예: `phase-01`) — 디렉토리는 `backlog/phase-{N}/`
- Spec ID:  `spec-{phaseN}-{seq}` (예: `spec-01-01`) — 디렉토리는 `specs/spec-{phaseN}-{seq}-{slug}/`
- Branch: `spec-{phaseN}-{seq}-{slug}` (브랜치 = spec 디렉토리 이름, `feature/` prefix 없음)
- Commit subject: `<type>(spec-{phaseN}-{seq}): <설명>` (모두 소문자)
- 모든 산출물은 한국어
- main 브랜치 직접 작업 금지
- **선택지 제시 시 반드시 권장안 포함** (agent.md §8.5)

자세한 내용은 `.harness-kit/agent/constitution.md` 와 `.harness-kit/agent/agent.md` 참조.

## 검증된 패턴 & 안티패턴 (phase-08~18 distilled)

**❌ 안티패턴 (피할 것):**
- **ceremony-over-work**: 1-2 commit 작업에 full SDD ceremony 금지. → FF (사용자 명시 승인) 또는 spec-x demote.
- **silent-inter-spec-drift**: 다음 spec 시작 전 직전 spec 실제 변경 영향 검토 의무. phase plan은 draft — 재검증 필수 (ADR-002).

**✅ 굿 패턴:**
- **bundle-before-spec-x**: 같은 테마 소규모 항목 3개+ → spec-x 여러 개 대신 하나로 묶기. phase 응집도 + ceremony 절감.
- **phase-FF**: 1-2 commit, 단일 파일, 가역적 변경 → spec 없이 phase base 브랜치 직접 커밋 (사용자 명시 승인 필요).

---

## 선택지 제시 규약 (Choice Presentation Protocol)

agent.md §8.5 의 강제 규칙입니다. 본 프로젝트의 에이전트는 **사용자에게 선택지를 제시하는 모든 순간** 반드시 권장안을 포함해야 합니다.

### 규칙

사용자에게 2개 이상의 선택지를 제시할 때마다 다음 형식을 따릅니다:

```
[상황 / 맥락]
<어떤 의사결정이 필요한지 1-2줄>

[선택지]
1. <옵션 A — 간결한 요약>
2. <옵션 B — 간결한 요약>
3. <옵션 C — 간결한 요약>  ← 해당 시

[권장]
<옵션 번호> — <이전 패턴 / 리스크 / 프로젝트 제약 기반의 간단한 근거>

[의사결정 요청]
<사용자에게 선택을 요청하는 명확한 질문 하나>
```

### 적용 범위

이 규칙은 다음 **모든 상황**에 적용됩니다:

- Alignment Phase 의 작업 모드 선택 (agent.md §3)
- Hard Stop for Review 이후 Plan Accept 선택 (agent.md §4.4)
- **Task 분해 제안** (Strict Loop 중간에 복합 task 를 쪼갤 때)
- **구현 방식 A/B/C 선택** (기술 방향 분기)
- **예상 못한 edge case 처리 방향 결정**
- Strict Loop 중 Ad-hoc 으로 발생하는 모든 선택지
- `/hk-phase-ship` 의 Go/No-Go 결정

### 자가 점검

선택지 메시지를 보내기 **전에** 에이전트는 반드시 내부적으로 확인합니다:

1. 서로 다른 2개 이상의 옵션이 있는가? → 그렇다면 [권장] 필수
2. 권장안에 구체적 이유(이전 패턴 / 리스크 / 제약)가 붙어있는가?
3. 의사결정 질문이 명확한가? (하나의 질문, 모호하지 않음)

셋 중 하나라도 실패하면 보내기 전에 수정합니다.

### 예외

**단순 Yes/No 확인** 질문은 기본 방향이 명시되어 있으면 [권장] 생략 가능합니다.

예: "Plan 을 이대로 수락하시겠습니까? [Y/n]" — Y 가 기본이므로 [권장] 생략 OK

### 왜 이 규칙이 필요한가

- 사용자는 모바일 (Telegram 알림 / Remote Control) 에서 의사결정을 내리는 경우가 많습니다.
- 긴 옵션을 모두 읽을 시간이 없으며, [권장] + 근거만 보고 빠르게 판단합니다.
- "권장안 누락" 은 반복적으로 발생하는 실수이므로, 에이전트가 **메시지 전송 전 자가 점검** 해야 합니다.

---

## Telegram 의사결정 알림 프로토콜

본 프로젝트는 SDD 워크플로우의 주요 **의사결정 지점(Decision Gate)** 에서 Telegram으로 알림을 발송합니다. 사용자가 PC 앞에 없을 때도 진행 상황을 파악하고 원격 판단을 내릴 수 있도록 지원합니다.

알림은 **두 가지 계층**으로 구성됩니다:

1. **자동 감지 알림 (Hook 기반)** — Claude Code가 사용자 입력을 대기하는 순간 자동 발화
2. **에이전트 발송 알림 (명시적 호출)** — 공식 Decision Gate에서 에이전트가 직접 호출

### 전제 조건

프로젝트 루트에 `.env.telegram` 파일이 존재하며 다음 변수가 설정되어 있어야 합니다:

```
TELEGRAM_BOT_TOKEN=<봇 토큰>
TELEGRAM_CHAT_ID=<사용자 chat_id>
```

이 파일이 없으면 알림은 **silent skip** (에러 없이 무시)됩니다. SDD 워크플로우 자체는 영향받지 않습니다.

### 계층 1: 자동 감지 알림 (Hook 기반)

`settings.json` 의 `Notification` 및 `Stop` hook 에 `notify-on-input-wait.sh` 가 등록되어 있습니다. 이 hook 은 **에이전트의 판단 없이 시스템 레벨에서 자동 발화**하므로 다음 상황을 모두 커버합니다:

- 에이전트가 공식 Gate 가 아닌 곳에서 사용자 선택지를 제시할 때 (예: "Task 분해할까요? 1/2/3")
- 에이전트가 60초 이상 사용자 응답을 대기할 때
- 권한 승인 다이얼로그가 뜨고 사용자가 자리를 비운 경우
- 세션 턴이 종료되고 사용자 입력 대기 상태로 진입할 때

메시지에는 **최근 Claude 발화 일부 (약 500자)** 가 포함되어 사용자가 Telegram 만 보고도 상황을 파악할 수 있습니다. 따라서 위의 "선택지 제시 규약" 에 따라 [권장] 이 메시지에 포함되어 있어야 사용자가 Telegram 만 보고도 판단할 수 있습니다.

**에이전트는 이 알림에 대해 아무것도 하지 않아도 됩니다.** 시스템이 자동으로 처리합니다.

### 계층 2: 에이전트 발송 알림 (명시적 Decision Gate)

공식 Gate 에서는 자동 알림보다 **구조화된 메시지** 가 유용합니다. 에이전트는 다음 단일 Bash 명령을 실행합니다 (agent.md §6.4 단일 명령 원칙 준수):

```bash
bash .harness-kit/bin/notify-telegram.sh "<메시지>" <level>
```

레벨: `info | align | plan | accept | stop | ship | merge | phase`

### 의사결정 지점별 알림 프로토콜

다음 지점들에서 알림을 발송합니다. 알림은 **보조 채널**이지 승인 채널이 아닙니다 — 최종 의사결정은 여전히 PC/CLI에서 이루어집니다.

#### 1. `/hk-align` 직후 — 세션 상태 보고 (align)

상태 요약을 사용자에게 보고한 직후, 동일 내용의 축약판을 Telegram에도 발송:

```bash
bash .harness-kit/bin/notify-telegram.sh "세션 시작
Phase: <phase-id 또는 없음>
Spec: <spec-id 또는 없음>
Branch: <current-branch>
Plan Accept: <yes/no>" align
```

⚠ 미완 항목이 있으면 메시지에 포함.

#### 2. Spec/Plan/Task 작성 완료 — Plan Accept 게이트 (plan) 【필수】

agent.md §4.4 Hard Stop for Review 시점. spec.md/plan.md/task.md 작성 완료 보고와 동시에:

```bash
bash .harness-kit/bin/notify-telegram.sh "<spec-id> 계획 작성 완료
Spec: specs/<spec-dir>/spec.md
Plan: specs/<spec-dir>/plan.md
Task: specs/<spec-dir>/task.md (총 <N>개 task)

선택지:
1. Plan Accept (/hk-plan-accept) — 즉시 실행 단계로 진입
2. Critique (/hk-spec-critique) — 요구사항 비평 (Opus, 선택)

권장: 1번 (spec/plan 품질에 확신이 있는 경우 기본 경로)
      2번을 선택할 경우 비평 후 plan 재작성 가능

⚠ 승인 전까지 코드 편집 금지" plan
```

#### 3. `/hk-plan-accept` 실행 — Execution 모드 진입 (accept)

코드 편집이 시작되는 중요한 전환점:

```bash
bash .harness-kit/bin/notify-telegram.sh "<spec-id> Plan Accepted
Strict Loop 실행을 시작합니다.
첫 Task: <첫 번째 미완 task 제목>" accept
```

#### 4. Hard Stop — 중단 상황 (stop) 【필수】

agent.md §7 Deviation & Hard Stop 시점. 사용자 개입이 반드시 필요:

```bash
bash .harness-kit/bin/notify-telegram.sh "<spec-id> HARD STOP
사유: <plan 이탈 / 테스트 실패 / hook 차단 / main 커밋 시도 등>
상세: <구체적 메시지 1-2줄>
Branch: <current-branch>
재정렬이 필요합니다." stop
```

#### 5. Ad-hoc 선택지 제시 — 중간 의사결정 (stop) 【필수】

Strict Loop 진행 중 plan 에 없는 선택지가 발생해 사용자 의사결정이 필요한 경우. 예: Task 분해 제안, 구현 방식 A/B 선택, 예상 못한 edge case 처리 방향.

이 경우 **계층 1 자동 감지 알림이 먼저 발동**하지만, 에이전트는 선택지 정보를 더 구체적으로 전달하기 위해 다음 명령을 **추가로** 실행합니다. 본 메시지는 반드시 "선택지 제시 규약" (위 섹션 참조) 을 따라 [권장] 을 포함합니다:

```bash
bash .harness-kit/bin/notify-telegram.sh "<spec-id> 의사결정 요청
상황: <1-2줄 요약>

선택지:
1. <옵션 1 요약>
2. <옵션 2 요약>
3. <옵션 3 요약>

권장: <N번> — <근거: 이전 패턴 / 리스크 / 제약>" stop
```

**판단 기준**: 사용자에게 2개 이상의 선택지를 제시하거나, 기술 방향이 갈리는 결정이면 명시적 알림을 발송합니다. 단순 Yes/No 확인은 계층 1 자동 알림으로 충분합니다.

**예시 (Task 분해 제안)**:

```bash
bash .harness-kit/bin/notify-telegram.sh "spec-8-001 의사결정 요청
상황: Task 13 을 RollbackService + MigrationCliService 로 분해 제안

선택지:
1. 분해 (13A → 13B 순차) — 이전 task 7/8/11 패턴과 일관
2. 단일 Task 13 유지 — 한 commit 에 둘 다
3. 순서 변경 — 13B 먼저

권장: 1번 — 두 서비스가 구현·테스트·의존성이 독립적이고,
           이전 복합 task 모두 분해 후 진행한 패턴을 유지" stop
```

#### 6. `/hk-ship` 완료 — PR 생성 (ship) 【필수】

```bash
bash .harness-kit/bin/notify-telegram.sh "<spec-id> PR 생성 완료
Title: <pr title>
Base: <PR_BASE>
URL: <pr-url>
머지 대기 중..." ship
```

#### 7. Post-Merge 진입 — 다음 Spec 제안 (merge)

agent.md §6.3.1 Post-Merge Protocol. 사용자가 "머지 완료" 신호를 주면:

```bash
bash .harness-kit/bin/notify-telegram.sh "<spec-id> Merged
NEXT: <다음 backlog spec 또는 'Phase 완료 준비'>
제안: <sdd spec new <slug> 또는 /hk-phase-ship>" merge
```

#### 8. `/hk-phase-ship` Go/No-Go — 최종 승인 요청 (phase) 【필수】

Phase 단위 main merge는 특히 중요한 의사결정. 본 메시지는 "선택지 제시 규약" 에 따라 [권장] 을 포함합니다:

```bash
bash .harness-kit/bin/notify-telegram.sh "<phase-id> Phase Ship Ready
성공 기준: <N>/<M> PASS
통합 테스트: <N>/<M> PASS
Spec 완료: <N>/<N> Merged
<FAIL 항목이 있으면 상세>

선택지:
1. Go — main 으로 merge 진행
2. No-Go — 보류하고 추가 작업

권장: <1번 또는 2번> — <FAIL 여부 및 리스크 기반 근거>" phase
```

### Strict Loop 중 Task 완료 알림 정책

매 task마다 알림은 소음이 되므로 **기본 비활성**. 다음 경우에만 발송:

- **첫 task 완료 시** (Execution 모드 정상 진입 확인)
- **마지막 task 완료 시** (`/hk-ship` 직전)

중간 task 알림은 사용자가 명시적으로 요청할 때만 활성화합니다.

### 중복 알림 방지 정책

계층 1 자동 알림과 계층 2 명시적 알림이 **동일 사건에 대해 양쪽 모두 발화**할 수 있습니다 (예: Plan Accept 게이트). 이는 **의도된 동작**이며 문제가 아닙니다:

- 계층 1 은 "Claude 가 입력 대기 중" 이라는 신호 + 최근 대화 컨텍스트
- 계층 2 는 Gate 에 최적화된 구조화 메시지 ([권장] + 다음 단계 안내 포함)

중복이 불편하면 `.env.telegram` 에 `HARNESS_NOTIFY_DEDUP=1` 를 추가해 계층 1 을 비활성화할 수 있습니다 (향후 지원 예정).

### 알림 정책

| 원칙 | 설명 |
|------|------|
| **보조 채널** | 알림은 정보 전달용. Telegram 답장으로 명령을 수행하지 않음. |
| **무음 실패** | `.env.telegram` 없거나 네트워크 실패 시 SDD 흐름은 계속 진행. 알림 실패로 작업 중단 금지. |
| **한국어** | 메시지 본문은 한국어 (constitution §5.4). 레이블(Phase, Spec, Task 등)과 기술 용어는 영어 허용. |
| **간결성** | 각 알림은 10줄 이내. 상세 내용은 본 세션에서 확인. |
| **민감정보 금지** | 토큰, 비밀번호, 환경변수 값 등을 메시지에 포함하지 않음. |
| **단일 명령** | `notify-telegram.sh` 호출은 한 번에 하나씩. 체이닝 금지 (agent.md §6.4). |
| **권장안 필수** | 선택지 2개 이상이면 [권장] 반드시 포함 (agent.md §8.5). |

### 알림 비활성화

일시적으로 끄려면 `.env.telegram` 파일을 이동:

```bash
mv .env.telegram .env.telegram.disabled
```

다시 활성화는 파일을 원래 이름으로 되돌리면 됩니다.
