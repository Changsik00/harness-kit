# refactor(spec-15-05): install/update 의 하드코딩 리스트 3개 → directory glob + state exclusion (P1)

## 📋 Summary

### 배경 및 목적

spec-15-01 audit §4.2 의 **Pattern A — Schema Drift** 가 가장 빈번한 버그 원인 (`#82`, `#83` 모두 발현). 본 spec 은 install.sh / update.sh 의 *명시적 enumeration* 3개를 *generic 메커니즘* 으로 교체.

### 주요 변경 사항

- [x] **install.sh:257-262** governance 하드코딩 (3 files) → **디렉토리 glob** (`sources/governance/*.md`)
- [x] **install.sh:262-267** templates 하드코딩 (8 files) → **디렉토리 glob** (`sources/templates/*.md`)
- [x] **update.sh:113-122** state 백업 inclusion (6 fields) → **exclusion** (`del(.kitVersion, .installedAt)`)
- [x] **신규 회귀 테스트** `tests/test-install-manifest-sync.sh` — sources/ 디렉토리 명단과 install 결과 1:1 검증 (Schema Drift 자동 감지)
- [x] **시나리오 6 추가** in `tests/test-update-stateful.sh` — 임의 신규 state 필드 (`_testCustomField`, `_testNumber`) 가 update 후 자동 보존되는지 검증

### Phase 컨텍스트

- **Phase**: `phase-15` (upgrade-safety, base: `phase-15-upgrade-safety`)
- **본 SPEC 의 역할**: Schema Drift 의 *근본 fix*. spec-15-03 (uninstall 대칭화) 의 패턴을 governance/templates/state 에도 확장.

## 🎯 Key Review Points

1. **state exclusion 의 의미** (`update.sh:113-122`) — install-managed 두 키 (`kitVersion`, `installedAt`) 만 제외, 나머지 자동 보존. 새 state 필드 추가 시 update.sh 손대지 않음.
2. **glob 패턴 일관성** — install.sh 의 sources/ 처리가 이제 5 영역 모두 generic (governance/templates/commands/hooks 글롭, bin cp -rf). claude-fragments 만 단일 파일 (각 fragment 가 다른 머지 정책).
3. **manifest-sync 테스트의 *향후* 가치** — 현재는 1:1 동기 사진 기록. 누군가 install.sh 를 hardcoded 리스트로 회귀시키면 즉시 빨간 신호.
4. **동작 동치** — 사용자 가시 동작 변경 0. 현재 sources/ 의 3 + 8 파일이 그대로 install 됨.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-install-manifest-sync.sh   # 6/6 PASS
bash tests/test-update-stateful.sh          # 16/16 PASS (S3 skip)
bash tests/test-version-bump.sh             # 전체 스위트 FAIL=0
```

**결과 요약**:
- ✅ manifest-sync: governance 2 + templates 2 + content 정합 2 = 6 PASS
- ✅ update-stateful 시나리오 6 (state exclusion): `_testCustomField` / `_testNumber` 보존 + kitVersion 갱신 = 3 PASS
- ✅ 기존 13 테스트 파일 회귀 0

### 수동 검증

```bash
F=$(mktemp -d) && bash install.sh --yes "$F" >/dev/null
ls "$F/.harness-kit/agent"               # constitution.md agent.md align.md (3)
ls "$F/.harness-kit/agent/templates"     # 8 templates
jq '. + {"_test":"preserved"}' "$F/.claude/state/current.json" > /tmp/_s
mv /tmp/_s "$F/.claude/state/current.json"
bash update.sh --yes "$F" >/dev/null
jq -r '._test' "$F/.claude/state/current.json"   # "preserved"
```

## 📦 Files Changed

### 🆕 New Files
- `tests/test-install-manifest-sync.sh` (90줄) — Schema Drift 자동 감지
- `specs/spec-15-05-dedupe-hardcoded-lists/{spec,plan,task,walkthrough,pr_description}.md`

### 🛠 Modified Files
- `install.sh` (+9, -6): governance + templates 루프를 디렉토리 glob 으로 교체
- `update.sh` (+3, -4): state 백업을 exclusion 으로 변경 + 주석 갱신
- `tests/test-update-stateful.sh` (+27, -1): 시나리오 6 (state exclusion) 추가

## ✅ Definition of Done

- [x] install.sh governance + templates 디렉토리 glob
- [x] update.sh state exclusion
- [x] manifest-sync 회귀 테스트 (6 checks)
- [x] state exclusion 시나리오 (3 checks)
- [x] 기존 회귀 PASS
- [x] walkthrough.md / pr_description.md 작성

## 🔗 관련 자료

- Phase: `backlog/phase-15.md`
- 의존: spec-15-01 audit §4.2 (Pattern A) / §5.4 (P1 항목) / §7.4 (spec-15-05 명세 초안)
- 참조 패턴: spec-15-03 (uninstall 대칭화) — 동일 *명단 동기화* 문제의 다른 해결법
- 다음: spec-15-06 (user-hook-preserve + 시나리오 3) 또는 phase-15 마무리
