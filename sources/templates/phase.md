# phase-{N}: <한글 제목>

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-{N}-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

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
<!-- 왜 이 phase 가 필요한가? 어떤 문제/위험/기회가 존재하는가? 1~3 문단 -->

### 목표 (Goal)
<!-- 이 phase 가 끝났을 때 어떤 상태가 되어야 하는가? -->

### 성공 기준 (Success Criteria) — 정량 우선
1. <기준 1>
2. <기준 2>
3. <기준 3>

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-{N}-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

### spec-{N}-001 — <한글 슬러그>

- **요점**: <한 줄 — 무엇을 바꾸는가>
- **방향성**: <어떻게 접근하는가, 1~2 줄>
- **참조**:
  - `docs/review/<관련 리뷰>.md` §<섹션>
  - `docs/decisions/ADR-<NNN>-<slug>.md` (있다면)
- **연관 모듈**: `<src/path/...>`

### spec-{N}-002 — <한글 슬러그>

- **요점**:
- **방향성**:
- **참조**:
- **연관 모듈**:

<!-- 추가 SPEC 들... -->

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 의 Done 조건 중 하나. 자세한 구현은 `test/e2e/phase-{N}/` (또는 stack 별 통합 테스트 위치).

### 시나리오 1: <제목>
- **Given**: ...
- **When**: ...
- **Then**: ...
- **연관 SPEC**: spec-{N}-001, spec-{N}-002

### 시나리오 2: <제목>
- **Given**: ...
- **When**: ...
- **Then**: ...
- **연관 SPEC**:

### 통합 테스트 실행
```bash
# 본 phase 의 통합 테스트만
npm run test:e2e -- --testPathPattern="phase-{N}"
```

## 🔗 의존성

- **선행 phase**: <phase-X 또는 없음>
- **외부 시스템**: <예: StepPay sandbox, MySQL 8.0+, Redis 6+>
- **연관 ADR**:
  - `docs/decisions/ADR-<NNN>-<slug>.md`

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| <위험 1> | <영향> | <완화> |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge (위 표의 상태 = Merged)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
