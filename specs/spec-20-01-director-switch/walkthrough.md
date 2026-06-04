# Walkthrough: spec-20-01

> 본 spec 은 **디렉터 모드 도그푸딩의 첫 실전 케이스**다 — 디렉터 모드를 *디렉터 모드로* 구현했다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| `sdd status` off 표시 | 행 생략 / "off" 표시 | **행 생략** (on 일 때만) | 기본값 off 노이즈 최소화 (uxMode 도 status 무노출) |
| `doctor` off 수준 | `_doc_warn` / `_doc_pass` | **`_doc_pass` 정보성** | off 는 의도적 기본값 — WARN 카운트 오염 금지 (spec-13-02 graceful 철학). 워커 초안은 warn 이었으나 디렉터가 교정 |
| 모드 강제 강도 | 런타임 커널 / 지시 주입 | **지시 주입** | Claude Code 에 모드 커널 없음 — hk-align 과 같은 규약 강도 (D3) |

### ADR 승격 가이드

- [x] ADR 승격 대상 있음 → `docs/decisions/ADR-006-director-mode.md` (phase-20 에서 초안, "지시 주입" 불변식 포함). 본 spec 의 `director-mode-as-instruction-injection` 결정은 ADR-006 에 통합됨.
- [ ] 없음

## 💬 사용자 협의

- **주제**: 디렉터 모드 도그푸딩
  - **사용자 의견**: "지금부터 개밥먹기로 디렉터 모드로 이번 phase 를 진행해봐."
  - **합의**: 디렉터 모드가 *명령으로 존재하기 전에* 프로토콜을 손으로 enact — 디렉터(Opus)가 의도·게이트 보유, ceremony 작성·구현은 Sonnet 워커에 위임, 증류 보고만 수신. base 모드(D1) 채택.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-director-mode.sh`
- **결과**: ✅ Passed (10/10)
- **로그 요약**:
```text
결과: PASS=10  FAIL=0
```

### 2. 수동 검증

1. **Action**: `sdd config director-mode on` → `sdd status --no-drift`
   - **Result**: `Director Mode: on` 행 출력됨 (live 동작 확인)
2. **Action**: `sdd config director-mode off` → `sdd status`
   - **Result**: Director Mode 행 미출력 (조건부 노출 정상)
3. **Action**: `sdd doctor`
   - **Result**: "설정" 섹션에 directorMode 항목 추가, WARN 증가 없음

## 🔍 발견 사항

- **[개밥먹기 핵심] context 보존이 실측으로 작동**: authoring 워커가 **55k 토큰**, impl 워커가 **100k 토큰**을 *각자 isolated context* 에서 소모하고 증류 보고만 반납 — 디렉터 메인 윈도우엔 미유입. 성공기준 ①(워커 토큰의 ≥70% 미유입)의 1차 증거.
- **단, 절감은 단계별로 다르다**: *authoring* 위임은 디렉터가 게이트 검토 위해 산출물을 다시 읽어야 해 절감이 제한적. **진짜 절감은 *implementation* 위임** — 디렉터가 diff 를 안 읽고 테스트 PASS·커밋 SHA 증류만 받고, 검증은 *테스트 재실행 + live 스모크*(행동 검증)로 대체. → spec-20-02 프로토콜에 "검증은 전문 재흡수가 아니라 *행동/증류 검증*으로" 불변식 추가 후보.
- **boolean 플래그 jq 패턴**: `uxMode`(문자열)는 `--arg`, `directorMode`(boolean)는 `--argjson` 필요. 워커가 자체 발견·적용. 미래 boolean config 의 레퍼런스.
- **워커 브리핑 갭**: 구현 워커가 task.md 만 커밋하고 spec.md/plan.md 는 미커밋으로 남김 → 디렉터가 사후 커밋. 워커 브리핑에 "기획 산출물도 커밋 범위"를 명시해야 함 — spec-20-03(ceremony 분업 계약)에 반영할 도그푸딩 발견.

## 🚧 이월 항목

- spec-20-02 ~ 20-06 (phase-20 잔여) — phase.md spec 표 참조. 특히 위 "행동 검증 불변식"·"워커 커밋 범위"는 20-02/20-03 입력.

## 🔗 관련 문서

- 관련 wiki: [[wiki/decisions]] (graceful degradation), [[wiki/patterns]] (dual-binary-dogfood-sync)
- 관련 ADR: [[ADR-005]] (context-orchestration), [[ADR-006]] (director-mode)
- 관련 RCA: 없음

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Director(Opus) + dennis, 구현 Sonnet 워커 |
| **작성 기간** | 2026-06-03 |
| **최종 commit** | (ship 직전) |
