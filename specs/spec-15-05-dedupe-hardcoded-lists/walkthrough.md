# Walkthrough: spec-15-05 (dedupe-hardcoded-lists)

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| state 보존 정책 | A) inclusion (whitelist) / B) exclusion (blacklist `del`) | **B** | inclusion 은 새 필드마다 update.sh 동기화 필요 (이미 #82 발현). exclusion 은 install template 변경 시에만 영향. install-managed 키 (kitVersion, installedAt) 만 제외 |
| governance/templates 메커니즘 | A) directory glob / B) installed.json 명단 기록 (spec-15-03 패턴) / C) manifest 파일 | **A** | sources/ 영역은 *디렉토리 통째 install* 모델. uninstall 도 `.harness-kit/` 통째 제거. 명단 기록 불필요 — drift 위험 0. commands/hooks 와 동일 패턴 |
| glob 정책 | `*.md` 만 | **확정** | bash 표준, dotfile 자연 제외, 본 프로젝트 컨벤션 일관 |
| state exclusion 의 install-managed 키 결정 | install.sh:481-491 의 8 키 중 어느 것이 install-managed? | **kitVersion + installedAt 두 개** | 나머지 6 키는 사용자 작업으로 채워지는 영역. install 은 fresh 시 null/false 로만 작성. exclusion 으로 모두 보존 |
| 테스트 분리 vs 통합 | A) 별 파일 / B) test-update-stateful.sh 의 시나리오 6 추가 | **B** | spec-15-04 의 시나리오 1~5 와 같은 맥락 (stateful upgrade). 시나리오 6 으로 추가가 응집도 ↑ |

## 💬 사용자 협의

- **주제**: P1 spec 진행 우선순위
  - **사용자 의견**: spec-15-05 가 추천 ⭐⭐ 로 가장 높음
  - **합의**: spec-15-03 의 *대칭화 패턴* 을 governance/templates/state 까지 확장. Schema Drift 의 근본 fix.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트 (`tests/test-install-manifest-sync.sh`)
- **결과**: ✅ Passed (6 / 6)
- **그룹**:
  - Group 1 — governance manifest sync (2 PASS): 3 files 일치, 파일명 1:1
  - Group 2 — templates manifest sync (2 PASS): 8 files 일치, 파일명 1:1
  - Group 3 — content cp 정합성 (2 PASS): constitution.md / spec.md diff

#### 단위 테스트 (`tests/test-update-stateful.sh` — 시나리오 6 신규)
- **결과**: ✅ Passed (16 / 16, S3 skip 제외)
- **시나리오 6 (state exclusion)** — 3 PASS:
  - `_testCustomField` 보존 (exclusion 동작)
  - `_testNumber` 보존 (다중 신규 필드)
  - kitVersion 갱신 (install-managed 키만 fresh)

#### 회귀 — `tests/test-version-bump.sh`
- **결과**: ✅ Passed (전체 스위트 FAIL=0)
- 영향 범위가 컸음에도 (`install.sh`, `update.sh` 핵심 흐름) 회귀 0. 기존 13 테스트 파일 모두 PASS.

### 2. 수동 검증

```bash
F=$(mktemp -d)
bash install.sh --yes "$F" >/dev/null
ls "$F/.harness-kit/agent" "$F/.harness-kit/agent/templates"
# → 각각 3 / 8 .md 파일 (이전과 동일)

# state exclusion
jq '. + {"_test": "preserved"}' "$F/.claude/state/current.json" > /tmp/_s
mv /tmp/_s "$F/.claude/state/current.json"
bash update.sh --yes "$F" >/dev/null
jq -r '._test' "$F/.claude/state/current.json"
# → "preserved" (이전 update.sh 라면 null)
```

✅ 동작 동치 — 사용자 가시 동작 변경 없음 + 신규 필드 보존.

## 🔍 발견 사항

### exclusion 의 부수 효과 — 사용자 직접 편집 보호

inclusion 패턴은 *지정된 키만 보존* — 사용자가 state.json 을 직접 편집해 새 필드를 추가했다면 update 시 손실. exclusion 은 *지정된 키만 제외* — 사용자 편집도 자동 보존. **반대 방향 위험** (사용자가 stale 키를 남겨둠) 도 있지만 본 프로젝트 컨벤션상 사용자가 state.json 직접 편집 안 함.

### glob 패턴이 commands/hooks 와 동일

본 변경으로 install.sh 의 sources/ 처리는 **5 영역 모두 디렉토리 glob 또는 cp -rf**:
- governance ← 본 spec
- templates ← 본 spec
- commands (이미)
- hooks (이미)
- bin (cp -rf)

claude-fragments 만 단일 파일 cp (CLAUDE.fragment.md / settings.json.fragment) — 본질적 차이 (각 fragment 가 다른 머지 정책).

### test-install-manifest-sync 의 *향후* 가치

본 테스트는 *현재* sources/governance/ + sources/templates/ 와 install 결과 1:1 일치를 검증. 만약 누군가 install.sh 를 수정해 다시 hardcoded list 로 회귀하거나 디렉토리 glob 을 망가뜨리면 즉시 빨간 신호. *현재* 사진 기록은 거의 의미 없지만 *변경 감지* 로 작용.

### update.sh exclusion 으로 향후 새 install-managed 키 추가 시 주의

만약 향후 install.sh 가 새로 `lastDoctorRun` 같은 키를 fresh 작성하기 시작하면, update.sh 의 `del(.kitVersion, .installedAt)` 도 그 키를 추가해야 함. *그래도* exclusion 패턴이 inclusion 보다 우월 — 키 추가 빈도가 훨씬 낮음 (install-managed vs user-managed).

## 🚧 이월 항목

- spec-15-06 (user-hook-preserve) 와 시나리오 3 (customized fragment) 가 다음 작업.
- spec-15-07 (harness-config-overwrite) — P2, harness.config.json OVERWRITE 정책. 사용자 영역이라기보다 키트 메타라 영향 적음. phase Done 시점에 분류.
- 본 spec 의 *exclusion 패턴* 을 settings.json 머지 (line 318-355) 에도 적용 가능 — `hooks = kit-overwrite` 정책이 사용자 hook 손실 — spec-15-06 의 핵심 주제.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-28 |
| **최종 commit** | `452e74c` (ship 직전 기준) |
