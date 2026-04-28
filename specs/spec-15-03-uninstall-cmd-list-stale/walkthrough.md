# Walkthrough: spec-15-03 (uninstall-cmd-list-stale)

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 명단 기록 위치 | A) `installed.json.installedCommands` / B) 별도 manifest 파일 | **A** | 이미 install.sh 가 쓰는 파일. 신규 파일 없이 기존 스키마 확장. update.sh 의 kitVersion 읽기 무영향 |
| JSON 조립 방식 | A) jq -n / B) 단순 텍스트 (printf 류) | **B** | install.sh 의 jq 의존도 최소화 (settings.json 머지 외엔 회피). 단순 문자열 조립이 더 robust |
| `installed.json` 읽기 시점 | A) `.harness-kit/` 제거 *전* / B) 백업 디렉토리에서 | **B** | `.harness-kit/` 는 line 68 에서 제거됨. 백업 디렉토리 (`$BACKUP/.harness-kit/installed.json`) 에서 읽는 게 자연스러움 |
| Fallback 패턴 | A) 모든 .md 제거 / B) `hk-*.md` glob 만 / C) fallback 없음 | **B** | hk- 접두사는 본 프로젝트 컨벤션 (audit §5.3.1). 사용자 본인 hk- 접두사 사용은 컨벤션 위반으로 간주 |
| spec 명세 swap | A) phase-15.md 그대로 (audit §7.4 순서) / B) 실행 순서대로 swap | **B** | sdd 가 단순 카운터로 ID 할당. ID 와 실행 순서 일치가 자연스러움. audit §4.3 Pattern B 와도 일관 |

## 💬 사용자 협의

- **주제**: P0 fix 우선
  - **사용자 의견**: 본 spec 을 회귀 테스트 spec 보다 먼저 진행
  - **합의**: 작은 단위 + 사용자 영향 즉시 제거. 회귀 테스트 spec 은 다음 spec-15-04 로.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (`tests/test-uninstall-cmd-list.sh`)
- **결과**: ✅ Passed (9 / 9)
- **시나리오**:
  - Scenario 1 (F1): `installed.json.installedCommands` 존재 + 12개 항목 — 3 PASS
  - Scenario 2 (F2): uninstall → hk-* 제거 + 사용자 foo.md 보존 — 2 PASS
  - Scenario 3 (F3): legacy installed.json (키 제거) → fallback 정상 — 2 PASS
  - Scenario 4 (F5): update 흐름 (install → uninstall → install) → 명단 일치 + 사용자 baz.md 보존 — 2 PASS

#### 회귀 — `tests/test-version-bump.sh`
- **결과**: ✅ Passed (6 / 6 + 전체 스위트 FAIL=0). `test-update.sh`, `test-install-layout.sh`, `test-fixture-lib.sh` 등 모두 통과.

### 2. 수동 검증

```bash
F=$(mktemp -d)
bash install.sh --yes "$F" >/dev/null
jq '.installedCommands' "$F/.harness-kit/installed.json"
# → ["hk-align","hk-archive","hk-cleanup","hk-code-review","hk-doctor",
#    "hk-phase-review","hk-phase-ship","hk-plan-accept","hk-pr-bb",
#    "hk-pr-gh","hk-ship","hk-spec-critique"]
```

✅ 12 항목 정확히 기록.

## 🔍 발견 사항

### `.harness-kit/` 가 line 68 에서 먼저 제거됨

uninstall.sh 의 흐름이 "백업 → .harness-kit 제거 → settings.json hooks 제거 → commands/ 정리" 순. `installed.json` 을 line 91 부근에서 읽으려면 이미 제거된 상태. **백업 디렉토리** 에서 읽는 방식으로 해결 — 코드 단순성 + 백업 본연의 목적 (recoverability) 둘 다 충족.

### 본 프로젝트 도그푸딩 시 hk-* 잔재 가능성

본 프로젝트는 `installed.json` 에 `installedCommands` 가 없는 (구) 상태로 시작. 다음 update 시 fallback 으로 hk-* 가 정확히 제거됨. 이후 install 이 새 installed.json 을 쓰면 다음 uninstall 부터는 정확 모드.

### `KIT_COMMANDS` 라인 외부 참조 가능성 — 없음

`grep -r KIT_COMMANDS` 검색 결과 uninstall.sh 외 참조 없음. 안전하게 제거.

## 🚧 이월 항목

- 본 spec 의 패턴 (`installed.json` 에 install 명단 기록 → uninstall 이 그 목록 사용) 을 **hooks** 와 **templates** 에도 적용 가능. spec-15-01 §7.4 의 spec-15-05 (`dedupe-hardcoded-lists`) 와 자연스럽게 통합. 본 spec 은 슬래시 커맨드만 — Out of Scope 명시.
- jq 미설치 환경에서 `installedCommands` 가 *기록*은 되지만 *uninstall 이 fallback 으로 동작* — 실 사용에서 jq 가 필수 의존이라 영향 적음. doctor.sh 가 jq 점검 함.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-28 |
| **최종 commit** | `543ad4d` (ship 직전 기준) |
