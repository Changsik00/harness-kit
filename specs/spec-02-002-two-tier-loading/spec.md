# spec-02-002: CLAUDE.md 2단계 로딩 전략

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-02-002` |
| **Phase** | `phase-02` |
| **Branch** | `spec-02-002-two-tier-loading` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

CLAUDE.md의 HARNESS-KIT 블록이 `@import`로 3개 거버넌스 파일을 매 세션 전량 로드:
- `@agent/constitution.md` (~1,032 words)
- `@agent/agent.md` (~1,331 words)
- `@agent/align.md` (~350 words)

합계 **~2,713 words** 가 매 세션 시작 시 자동 소모. 여기에 CLAUDE.md 본문(~400 words)과 핵심 규칙 요약(~80 words)이 추가되어 총 ~3,200 words.

### 문제점

1. **토큰 낭비**: FF 모드나 단순 질문 세션에서도 전체 거버넌스가 로드됨
2. **중복 로드**: `/align` 호출 시 align.md가 이미 `@import`하므로 constitution/agent.md가 2번 로드됨
3. **핵심 규칙 요약이 이미 인라인**: 일상 작업에 필요한 핵심 규칙 8줄이 이미 CLAUDE.md에 있으므로 @import는 SDD 모드 진입 시에만 필요

### 해결 방안 (요약)

**2단계 로딩** 구조로 전환:
- **Tier 1 (항상 로드)**: CLAUDE.md에 핵심 규칙 요약만 인라인 (~80 words)
- **Tier 2 (요청 시 로드)**: `/align` 호출 시 전체 거버넌스 Read (~2,713 words)

## 🎯 요구사항

### Functional Requirements
1. `CLAUDE.md.fragment`에서 3개 `@import` 제거.
2. 핵심 규칙 요약 (~8줄)은 유지.
3. `/align` 슬래시 커맨드가 전체 거버넌스를 로드하는 역할 유지 (이미 동작 중).
4. `CLAUDE.md` 본체에도 동일 변경 적용 (도그푸딩).
5. `install.sh`가 새 fragment를 올바르게 append하는지 확인.

### Non-Functional Requirements
1. `/align` 미호출 세션의 자동 로드 토큰: ~500 words 이하 (현재 ~3,200 → 목표 ~500).
2. `/align` 호출 세션은 기존과 동일한 거버넌스 커버리지.
3. 기존 hook, sdd, 슬래시 커맨드에 영향 없음.

## 🚫 Out of Scope

- constitution.md, agent.md 내용 변경 (spec-02-001에서 완료)
- hook 동작 모드 변경 (spec-02-003)
- align.md 내용 변경 (이미 적절)

## ✅ Definition of Done

- [ ] CLAUDE.md.fragment에서 3개 @import 제거
- [ ] 핵심 규칙 요약 유지 확인
- [ ] CLAUDE.md 본체 동기화
- [ ] `/align` 호출 시 전체 거버넌스 로드 검증
- [ ] 토큰 카운트: 자동 로드 ~500 words 이하
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-02-002-two-tier-loading` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
