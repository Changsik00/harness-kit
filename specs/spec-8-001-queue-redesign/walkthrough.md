# Walkthrough: spec-8-001

> 본 문서는 *증거 로그* 입니다.

## 📋 실제 구현된 변경사항

- [x] `sources/governance/constitution.md` + `agent/constitution.md` — §3 Work Type Model 추가 (Phase/Spec/spec-x/Icebox 정의), 기존 §3~§11 → §4~§12 번호 재부여
- [x] `sources/templates/queue.md` — NOW/NEXT/Icebox 섹션 구조로 재설계, 신규 sdd 마커(`sdd:now`, `sdd:next`, `sdd:specx`, `sdd:icebox`) 추가
- [x] `sources/templates/phase.md` — 메타 테이블에 `Base Branch` 행 추가, spec 표 `In Progress` 상태 및 상태 허용값 주석 추가
- [x] `scripts/harness/bin/sdd` — `compute_next_spec()` 함수 추가, `cmd_status()`에 NEXT 출력 추가, `cmd_queue()`에 구조화 출력 + `--raw` 플래그 추가
- [x] `tests/test-sdd-queue-redesign.sh` — TDD 테스트 5종 신규 작성
- [x] `backlog/queue.md` — 신규 NOW/NEXT/Icebox 구조로 도그푸딩 반영

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-sdd-queue-redesign.sh`
- **결과**: ✅ Passed (5/5)
- **로그 요약**:
```text
═══════════════════════════════════════════
 Queue Redesign Verification (spec-8-001)
═══════════════════════════════════════════

▶ Check 1: sdd status — NEXT 행 존재 여부
  ✅ sdd status 출력에 'NEXT:' 행이 있음
▶ Check 2: sdd status — NEXT 값이 spec-8-002인지 확인
  ✅ NEXT = spec-8-002 (첫 번째 Backlog spec)
▶ Check 3: sdd queue — NOW/NEXT/Icebox 섹션 헤더 존재
  ✅ queue 출력에 NOW/NEXT/Icebox 섹션 모두 존재
▶ Check 4: sdd queue --raw — queue.md 원문 출력
  ✅ sdd queue --raw 는 queue.md 원문(마커 포함) 출력
▶ Check 5: 모든 spec Merged 시 NEXT = 없음
  ✅ 모든 spec Merged 시 NEXT = 없음

 ✅ ALL 5 CHECKS PASSED
```

### 2. 수동 검증

1. **Action**: `sdd status` 실행
   - **Result**: `NEXT: spec-8-002-phase-base-branch` 출력 확인
2. **Action**: `sdd queue` 실행
   - **Result**: 🔴 NOW / ⏭ NEXT / 🧊 Icebox 섹션 색상 하이라이트 확인
3. **Action**: `sdd queue --raw` 실행
   - **Result**: queue.md 마커 포함 원문 그대로 출력 확인

## 🔍 발견 사항

- `sources/bin/sdd`와 `scripts/harness/bin/sdd`가 현재 동일 파일 역할을 함 — 도그푸딩 구조 개선 시 고려 필요 (Icebox에 추가)
- `sdd:now`/`sdd:next` 마커가 queue.md에 추가됐으나 `sdd plan accept`, `sdd archive` 시 자동 갱신 로직은 spec-8-003에서 구현 예정

## 🚧 이월 항목

- `update_queue_now_next()` 자동 갱신 (plan accept / archive 연동) → spec-8-003에서 구현

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-11 |
| **최종 commit** | `d0f3f5f` |
