# Walkthrough: spec-14-01

> 본 문서는 *작업 기록* 입니다. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| `sdd:queued` 마커를 어떻게 처리할 것인가 | A: `queue_sync_queued_table()` 신구현 / B: 마커 + 안내문 제거 | **B** | YAGNI — 현재까지 모든 phase 가 직렬 진행이라 queued 가 동시에 여러 개였던 적 없음. Icebox 가 이미 사람 편집이라 정책 통일이 멘탈 모델 단순. 코드 추가 0, 마이그레이션 불필요 |
| 픽스처 셋업에서 `sdd phase new` 가 "프로젝트 루트 못찾음" 으로 실패 | A: SDD 스크립트의 root 탐색 로직 변경 / B: 픽스처에 `installed.json` + `current.json` 추가 | **B** | 본 spec 의 범위가 아닌 변경. 기존 `test-sdd-queue-redesign.sh` 가 사용하는 패턴 재활용 |
| 회귀 테스트의 active 마커 검증이 `phase-1` 으로 grep 했지만 실제는 `phase-01` | A: grep 패턴을 `phase-0*1\b` 로 / B: zero-padding 비활성화 | **A** | zero-padding 은 `spec-x-id-padding` 에서 의도한 동작. 검증 패턴만 수정 |

## 💬 사용자 협의

- **주제**: 도그푸딩 잔재 처리 — phase-13 done 미처리 + untracked 버그 리포트 2건
  - **사용자 의견**: "bugfix 로 phase 만들어서 해결해... gitignore 중복 추가도 같은 논리로 다른 부분 확인"
  - **합의**: phase-14 (correctness-fixes) 신규 생성 → 4 spec 으로 분리. 본 spec 은 그 중 첫 번째.

- **주제**: spec-14-01 의 Option A vs B 결정
  - **사용자 의견**: 사전에 명시 없음 — "spec.md 의 trade-off 분석으로 결정" 에 동의
  - **합의**: spec.md 분석 후 Option B 추천 → Plan Accept (1) 으로 채택 확정

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (본 spec 신규)
- **명령**: `bash tests/test-sdd-queued-marker-removed.sh`
- **결과**: ✅ Passed (7/7)
- **로그 요약**:
```text
▶ Phase 1: 템플릿에 sdd:queued 마커가 없는지 검증
  ✅ sources/templates/queue.md — sdd:queued 마커 없음
  ✅ .harness-kit/agent/templates/queue.md — sdd:queued 마커 없음
▶ Phase 2: 마커 없는 queue.md 픽스처에서 sdd 명령 정상 동작
  ✅ sdd phase new — 마커 부재 상태에서 정상 동작
  ✅ queue.md active 마커에 phase-01 등록됨
  ✅ sdd status — 마커 부재 상태에서 정상 출력
  ✅ sdd phase done — 마커 부재 상태에서 정상 동작
  ✅ 📋 대기 Phase 섹션 사람 편집 안내문 보존
ALL 7 CHECKS PASSED
```

#### 회귀 테스트
- **명령**: `bash tests/test-sdd-queue-redesign.sh`
- **결과**: ✅ Passed (5/5)
- **명령**: `bash tests/test-sdd-status-cross-check.sh`
- **결과**: ✅ Passed (7/7)

### 2. 수동 검증

1. **Action**: `grep -rn "sdd:queued" sources/ .harness-kit/agent/` (템플릿)
   - **Result**: 0 매치 — 템플릿에서 마커 완전 제거 확인
2. **Action**: `bash .harness-kit/bin/sdd status` (도그푸딩 후)
   - **Result**: Active Phase = phase-14, Branch = spec-14-01-sdd-queued-marker, Plan Accept = yes — 정상

## 🔍 발견 사항

- **버그 보고서의 grep 결과가 보고 시점에 비해 줄었음** — 보고서는 4건 매치를 인용했는데 실제로는 0건. 모두 이전에 help/warning 워딩으로 들어있던 것이 phase-13 (DX 향상) 작업 중 사라진 듯. 본질(R/W 코드 부재)은 그대로라 보고서 결론은 유효.
- **`sdd phase new` 가 active phase 가 있어도 거부하지 않음** — `sdd status` 가 active phase 가 phase-14 라고 보고했는데도 phase 새로 생성이 가능했던 것 같다. 본 spec 직전에 발견한 잔재 (`sdd phase done phase-13` 으로 정리) 가 그 증거. 별건 이슈 — 추후 별도 확인 필요.
- **픽스처 셋업의 최소 요구사항**: `.harness-kit/installed.json` + `.claude/state/current.json` 두 파일이 모두 필요. test-sdd-queue-redesign.sh 와 같은 패턴 — 향후 다른 sdd 스모크 테스트도 같은 셋업 사용 가능.

## 🚧 이월 항목

- 없음. spec-14-02 ~ 04 는 phase-14 의 다음 spec 으로 진행.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-25 |
| **최종 commit** | `36941af` (chore: apply queue.md cleanup to project backlog) |
