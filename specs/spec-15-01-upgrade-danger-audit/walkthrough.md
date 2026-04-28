# Walkthrough: spec-15-01 (upgrade-danger-audit)

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 산출물 파일명 | A) `report.md` (constitution §9.2 명세) / B) `spec.md` (도구 운영 현실) | **B** | 사용자 지적 — `.harness-kit/agent/templates/` 에 report.md 템플릿 부재, sdd CLI 가 spec.md 만 생성, 운영 일관성 우선. constitution 흠집은 §7.4 P2 후보로 등록 |
| Fixture 옵션 | A) 함수 합성 / B) declarative manifest / C) file-per-scenario | **A** | 5~10 시나리오 규모에 B 의 파서 비용 정당화 안 됨 (YAGNI). 기존 `make_fixture()` 와 자연스럽게 통합. bash 3.2 호환. 50+ 로 커지면 B 로 마이그레이션 |
| 본 phase 의 P0 흡수 여부 | A) audit 만 머지 후 별도 phase / B) P0(spec-15-04) 본 phase 흡수 | **B** | uninstall.sh stale KIT_COMMANDS 는 슬래시 커맨드 rename 시 즉시 사용자 영향. 발견 즉시 같은 phase 안에서 픽스가 안전 |
| update.sh 모델 리팩토링 | A) 본 audit 에서 spec 화 / B) 별도 research spec 또는 후속 phase | **B (P2)** | "uninstall+install" 모델 자체 변경은 거대 변경. 본 audit 결론을 검증한 뒤 별 research 가 적합 |

## 💬 사용자 협의

- **주제**: 사용자가 update 후 반복적으로 발견하는 버그가 위험 신호
  - **사용자 의견**: "이전에 사용하고 있던 사람이 update 를 했을때 state, phase, specs 기타등등이 존재 하고 있을텐데 이 부분에서 계속 버그가 나오고 있어 .. 위험지역으로 판단되고 있고 이 부분에 대해서 심층 분석이 필요"
  - **합의**: phase-15 신설 + spec-15-01 audit 으로 시작.

- **주제**: `report.md` vs `spec.md`
  - **사용자 의견**: "report.md 가 spec.md 로 해야 하는거 아냐?"
  - **합의**: spec.md 로 통일. constitution §9.2 의 "report.md replaces spec.md" 는 미운영 규약 → §7.4 P2 후보로 등록 (`report-md-spec-md-cleanup`)

## 🧪 검증 결과

### 1. 자동화 테스트

본 spec 은 Research Spec — 코드 수정 0. 검증은 회귀 스위트로:

- **명령**: `bash tests/test-version-bump.sh`
- **결과**: ✅ Passed (6 / 6 + 전체 스위트 FAIL=0)

### 2. 수동 검증 — 산출물 자체 검토

§3 DoD 체크리스트 통과 여부:
- ✅ §4 과거 버그 분석 (4건 카탈로그 + 3개 패턴 + 잠재 위험 후보)
- ✅ §5 install/update/uninstall 정책 단면 (12개 처리 단위 분류 + P0 잠재 버그 발견)
- ✅ §6 fixture 옵션 비교 (3 옵션 × 10 기준 trade-off + 권고)
- ✅ §7 후속 spec 명세 (4건 spec 초안 + Go/No-Go GO + 5단계 액션)
- ✅ phase-15.md 갱신 (spec 표 + 위험 섹션)

### 3. 분석 깊이 검증

- 4건 버그 spec 디렉토리 정독: ✅
- 4건 머지 commit diff (`git show`) 정독: ✅
- install.sh / update.sh / uninstall.sh 라인 단위 정독: ✅
- 기존 fixture 패턴 (`tests/test-sdd-base-branch.sh`, `tests/test-update.sh`) 정독: ✅

## 🔍 발견 사항

### 가장 중요한 발견 — uninstall.sh 의 KIT_COMMANDS stale (P0)

`uninstall.sh:92` 의 KIT_COMMANDS 리스트가 **구 슬래시 커맨드 이름** (`align`, `spec-new`, `plan-accept`, `phase-new` 등) 을 가리키고 있다. 현재 `sources/commands/` 는 모두 **`hk-` prefix** (`hk-align`, `hk-plan-accept`, ...). 즉 uninstall 은 어떤 hk-* 슬래시 커맨드도 제거하지 않음. update 시점에 install 이 다시 덮어쓰기 때문에 우연히 정상 동작하지만, **슬래시 커맨드가 이름 변경 또는 제거되는 순간 사용자 환경에 영구 잔재**.

이는 **install.sh:269-280 (디렉토리 glob, 자동 동기화) ↔ uninstall.sh:92-95 (하드코딩 명단) 의 비대칭** 이 원인. install 측은 spec-9 phase 에서 디렉토리 glob 으로 진화했는데 uninstall 측은 v0.3 시절 명단 그대로.

### 거버넌스 흠집 — `report.md` 명세

constitution §9.2 의 "Research Report: `report.md` (replaces `spec.md` for research-only specs)" 는 운영되지 않은 규약. 실제로 본 spec 작성 중 사용자 지적으로 발견. spec-15-01 자신이 첫 적용 시도였는데 도구가 받쳐주지 않음.

### update.sh = uninstall + install 모델의 부담

본 audit 의 4건 버그 + P0/P1 잠재 버그가 모두 **"install.sh 가 항상 OVERWRITE → update.sh 가 사후 복원"** 패턴에서 비롯. 각 OVERWRITE 마다 사용자 자산을 보호할 별도 로직이 필요. 이 모델 자체를 **in-place upgrade** 로 리팩토링하면 위험 면적이 한 자릿수로 줄어들 가능성. 단 거대 변경이라 별 research spec 필요. §7.4 P2 후보.

### 3개 패턴의 보편성

Schema Drift / User Content Blindness / Insufficient Idempotency — 이 셋은 *어떤 메타-도구* 라도 만나는 패턴. harness-kit 이 도그푸딩 메타 도구라 발현 빈도가 높을 뿐. fixture 시스템 (spec-15-02) 이 이 셋을 명시적으로 검증하면 향후 본 프로젝트뿐 아니라 키트가 install 되는 *다른 프로젝트* 도 보호.

## 🚧 이월 항목

- **`inplace-upgrade-rewrite`** (P2, TBD) → 후속 research spec 또는 phase 후보. 본 phase Done 시점에 다시 평가.
- **`report-md-spec-md-cleanup`** (P2, TBD) → 거버넌스 흠집. 본 phase Done 시점에 Icebox 또는 phase-16 후보로 분류.
- 통합 시나리오 5번 (신규 산출물 도입) — spec-15-03 에서 구체화 시 fixture 자체에 "이전 버전 install.sh" 시뮬레이션이 필요할 수 있음 — 추가 mixin 후보.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-28 |
| **최종 commit** | `945da9c` (ship 직전 기준) |
