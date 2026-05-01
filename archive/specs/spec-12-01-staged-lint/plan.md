# Implementation Plan: spec-12-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-12-01-staged-lint`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 훅 경고 모드(exit 0)로 시작 — 차단 모드(exit 2)는 이번 spec 범위 아님

## 🎯 핵심 전략

### 아키텍처 컨텍스트

```
pre-commit
  └── check-staged-lint.sh
        ├── git diff --cached --name-only  → staged 파일 목록
        ├── 프로젝트 타입 감지 (package.json / go.mod / pyproject.toml / *.sh)
        ├── 해당 타입 파일만 필터
        └── linter 실행 (경고 모드 — exit 0)
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **모드** | 경고 모드(exit 0) | 훅 단계론 — 신규 훅은 경고로 시작 |
| **타입 감지** | 마커 파일 기반 | bash 3.2 호환, 단순 |
| **linter 미설치** | 경고 후 skip | 강제 설치 마찰 방지 |
| **staged 파일 없으면** | silent skip | 불필요한 노이즈 제거 |

## 📂 Proposed Changes

### [NEW] `sources/hooks/check-staged-lint.sh`
staged 파일 추출 → 타입 감지 → linter 실행 (경고 모드)

### [MODIFY] `install.sh`
`check-staged-lint.sh`를 hooks 배포 목록에 추가

### [NEW] `tests/test-staged-lint.sh`
훅 동작 검증: staged 없음/타입 미감지/linter 없음/shellcheck 실행

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-staged-lint.sh
```

### 통합 테스트
```bash
bash tests/test-staged-lint.sh
```

### 수동 검증 시나리오
1. `package.json` 없는 프로젝트, JS 파일 staged → skip
2. `package.json` 있고 eslint 없음 → 경고 후 commit 통과
3. `.sh` 파일 staged + shellcheck 있음 → shellcheck 실행

## 🔁 Rollback Plan

- `sources/hooks/check-staged-lint.sh` 삭제 후 update.sh 재실행

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
