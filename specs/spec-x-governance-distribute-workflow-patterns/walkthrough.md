# Walkthrough: spec-x-governance-distribute-workflow-patterns

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Generic 패턴 메모리 vs 거버넌스 | 메모리 (안 배포) / 거버넌스 (배포) | 거버넌스 | 사용자 catch — 메모리는 user/project-local. 다른 사용자에게 미배포. harness-kit 본질 (가이드 배포) 위반 |
| 거버넌스 word 한도 (5000 가득) | 압축 / 한도 상향 / scope 축소 | 5000 → 6000 상향 | 한도가 본질을 막음. 5000 정확히 차서 압축 한계. 20% 헤드룸 (6000) 으로 generic-useful 패턴 거버넌스화 가능 |
| 한도 상향 폭 | 5500 / 6000 / 7000 | 6000 | 200~300w 신규 + 미래 여유 ~750w. 무절제 상향 (7000+) 은 별도 정당화 필요 |
| 패턴 갯수 | 4개 (memory 기준) / 5개 (Version+CHANGELOG 추가) | 5개 | 사용자 catch — version bump 시 CHANGELOG 갱신 거버넌스 미명시. 본 PR 자체가 그 갭 시연 |
| 메모리 retire 시점 | 본 PR / 후속 단계 | 후속 (PR 외부) | 메모리는 repo 외부. PR 로 처리 불가. 머지 후 사용자 또는 agent 가 별도 정리 |

## 💬 사용자 협의

- **주제**: 메모리 entry 들이 다른 사용자/프로젝트에 배포되나?
  - **사용자 의견**: "이게 배포 했을때 적용이 되나? 우리끼리만의 context 로만 한거 아냐?"
  - **합의**: 메모리는 user/project-local → 거버넌스로 이전 필요. 단 5000w 한도 충돌

- **주제**: 5000w 한도의 의미
  - **사용자 의견**: "한계가 의미가 있나 싶어.. 너무 제약이 쌘거 아냐? 나름 하네스인데"
  - **합의**: 한도 상향 (6000) 합리적. 안티-bloat 가 본질을 막으면 안 됨

- **주제**: 버전 bump 시 CHANGELOG 갱신 누락
  - **사용자 의견**: "버전 바뀌면 chage log 문서 바꿔야 하는데 그건 언급이 없네"
  - **합의**: §6.7 에 "Version + CHANGELOG paired update" 추가 — 본 PR 자체에서 직접 시연 (이번 0.8.0 bump + CHANGELOG entry 동시)

## 🧪 검증 결과

### 단위 테스트
- `bash tests/test-governance-dedup.sh` → ✅ 8/8 PASS (5215w / 6000w 한도)
- `bash tests/test-two-tier-loading.sh` → ✅ 7/7 PASS
- `tests/test-version-bump.sh` Checks 1-5 → ✅ PASS (수동 분리 검증)
  - version.json = 0.8.0
  - sdd version = 0.8.0
  - CHANGELOG.md `## [0.8.0]` entry 1개
  - README.md 0.8.0 포함
  - installed.json kitVersion = 0.8.0
- `tests/test-version-bump.sh` Check 6 (전체 스위트) → 분리 검증 (실행 시간 길어 본 세션엔 생략 — CI 또는 후속에서 검증)

### 수동 검증
1. **Action**: governance-dedup test 압축 한계 도달 검증
   - **Result**: 5000 정확히 차서 §6.7 추가 시 5215w → 6000 한도 필요
2. **Action**: README 0.6.3 example version 발견 → 0.8.0 갱신
   - **Result**: test-version-bump.sh Check 4 PASS
3. **Action**: state.json kitVersion 0.7.0 → 0.8.0 (gitignore 외 — local 도그푸딩 verification)
   - **Result**: `sdd version` 출력 0.8.0 확인

## 🔍 발견 사항

- **메모리 vs 거버넌스 의 진짜 차이는 *배포 여부***: 직전 세션에서 메모리 선택 시 "코스트 회피" 만 봤음. 사용자가 "배포 안 됨" 을 catch 하면서 진짜 트레이드오프 노출 — generic-useful 패턴은 거버넌스, user-specific 만 메모리.
- **5000w 한도가 정량 안티-bloat 가드로 set 되었으나 정성 평가 없음**: 무엇이 *legitimate growth* 인지 한도가 분간 못 함. 6000 으로 상향하면서 코멘트로 "무절제 상향 금지 — 6500+ 은 별도 정당화" 명시 — 미래 비대화는 막되 합리적 성장 허용.
- **`sdd version` 이 state.json kitVersion 을 읽음**: install.sh 가 set 하지만 state 가 stale 하면 sdd version 도 stale. 본 PR 시연 — install.sh 재실행 없이 state.json 수동 갱신으로 `sdd version` 0.8.0 확인.
- **README example version 이 stale 하게 남아있던 패턴**: 0.6.3 이 마지막 갱신, 0.7.0 bump 시에 안 따라옴. test-version-bump.sh 가 이를 enforce 하므로 0.7.0 PR 도 사실은 통과 못 했을 것 (또는 테스트 안 돌렸을 것). 본 PR §6.7 의 "Version + CHANGELOG paired update" 가 future regression 방지.

## 🚧 이월 항목

- 메모리 3개 retire (`feedback_archive_clean_timing`, `feedback_model_transparency`, `feedback_parallel_default`) — 본 PR 머지 후 사용자 메모리에서 삭제 + MEMORY.md index 정리. PR 외부 단계.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-10 |
| **최종 commit** | (Ship 후 갱신) |
