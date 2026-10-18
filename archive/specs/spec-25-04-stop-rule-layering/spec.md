# spec-25-04: 정지규칙 ② 2층 모델 명문화 + 차단 승격 준비 (W3)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-25-04` |
| **Phase** | `phase-25` |
| **Branch** | `spec-25-04-stop-rule-layering` |
| **Base 브랜치** | `phase-25-auto-reliability` (base 모드) |
| **상태** | Planning |
| **타입** | Refactor/Fix |
| **작성일** | 2026-06-22 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

auto 의 비가역 행동 방어는 **두 층**이 겹쳐 있다:
- **settings `deny`**: `git reset --hard`·`git rebase --onto`·force push·`rm -rf /`·sudo·`curl|bash` 등을 *프롬프트 없이 완전 차단*.
- **`check-irreversible` hook (②)**: force push·filter-branch·`rm -rf` glob·`git clean -fd`·publish/release 를 감지해 "멈추고 사람 대기" (현재 경고 모드).

### 문제점 (phase-review W3)

두 층의 역할 경계가 명문화돼 있지 않다. 그 결과:
1. **데드락**: auto 가 정당한 복구(예: 꼬인 머지 후 `git reset --hard`)를 시도하면 `deny` 가 *프롬프트도 없이* 거부 → 진행도 사람 개입 호출도 안 되는 교착. ②의 "멈추고 대기" 의도와 `deny` 의 "완전 차단" 이 충돌.
2. **hook 커버리지 공백**: `check-irreversible` 는 정작 `git reset --hard`·`git rebase --onto` 를 *감지하지 못한다*(현재 deny 전담). 그래서 hook 이 그 명령들의 "stop+confirm" 층을 떠맡으려 해도 못 한다.

### 해결 방안

destructive 행동의 **2층 모델**을 명문화한다:
- **deny = never-justify** (어떤 맥락도 정당화 못 함): `rm -rf /`·sudo·`curl|bash`·공유 히스토리 force push. 영구 완전 차단.
- **hook ② = context-dependent** (복구 등에서 정당할 수 있음): `git reset --hard`·`git rebase --onto`·`git clean -fd`. "멈추고 사람 확인" 이 맞는 부류.

본 spec 은 이 모델을 명문화하고, hook 이 context-dependent 명령을 **감지하도록 준비**(warn)한다. **실제 플립**(warn→block + deny 에서 해당 명령 제거)은 hook 단계론(CLAUDE.md #5, 1주 운영)상 **2026-06-26 이후 phase-FF** 로 미룬다 — check-irreversible 는 2026-06-19 추가라 아직 3일째.

## 요구사항

1. `check-irreversible` 가 `git reset --hard` 와 `git rebase --onto` 를 **감지**(현재 경고 모드, exit 0). 기존 force-push narrow 제외 로직 유지.
2. hook 헤더에 **2층 모델**(deny=never-justify / hook=context-dependent) 분류표 + 데드락 설명 + **승격 적격일(2026-06-26)** 명시.
3. `test-stop-rules.sh` 가 새 감지(reset --hard·rebase --onto)를 경고로 고정 + **block 모드 경로**(exit 2)도 고정(승격 준비). 기존 "reset --hard 미감지" 경계 단언을 갱신.
4. **이번엔 플립/deny 변경 없음** — warn 기본 유지, deny 그대로(이중 방어). 플립은 phase-FF(기등록).
5. 도그푸딩 미러.

## Out of Scope

- **warn→block 플립** + **deny 에서 reset/rebase 제거** — 2026-06-26 phase-FF (지금 하면 1주 원칙 위반 + warn 창 무방비 공백).
- 새 정지규칙(④⑤…) 추가.
- settings 권한 재설계.

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **지금 reset --hard 감지 추가가 안전한가**: 경고(exit 0)라 동작 변화 없음 + deny 가 여전히 실제 차단 → warn 창 공백 없음. 단 `git reset --hard` 는 흔한 명령이라 *경고 노이즈*가 늘 수 있음(예: 의도적 로컬 리셋). narrow 화(예: `HEAD~` 등 특정 패턴만)할지 검토. 권장: 일단 광의 감지 + 경고, 노이즈는 운영 관찰.
> - [ ] **2층 모델을 ADR 로 승격할지**: 재사용 불변식(향후 hook/명령이 참조)이라 ADR 후보. 단 ADR-009 가 이미 ② 를 다룸 → walkthrough + hook 헤더로 충분할 수 있음.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **감지 확장** | `check-irreversible` 에 `git reset --hard`·`git rebase --onto` 패턴 추가(warn) | hook 이 플립 시 context-dependent 층을 떠맡을 수 있게 *미리* 학습 |
| **무공백 보장** | deny 는 그대로 유지(이중 방어) | warn 창에서 실제 차단은 deny 가 계속 담당 → 보호 공백 0 |
| **모델 명문화** | hook 헤더 분류표 + 승격 적격일 | "왜 어떤 건 deny, 어떤 건 hook 인가" 를 코드 옆에 박아 잊힘·재발 방지 |
| **승격 준비** | block 경로 테스트 고정 | 6/26 플립이 1줄 mechanical 이 되도록 |

## Proposed Changes

#### [MODIFY] `sources/hooks/check-irreversible.sh`
- `git reset --hard`, `git rebase --onto` 감지 패턴 추가 (warn). force-push narrow 제외 유지.
- 헤더에 2층 모델 분류표(deny=never-justify / hook=context-dependent) + 데드락(W3) 설명 + 승격 적격일 2026-06-26 + 플립 시 deny→hook 이관 메모.

#### [MODIFY] `tests/test-stop-rules.sh`
- 새 감지 경고 케이스(reset --hard·rebase --onto) 추가. 기존 "reset --hard 미감지" 경계 단언 갱신.
- block 모드(exit 2)에서 새 명령이 차단됨을 고정(승격 준비).

#### [MODIFY] 도그푸딩 미러
`.harness-kit/hooks/check-irreversible.sh` byte-identical.

## 검증 계획

```bash
bash tests/test-stop-rules.sh
bash tests/run.sh
```
수동: `git reset --hard` 를 CLAUDE_TOOL_INPUT_command 로 hook 에 넣어 경고 확인.

## 롤백 계획

- `git revert` — hook 패턴 + 테스트 + 주석만. deny/플립 미변경이라 동작 영향 최소(경고 1건 추가).

## ADR 후보

- [ ] 2층 모델(deny vs hook 경계) — 재사용 불변식이라 ADR 후보(type: convention). Ship 시 walkthrough vs ADR 판단(🛑 검토 2).

## ✅ Definition of Done

- [ ] `test-stop-rules.sh` 갱신 PASS + 전체 회귀 PASS
- [ ] reset --hard·rebase --onto 경고 감지 + block 경로 고정
- [ ] 2층 모델 + 승격 적격일 hook 헤더 명문화
- [ ] 플립/deny **미변경** 확인 (warn 기본 유지)
- [ ] sources ↔ 설치본 미러 동일
- [ ] `walkthrough.md` / `pr_description.md` ship commit + 브랜치 push
