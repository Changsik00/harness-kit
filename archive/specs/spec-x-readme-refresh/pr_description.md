# docs(spec-x-readme-refresh): README 최신화 및 키트 의도/철학 보강

## 📋 Summary

### 배경 및 목적

키트가 0.9.1 까지 진화하는 동안 `README.md` 의 일부 정보가 outdated 되었고, 외부 진단(아젠틱 코딩의 8문제: 가정 전파 / 추상화 비대화 / 죽은 코드 / 아부성 동의 / 이해 부채 …) 에 본 키트가 *우연이 아니라 구조적으로* 대응한다는 점이 README 의 기능 나열 톤에 묻혀 있었다. 본 PR 은 추가 구현 없이 사실 정정 + 의도 보강만으로 그 갭을 메운다.

### 주요 변경 사항

- [x] **의존성 명세 정정**: `bash 4.0+` 표기를 `bash 3.2+` 로 통일하고 `brew install bash jq git` → `brew install jq git` 으로 정리. macOS 기본 bash 3.2 호환 작업과 README 동기화.
- [x] **"🎯 왜 이 구조인가" mini sub-section 추가**: "💡 이 키트는 무엇인가" 끝에 *이해 부채 방지 / 선언형 명세 / Plan Accept = 가정 검증 게이트 / walkthrough.md 의 역할* 을 엮은 1 문단 + 3 bullet 추가.
- [x] **Step 4 (Plan Accept) 의미 보강**: "단순 승인이 아니라 가정·범위·접근법 검증 게이트" 한 줄 삽입.

### Phase 컨텍스트

- **Phase**: 없음 (Solo Spec — `spec-x-readme-refresh`)
- **본 SPEC 의 역할**: 외부 진단에서 얻은 인사이트를 *추가 구현 없이* README 의도 문단에 반영. 키트의 "왜" 가시성을 높여 첫 인상에서 동기를 잡을 수 있게 함.

## 🎯 Key Review Points

1. **"🎯 왜 이 구조인가" 문단 톤**: 기존 README 톤·이모지 컨벤션과 일관하는지, 표 5번 행(모델 분배) 과 자연스럽게 이어지는지.
2. **"이해 부채" 라는 단어 도입**: 한국어 독자에게 부담스럽지 않은지 — 영문 병기(`understanding debt`) 를 한 번 둠.
3. **Step 4 한 줄 추가의 위치**: "단순 승인이 아니라" 표현이 기존 헤더(`### Step 4: Plan Accept (승인)`) 와 자연스러운지.
4. **`bash 3.2` 표기 일관성**: 의존성 표 3행 + 코드블록 주석에서 동일 표현이 사용되는지.

## 🧪 Verification

### 자동 테스트
- 본 spec 은 docs only — 자동 테스트 없음.

### 수동 검증 시나리오

1. **시나리오 1**: `grep -n "bash 4" README.md` → 비어 있음 (`✓ no 'bash 4' references remain`).
2. **시나리오 2**: `git diff main -- README.md` 검토 → 변경 범위가 (a) 의존성 표 / 코드블록, (b) `### 🎯 왜 이 구조인가` 신규, (c) Step 4 한 줄 보강 으로 plan 범위와 정확히 일치.
3. **시나리오 3**: 마크다운 시각 점검 → 표·코드블록·`###` 헤더 렌더링 정상, 기존 톤 보존.

## 📦 Files Changed

### 🛠 Modified Files

- `README.md` (+13, -3): 의존성 명세 정정 + "🎯 왜 이 구조인가" sub-section 추가 + Step 4 한 줄 보강.

### 🆕 New Files

- `specs/spec-x-readme-refresh/spec.md`, `plan.md`, `task.md`, `walkthrough.md`, `pr_description.md`

**Total**: 1 코드 파일 변경 + spec-x 산출물 5개

## ✅ Definition of Done

- [x] README.md 의 의존성 명세·"왜" 문단·Plan Accept 설명 3가지 변경 반영
- [x] 마크다운 렌더링 시각 점검 통과
- [x] `walkthrough.md` / `pr_description.md` 작성 및 ship commit
- [x] `spec-x-readme-refresh` 브랜치 push 완료, PR 생성
- [ ] merge 후 `sdd specx done readme-refresh` 로 queue.md 갱신

## 🔗 관련 자료

- Spec: `specs/spec-x-readme-refresh/spec.md`
- Plan: `specs/spec-x-readme-refresh/plan.md`
- Walkthrough: `specs/spec-x-readme-refresh/walkthrough.md`
- 외부 진단 원문: https://velog.io/@typo/80-problem-in-agentic-coding
