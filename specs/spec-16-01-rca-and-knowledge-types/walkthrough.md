# Walkthrough: spec-16-01

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 정규 type 집합 개수 | 4 / 5 / 6 | **5** (decision / invariant / failure-pattern / convention / tradeoff) | runbook 은 RCA prevention 이 흡수. 5 가 grep / 인지 부하 균형점 — 추가 제안서 §D 의 권장과 일치 |
| 어휘 문서화 위치 | constitution §6 / 별도 vocabulary.md / ADR | **constitution §6.4 신설** | §6 이 식별자 시스템 — type 도 명명 규약. 외부 문서 분산 회피 |
| 기존 §6.4 (Branch Naming) 처리 | §6.5 로 밀기 / §6.0 으로 끌어올리기 | **§6.5 로 밀기** | 본 spec 의 본질이 *새 어휘 추가*. §6.4 위치가 ADR (§6.3) 옆이 의미상 자연스러움. agent.md §6.4 참조도 §6.5 로 동시 갱신 |
| install matrix 확장 commit | install.sh 명시 변경 / glob 자동 흡수 | **glob 자동 흡수** ([-] passed) | spec-15-05 의 디렉토리 glob 으로 sources/templates/*.md, sources/commands/*.md 가 *자동* install. 코드 변경 0 라인이라 commit 생략. dry-run 검증만 |
| 도그푸딩 mirror 실행 도구 | install.sh / update.sh | **update.sh --yes** | install.sh 는 이미 설치된 경우 사용자 확인 프롬프트(`/dev/tty`)를 띄워 비대화형 환경에서 실패. update.sh 가 권장 경로 |
| 사전 누적 install drift 처리 | Task 5-2 흡수 / 별도 commit / 되돌리기 | **별도 chore commit** | 사용자 결정. PR scope 깨끗하게 유지 + history 추적 용이. `chore(spec-16-01): sync stale install drift` 1 commit 으로 분리 |
| 첫 RCA 주제 | gh CLI 실패 / sdd ship 산출물 누락 / Plan Accept 흐름 | **sdd ship 산출물 누락** | 두 번 연속 (spec-x-readme-refresh, spec-x-phase-16-define) 확인된 실제 운영 이슈. phase 성공 기준 1 (1 회 RCA) 자연 만족 + 두 번째 사용 우려 차단 |
| RCA-001 의 prevention 범위 | 본 spec 내 fix / 별도 spec 후보 | **별도 spec 후보** | 본 spec 은 *vocabulary + 템플릿 + 첫 사용자*. sdd ship 코드 수정은 별도 작업으로 분리 — scope 폭주 회피 |

## 💬 사용자 협의

- **주제**: 의도 외 install drift 처리
  - **상황**: update.sh 실행 시 본 spec 과 무관한 사전 누적 drift 4 파일 (`hk-update.md`, `settings.json`, `bin/sdd`, `check-kit-version.sh`) 이 함께 sync
  - **사용자 의견**: 별도 chore commit 으로 *분리* — PR scope 깨끗하게 유지
  - **합의**: `chore(spec-16-01): sync stale install drift` 별도 commit (0ad73ca). 본 spec PR 에는 포함되지만 history 상 의도 mirror 와 분리 가능

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: 본 spec 은 docs / script copy matrix / 신규 디렉토리 변경. 단위 테스트 *없음* (plan.md §검증 계획 명시).
- **결과**: N/A

#### 통합 테스트
- **결과**: N/A (phase 단위 통합 테스트는 `/hk-phase-ship` 시점)

### 2. 수동 검증

1. **Action**: `bash install.sh --dry-run .`
   - **Result**: 신규 2 라인 노출 — `sources/templates/rca.md → .harness-kit/agent/templates/rca.md`, `sources/commands/hk-rca.md → .claude/commands/hk-rca.md`
2. **Action**: `bash update.sh --yes`
   - **Result**: kit version 0.9.0 유지, PASS 44 / WARN 0 / FAIL 0
3. **Action**: `diff sources/templates/rca.md .harness-kit/agent/templates/rca.md && diff sources/commands/hk-rca.md .claude/commands/hk-rca.md && diff sources/governance/constitution.md .harness-kit/agent/constitution.md`
   - **Result**: 모두 동일 (ALL_SYNC)
4. **Action**: `jq -r '.installedCommands' .harness-kit/installed.json`
   - **Result**: `hk-rca` 포함 (총 14 commands, 알파벳 정렬)
5. **Action**: `grep -rh "^type:" docs/rca | sort -u`
   - **Result**: `type: failure-pattern` 한 줄 — 정규 집합 안
6. **Action**: `grep -c "^## " docs/rca/RCA-001-*.md`
   - **Result**: 6 (5 필수 섹션 + Related)
7. **Action**: `grep -n "Knowledge Type Vocabulary" sources/governance/constitution.md .harness-kit/agent/constitution.md`
   - **Result**: 두 경로 모두 line 213 hit

## 🔍 발견 사항

- **install.sh 비대화형 실패**: 이미 설치된 환경에서 `install.sh .` 가 사용자 확인 프롬프트를 띄우고 `/dev/tty` not configured 에서 즉시 취소. 비대화형 (Claude Code 세션) 에서는 update.sh 가 사실상 유일 경로 — 가이드 / `hk-rca.md` 사전 검증 단계에서 update.sh 안내가 더 정확할 수 있음. (별도 개선 후보 — backlog Icebox)
- **glob 매트릭스의 효과**: spec-15-05 의 디렉토리 glob 덕분에 install.sh 코드 한 줄 변경 없이 새 template / command 가 자연 install. 본 spec 이 그 효과를 처음 *증명*한 사례. install.sh 매트릭스가 "schema drift" 도구에서 "확장 친화 매트릭스"로 자연 진화.
- **사전 누적 install drift 의 가시화**: update.sh 가 본 spec 무관한 4 파일 drift 를 노출. 정상 운영에서 update.sh 가 정기 실행되지 않으면 mirror 가 *조용히* 어긋남. 정기 sync 시점이 없음 — 별도 개선 후보.

## 🚧 이월 항목

- **RCA-001 의 직접 fix**: `sdd ship` 의 git add 매트릭스에 `specs/<active-spec>/{spec,plan,task}.md` 도 포함 → 별도 spec-x 또는 phase-16 후속 spec 후보. 본 RCA prevention 섹션에 명시.
- **install.sh 비대화형 모드**: 비대화형 환경 detection 후 `--force` 또는 update.sh 자동 위임 → Icebox 후보.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent (Opus 4.7) + 사용자 |
| **작성 기간** | 2026-05-15 |
| **최종 commit** | (ship commit 직후 갱신 예정) |
