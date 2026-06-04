# Implementation Plan: spec-20-03

## 📋 Branch Strategy

- 브랜치: `spec-20-03-ceremony-split` (이미 생성됨 — phase-20 base 모드 작업 브랜치)
- Base: `phase-20-director-mode`
- 첫 task 는 브랜치 생성이 아니라 테스트 작성부터 시작 (브랜치 이미 체크아웃 상태)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **§6.1 위임 단락 배치**: §6.1 말미(7번 항목 뒤)에 "Director Mode delegation" 블록을 추가한다. 별도 §6.1.1 하위 섹션 또는 인라인 단락 — 인라인 단락 채택(헤더 없이 하나의 Note 블록). 디렉터 판단 우선.
> - [ ] **단어 예산 확정**: 현재 7507w. 추가 목표 ≤120w → 합계 ≤7627w. 실제 작성 후 측정 필수.

> [!WARNING]
> - [ ] **이중 미러 순서**: sources/governance/agent.md 수정 → .harness-kit/agent/agent.md 를 동일 내용으로 덮어씀. 순서 어긋나면 parity 테스트 실패. 항상 sources 를 원본으로 삼고 mirror 는 복사.
> - [ ] **단어 예산 초과 위험**: 120w 초과 시 §6.6 또는 §6.7 일부를 prune 해야 하며 디렉터 판단 필요 → 구현 전 초안 단어 수 측정 후 보고.

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

분업 계약은 두 군데 최소 삽입으로 박는다:

```
agent.md §6.1 (Strict Loop Rule)
  └─ 기존 7단계 말미에 "Director Mode delegation" 블록 추가
       - 위임 조건: directorMode 활성 + 작업이 bundled(3+ 단계)
       - 브리핑 범위 명시: 타깃 파일, 동작, 테스트 명령, 커밋 형식, 산출물 포함
       - 불변식 3가지 인라인 나열
       - 예상 단어 수: ~90-110w

agent.md §6.8 (Director Mode Protocol)
  └─ 규칙6 다음에 참조 줄 1행 추가
       - "SDD ceremony task delegation → §6.1 Director Mode delegation block."
       - 예상 단어 수: ~10w
```

### 주요 결정

| 결정 항목 | 채택 방향 | 이유 |
|:---:|:---|:---|
| **§6.1 삽입 위치** | 7번 항목(Auto-proceed) 뒤 별도 단락 | §6.1 의 번호 목록을 깨지 않고 확장 — 기존 루프 단계와 논리적으로 구분 |
| **§6.8 참조 방식** | 한 줄 cross-ref (`→ §6.1 delegation`) | 중복 서술 최소화 — §6.8 은 "모드 진입 시" 총괄, §6.1 은 "실행 루프 시" 세부 |
| **테스트 전략** | 기존 test-director-protocol.sh 확장 | 신규 파일 불필요, 기존 구조(pass/fail/check 함수) 재사용 |
| **미러 동기화** | T3 에서 cp 명령으로 sources → .harness-kit 복사 | 수동 편집 대신 복사 — parity 100% 보장 |
| **단어 예산 검증** | T3 완료 후 테스트로 자동 측정 | test-director-protocol.sh Check 4 가 이미 wc -w 로 측정 |

### 📑 ADR 후보

- [ ] 없음 — ADR-006 에 이미 ceremony 분업 원칙 흡수됨.

## 📂 Proposed Changes

### [거버넌스 문서]

#### [MODIFY] `sources/governance/agent.md`

§6.1 말미에 Director Mode delegation 단락 추가:

```text
**Director Mode delegation** (active when `directorMode` is enabled):
When the Strict Loop runs under director mode, the director MUST delegate
task execution to a Sonnet worker sub-agent via a scoped brief (target files,
expected behaviour, test command, commit format). The worker's commit scope
MUST include planning artifacts (spec/plan/task files). Three invariants apply:
① Plan Accept and Ship gates are NOT delegated — held by director + user.
② Worker commit scope MUST include spec/plan/task artifact files.
③ Verification follows §6.8 rule 4 — action/distillation only, no transcript re-ingestion.
```

§6.8 에 참조 줄 1행 추가 (규칙6 다음):

```text
**SDD ceremony task delegation**: For delegating Strict Loop execution to a worker, → §6.1 Director Mode delegation block.
```

#### [MODIFY] `.harness-kit/agent/agent.md`

sources/governance/agent.md 와 동일 내용으로 미러 동기화 (cp 명령 사용).

### [테스트]

#### [MODIFY] `tests/test-director-protocol.sh`

Check 5(신규): ceremony-split 핵심 용어 grep 추가:
- `"Director Mode delegation"` — §6.1 위임 단락 존재 확인
- `"artifact files\|planning artifacts"` — 산출물 커밋 의무 확인
- `"§6.1 Director Mode delegation\|→ §6.1"` — §6.8 참조 줄 존재 확인

기존 Check 4(단어 예산) 는 자동으로 검증 커버 (7627w 이하 확인).

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-director-protocol.sh
```

검증 항목:
- Check 1: §6.8 섹션 존재
- Check 2: 핵심 불변식 용어 (기존)
- Check 3: 미러 parity
- Check 4: 단어 예산 (7627w 이하)
- Check 5 (신규): ceremony-split 용어 + §6.1 위임 단락 + §6.8 참조 줄

### 수동 검증 시나리오

1. **§6.1 위임 단락 위치 확인**: `grep -n "Director Mode delegation" sources/governance/agent.md` — §6.1 Strict Loop 절 내부(L170–L200 범위) 출력 확인.
2. **§6.8 참조 줄 확인**: `grep -n "§6.1 Director Mode delegation" sources/governance/agent.md` — §6.8 절 내부 출력 확인.
3. **미러 parity**: `diff sources/governance/agent.md .harness-kit/agent/agent.md` — 출력 없음(동일).
4. **단어 예산**: `wc -w sources/governance/agent.md sources/governance/constitution.md` — 합계 ≤8000.

## 🔁 Rollback Plan

- agent.md 는 git 관리 대상. `git checkout sources/governance/agent.md .harness-kit/agent/agent.md` 로 즉시 원복.
- 테스트 스크립트도 git 관리 대상. 별도 데이터/상태 영향 없음.

## ⚠️ 위험 및 완화

| 위험 | 완화 |
|---|---|
| 단어 예산 초과 (120w 목표 넘음) | T2 에서 초안 작성 직후 wc -w 측정 → 초과 시 문장 압축 후 진행 (디렉터 보고 후 계속) |
| **단어 예산 누적 — §13 prune 필요 시점** | spec-20-04(모델 config) 도 agent.md 를 건드림. 7627+α 가 7900w 초과 시 phase-20 후반 spec-x 로 prune 필요. 디렉터가 인지하고 있어야 함. |
| §6.1 번호 목록 구조 훼손 | 위임 블록을 번호 목록 *바깥*의 별도 단락으로 배치 (번호 없이 굵은 제목만) |

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
