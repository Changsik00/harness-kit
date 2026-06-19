# Walkthrough: spec-24-02

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| commit 모드가 mode 를 bypass 하나 | edit 처럼 turbo/auto bypass / mode 무관 | **mode 무관** | scope 를 blast-radius 가드(B)로 재정의 — auto(unattended)에서 MCP 우회를 잡는 게 목적이라 auto 에서 *반드시* 돌아야 함 |
| 차단 vs 경고 | 차단 / 경고 | **경고(exit 0)** | hook 단계론 + ADR-009 — auto 를 멈추지 않고 blast-radius 를 *사후 노출*(phase-ship). 1주 후 차단 승격 검토 |
| 코드 중복 | edit/commit 별도 구현 / 함수 공유 | **함수 공유** | check-secrets dual-mode 선례. scope 추출·매칭·안전경로·전제를 헬퍼로 분리 |

## 💬 사용자 협의

- **주제**: "다음" — phase-24 계속 진행
  - **합의**: 24-02 (blast-radius 커밋시점 정렬) 진행

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-scope-commit.sh` + 전체
- **결과**: ✅ test-scope-commit 4/4, 전체 68/68
```text
범위 밖 staged → 경고+exit0 / 범위 안 → 무경고 / auto 에서도 경고(mode 무관) / .md 면제
```

## 🔍 발견 사항

- **scope 매칭은 디렉토리 단위(loose).** 기존 `check-scope.sh` 의 매칭이 `${pattern%/*}/` — scope 가 `src/in-scope.sh` 면 `src/` *전체* 가 통과한다. 처음 테스트에서 out-of-scope 파일을 같은 `src/` 에 둬서 "범위 안"으로 통과 → 테스트 자체가 Red 를 잘못 잡음. out-of-scope 파일을 *다른 디렉토리*(`lib/`)로 바꿔 해결. (impl 버그 아님 — 기존 의미론을 테스트가 안 지킨 것)
- **24-01 의 pre-commit turbo 수정이 실증됨.** 본 spec 의 실패 테스트(.sh)를 turbo 에서 `plan accept` *없이* 커밋 성공 — 24-01 직전 spec 에서는 같은 상황이 차단됐었다. 회귀 방지 가치 확인.

## 🚧 이월 항목

- scope 디렉토리-단위 매칭이 의도보다 느슨할 수 있음(같은 디렉토리 내 임의 파일 통과). 파일-단위 엄격 매칭이 필요한지는 commit-warn 운영 데이터 본 후 판단 — 현재는 기존 의미론 보존.
- 경고 → 차단 승격: 1주 운영 후 (hook 단계론).
