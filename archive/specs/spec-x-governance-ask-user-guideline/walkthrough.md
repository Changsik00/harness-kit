# Walkthrough: spec-x-governance-ask-user-guideline

> 본 문서는 *작업 기록* 입니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 수정 강도 | A) MUST 강제 / B) SHOULD 권장 | B | 환경(CLI/IDE/Web)마다 AskUserQuestion 렌더링이 다를 수 있어 강제 불가 |
| 기존 텍스트 포맷 처리 | A) 삭제 / B) fallback으로 유지 | B | constitution §5.2·§5.7 하위 호환성 유지, 거버넌스 breaking change 없음 |
| 수정 범위 | A) 가이드라인 섹션만 추가 / B) uxMode 설정 + sdd 커맨드까지 | B | 사용자 요청 — 설정 값으로 AskUserQuestion 사용 여부 제어 가능하게 |
| uxMode 저장 위치 | A) .claude/state (gitignored) / B) installed.json (git-tracked) | B | 프로젝트별 git 이력 관리 + 멀티 디바이스 동기화 |
| 기본값 | interactive / text | interactive | 기존 동작 유지 — 기존 설치본에서 변화 없음 |

## 💬 사용자 협의

- **주제**: AskUserQuestion UX 불일치 원인 분석
  - **사용자 관찰**: 동일한 거버넌스 흐름에서도 텍스트 목록(1/2), [Y/n], 화살표 선택 UI가 혼재
  - **원인**: 거버넌스가 `AskUserQuestion` 툴을 인지하지 않고 텍스트 포맷만 명시한 채 작성됨
- **주제**: 수정 범위 확장
  - **사용자 요청**: "커맨드로 고를 수 있게 하는 것도 의미 있지 않아?" — uxMode 설정 + sdd 커맨드 추가
  - **합의**: `install.sh` 기본값 + `sdd config ux-mode` 커맨드 + `§8.4` uxMode 참조 모두 포함

## 🧪 검증 결과

### 1. 자동화 테스트

#### sdd config ux-mode 동작 검사 (신규)
- **명령**: `bash tests/test-sdd-config.sh`
- **결과**: ✅ PASS=4, FAIL=0

```text
T1: sdd config ux-mode text → installed.json uxMode=text     ✅
T2: sdd config ux-mode interactive → uxMode=interactive      ✅
T3: sdd config ux-mode (인자 없음) → 현재값 출력             ✅
T4: 잘못된 값 → 오류 메시지                                  ✅
```

#### 거버넌스 중복/동기화 검사
- **명령**: `bash tests/test-governance-dedup.sh`
- **결과**: ✅ ALL 8 CHECKS PASSED

```text
▶ Check 1: 중복 문장 검출 — ✅ 0건
▶ Check 2: sources ↔ .harness-kit 동기화 — ✅ agent.md OK
▶ Check 3: 토큰 카운트 — ✅ (상한 6000w 이하)
▶ Check 4: Dead letter 제거 — ✅
▶ Check 5: 섹션 번호 중복 — ✅
▶ Check 6: sdd 경로 — ✅
```

### 2. 수동 검증

1. **Action**: `sdd config ux-mode text` 실행 후 `installed.json` 확인
   - **Result**: `"uxMode": "text"` 정상 기록됨

2. **Action**: `sdd config ux-mode` (인자 없음) 실행
   - **Result**: `uxMode: text` 현재값 출력됨

3. **Action**: `sources/governance/agent.md §8.4` uxMode 참조 확인
   - **Result**: `uxMode` 필드 동작 설명 + `sdd config ux-mode` 변경 명령 포함됨

## 🔍 발견 사항

- `uxMode` 필드가 없는 기존 설치본은 `"interactive"` fallback으로 처리 — 기존 사용자 동작 변화 없음.
- `sdd config` 서브커맨드 패턴이 향후 다른 설정 항목(예: `sdd config language`) 확장의 기반이 됨.
- 이 가이드라인이 정착되면 주요 결정 포인트에서 `AskUserQuestion` 툴 사용 빈도가 높아질 것.

## 🚧 이월 항목

- §5.2 Plan Accept/Critique, §5.7 PR 확인 포맷을 `AskUserQuestion` 기반으로 교체 → 향후 필요시 spec-x

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + changsik |
| **작성 기간** | 2026-05-12 ~ 2026-05-12 |
| **최종 commit** | `15129df` |
