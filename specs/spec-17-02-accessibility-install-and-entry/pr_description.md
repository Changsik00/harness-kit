# feat(spec-17-02): Accessibility — `/hk` 단일 진입점 + README onboarding

> ★ **PR Target**: `phase-17-coherence-fix` (main 직 PR 아님 — phase base branch 모드)

## 📋 Summary

### 배경 및 목적

phase-17 (운영 성숙도) 의 *외부 접근성* 묶음 — 신규/기존 사용자가 키트의 13 개 슬래시 커맨드를 외울 필요 없이 *현재 상태에서 다음에 무엇을 해야 하는지* 1 줄로 안내받게 한다. install 경로 (`get.sh`) 는 이미 존재 + 작동 — 본 PR 은 *진입점 단순화* 와 *onboarding 가시성* 에 집중.

phase-16 회고 시점 Icebox 의 "접근성 개선 Phase 후보" 가 사용자 피드백 ("phase 단위가 너무 작다") 으로 phase-17 안으로 흡수된 결과 — 본 PR 이 그 결정의 직접 실현.

### 주요 변경 사항

- [x] **`/hk` 슬래시 커맨드 신규** (`sources/commands/hk.md` + `.claude/commands/hk.md`) — 8 상태 분기 (7 매핑 + 1 fallback). read-only 안내, state 변경 동작은 기존 `hk-*` 커맨드 호출에 위임.
- [x] **README onboarding 갱신** — Step 1 (`/hk-align`) 직후에 `/hk` 보완 진입점 안내 5 줄. `/hk-align` (세션 시작 부트스트랩) vs `/hk` (작업 중 가벼운 안내) 차이 명시.
- [x] **install URL 접근성 확인** — `curl -fsSL ... get.sh` → 정상 fetch + valid bash script. 실제 install 동작은 fixture 환경 외부에서 검증 필요 (본 PR scope 밖).
- [x] **phase-17.md spec table 재조정** — sdd 가 sequential 로 17-02 할당함 수용 (accessibility = 17-02, internal-reliability = 17-03 으로 swap).

### Phase 컨텍스트

- **Phase**: `phase-17` — 운영 성숙도 (Operational Maturity)
- **Base branch**: `phase-17-coherence-fix`
- **본 SPEC 의 역할**: phase-17 의 *외부 접근성* 묶음 (4 spec 중 P0). spec-17-01 (sdd marker bugs) 의 *내부 신뢰성* 과 함께 phase-17 의 두 축 중 하나 완수.

## 🎯 Key Review Points

1. **8 상태 매핑 완전성** — `/hk` 가 가능한 모든 sdd state 조합을 7 매핑 + 1 fallback 으로 커버하는가. *상태 조합 누락* 시 fallback 동작.
2. **read-only 원칙 일관성** — `/hk` 가 *상태 변경* 동작 (Plan Accept, Ship 등) 을 절대 하지 않음. 추천만, 실행은 사용자.
3. **`/hk-align` 과의 역할 분리** — *세션 시작 부트스트랩* vs *작업 중 안내*. README 와 `/hk` 자체 설명에 모두 명시.
4. **README onboarding 침습 최소** — Step 1 안에 5 줄 추가만. install 섹션 / 본문 구조 / 한영 병기 슬로건 (phase-16) 모두 보존.

## 🧪 Verification

### 자동 테스트 (단위 + 회귀)
```bash
# 단위
diff sources/commands/hk.md .claude/commands/hk.md   # identical
grep -c "/hk\`" README.md                            # ≥2

# 회귀
bash tests/test-sdd-marker-idempotent.sh             # 3/3 PASS
bash tests/test-drift-stale-adr.sh                   # 3/3 PASS

# Install URL 접근성
curl -fsSL --max-time 5 https://raw.githubusercontent.com/Changsik00/harness-kit/main/get.sh | head -3
# → #!/usr/bin/env bash + set -euo pipefail
```

**결과 요약**:
- ✅ `/hk` install 미러 동일성
- ✅ 7 상태 키워드 모두 hit (Active phase 없음, Plan Accept, /hk-ship, /hk-phase-ship 등)
- ✅ README onboarding 갱신 (`/hk` 2 곳 hit)
- ✅ install URL 접근성 + valid bash script
- ✅ 회귀 0 (spec-17-01 / spec-16-03 단위 테스트 모두 통과)

### 통합 테스트 (Integration Test Required = yes)
phase-17 시나리오 3 (단일 명령 install + 진입점) 의 *진입점 부분* 검증. install 부분은 *URL 접근성* 으로 1 단계 (실제 fresh install 은 fixture 환경 필요).

### 수동 검증 시나리오
1. **`/hk` 자기 시연** — 현 phase-17 상태에서 `/hk` 호출 → 상태 6 (Strict Loop) 안내 (본 spec 의 ship 직전 시점에 *현 행동* 정확히 안내) ✓
2. **README Step 1 가독성** — `/hk-align` 직후 `/hk` 보완 섹션이 자연스러움 ✓
3. **install URL 접근성** — get.sh 가 valid bash script 형식으로 fetch ✓

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/hk.md` (65 줄) — `/hk` slash command 본문 (8 상태 분기)
- `.claude/commands/hk.md` (65 줄) — install 미러
- `specs/spec-17-02-accessibility-install-and-entry/spec.md` / `plan.md` / `task.md` / `walkthrough.md` / `pr_description.md`

### 🛠 Modified Files
- `README.md` (+8, -0) — Step 1 에 `/hk` 안내 추가
- `backlog/phase-17.md` — spec table swap (17-02 ↔ 17-03 의 의미 정렬)
- `backlog/queue.md` — sdd spec new 자동 갱신

**Total**: 9 files changed (7 new + 2 modified)

## ✅ Definition of Done

- [x] `/hk` 슬래시 커맨드 작성 + install 미러 동기화
- [x] README onboarding 갱신
- [x] install URL 접근성 검증
- [x] 단위 grep + 회귀 테스트 PASS
- [x] `walkthrough.md` / `pr_description.md` ship commit

## 🔗 관련 자료

- Phase: `backlog/phase-17.md` (운영 성숙도)
- Walkthrough: `specs/spec-17-02-accessibility-install-and-entry/walkthrough.md`
- 사용자 피드백 메모리: `feedback_phase_size.md` (phase 단위 적정 크기)
- 선행 spec: spec-17-01 (sdd marker bugs fix — *내부 신뢰성* 쪽)

## ⏭ 다음 단계

본 PR 머지 → phase-17 의 spec-17-03 (internal-reliability-infra, P1) 진입. cache 분리 + integration test + doctor 확장 묶음.
