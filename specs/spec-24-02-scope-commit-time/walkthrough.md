# Walkthrough: spec-24-02

> blast-radius scope 가드를 *편집 시점* 에서 *커밋 시점* 으로 정렬 — MCP/Serena 편집 우회를 도구 무관하게 포착.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 커밋시점 검사 위치 | ① git 네이티브 `pre-commit.sh` 확장 / ② Bash PreToolUse 매처 신설 | **① git 네이티브 hook** | git hook 은 편집도구·MCP·터미널 등 *모든* 커밋 경로에서 발동 → ADR-009 "도구 무관하게 유효" 에 가장 부합. Bash 매처는 Claude Code Bash 도구 경유 커밋만 잡아 우회 여지. phase 계획서의 "Bash 매처" 표현에서 의도적 정정(사용자 승인 2026-06-21). |
| scope 로직 공유 방식 | inline 중복 / 순수 함수 추출 | **`_scope.sh` 추출** | 편집시점·커밋시점이 *동일 불변식* 공유 → DRY·일관·단위 테스트 용이. |
| 검사 동작 조건 | `planAccepted` 기반 / 활성 spec+spec.md 기반 | **활성 spec + spec.md scope 패턴** | turbo/auto 는 `planAccepted=false` 여도 spec.md `Proposed Changes` 가 존재 → planAccepted 무관 조건이라야 auto 우회를 잡음. |
| 초기 강도 | 경고 / 차단 | **경고 모드(stderr+exit0)** | hook 단계론(CLAUDE.md #5). 1주 운영 후 차단 승격은 별건. |

<!-- ADR 승격: ADR-009 가 이미 거버닝하므로 신규 ADR 불필요. 위치 선택 근거는 본 표에 기록. -->

## 💬 사용자 협의

- **주제**: 커밋시점 가드 위치 (git 네이티브 hook vs Bash 매처)
  - **합의**: 설계 1번(git 네이티브 `pre-commit.sh` 확장) 채택. phase 계획서의 "Bash 매처" 표현보다 도구 무관성이 강함.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-scope-commit-time.sh` + 전체 스위트
- **결과**: ✅ Passed (신규 7/7, 전체 68/68)
```text
test-scope-commit-time: PASS=7 FAIL=0
  (_scope 함수 in/out/safe-path · pre-commit out-of-scope 경고 · in-scope 무경고 · 경고모드 exit0 · spec.md 부재 no-op)
test-git-precommit-hook: PASS=13 FAIL=0  (회귀 없음)
전체: PASS=68 FAIL=0
```

### 수동 검증
1. **Action**: scope 밖 파일(`b.sh`) staged 후 `pre-commit.sh` 실행
   - **Result**: stderr `⚠ [scope:warn] spec 범위 밖 파일 커밋: b.sh`, **exit 0**(커밋 통과)
2. **Action**: 본 spec 의 in-scope 파일들 실제 커밋 (Task 2·3)
   - **Result**: scope 경고 없음 — 라이브 도그푸딩 hook 정상 동작 확인

## 🔍 발견 사항

- **도그푸딩 즉시 반영 확인.** `.git/hooks/pre-commit` 은 `.harness-kit/hooks/pre-commit.sh` 를 호출하는 *래퍼* 라, `.harness-kit/hooks/` 미러만 수정하면 재설치 없이 이 저장소의 실제 hook 에 즉시 반영된다. (align 단계에서 wrapper indirection 을 drift 로 오판했다가 정정 — 실제 drift 아님.)
- **check-scope.sh 리팩터는 behavior-preserving.** 안전경로 early-exit·patturn 매칭을 `_scope.sh` 로 위임했으나 모드/plan/spec early-exit 분기는 그대로 유지. 기존 동작 회귀 없음.

## 🚧 이월 항목

- **경고 → 차단(exit 2) 승격**: 1주 운영(false-positive 관찰) 후 phase-FF 또는 후속 spec 에서 승격. 본 spec 범위 밖.
