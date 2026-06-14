# Walkthrough: spec-21-04

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| T01/T05 false positive | `grep -q "Mode D"` vs `grep -q "2.5 Mode D"` | `"2.5 Mode D"` 사용 | `"Work Mode Decision Tree"` 에 `"Mode D"` 부분 문자열 존재 — 구체적 패턴으로 픽스 |
| §2.4 Decision Tree 위치 | Step 0 삽입 위치 | 기존 Step 1 앞에 Step 0 추가 | Turbo는 게이트 아닌 mode — 전제 조건으로 선체크가 자연스러움 |
| §2.5 위치 | §2.3 뒤 / §2.4 뒤 | §2.3 뒤에 §2.5 배치 | §2.4 Decision Tree를 분리하지 않고 Mode 목록(§2.1~2.3) 끝에 추가 — 번호 점프는 의도적 (§2.4는 기존 트리) |
| `/hk-turbo` 동작 | 단방향 turbo 전환 vs toggle | toggle (현재 모드 확인 후 역전환) | 사용자가 현재 상태를 몰라도 올바른 방향으로 안내 가능 |

### ADR 승격 가이드

- [ ] 없음 — Turbo 모드 설계 결정은 spec-21-01 walkthrough에 기록됨

## 💬 사용자 협의

- **주제**: `/hk-mode` 이름이 `/hk-ask-mode`와 혼동
  - **사용자 의견**: `/hk-turbo` 로 변경 요청
  - **합의**: `/hk-turbo` 채택 — 기능 목적 직접 표현

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (spec-21-04)
- **명령**: `bash tests/test-governance-update.sh`
- **결과**: ✅ Passed (6/6)
- **로그 요약**:
```text
=== test-governance-update ===
T01: constitution.md — 2.5 Mode D Turbo 섹션 포함
  ✅ PASS: T01: constitution.md 에 '2.5 Mode D' 있음
T02: constitution.md — sdd mode turbo 언급
  ✅ PASS: T02: constitution.md 에 'sdd mode turbo' 있음
T03: agent.md — §3.1 Turbo 행 포함
  ✅ PASS: T03: agent.md 에 Turbo 행 있음
T04: .claude/commands/hk-turbo.md 존재
  ✅ PASS: T04: hk-turbo.md 존재
T05: sources/governance/constitution.md — 2.5 Mode D 미러링
  ✅ PASS: T05: sources/governance/constitution.md 에 '2.5 Mode D' 있음
T06: sources/commands/hk-turbo.md 존재
  ✅ PASS: T06: sources/commands/hk-turbo.md 존재
=== 결과: PASS=6 FAIL=0 ===
```

#### 회귀 테스트 (spec-21-02 hooks)
- **명령**: `bash tests/test-turbo-hooks.sh`
- **결과**: ✅ Passed (8/8)

### 2. 수동 검증

1. **Action**: `grep -n "2.5 Mode D" .harness-kit/agent/constitution.md`
   - **Result**: `§2.5 Mode D — Turbo` 섹션 확인

2. **Action**: `grep "Turbo" .harness-kit/agent/agent.md`
   - **Result**: §3.1 테이블에 Turbo 행 확인

## 🔍 발견 사항

- `grep -q "Mode D"` 가 `"Work Mode Decision Tree"` 의 부분 문자열로 false positive 발생 — 테스트 패턴 특이성 중요 (이슈 기록 완료)
- §2.5를 §2.3 바로 뒤에 두면 §2.4 Decision Tree의 번호가 §2.5보다 작아지는 번호 역전이 생김 — 향후 정리 spec에서 번호 재배정 고려 가능 (Icebox)

## 🚧 이월 항목

- ADR-007 (Turbo 모드 설계 결정 공식화) — Icebox 보류

## 🔗 관련 문서

- 관련 spec: `specs/spec-21-01-mode-schema/`, `specs/spec-21-02-turbo-hooks/`, `specs/spec-21-03-intent-block/`
- 관련 Phase: `backlog/phase-21.md`

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-06-13 |
| **최종 commit** | `44ee32e` |
