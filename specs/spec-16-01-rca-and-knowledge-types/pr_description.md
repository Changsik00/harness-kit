# feat(spec-16-01): RCA 템플릿 + Knowledge Type 정규 어휘 도입

## 📋 Summary

### 배경 및 목적

phase-16 (Reliability Layer) 의 첫 도그푸딩. spec-x-readme-refresh / spec-x-phase-16-define 작업 중 같은 실패 패턴 (`sdd ship` 후 spec/plan/task 산출물 untracked) 이 두 번 반복됐다. *반복되는 실패 패턴* 을 정규 RCA 로 박을 도구가 없어, 본 spec 으로 다음 3 가지를 한 번에 도입:

1. **Knowledge Type 정규 어휘** — frontmatter `type:` 의 5 정규 값 (`decision` / `invariant` / `failure-pattern` / `convention` / `tradeoff`) 을 constitution §6.4 에 박는다. grep 친화적 closure 확보.
2. **RCA 템플릿** — 5 섹션 (Symptom / Reproduction / Root Cause / Invariant Violated / Prevention) 강제. 외부 진단 #3 / 추가 제안서 §D 표준.
3. **`/hk-rca` 슬래시 커맨드** — 자동 id 부여 + 사용자 입력 (slug, severity) + frontmatter 자동 채움. 자동 진단은 의도적 out of scope.

추가로 첫 사용자 `RCA-001-sdd-ship-spec-add-missing.md` 작성으로 phase-16 성공 기준 1 (1 회 RCA) 자연 만족.

### 주요 변경 사항

- [x] `sources/governance/constitution.md` §6.4 신설 (Knowledge Type Vocabulary, 5 type 표 + 3 룰) — 기존 §6.4 Branch Naming 은 §6.5 로 이동
- [x] `sources/templates/rca.md` 신규 — 5 섹션 + frontmatter (id / type=failure-pattern / date / severity / status)
- [x] `sources/commands/hk-rca.md` 신규 — 부트스트랩 슬래시 커맨드 가이드
- [x] 도그푸딩 mirror — `bash update.sh --yes` 로 `.harness-kit/agent/templates/rca.md`, `.claude/commands/hk-rca.md`, `.harness-kit/agent/constitution.md`, `.harness-kit/agent/agent.md` 자동 동기화. `installedCommands` 에 `hk-rca` 등록
- [x] `docs/rca/.gitkeep` + `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` 신규 — phase-16 첫 사용자 RCA
- [x] install.sh 코드 변경 0 라인 — spec-15-05 디렉토리 glob 으로 신규 2 파일이 *자동* install 매트릭스 진입 (dry-run 검증 완료)

### Phase 컨텍스트

- **Phase**: `phase-16` (Reliability Layer)
- **본 SPEC 의 역할**: phase-16 의 *지식 분류 인프라* 첫 조각 — RCA 카테고리 어휘 박기 + 첫 사용자 박기. 후속 spec-16-02 가 ADR 에 type 슬롯 도입.

## 🎯 Key Review Points

