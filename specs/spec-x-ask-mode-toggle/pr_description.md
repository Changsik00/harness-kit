# feat(spec-x-ask-mode-toggle): uxMode 토글 액션 + `/hk-ask-mode` 슬래시 커맨드

## 📋 Summary

### 배경 및 목적

`uxMode` 는 `AskUserQuestion` 사용 여부를 결정하는 영구 설정 (agent.md §8.4). 기존에는 변경하려면 *현재값* 을 알고 *반대 값* 을 외워 `sdd config ux-mode interactive|text` 를 타이핑해야 했고, 슬래시 커맨드도 없어 `/` 자동완성으로 발견할 수 없었다.

본 spec 은 두 가지 UX 개선을 추가한다:
1. **CLI 토글 액션**: `sdd config ux-mode toggle` — 현재값을 자동 반전.
2. **슬래시 커맨드**: `/hk-ask-mode` — 위 토글을 한 번에 호출.

### 주요 변경 사항

- [x] `sources/bin/sdd` 의 `_config_ux_mode` 에 `toggle` 분기 추가 + 도움말/에러 메시지 갱신
- [x] `sources/commands/hk-ask-mode.md` 신설 (description + 단일 bash 호출)
- [x] `sources/governance/agent.md` §8.4 의 변경 방법 안내에 toggle + 슬래시 명시
- [x] 도그푸딩 동기화: `.harness-kit/bin/sdd`, `.harness-kit/agent/agent.md`, `.claude/commands/hk-ask-mode.md`, `.harness-kit/installed.json`
- [x] `tests/test-sdd-config.sh` 에 T5(toggle 양방향) / T6(에러 메시지) 추가
- [x] 작업 중 발견된 3 건의 부수 이슈를 `backlog/queue.md` Icebox 에 등록

### Phase 컨텍스트

- **Phase**: 없음 (spec-x — Solo Spec)
- **본 SPEC 의 역할**: `uxMode` 설정의 일상 사용 마찰 해소. 향후 `/hk-doctor` 출력에 `uxMode` 노출 등 후속 발견성 개선은 별도 spec 으로.

## 🎯 Key Review Points

1. **CLI 동작의 멱등성과 자기 일관성**: `toggle` 분기가 *읽고 → 반전 → 기존 set 로직 재사용* 구조라 새 race condition / 출력 차이 없음. 출력 포맷 (`✓ uxMode = $value`) 도 기존 set 액션과 동일.
2. **거버넌스 한 줄 갱신** (§8.4): "to change" 안내가 enum 형식 (`[interactive|text|toggle]`) + 슬래시 alias 를 모두 노출. 신규 사용자 진입 시 메뉴 한눈에 보임.
3. **도그푸딩 동기화 4 종**: sources/ 와 `.harness-kit/` / `.claude/` / `.harness-kit/installed.json` 의 sources↔installed 정합성 유지. `test-governance-dedup` 의 cp 정합 체크 통과.
4. **Pre-existing FAIL 비대응 결정**: `test-uninstall-cmd-list.sh` Scenario 1 (sources/installed 개수 불일치) 과 `test-governance-dedup` 단어 수 초과는 모두 main 부터 존재하던 결함. 본 PR 범위 외 — Icebox 등록 후 별도 spec 으로 처리. → walkthrough.md "발견 사항" 참조.

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-sdd-config.sh
```

**결과 요약**:
- ✅ T1~T4 (기존 시나리오): 무회귀
- ✅ T5 (toggle 양방향): interactive → text → interactive
- ✅ T6 (에러 메시지 toggle 노출): PASS
- **Total**: 7 PASS / 0 FAIL

### 수동 검증 시나리오

1. **현재값 조회**: `sdd config ux-mode` → `uxMode: interactive`
2. **첫 토글**: `sdd config ux-mode toggle` → `✓ uxMode = text`
3. **재토글 (원복)**: `sdd config ux-mode toggle` → `✓ uxMode = interactive`
4. **잘못된 값**: `sdd config ux-mode invalid` → `✗ 허용된 값: interactive | text | toggle (입력: invalid)`
5. **슬래시**: `/hk-ask-mode` 입력 → 자동완성에 `(project)` 만 표시, 호출 시 동일 토글 동작

## 📦 Files Changed

### 🆕 New Files

- `sources/commands/hk-ask-mode.md`: `/hk-ask-mode` 슬래시 커맨드 정의 (description + 단일 bash 호출)
- `.claude/commands/hk-ask-mode.md`: 도그푸딩 복사본
- `specs/spec-x-ask-mode-toggle/{spec,plan,task,walkthrough,pr_description}.md`: SDD 산출물

### 🛠 Modified Files

- `sources/bin/sdd` (+11, -3): `_config_ux_mode` 의 toggle 분기 + 도움말/에러 메시지 갱신
- `.harness-kit/bin/sdd` (+11, -3): 도그푸딩 동기화
- `sources/governance/agent.md` (+1, -1): §8.4 변경 방법 안내 갱신
- `.harness-kit/agent/agent.md` (+1, -1): 도그푸딩 동기화
- `.harness-kit/installed.json` (+1, -0): `installedCommands` 배열에 `hk-ask-mode` 추가
- `tests/test-sdd-config.sh` (+42, -0): T5/T6 시나리오 추가
- `backlog/queue.md` (+3, -0): Icebox 항목 3 건 추가

**Total**: 12 files changed

## ✅ Definition of Done

- [x] `tests/test-sdd-config.sh` 7/7 PASS
- [x] `walkthrough.md` / `pr_description.md` 작성
- [x] sources↔installed 정합성 유지 (`test-governance-dedup` cp 체크 PASS)
- [x] 부수 발견 3 건 Icebox 등록
- [ ] PR 생성 + URL 보고

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-ask-mode-toggle/walkthrough.md`
- 관련 거버넌스: `sources/governance/agent.md` §8.4 AskUserQuestion Tool Preference
