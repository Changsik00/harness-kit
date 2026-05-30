# Implementation Plan: spec-x-doctor-hookspath-lefthook

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-doctor-hookspath-lefthook` (브랜치 = spec 디렉토리 이름)
- 시작 지점: `main` (spec-x 는 항상 main 에서 브랜치)
- 첫 task 가 브랜치 생성

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **감지 범위**: "lefthook 사용 + core.hooksPath 로컬 설정" 일 때만 warn. lefthook 미사용 시 무출력(소음 방지). hooksPath 가 비-기본 경로인 별개 footgun 은 범위 외.

> [!WARNING]
> - [ ] harness 가 사용자 git 설정(core.hooksPath)을 **변경하지 않음** — 진단·안내만. 자동 unset 은 의도적으로 배제.

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| 감지 위치 | `sdd cmd_doctor` + 루트 `doctor.sh` 양쪽 | target 일상 진단은 `sdd doctor`, update 시엔 루트 `doctor.sh` 실행 — 둘 다 target repo 대상 |
| 대응 | 비차단 warn + unset 가이드 | issue 실패는 사용자 hooksPath 가 원인 → harness 는 진단·안내가 최대 레버리지 |
| lefthook 감지 | 설정 파일 존재 OR package.json lefthook 참조 | prepare 스크립트/yml 어느 쪽이든 포착 |
| #2 네이티브 통합 | Icebox 보류 | over-engineering 회피 (NestJS 1차 타깃, YAML 편집 비용) |

### 📑 ADR 후보
- [x] 없음

## 📂 Proposed Changes

### [MODIFY] `sources/bin/sdd` — `cmd_doctor()`
- `_check_lefthook_hookspath()` 헬퍼 추가, "훅 파일" 섹션(`_check_hooks` 직후)에서 호출.
- 로직: `$SDD_ROOT` 가 git repo → lefthook 사용 감지(`lefthook.yml`/`.lefthook.yml`/`*.yaml` 또는 `package.json` 내 `lefthook`) → 사용 시 `git config --local --get core.hooksPath` 확인 → 비어있지 않으면 `_doc_warn`(원인+unset 명령+#161), 비어있으면 `_doc_pass`.
- `.harness-kit/bin/sdd` 동기화.

### [MODIFY] `doctor.sh` — §6 Hook 권한
- pre-commit 체크(`:184-193`) 직후 동일 감지 추가. `$TARGET` 기준, `check_warn`/`check_pass` 헬퍼 사용.

### [NEW] `tests/test-doctor-hookspath-lefthook.sh`
- fixture: temp git repo + `lefthook.yml` + `git config --local core.hooksPath <repo>/.git/hooks`.
- 케이스:
  1. lefthook + hooksPath 설정 → `sdd doctor` warn 출력(원인/unset 문자열 포함)
  2. 동일 fixture → 루트 `doctor.sh <fixture>` warn 출력
  3. lefthook + hooksPath 미설정 → warn 없음(pass)
  4. lefthook 미사용 + hooksPath 설정 → 충돌 warn 없음(범위 외)

### [MODIFY] `backlog/queue.md`
- Icebox 에 "lefthook 네이티브 hook 통합(#2)" 한 줄 캡처.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-doctor-hookspath-lefthook.sh   # 신규 4 케이스
bash tests/test-hk-doctor.sh                   # sdd doctor 회귀
bash tests/test-doctor-wiki.sh                 # doctor 회귀
```

### 수동 검증 시나리오
1. lefthook.yml 있는 temp repo 에서 `core.hooksPath` 설정 후 `sdd doctor` → 충돌 warn + unset 가이드 출력
2. unset 후 재실행 → pass

## 🔁 Rollback Plan
- 진단 추가뿐, 가역적. 문제 시 해당 커밋 revert.
- 오탐(소음)이 보고되면 감지 조건(lefthook AND hooksPath)을 좁히는 후속 패치.

## 📦 Deliverables 체크
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
