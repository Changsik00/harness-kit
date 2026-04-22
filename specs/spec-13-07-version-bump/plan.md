# Implementation Plan: spec-13-07

## 📋 Branch Strategy

- 신규 브랜치: `spec-13-07-version-bump`
- 시작 지점: `phase-13-dx-enhancements` (phase base branch)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] `0.6.0` 버전 번호 동의 여부

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **버전 관리** | `VERSION` 파일 단일 소스 | install.sh가 이미 `cat VERSION`으로 읽음 |
| **CHANGELOG** | 신규 작성 | phase-13 DX 개선사항 기록 |

## 📂 Proposed Changes

#### [MODIFY] `VERSION`
`0.5.0` → `0.6.0`

#### [MODIFY] `.harness-kit/installed.json`
`kitVersion: "0.5.0"` → `"0.6.0"`

#### [NEW/MODIFY] `CHANGELOG.md`
```text
## [0.6.0] - 2026-04-23
### Added
- sdd doctor: 환경 진단 체크리스트
- sdd pr-watch: PR merge 자동 감지 (30초 폴링)
- sdd run-test: 테스트 결과 자동 기록 wrapper
```

### [테스트]

#### [NEW] `tests/test-version-bump.sh`
1. `VERSION` 파일에 `0.6.0` 포함 확인
2. `sdd version` → `0.6.0` 출력 확인
3. `CHANGELOG.md` 존재 + `0.6.0` 포함 확인
4. 전체 테스트 스위트 FAIL=0 확인

## 🧪 검증 계획

```bash
bash tests/test-version-bump.sh
```

## 🔁 Rollback Plan

- `VERSION` → `0.5.0` 복원
- `.harness-kit/installed.json` 복원

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
