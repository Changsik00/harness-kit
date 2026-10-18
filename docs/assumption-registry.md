# 하네스 가정 레지스트리

> 출처: GitHub #181 제안 3. 하네스의 각 구성요소는 *"모델이 스스로 할 수 없다"* 는 가정을 인코딩한다. 새 모델 세대가 나오면 이 가정을 스트레스 테스트해 ceremony 를 줄일지 판단한다 (ADR-002 planning economy, ADR-009 신뢰도 재배분).

## 재검토 트리거

- `harness.config.json` 의 모델 매핑(director / worker / scout) 변경
- 새 모델 세대 출시 후 릴리스 시점 ([`release-strategy.md`](release-strategy.md) 절차에 체크 1줄)

## 재검토 방법

각 행의 *깨지는 신호* 를 현 모델로 시험한다 (해당 ceremony 를 끈 채 spec 1~2건 진행 → 실패 여부 관찰). 가정이 더 이상 성립하면 ADR 로 완화/폐기를 기록하고 이 표를 갱신한다. 시험 전에는 제거하지 않는다.

## 레지스트리

| 구성요소 | 인코딩된 가정 (모델이 못 한다) | 깨지는 신호 | 완화 선례 |
|---|---|---|---|
| Plan Accept 게이트 / PLANNING 잠금 | 합의 없이 두면 엉뚱한 방향으로 구현한다 | 승인 없이 진행해도 방향 오류가 거의 없다 | turbo / auto 모드 (ADR-009) |
| One Task = One Commit (Strict Loop) | 큰 단위는 중간 오류가 누적돼 되돌리기 어렵다 | 큰 단위 커밋도 회귀 없이 통과 | phase-FF (ADR-004) |
| spec / plan / task 산출물 | 의도를 문서로 고정하지 않으면 맥락을 잃는다 | 짧은 지시만으로 일관된 결과 | right-size, plan.md 폐기 (ADR-002) |
| transcript 재흡수 금지 / distilled return | 긴 raw 출력이 메인 컨텍스트를 오염시킨다 | 장문 컨텍스트에서도 의도 유지 | ADR-005 |
| 독립 서브에이전트 리뷰 (code / phase review, spec-critique) | 생성자는 자기 결과를 관대하게 본다 (self-review blind spot) | 자기 리뷰가 독립 리뷰와 같은 결함을 잡는다 | 위험 비례 호출 (`/hk-refute`) |
| 테스트 신뢰 hook (`check-test-trust`) | 에이전트 TDD 는 동어반복·가짜 red 를 만든다 | 뮤테이션 점수가 높게 유지 (#212 칸 1 로 측정) | 칸 0 경고 → 차단 승격 |
| 역할 기반 모델 분배 | 작은 모델은 판단 작업에 약하다 | scout/worker 모델이 director 판단 품질을 낸다 | `harness.config.json` |
| 비가역 행동 차단 (`check-irreversible`) | 파괴 명령을 맥락 없이 실행할 수 있다 | 파괴 명령 시도 0건 지속 | attended=warn / auto=block |
| 결정 시 차단형 질문 (`AskUserQuestion`) | 모호한 결정을 임의로 고른다 | 기본값 선택이 사람 선택과 일치 | auto 리다이렉트 (spec-25-01) |
