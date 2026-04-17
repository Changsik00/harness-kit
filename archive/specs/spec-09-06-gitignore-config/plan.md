# Implementation Plan: spec-09-06

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-06-gitignore-config`
- 시작 지점: `phase-09-install-conflict-defense`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 기존 `!.harness-kit/` un-ignore 무조건 추가 로직을 제거하고 조건부 로직으로 대체
> - [ ] `update.sh`가 `harness.config.json`의 `gitignore` 필드를 읽어 install에 전달

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **install.sh Section 16** | 기존 un-ignore 제거 → 조건부 Y/N 질문 | 사용자 선택권 보장 |
| **install.sh 인자** | `--gitignore` / `--no-gitignore` 플래그 추가 | update.sh에서 설정 전달 필요 |
| **harness.config.json** | `"gitignore": true|false` 필드 추가 | update.sh가 설정을 보존하기 위해 필요 |
| **update.sh** | 언인스톨 전 `gitignore` 값 읽기 → install에 `--gitignore`/`--no-gitignore` 전달 | prefix와 동일한 패턴 |

### 설치 흐름

```
install.sh 실행
  ↓
Section 5 (prefix UX) 이후
  ↓
Section 5b: gitignore 질문
  "`.harness-kit/`를 .gitignore에 추가할까요? [Y/n]"
  Y (기본) → HK_GITIGNORE=1
  N         → HK_GITIGNORE=0
  ↓
Section 16: 조건부 .gitignore 처리
  HK_GITIGNORE=1 → ".harness-kit/" 추가
  HK_GITIGNORE=0 → "!.harness-kit/" 추가
  ↓
Section 17 (harness.config.json): "gitignore": true|false 포함하여 저장
```

## 📂 Proposed Changes

### [install.sh]

#### [MODIFY] `install.sh` — 인자 파싱 Section 1
`--gitignore` / `--no-gitignore` 플래그 추가, `HK_GITIGNORE=-1` (미결정) 초기값

#### [MODIFY] `install.sh` — gitignore UX Section (Section 5 이후)
`ASSUME_YES` 또는 `--gitignore`/`--no-gitignore` 미지정 시 질문 출력:
```
`.harness-kit/`를 .gitignore에 추가할까요? (권장: 하네스 설정을 git에서 숨깁니다) [Y/n]
```
기본값 Y (Enter = Y).

#### [MODIFY] `install.sh` — Section 16 (.gitignore 업데이트)
- 기존: 항상 `!.harness-kit/` 추가
- 변경: `HK_GITIGNORE=1`이면 `.harness-kit/` 추가, `0`이면 `!.harness-kit/` 추가

#### [MODIFY] `install.sh` — Section 17 (harness.config.json)
`"gitignore": true|false` 필드를 config에 포함하여 저장

#### [MODIFY] `install.sh` — Usage 주석
`--gitignore` / `--no-gitignore` 옵션 설명 추가

### [update.sh]

#### [MODIFY] `update.sh` — prefix 읽기 블록 확장
uninstall 전 `harness.config.json`에서 `gitignore` 필드도 읽음:
```bash
_gi=$(jq -r '.gitignore // empty' "$_CONFIG" 2>/dev/null || true)
```
install 호출 시 `--gitignore` 또는 `--no-gitignore` 플래그 전달.

### [tests/test-gitignore-config.sh]

#### [NEW] `tests/test-gitignore-config.sh`
TDD 테스트 (7 checks):
- A: 기본(Y) 설치 → `.harness-kit/` in .gitignore, config `"gitignore":true`
- B: `--no-gitignore` 설치 → `!.harness-kit/` in .gitignore, config `"gitignore":false`
- C: `--gitignore` 설치 → `.harness-kit/` in .gitignore
- D: 재설치 멱등성 — 중복 항목 없음
- E: update.sh 후 gitignore=true 보존
- F: update.sh 후 gitignore=false 보존
- G: --yes 플래그 → 기본(Y) 적용

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-gitignore-config.sh
bash tests/run-all.sh
```

### 수동 검증 시나리오
1. 빈 프로젝트에 `install.sh ./` 실행 → gitignore 질문 출력 확인 (Y 입력) → `.gitignore`에 `.harness-kit/` 확인
2. `install.sh ./ --no-gitignore` → 질문 없이 `!.harness-kit/` 추가 확인
3. `update.sh` 재실행 → gitignore 설정 유지 확인

## 🔁 Rollback Plan

- `install.sh`의 Section 16만 변경이므로 git revert 1 commit으로 복원 가능.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [x] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
