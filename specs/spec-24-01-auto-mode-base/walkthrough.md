# Walkthrough: spec-24-01

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 토대 단계 auto 의 행동 | 정지규칙까지 한 번에 / 모드 plumbing 만 | plumbing 만 | 정지규칙·결정로그(24-03)·논블로킹 결정(24-04)이 올라탈 *토대* 만 분리. auto 는 일단 turbo 동급 |
| auto 의 settings 패치 | turbo 와 동일(push allow) / 별도 | turbo 동일 | unattended 라 push 프롬프트 불가 — turbo 보다 *덜* 허용할 이유 없음 |
| pre-commit turbo 버그 | 24-01 에 포함 / 별도 fix | 24-01 포함 | "모드를 모든 게이트에서 일관 인식"이 본 spec 의 핵심 요구(#3). auto 인식 추가하려다 turbo 도 안 보던 걸 발견 |

## 💬 사용자 협의

- **주제**: "재시도" 후 자율 모드 진행 — phase-24 착수
  - **합의**: ADR-009 accepted 후 24-01(모드 토대)부터 turbo 로 구현

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-mode-auto.sh` + 전체 스위트
- **결과**: ✅ Passed (test-mode-auto 6/6, 전체 67/67)
```text
test-mode-auto: PASS=6 FAIL=0   (전환/상태/status/훅 비차단/control/잘못된 모드 거부)
전체: PASS=67 FAIL=0
```

### 수동 검증
1. **Action**: `sdd mode auto` → `sdd status`
   - **Result**: `Active Mode: auto` (cyan 강조) 출력

## 🔍 발견 사항

- **pre-commit.sh 가 turbo 를 전혀 안 봄 (버그).** Edit/Write 매처 훅(`check-plan-accept.sh`)은 turbo bypass 하는데, git `pre-commit.sh` 는 `planAccepted`+active spec 만 보고 mode 를 무시 → **turbo 에서 production 코드 편집은 되는데 커밋만 막히는** 불일치. 본 spec 의 실패 테스트(.sh)를 커밋하려다 적발됨. circular bootstrap(turbo 가 커밋을 막아 turbo 수정도 못 커밋) — `sdd plan accept` 로 1회 부트스트랩 후 수정. 이제 turbo/auto 가 lint/secret 은 유지하되 plan-accept 게이트만 면제.
- **ADR-009 frontmatter 의 템플릿 주석 잔재.** `type: decision  # decision | invariant | ...` 인라인 주석을 실제 ADR 에 그대로 둬서 phase16 integration 의 type-closure 검사가 주석째 읽어 'out-of-closure' 적발 (#200 머지 후 main 에 들어간 결함). 주석 제거로 수정.

## 🚧 이월 항목

- **ADR 템플릿 footgun**: `adr.md` 템플릿이 `type:`/`status:` 줄에 인라인 주석으로 허용값을 안내 → 저자가 안 지우면 본 결함 재발. 허용값 힌트를 frontmatter 줄 밖으로 옮기는 개선 → `backlog/queue.md` Icebox 권장.
