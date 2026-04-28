# fix(spec-15-03): uninstall.sh KIT_COMMANDS stale 명단 fix — installedCommands 기록 + 정확 제거 (P0)

## 📋 Summary

### 배경 및 목적

spec-15-01 audit §5.3.1 에서 발견한 **P0 잠재 버그**:

`uninstall.sh:92` 의 `KIT_COMMANDS="align spec-new plan-accept ..."` 명단이 v0.3 시절 슬래시 커맨드 이름. 현재 `sources/commands/` 는 12개 모두 `hk-` 접두사 사용. 결과:

- uninstall 단독 실행 시 `.claude/commands/hk-*.md` 12개 영구 잔재
- update 흐름에서는 install 이 다시 덮어써서 우연히 정상 동작하지만, **슬래시 커맨드 이름 변경/제거** 시 사용자 환경에 stale 잔재. AI 가 stale 커맨드 사용 가능.
- install (디렉토리 glob, 자동 동기화) ↔ uninstall (하드코딩 명단) **비대칭**

### 주요 변경 사항

- [x] **install.sh**: `installed.json` 에 `installedCommands` 배열 기록 (`sources/commands/*.md` basename)
- [x] **uninstall.sh**: stale `KIT_COMMANDS` 라인 제거 → 백업의 `installed.json` 에서 명단 읽어 정확 제거 + jq 없거나 키 부재 시 `hk-*.md` glob fallback
- [x] **신규 테스트** `tests/test-uninstall-cmd-list.sh` — 4 시나리오 × 9 checks
- [x] **phase-15.md spec 명세 swap** — spec-15-03 (uninstall) ↔ spec-15-04 (regression-tests). 실행 순서 일치.

### Phase 컨텍스트

- **Phase**: `phase-15` (upgrade-safety, base: `phase-15-upgrade-safety`)
- **본 SPEC 의 역할**: P0 즉시 픽스. install/uninstall 의 *대칭화* — 이는 다른 P1/P2 (hooks/templates 명단) 의 모범 사례.

## 🎯 Key Review Points

1. **`installed.json` 스키마 확장** (`install.sh:447-466`) — 신규 키 `installedCommands` 추가만. `kitVersion`, `installedAt` 변경 없음. update.sh 의 kitVersion 읽기 무영향.
2. **백업에서 명단 읽기** (`uninstall.sh:91-104`) — `.harness-kit/` 가 line 68 에서 이미 제거되므로 `$BACKUP/.harness-kit/installed.json` 에서 읽음. 백업 본연의 목적과 자연스럽게 통합.
3. **Fallback 정책** — jq 부재 또는 legacy installed.json 의 경우 `hk-*.md` glob. 사용자 본인 hk- 접두사 사용은 컨벤션 위반으로 간주 (audit §5.3.1).
4. **JSON 조립 = 단순 텍스트** — install.sh 의 jq 의존 최소화. printf 류 문자열 조립이 더 robust.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-uninstall-cmd-list.sh   # 9/9 PASS
bash tests/test-version-bump.sh         # 전체 스위트 FAIL=0
```

**결과 요약**:
- ✅ Scenario 1: installedCommands 존재 + 12개 일치 (3 PASS)
- ✅ Scenario 2: uninstall → hk-* 제거 + 사용자 foo.md 보존 (2 PASS)
- ✅ Scenario 3: legacy installed.json → fallback 정상 (2 PASS)
- ✅ Scenario 4: update 흐름 → 명단 일치 + 사용자 baz.md 보존 (2 PASS)

### 수동 검증

```bash
F=$(mktemp -d) && bash install.sh --yes "$F" >/dev/null
jq '.installedCommands | length' "$F/.harness-kit/installed.json"
# → 12
```

## 📦 Files Changed

### 🆕 New Files
- `tests/test-uninstall-cmd-list.sh`: 4 시나리오 × 9 checks (153줄)
- `specs/spec-15-03-uninstall-cmd-list-stale/{spec,plan,task,walkthrough,pr_description}.md`

### 🛠 Modified Files
- `install.sh` (+18, -3): `installed.json` 작성 블록에 `installedCommands` 추가
- `uninstall.sh` (+12, -3): stale `KIT_COMMANDS` 제거 → installed.json 우선 + hk-* fallback
- `backlog/phase-15.md`: §spec-15-03 / §spec-15-04 swap + 위험 섹션 ID 갱신

## ✅ Definition of Done

- [x] install.sh `installedCommands` 기록
- [x] uninstall.sh stale 명단 제거 + 정확 제거 + fallback
- [x] phase-15.md spec 명세 swap + 위험 섹션 갱신
- [x] 단위 테스트 9/9 PASS
- [x] 회귀 스위트 FAIL=0
- [x] walkthrough.md / pr_description.md 작성

## 🔗 관련 자료

- Phase: `backlog/phase-15.md`
- spec-15-01 audit (의존): §5.3.1 P0 발견 / §7.4 후속 spec 명세
- 다음 spec: spec-15-04 (historical-regression-tests — 본 fix 도 회귀 테스트 시나리오 추가 후보)
