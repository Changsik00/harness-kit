# Walkthrough: spec-24-05

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| rollup 위치 | 새 `sdd phase decisions` / `decision list --phase` 확장 | **`decision list --phase`** | 24-03 의 `decision` 커맨드 자연 확장. 기존 `list`(현재 spec) 불변 보존 |
| spec 사이 테스트 게이트 | 24-05 에 포함 / 제외 | **제외** | 이미 `post-commit-verify`(24-03 ③) + `check-test-passed` 가 담당 — 중복 회피. 24-05 는 결정 rollup 에 집중 |
| 결정 표 데이터 행 추출 | 파서 / grep 필터 | **grep 필터** (`^\|` 데이터행, 헤더·구분선 제외) | bash 3.2, 24-03 의 고정 표 형식 의존 |

## 💬 사용자 협의

- **주제**: "git main 최신 확인 — 다른 곳에서 처리했을 수 있어"
  - **합의**: 머지 전 원격 확인 → 24-02/03/04 가 다른 세션에서 머지됨을 발견. pull 동기화 후 남은 24-05 만 진행. 충돌 방지로 브랜치 선점.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-decision-phase.sh` + 전체
- **결과**: ✅ test-decision-phase 5/5, 전체 72/72

### 수동 검증
1. **Action**: 실제 phase-24 에서 `sdd decision list --phase`
   - **Result**: `(결정 로그 없음)` — phase-24 는 attended(turbo)로 만들어져 auto 결정이 없음. graceful 정상.

## 🔍 발견 사항

- **24-03/24-04 가 다른 세션에서 병렬 처리됨.** 머지 시도 직전 사용자 지시로 원격 확인 → #208(내 24-02)·#210(24-03)·#211(24-04) 이미 머지. 로컬 main 이 3 commit behind → `git pull --ff-only` 로 동기화(behind 시 /hk-update 아닌 pull — 산물 갈라짐 방지). floating `.claude/settings.json`(turbo 패치)이 ff 를 막아 discard 후 pull.
- **rollup 의 첫 실사용은 phase-25+ 다.** phase-24 자체는 turbo(attended)로 구축돼 `decision add` 호출이 없었으므로 rollup 이 비어 있다(정상). auto 모드로 phase 를 돌리는 phase-25+ 에서 결정이 쌓이고 phase-ship rollup 이 의미를 갖는다 — 닭-달걀 구조의 자연스러운 귀결.

## 🚧 이월 항목

- phase-24 를 auto 모드로 한 번 도그푸딩(phase-25 후보)하면 rollup 실효 검증 가능.
