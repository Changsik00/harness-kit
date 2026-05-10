# docs(spec-x-governance-distribute-workflow-patterns): 워크플로우 패턴 거버넌스화 + 한도 상향 + 버전 0.8.0

## 📋 Summary

### 배경 및 목적
직전 세션에서 generic-useful 워크플로우 패턴 3개 (archive timing / model transparency / parallel-by-default) 를 메모리 entry 로 작성. 거버넌스 word 한도 (5000) 가 가득 차서 거버넌스 비용이 높다고 판단했음.

사용자 catch: **"이게 배포 했을때 적용이 되나? 우리끼리만의 context 로만 한거 아냐?"**

검증 결과 — 메모리는 `~/.claude/projects/<id>/memory/` 에 저장되어 **user/project-local**. 다른 사용자가 install/update 해도 미배포. harness-kit 의 본질 (사용자에게 가이드 전달) 위반.

근본 원인: **5000w 한도가 자기 목적을 잃음**. 안티-bloat 가드가 generic-useful 패턴 배포까지 막음. 한도가 *수단* 이지 *목적* 이 아닌데 수단이 목적을 가로막는 상태.

### 주요 변경 사항
- [x] **agent.md §6.7 Workflow Patterns 신설** (5 패턴):
  - Model transparency (헤더 + dispatch 표기)
  - Parallel-by-default (독립 작업 한 메시지 동시)
  - Background for long-running (5초+ 작업)
  - Sub-agent dispatch threshold (단일 명령은 메인)
  - Archive timing (intentional checkpoint)
  - Version + CHANGELOG paired update (paired update 강제)
- [x] **거버넌스 word 한도 5000 → 6000**: 20% 헤드룸. 인라인 코멘트로 상향 사유 + 무절제 상향 금지 명시
- [x] **version.json 0.7.0 → 0.8.0**
- [x] **CHANGELOG.md `## [0.8.0]` entry**: 직전 세션 + 본 PR 변경 정리 (Added/Fixed/Changed)
- [x] **README example version 0.6.3 → 0.8.0**: test-version-bump.sh Check 4 enforce
- [x] **dogfood sync**: `.harness-kit/agent/agent.md` + `.harness-kit/installed.json`

## 🎯 Key Review Points

1. **한도 상향의 정당성 (5000 → 6000)**: 본 PR 자체가 정당화. 5000 정확히 찼고 generic-useful 패턴 거버넌스화 시 5215w. 6000 헤드룸 (~750w 미래 여유) + "6500+ 별도 정당화" 코멘트로 무절제 상향 차단.
2. **§6.7 의 6번째 패턴 (Version + CHANGELOG)**: 본 PR 작성 중 사용자가 catch 한 갭 — *바로 그 갭이 본 PR 자체에서도 검증 누락 직전이었음*. §6.7 에 paired update 강제로 future regression 방지.
3. **메모리 retire 는 PR 외부**: `~/.claude/projects/<id>/memory/` 는 repo 외부. PR 로 못 다룸. 머지 후 별도 단계.

## 🧪 Verification

```bash
bash tests/test-governance-dedup.sh    # 8/8 PASS (5215w / 6000w 한도)
bash tests/test-two-tier-loading.sh    # 7/7 PASS
# version-bump Checks 1-5 (수동):
#   version.json 0.8.0 ✓
#   sdd version 0.8.0 ✓
#   CHANGELOG.md [0.8.0] entry ✓
#   README.md 0.8.0 ✓
#   installed.json kitVersion 0.8.0 ✓
```

### 수동 검증 시나리오
1. `cat version.json` → 0.8.0
2. `bash .harness-kit/bin/sdd version` → harness-kit 0.8.0
3. agent.md 의 §6.7 가 §6.6 다음, §7 앞에 존재
4. CHANGELOG.md 첫 entry 가 `## [0.8.0]`

## 📦 Files Changed

### 🛠 Modified Files
- `tests/test-governance-dedup.sh` (+4, -1): LIMIT 5000 → 6000 + 상향 사유 코멘트
- `sources/governance/agent.md` (+15): §6.7 Workflow Patterns
- `.harness-kit/agent/agent.md` (+15): dogfood sync
- `version.json` (+1, -1): 0.7.0 → 0.8.0
- `CHANGELOG.md` (+22): `## [0.8.0]` entry
- `README.md` (+1, -1): example version 0.6.3 → 0.8.0
- `.harness-kit/installed.json` (+1, -1): kitVersion sync

### 🆕 New Files
- `specs/spec-x-governance-distribute-workflow-patterns/{spec,plan,task,walkthrough,pr_description}.md`

## ✅ Definition of Done

- [x] §6.7 + 한도 상향 + version + CHANGELOG
- [x] 도그푸딩 sync
- [x] 회귀 (governance-dedup, two-tier-loading)
- [x] walkthrough.md / pr_description.md
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)
- [ ] (머지 후) 메모리 3개 retire — 별도 단계

## 🔗 관련 자료

- 직전 세션 메모리 entries: `feedback_archive_clean_timing.md`, `feedback_model_transparency.md`, `feedback_parallel_default.md` (본 PR 머지 후 retire)
- 직전 PRs (0.7.0 → 0.8.0 사이): #102, #103, #104, #105 + FF 85d2462, FF f48cc4c
