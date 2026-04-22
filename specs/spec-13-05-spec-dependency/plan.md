# Implementation Plan: spec-13-05

## 📋 Branch Strategy

- 신규 브랜치: `spec-13-05-spec-dependency`
- 시작 지점: `phase-13-dx-enhancements` (phase base branch)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 검사 시점을 `sdd plan accept`로 결정한 것에 동의 여부 (`sdd spec new` 시점 아님)
> - [ ] 첫 버전은 경고만 (exit 0) — 차단(exit 2)은 다음 phase 동의 여부

> [!NOTE]
> - `depends_on` 값 형식: `spec-13-01, spec-13-02` (쉼표 구분, 대시 `-` 면 검사 생략)
> - 파싱/검사 실패는 조용히 skip → 기존 워크플로우 방해 없음

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **검사 시점** | `sdd plan accept` | spec.md 작성 후 내용을 읽는 가장 자연스러운 시점 |
| **파싱 방식** | grep으로 테이블 행 추출 | jq 의존 없음, 단순 |
| **의존성 위반 시** | 경고만 (exit 0) | 강제 차단은 운영 경험 쌓은 후 결정 |
| **형식** | 메타 테이블 행 추가 | 기존 spec.md 스타일 일관성 |

## 📂 Proposed Changes

### [템플릿]

#### [MODIFY] `sources/templates/spec.md`
메타 테이블에 depends_on 행 추가:
```text
| **depends_on** | `-` |
```

### [CLI]

#### [MODIFY] `sources/bin/sdd` — `cmd_plan_accept()` (또는 `plan_accept()`)
plan accept 시 depends_on 검사 추가:
```text
_check_depends_on() {
  # spec.md에서 depends_on 행 파싱
  # "-" 이면 skip
  # phase.md에서 각 spec-id 상태 확인
  # Merged 아니면 경고 출력 (exit 0)
}
```

### [테스트]

#### [NEW] `tests/test-spec-dependency.sh`
1. `sources/templates/spec.md`에 `depends_on` 행 포함 확인
2. depends_on = `-` 인 spec → plan accept 시 경고 없음 확인
3. depends_on = Merged spec → plan accept 시 경고 없음 확인
4. depends_on = non-Merged spec → plan accept 시 경고 출력 확인
5. `sources/bin/sdd` ↔ `.harness-kit/bin/sdd` 동기화 확인

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-spec-dependency.sh
```

### 수동 검증 시나리오
1. spec.md에 `depends_on: spec-13-99` 작성 → `sdd plan accept` → 경고 출력 확인
2. `depends_on: -` → `sdd plan accept` → 경고 없음 확인

## 🔁 Rollback Plan

- `sdd plan accept`에서 `_check_depends_on` 호출 제거
- `sources/templates/spec.md`에서 depends_on 행 제거

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
