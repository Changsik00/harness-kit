# Implementation Plan: spec-19-03

## 📋 Branch Strategy

- 신규 브랜치: `spec-19-03-doctor-wiki-slim`
- 시작 지점: `phase-19-doc-knowledge-graph` (phase base branch)
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] `CLAUDE.md` 에서 `## 대상 환경` + `## 디렉토리 의미` 섹션 제거 → `docs/project-guide.md` 로 이동. CLAUDE.md 행 수가 71 → 약 45줄로 줄어듦.
> - [ ] `sources/governance/constitution.md` 에 rule prune 기준 섹션 추가 (실제 규칙 변경은 없음, 가이드라인 문서화).

## 🎯 핵심 전략

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **doctor W-2 (고아 wikilink)** | grep `\[\[...\]\]` → 파일명 매핑 후 존재 확인 | bash 3.2+, 외부 도구 불필요 |
| **doctor W-3 (stale docs)** | `git log --format="%ct"` 로 unix timestamp 추출, `$(date +%s)` 와 차분 비교 | bash 3.2+ 호환 날짜 연산 |
| **doctor W-4 (word count)** | `wc -w` 결과 합산, 7,000w 초과 시 ⚠ | 간단한 proxy metric |
| **CLAUDE.md 슬림화** | 저빈도 2개 섹션 → `docs/project-guide.md` 이동 + CLAUDE.md 포인터 | root 파일 핵심 집중 |
| **constitution prune 기준** | "6개월+ AND 모델 2세대 경과" 기준을 Section "Rule Prune Guidance" 로 추가 | 강제 아닌 권고 — 비차단 |

### ADR 후보

- [x] 없음

## 📂 Proposed Changes

### sdd doctor — wiki 섹션 추가

#### [MODIFY] `sources/bin/sdd` + `.harness-kit/bin/sdd`

`cmd_doctor()` 의 `printf "훅 파일\n"` 섹션 뒤에 `printf "\nwiki layer\n"` 섹션 추가:

```bash
printf "\nwiki layer\n"
_check_wiki_layer   # W-1: docs/wiki/ 존재
_check_wiki_orphans # W-2: [[wikilinks]] 고아 링크
_check_stale_docs   # W-3: 90일+ 미참조 decisions/rca
_check_gov_size     # W-4: governance 단어 수 7,000w 상한
```

각 헬퍼 함수는 `cmd_doctor()` 내부 local function 패턴으로 추가.

**W-2 구현 접근**:
```bash
# docs/wiki/*.md 에서 [[link]] 패턴 추출
# link → docs/wiki/<link>.md 또는 docs/decisions/<link>.md 등 경로 매핑
# 파일 없으면 고아 링크
```

**W-3 구현 접근**:
```bash
# git log -1 --format="%ct" -- <file> → last touch timestamp
# now=$(date +%s); diff=$((now - last_touch)); 90일 = 7776000초
```

### CLAUDE.md 슬림화

#### [NEW] `docs/project-guide.md`

이동 내용:
- `## 대상 환경 (고정)` 섹션 전체
- `## 디렉토리 의미` 섹션 전체

#### [MODIFY] `CLAUDE.md`

두 섹션 제거 + 포인터로 교체:
```markdown
> 대상 환경, 디렉토리 구조 → [`docs/project-guide.md`](docs/project-guide.md)
```

### governance prune 기준

#### [MODIFY] `sources/governance/constitution.md`

파일 끝에 "## Rule Prune Guidance" 섹션 추가 (영어, governance는 영어 원칙):

```markdown
## Rule Prune Guidance

A rule is a candidate for review (not mandatory deletion) when:
1. It was written **6+ months ago**, AND
2. The model has advanced **2+ generations** since it was written.

Review means: "Is this rule still load-bearing or has the model's default behavior made it redundant?"
Prune only after validating the rule is no longer enforced or needed.
```

### 테스트

#### [NEW] `tests/test-doctor-wiki.sh`

- Check 1: `sdd doctor` 출력에 "wiki layer" 섹션 존재
- Check 2: W-1 경고 — `docs/wiki/` 없는 fixture에서 `⚠` 포함 출력
- Check 3: docs/project-guide.md 존재
- Check 4: CLAUDE.md 에 `docs/project-guide.md` 포인터 포함
- Check 5: constitution.md 에 `Rule Prune Guidance` 섹션 존재

## 🧪 검증 계획

### 단위 테스트
```bash
bash tests/test-doctor-wiki.sh
bash tests/test-wiki-structure.sh  # 기존 45/45 유지 확인
```

### 수동 검증
1. `sdd doctor` 실행 → "wiki layer" 섹션 출력 확인
2. `docs/wiki/` 디렉토리 없는 빈 디렉토리에서 W-1 경고 확인

## 🔁 Rollback Plan

- git revert (단일 commit per task — 선택적 revert 가능)
- `docs/project-guide.md` 삭제 + CLAUDE.md 복원

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
