# spec-15-03: uninstall.sh KIT_COMMANDS stale 명단 fix (P0)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-15-03` |
| **Phase** | `phase-15` (base: `phase-15-upgrade-safety`) |
| **Branch** | `spec-15-03-uninstall-cmd-list-stale` |
| **상태** | Planning |
| **타입** | Fix (P0 — spec-15-01 audit 발견) |
| **Integration Test Required** | no (단위 테스트 + 도그푸딩) |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`uninstall.sh:92`:
```bash
KIT_COMMANDS="align spec-new plan-accept spec-status handoff phase-new phase-status task-done archive"
for c in $KIT_COMMANDS; do
  rm -f "$TARGET/.claude/commands/$c.md" 2>/dev/null || true
done
```

이 명단은 v0.3 시절 슬래시 커맨드 이름. 현재 `sources/commands/` 에는 12개 커맨드가 모두 **`hk-` prefix** 로 등록:
```
hk-align, hk-archive, hk-cleanup, hk-code-review, hk-doctor,
hk-phase-review, hk-phase-ship, hk-plan-accept, hk-pr-bb, hk-pr-gh,
hk-ship, hk-spec-critique
```

### 문제점

1. **uninstall 단독 실행 시 hk-* 커맨드 영구 잔재** — 사용자가 키트를 완전히 제거하려 해도 `.claude/commands/hk-*.md` 12개가 남음.
2. **Update 시 잠재 영구 잔재** — `update.sh` = `uninstall --keep-state` + `install`. uninstall 단계에서 hk-* 가 안 지워지지만 install 단계에서 동일 이름으로 덮어쓰기 → 우연히 정상 동작. 그러나 **새 버전에서 슬래시 커맨드를 *이름 변경* 또는 *제거* 하면**, 구 hk-* 가 사용자 환경에 영구 잔재. AI 가 stale 커맨드를 사용 가능.
3. **install/uninstall 비대칭** — install.sh:269-280 은 디렉토리 glob (자동 동기화 ✅) 인데 uninstall.sh:92-95 는 hardcoded 명단. 한쪽은 진화했고 한쪽은 v0.3 그대로.

### 해결 방안 (요약)

**install.sh 가 설치 시점의 슬래시 커맨드 명단을 `installed.json` 에 기록 → uninstall.sh 가 그 목록을 읽어 정확히 제거 (대칭화).**

`installed.json` 에 신규 키 `installedCommands` 추가:
```json
{
  "kitVersion": "0.6.2",
  "installedAt": "...",
  "installedCommands": ["hk-align", "hk-archive", "hk-cleanup", ...]
}
```

uninstall.sh:
```bash
if jq -e '.installedCommands' "$INSTALLED_JSON" >/dev/null 2>&1; then
  for c in $(jq -r '.installedCommands[]' "$INSTALLED_JSON"); do
    rm -f "$TARGET/.claude/commands/$c.md"
  done
else
  # legacy install — fallback
  rm -f "$TARGET/.claude/commands/hk-"*.md 2>/dev/null
fi
```

## 🎯 요구사항

### Functional Requirements

1. **F1.** `bash install.sh --yes <target>` 실행 후 `<target>/.harness-kit/installed.json` 에 `installedCommands` 배열이 존재. 배열은 `sources/commands/*.md` 의 basename (확장자 제외) 들로 구성.
2. **F2.** `bash uninstall.sh --yes <target>` 실행 시 `installedCommands` 가 있으면 그 목록의 파일만 제거. 사용자가 추가한 다른 슬래시 커맨드 (`.claude/commands/foo.md`) 는 보존.
3. **F3.** **Legacy fallback** — `installedCommands` 가 부재 (구 버전으로 install 된 환경) 면 `.claude/commands/hk-*.md` glob 으로 fallback 제거. fallback 은 hk- 접두사만 — 다른 사용자 커맨드 안전.
4. **F4.** `uninstall.sh:92` 의 stale `KIT_COMMANDS="align spec-new ..."` 라인 제거.
5. **F5.** `update.sh` 흐름에서도 정상 동작 — uninstall 단계에서 정확한 hk-* 제거 후 install 이 다시 복사.

### Non-Functional Requirements

1. **NF1.** `installed.json` 스키마 변경의 호환성: 새 키 *추가* 만. 기존 키 (`kitVersion`, `installedAt`) 변경 없음. update.sh 의 `kitVersion` 읽기 정상 동작.
2. **NF2.** bash 3.2+ 호환.
3. **NF3.** jq 미설치 환경 graceful — install.sh 의 jq 의존도는 이미 (settings.json 머지에) 존재하므로 신규 의존 추가 아님. uninstall.sh 의 신규 jq 사용처는 `command -v jq` 가드.

## 🚫 Out of Scope

- `installedCommands` 외 추가 메타데이터 (예: `installedHooks`, `installedTemplates`) — 본 spec 은 슬래시 커맨드만. 같은 패턴이 hooks/templates 에도 필요하다면 별 spec.
- update.sh 의 in-place upgrade 리팩토링 (audit §7.4 P2 후보) — 본 spec 은 현 모델 안에서의 fix.
- `installed.json` 의 schema 검증 또는 마이그레이션 도구 — fallback 으로 충분.

## ✅ Definition of Done

- [ ] `install.sh` — `installedCommands` 기록 (jq 또는 텍스트 조립)
- [ ] `uninstall.sh` — `installedCommands` 우선, 부재 시 hk-* glob fallback. `KIT_COMMANDS=...` stale 라인 제거.
- [ ] `tests/test-uninstall-cmd-list.sh` 신규 — 4 시나리오:
  1. fresh install → installed.json 에 installedCommands 존재
  2. install → uninstall: 모든 hk-* 제거됨 + 사용자 추가 foo.md 보존
  3. legacy installed.json (installedCommands 없음) → uninstall fallback 정상
  4. update 흐름 (install → uninstall → install): hk-* 잔재 없음
- [ ] `phase-15.md` §spec 명세 swap — spec-15-03 (uninstall-cmd-list-stale) ↔ spec-15-04 (historical-regression-tests)
- [ ] 회귀 스위트 PASS
- [ ] `walkthrough.md` / `pr_description.md` ship + push + PR (base: `phase-15-upgrade-safety`)
