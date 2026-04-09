# phase-{N}: <한글 제목>

> Phase 는 전략적으로 묶인 SPEC 들의 그룹입니다. 한 비즈니스 가치 또는 한 위험 영역을 다룹니다.
> 본 문서는 phase 의 *계획* 입니다 (`backlog/` 아래에 위치). 실제 SPEC 작업은 `specs/spec-{N}-{seq}-{slug}/` 에 별도로 진행됩니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-{N}` |
| **상태** | Planning / In Progress / Done |
| **시작일** | YYYY-MM-DD |
| **목표 종료일** | YYYY-MM-DD |
| **소유자** | <name> |

## 🎯 배경 및 목표

### 현재 상황
<!-- 왜 이 Phase 가 필요한가? 어떤 문제/위험/기회가 존재하는가? -->

### 목표 (Goal)
<!-- 이 Phase 가 끝났을 때 어떤 상태가 되어야 하는가? -->

### 성공 기준 (Success Criteria) — 정량 우선
1. <기준 1> — 예: 동시 100 주문 시 재고 음수 0건
2. <기준 2> — 예: 웹훅 처리 SLA p99 < 5초
3. <기준 3> — 예: integration-tests.md 의 모든 시나리오 PASS

## 🧩 포함된 SPECs (todo list)

> 본 표는 phase 의 *작업 백로그* 입니다. SPEC 이 시작/완료되면 상태를 갱신하세요.
> 실제 SPEC 산출물은 `specs/spec-{N}-{seq}-{slug}/` 에 있습니다.

| SPEC ID | 제목 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-{N}-001` | <제목> | P0/P1/P2 | Backlog/Planning/Active/Merged | `specs/spec-{N}-001-{slug}/` |
| `spec-{N}-002` | <제목> | ... | ... | `specs/spec-{N}-002-{slug}/` |

## 🔗 의존성

- **선행 Phase**: <phase-X 또는 없음>
- **외부 시스템**: <예: StepPay API, MySQL 8.0+, Redis 6+>
- **영향받는 모듈**: <리스트>

## 🧪 통합 테스트 전략 (필수)

> 상세 시나리오는 `integration-tests.md` 에 작성합니다.
> 본 섹션은 요약과 실행 방법만 명시합니다.

### 테스트 환경
- <예: 로컬 docker-compose 로 MySQL + Redis 띄움>
- <예: StepPay sandbox 사용>

### 실행 방법
```bash
# 본 phase 의 통합 테스트 모두 실행
npm run test:e2e
```

### 통과 기준
- 모든 시나리오가 PASS
- 결과 로그가 phase 의 `walkthrough.md` 에 첨부됨

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| <예: StepPay sandbox 불안정> | 통합 테스트 지연 | 로컬 mock 서버 폴백 |

## 🏁 Phase Done 조건 (체크리스트)

- [ ] 모든 SPEC 이 main 에 merge 됨
- [ ] `integration-tests.md` 의 모든 시나리오 PASS
- [ ] `walkthrough.md` (Phase 단위) 작성 및 commit
- [ ] 성공 기준 정량 측정 결과 첨부
- [ ] 사용자 최종 승인