1. **§6.4 신설 위치와 §6.5 밀기**: 기존 `§6.4 Branch Naming` 을 `§6.5` 로 옮긴 결정. `agent.md` 의 `constitution §6.4` 참조도 `§6.5` 로 동시 갱신. 다른 곳의 §6.4 참조는 없음을 grep 으로 확인.
2. **type 정규 집합 5 개**: runbook 제외 이유 (RCA prevention 이 흡수). 향후 vocabulary 변경은 ADR (`type: decision`) 로 박는다는 룰.
3. **install.sh 미변경**: spec-15-05 의 디렉토리 glob 으로 sources/templates/*.md, sources/commands/*.md 가 자동 install. dry-run 검증 결과만 walkthrough 에 기록. task.md 5-1 commit 은 `[-]` Passed.
4. **사전 누적 install drift 별도 분리**: update.sh 가 본 spec 무관 4 파일 (`hk-update.md`, `settings.json`, `bin/sdd`, `check-kit-version.sh`) 도 함께 sync. 사용자 결정으로 `chore(spec-16-01): sync stale install drift` 별도 commit 으로 분리 (0ad73ca).
5. **RCA-001 의 prevention scope**: 본 RCA 가 식별한 `sdd ship` 매트릭스 확장은 *별도 spec 후보*. 본 PR 은 vocabulary + 템플릿 + 첫 사용자까지만.

## 🧪 Verification

본 spec 은 docs / script copy matrix / 신규 디렉토리 변경 — 단위 테스트 없음 (plan.md §검증 계획 명시).

### 수동 검증 시나리오

1. **install.sh dry-run**: `bash install.sh --dry-run .` → 신규 2 라인 노출 ✓
2. **본 키트 도그푸딩 mirror**: `bash update.sh --yes` → kit 0.9.0 PASS 44 / WARN 0 / FAIL 0 ✓
3. **mirror 동등성**: `diff sources/templates/rca.md .harness-kit/agent/templates/rca.md && diff sources/commands/hk-rca.md .claude/commands/hk-rca.md && diff sources/governance/constitution.md .harness-kit/agent/constitution.md` → ALL_SYNC ✓
4. **installedCommands 등록**: `jq -r '.installedCommands' .harness-kit/installed.json` → `hk-rca` 포함 ✓
5. **type 정규 집합 closure**: `grep -rh "^type:" docs/rca | sort -u` → `type: failure-pattern` 한 줄 ✓
6. **RCA-001 섹션 점검**: `grep -c "^## " docs/rca/RCA-001-*.md` → 6 (5 필수 + Related) ✓
7. **constitution §6.4 visibility**: `grep -n "Knowledge Type Vocabulary" sources/governance/constitution.md .harness-kit/agent/constitution.md` → 두 경로 모두 hit ✓

## 📦 Files Changed

### 🆕 New Files
- `sources/templates/rca.md`: RCA 템플릿 (5 섹션 + frontmatter)
- `sources/commands/hk-rca.md`: `/hk-rca` 슬래시 커맨드 가이드
- `.harness-kit/agent/templates/rca.md`: 위의 도그푸딩 mirror
- `.claude/commands/hk-rca.md`: 위의 도그푸딩 mirror
- `docs/rca/.gitkeep`: 디렉토리 컨벤션
- `docs/rca/RCA-001-sdd-ship-spec-add-missing.md`: 첫 사용자 RCA
- `specs/spec-16-01-rca-and-knowledge-types/{spec,plan,task,walkthrough,pr_description}.md`: spec 산출물
- `.harness-kit/hooks/check-kit-version.sh`: 사전 누적 drift (별도 chore commit)

### 🛠 Modified Files
- `sources/governance/constitution.md` (+18, -1): §6.4 Knowledge Type Vocabulary 신설, 기존 §6.4 Branch Naming → §6.5
- `sources/governance/agent.md` (+1, -1): `constitution §6.4` 참조 → `§6.5`
- `.harness-kit/agent/constitution.md`, `.harness-kit/agent/agent.md`: 위의 도그푸딩 mirror
- `.harness-kit/installed.json` (+1, -0 in installedCommands): `hk-rca` 등록 + planAccepted=true
- `backlog/phase-16.md`, `backlog/queue.md`: sdd 자동 갱신
- `.claude/commands/hk-update.md`, `.claude/settings.json`, `.harness-kit/bin/sdd`: 사전 누적 drift (별도 chore commit)

**Total**: 20 files changed

## ✅ Definition of Done

- [x] 단위 테스트 없음 (spec 명시)
- [x] 수동 검증 시나리오 7 종 모두 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 도그푸딩 mirror 정합성 확인 (diff 0)
- [x] 첫 사용자 RCA-001 작성 — phase-16 성공 기준 1 자연 만족
- [x] 사용자 검토 요청 알림 (push 후 PR URL 보고)

## 🔗 관련 자료

- Phase: `backlog/phase-16.md`
- Walkthrough: `specs/spec-16-01-rca-and-knowledge-types/walkthrough.md`
- 첫 RCA: `docs/rca/RCA-001-sdd-ship-spec-add-missing.md`
- 정규 어휘: `sources/governance/constitution.md` §6.4
- 후속 spec 후보: spec-16-02 (ADR type 슬롯 도입), `sdd ship` 매트릭스 확장
