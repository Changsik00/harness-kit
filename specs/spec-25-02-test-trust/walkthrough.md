# Walkthrough: spec-25-02

> 사후 테스트 신뢰(#212 비용 사다리)를 위험 비례로 — 칸0(commit-time 휴리스틱) + 칸2(의도 앵커 적대적 반증 골격).

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 칸0 구현 방식 | revert 자동 실행 / 정적 휴리스틱 | **정적 휴리스틱** | 자동 revert 는 컴퓨트(=칸1 영역). 토큰 0·상시·스택 무관을 지키려 "구현 변경에 테스트 동반했나 / 단언 있나"의 정적 프록시 |
| 칸2 구현 형태 | bash hook / 커맨드(에이전트 디스패치) | **커맨드(`hk-refute`)** | 적대적 반증은 LLM 구동이라 hook 불가. hk-spec-critique 형제이되 입력이 코드가 아닌 **의도(spec)** |
| 칸0·칸2 한 spec 유지 vs 분할 | 통합 / 칸2 → spec-25-05 | **통합 유지** | 칸0=정적 hook, 칸2=커맨드 골격 둘 다 경량이라 한 PR 로 과대하지 않음. 분할 출구는 남겨둠 |
| 칸0 발동 모드 | warn / block | **warn (1차)** | 휴리스틱이라 coarse — 오탐을 운영으로 관찰 후 승격(hook 단계론) |

## 💬 사용자 협의

- **주제**: #212 전체를 sdd 에서 처리하게 계획됐나?
  - **합의**: 칸0 만 등록돼 있었음(칸1·칸2 누락 = "선언만" 갭). **칸0+칸2 를 spec-25-02 에 통합, 칸1(뮤테이션)은 Icebox→phase-26 등록**으로 #212 전체를 sdd SSOT 화.
- **주제**: Plan Accept vs Critique
  - **합의**: 설계 불확실성(칸0 의미성·분할)에 critique 를 *권고* 했으나 사용자가 Plan Accept(1) 선택 — 골격 수준이라 진행.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-test-trust.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (test-trust 5/5, 전체 74/74, FAIL 0)
```text
칸0: (a)구현+테스트무변경→경고 / (b)단언없는테스트→경고 / 구현+테스트동반→무경고 / 안전경로→무경고 / self-match 오탐방지
```

### 수동 검증 (라이브)
1. **칸0 경고**: Task 2-2 커밋 시 pre-commit 이 `check-test-trust.sh` 를 돌려 `sources/hooks/pre-commit.sh`(테스트 없는 구현 변경)를 **실제로 경고**(비차단, 커밋 진행). `.harness-kit/*` 미러는 안전 경로로 올바르게 제외.
2. **칸2 권고 노출**: `hk-refute` 커맨드 등록(스킬 목록 노출) + agent.md §6.7 위험비례 렌즈 존재. (골격 — 고위험 자동 트리거는 scope 외)

## 🔍 발견 사항

- **칸0 휴리스틱의 self-match 위험**: `check-test-trust.sh` 파일명에 'test' 가 들어가 *테스트로 오분류*될 뻔함. `_tt_is_test` 를 "테스트 디렉토리 하위 또는 basename 이 test 로 시작/끝/`.test.`" 로 엄격화해 해소(테스트 E 로 고정).
- **fixture 우발 토큰**: "no assertion" 문자열이 단언 토큰 `assert` 를 포함 → 정적 grep 이 참으로 오판. fixture 를 중립 문자열로 교정(Red 커밋 amend).
- **`-b`/`\b` 비이식성 회피**: 단언 grep 에서 word-boundary 대신 broad 토큰(`-eq `·`[[`·`grep -q` 등)으로 macOS/bash 3.2 호환 유지.
- **칸0 의 진짜 가치는 경고 자체가 라이브로 작동함을 도그푸딩으로 증명한 것** — 내 커밋이 첫 적발 대상이 됐다.

## 🚧 이월 항목

- **칸2 완전 자동화** — 현재는 골격(커맨드+렌즈). 고위험 감지 시 *자동 호출*은 운영 데이터 축적 후 검토 (spec-25-02 Out of Scope).
- **칸1 (뮤테이션)** — queue.md Icebox → phase-26 후보 (이미 등록).
- **칸0 오탐 관찰** — 리팩터/extensionless 스크립트(`sources/bin/sdd`)는 `bin/*` 로 code 처리하나, 경고 노이즈를 1주 운영 후 평가.
