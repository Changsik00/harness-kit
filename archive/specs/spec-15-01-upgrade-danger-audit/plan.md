# Research Plan: spec-15-01 (upgrade-danger-audit)

## 📋 Branch Strategy

- 신규 브랜치: `spec-15-01-upgrade-danger-audit`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함.

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **본 spec 은 Research 타입** — 코드 수정 0. 산출물은 `spec.md` 본문 자체 (constitution §9).
> - [ ] **분석 깊이 합의** — 4건 spec 의 git diff + 코드 단면을 직접 읽음. 기존 spec.md / walkthrough 만 요약하면 audit 가치 없음.
> - [ ] **fixture 옵션 비교는 trade-off 까지만** — 본 spec 에서 코드를 작성하지 않음. 권고 + 의사코드 수준까지.

> [!WARNING]
> - [ ] **audit 결과로 phase-15.md 갱신** 가능성 — spec 분할이 바뀔 수 있음. PR 시 phase-15.md 변경분이 포함될 수 있음을 인지.

## 🎯 핵심 전략 (Core Strategy)

### 분석 대상

| 영역 | 자료원 |
|---|---|
| **버그 4건** | `archive/specs/spec-x-update-preserve-state/` 또는 `specs/spec-x-update-preserve-state/`, install-phase-ship-template, sdd-phase-activate, gitignore dup spec 디렉토리 + 머지 PR diff |
| **install.sh** | 라인 단위 정독. 어떤 파일이 어떤 정책으로 처리되는지 표 작성 |
| **update.sh** | 동일. 특히 백업/복원 로직과 `claude-fragments/` 머지 처리 |
| **claude-fragments** | `sources/claude-fragments/*.fragment.md`, `install.sh` 의 머지 코드 |
| **state.json 스키마** | `sources/bin/lib/state.sh`, `install.sh` 의 state 템플릿, `update.sh` 의 백업 키 |
| **queue.md 마커** | `sources/templates/queue.md` 의 마커, `sdd_marker_*` 헬퍼 |

### 분석 절차

1. **버그 카탈로그** — 4건 spec 의 spec.md / walkthrough / diff 를 읽고 공통 패턴 추출
2. **정책 단면** — install.sh + update.sh 를 읽으며 처리 단위마다 분류 (OVERWRITE / MERGE / SKIP-IF-EXISTS / APPEND-IDEMPOTENT)
3. **잠재 위험 도출** — 각 정책 미명시 항목 + 정책 위반 가능 코드 경로 식별
4. **fixture 옵션 비교** — 함수 합성 vs declarative manifest (+ 추가 안 도출 가능)
5. **권고 작성** — Go/No-Go + spec-15-02/03 명세 초안 + spec-15-04+ 후보 P0/P1/P2 분류

### Trade-off 비교 양식 (Q3)

| 기준 | 옵션 A (함수 합성) | 옵션 B (declarative manifest) |
|---|---|---|
| 구현 복잡도 | | |
| 가독성 (테스트 작성자 입장) | | |
| 시나리오 추가 비용 | | |
| bash 3.2 호환 | | |
| 기존 `make_fixture()` 와의 통합 | | |
| 디버깅 용이성 | | |

## 📂 산출물

### [MODIFY] `specs/spec-15-01-upgrade-danger-audit/spec.md`
- §1~§3 은 본 spec 시작 시 작성됨 (배경, 질문, DoD)
- §4~§7 은 task 별로 누적 작성 (Research 산출물)

### [NEW] `specs/spec-15-01-upgrade-danger-audit/walkthrough.md`
- 결정 기록, 분석 중 발견사항, 후속 spec 후보

### [NEW] `specs/spec-15-01-upgrade-danger-audit/pr_description.md`

### [MODIFY] `backlog/phase-15.md`
- audit 결과 spec 표 / 위험 섹션 / spec-15-02+ 요점 갱신 (필요 시)

### 코드 변경
- **없음** (Research Spec 원칙)

## 🧪 검증 계획 (Research 의 "검증")

constitution §9.1 의 DoD 가 그대로 검증 항목:
- Trade-off Analysis ≥ 2 안 — §6 에 표 형식
- Go/No-Go 권고 — §7 에 명시
- §4~§7 모두 채워짐

> 단위 테스트 / 통합 테스트는 본 spec 산출물이 아님 (spec-15-02/03 에서).

### 회귀 검증

- 기존 테스트 스위트는 변경 없음 — 회귀 없음을 push 직전에 확인:
  ```bash
  bash tests/test-version-bump.sh   # 전체 스위트 자동 실행
  ```

## 🔁 Rollback Plan

- 본 spec 은 문서만 추가 (+ phase-15.md 일부 갱신). 머지 후 롤백 시 `git revert` 로 단순 처리.
- audit 결론이 잘못되어도 후속 spec 시작 전 `spec.md` 만 수정 가능 (코드 영향 없음).

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] §4~§7 모두 작성
- [ ] phase-15.md 갱신 (필요 시)
- [ ] walkthrough.md / pr_description.md ship
- [ ] PR 생성
