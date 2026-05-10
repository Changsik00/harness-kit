# spec-x-governance-distribute-workflow-patterns: 워크플로우 패턴 거버넌스화 + 한도 상향 + 버전 bump

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-governance-distribute-workflow-patterns` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-governance-distribute-workflow-patterns` |
| **상태** | Planning |
| **타입** | Fix (governance + version) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-10 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
직전 세션에서 generic-useful 워크플로우 패턴 3개를 메모리 entry 로 작성:
- `feedback_archive_clean_timing` — archive timing 원칙
- `feedback_model_transparency` — 모델 사용 표시
- `feedback_parallel_default` — 독립 작업 병렬 / long-running background

이때 거버넌스 word 한도 (5000w) 가 가득 차 있어 거버넌스화 비용이 높다고 판단, 메모리만 추가하고 종료.

### 문제점
사용자 지적: **"이게 배포 했을때 적용이 되나? 우리끼리만의 context 로만 한거 아냐?"**

검증 결과:
- 메모리 entry 는 `~/.claude/projects/<id>/memory/` 에 저장 → **사용자·프로젝트 한정**
- 다른 사용자가 install / update 해도 메모리 미배포
- 동일 사용자의 다른 프로젝트도 미적용
- 즉 **harness-kit 의 본질 (사용자에게 행동 가이드 전달) 을 못 함**

근본 원인: **5000w 한도가 자기 목적을 잃음**. 안티-bloat 가드가 *generic-useful 패턴 배포* 까지 막음. 한도가 *수단* 이지 *목적* 이 아닌데, 수단이 목적을 가로막는 상태.

또 부수: `version.json` 미증가 → 직전 세션의 4 PR + FF 변경이 다른 install 에 자동 알림 안 감.

### 해결 방안
1. **한도 5000 → 6000 상향** (20% 헤드룸): 현재 5000 정확 + 메모리 이전 ~250w + 미래 여유 ~750w. 의미 있는 안티-bloat 유지.
2. **agent.md §6.7 Workflow Patterns 신설**: 메모리 3개의 핵심을 압축 거버넌스화.
3. **메모리 3 retire**: 거버넌스 이전 완료 후 user memory 에서 삭제 (중복 제거 + drift 방지).
4. **version.json 0.7.0 → 0.8.0**: 직전 세션의 5 변경 + 본 PR = minor bump.

## 🎯 요구사항

### Functional Requirements
1. **F1**: `tests/test-governance-dedup.sh` LIMIT 5000 → 6000. 인라인 코멘트로 상향 사유 명시.
2. **F2**: `sources/governance/agent.md` 에 `### 6.7 Workflow Patterns` 신설. 5가지 패턴 압축 명시:
   - Model transparency (헤더 + dispatch 표기)
   - Parallel-by-default (독립 작업 한 메시지 동시)
   - Background for long-running
   - Archive timing (intentional checkpoint)
   - Version + CHANGELOG paired update
3. **F3**: `version.json` 0.7.0 → 0.8.0.
4. **F4**: `CHANGELOG.md` 에 `## [0.8.0]` entry 추가 — 직전 세션의 4 PR + 2 FF + 본 PR 변경 정리 (Added/Fixed/Changed/Tests 분류).
5. **F5**: 사용자 메모리 3개 retire — 본 spec-x 머지 후 후속 단계 (PR 외부).

### Non-Functional Requirements
1. **N1**: 거버넌스 영어 (agent.md). 메모리는 한국어 (이전 패턴 유지하나, 본 PR 에선 영어 governance 만 다룸).
2. **N2**: 도그푸딩 sync (`.harness-kit/agent/agent.md`).
3. **N3**: 회귀 — `test-governance-dedup.sh` (새 한도 통과), `test-two-tier-loading.sh` PASS.

## 🚫 Out of Scope
- 메모리 파일 실제 삭제 — 본 PR 머지 후 별개 단계 (사용자 메모리는 repo 외부, PR 로 처리 불가).
- 한도 이외 governance 의 다른 verbose 정리 — 현재 5000w 정확 상태이므로 추가 압축 불필요.
- Workflow patterns 외 기타 메모리 entries 의 governance 화 — 본 3개만 처리.

## ✅ Definition of Done
- [ ] LIMIT 6000 + §6.7 추가 + version.json 0.8.0
- [ ] 도그푸딩 sync
- [ ] 회귀 PASS
- [ ] walkthrough / pr_description ship
- [ ] push + PR
